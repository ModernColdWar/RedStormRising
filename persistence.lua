--- Saving/loading/updating code for managing "live" units and persisting them across server restarts
local utils = require("utils")
local JSON = require("JSON")
require("mist_4_3_74")

local log = mist.Logger:new("Persistence", "info")

local M = {}

-- recently spawned units (from player unpacking via CTLD or via code)
M.spawnQueue = {}

-- The initial configuration of the persistent data we save to disk
local state = {
    ctld = {
        nextGroupId = 1,
        nextUnitId = 1,
    },
    persistentGroupData = {},
    baseOwnership = {} -- populated at startup if not from state file
}

function M.pushSpawnQueue(groupName)
    log:info("Adding $1 to spawn queue", groupName)
    table.insert(M.spawnQueue, groupName)
end

local function handleSpawnQueue()
    -- get MIST group data for newly unpacked units (if it's available)
    log:info("Handling spawn queue (length $1)", #spawnQueue)
    for i = #M.spawnQueue, 1, -1 do
        local groupName = M.spawnQueue[i]
        log:info("Getting group data for spawned group $1", groupName)
        local groupData = mist.getGroupData(groupName)
        if groupData ~= nil then
            log:info("Successfully got group data for $1", groupName)
            table.insert(state.persistentGroupData, groupData)
            log:info("Removing $1 from spawn queue", groupName)
            table.remove(M.spawnQueue, i)
        else
            log:warn("Unable to get group data for $1; leaving in spawn queue", groupName)
        end
    end
    log:info("Spawn queue handling complete")
end

local function readStateFromDisk(filename)
    log:info("Reading state from disk at $1", filename)
    local f = io.open(filename, "r")
    local json = f:read("*all")
    f:close()
    local _state = JSON:decode(json)
    log:info("Finished reading state from disk at $1", filename)
    return _state
end

--- Removes groupId and unitId from data so that upon respawn, MIST assigns new IDs
--- Avoids accidental overwrite of units
--- This is called at write-to-disk time
function M.removeGroupAndUnitIds(persistentGroupData)
    for _, groupData in ipairs(persistentGroupData) do
        groupData["groupId"] = nil
        for _, unitData in ipairs(groupData.units) do
            unitData["unitId"] = nil
        end
    end
end

local function writeStateToDisk(_state, filename)
    local stateToWrite = mist.utils.deepCopy(_state)
    removeGroupAndUnitIds(stateToWrite.persistentGroupData)
    log:info("Writing state to disk at $1", filename)
    local json = JSON:encode_pretty(stateToWrite)
    local f = io.open(filename, "w")
    f:write(json)
    f:close()
    log:info("Finished writing state to $1", filename)
end

local function updateGroupData(persistentGroupData)
    log:info("Updating persistent group data")
    for i = #persistentGroupData, 1, -1 do
        local groupData = persistentGroupData[i]
        local groupName = groupData.name
        log:info("Processing units in group $1", groupName)
        for i = #groupData.units, 1, -1 do
            local unitData = groupData.units[i]
            local unitName = unitData.unitName
            local unit = Unit.getByName(unitName)
            if unit == nil then
                log:info("Removing persistent data for dead unit $1", unitName)
                table.remove(groupData.units, i)
            else
                log:info("Updating position information for unit $1", unitName)
                local position = unit:getPosition().p
                unitData.x = position.x
                unitData.y = position.z
                unitData.alt = position.y
                unitData.heading = mist.getHeading(unit, true)
                log:info("Updated position info for $1", unitName)
            end
        end
        if #groupData.units == 0 then
            log:info("Removing persistent data for dead group $1", groupName)
            table.remove(persistentGroupData, i)
        end
    end
    log:info("Persistent group data update complete")
end

local function getBaseOwnership(category)
    local baseOwnership = {}
    for _, side in ipairs({ coalition.side.RED, coalition.side.BLUE }) do
        local sideName = utils.getSideName(side)
        baseOwnership[sideName] = {}
        for _, base in ipairs(AIRBASE.GetAllAirbases(side, category)) do
            table.insert(baseOwnership[sideName], base:GetName())
        end
    end
    return baseOwnership
end

local function getAllBaseOwnership()
    return {
        airbases = getBaseOwnership(Airbase.Category.AIRDROME),
        farps = getBaseOwnership(Airbase.Category.HELIPAD)
    }
end

local function updateState()
    updateGroupData(state.persistentGroupData)
    handleSpawnQueue()
    state.ctld.nextGroupId = ctld.nextGroupId
    state.ctld.nextUnitId = ctld.nextUnitId
    state.baseOwnership = getAllBaseOwnership()
end

local function persistState(rsrConfig)
    updateState()
    if UTILS.FileExists(rsrConfig.stateFileName) then
        utils.createBackup(rsrConfig.stateFileName)
    end
    writeStateToDisk(state, rsrConfig.stateFileName)
end

local function spawnGroup(groupData)
    -- Currently this code replicates the actions from ctld.unpackCrates
    local groupName = groupData.groupName
    log:info("Spawning $1 from saved state $2", groupName, groupData)
    mist.dynAdd(groupData)
    if ctld.isJTACUnitType(groupName) then
        local _code = ctld.getLaserCode(Group.getByName(groupName):getCoalition())
        log:info("Configuring group $1 to auto-lase on $2", groupName, _code)
        ctld.JTACAutoLase(groupName, _code)
    end
    pushSpawnQueue(groupName)
end


local function isReplacementGroup(group)
    return string.find(group:GetName():lower(), "replacement")
end

-- Base defences are defined as late-activated group groups in proximity to an airbase or helipad
local function activateBaseDefences(rsrConfig, baseOwnership)
    local allLateActivatedGroundGroups = SET_GROUP:New()
                                                  :FilterCategories("ground")
                                                  :FilterActive(false)
                                                  :FilterOnce()

    for baseType, ownershipData in pairs(baseOwnership) do
        for sideName, baseNames in pairs(ownershipData) do
            local side = utils.getSide(sideName)
            for _, baseName in pairs(baseNames) do
                local radius = baseType == "airbases" and rsrConfig.baseDefenceActivationRadiusAirbase or rsrConfig.baseDefenceActivationRadiusFarp
                local activationZone = ZONE_AIRBASE:New(baseName, radius)
                allLateActivatedGroundGroups:ForEachGroup(function(group)
                    -- we can't use any of the GROUP:InZone methods as these are late activated units
                    if group:GetCoalition() == side and activationZone:IsVec3InZone(group:GetVec3()) and not isReplacementGroup(group) then
                        log:info("Activating $1 $2 base defence group $3", baseName, sideName, group:GetName())
                        group:Activate()
                    end
                end)
            end
        end
    end
end

--- Note that we don't directly update the state variable from here, this is done in handleSpawnQueue later
local function restoreFromState(rsrConfig, _state)
    log:info("Restoring mission state")

    ctld.nextGroupId = _state.ctld.nextGroupId
    ctld.nextUnitId = _state.ctld.nextUnitId

    for _, groupData in ipairs(_state.persistentGroupData) do
        spawnGroup(groupData)
    end

    -- use default ownerships if ownership is not in the passed state (ie it came from a file without baseOwnership)
    local baseOwnership = _state.baseOwnership or getAllBaseOwnership()
    activateBaseDefences(rsrConfig, baseOwnership)

    log:info("Mission state restored")
end

function M.restore(rsrConfig)
    if UTILS.FileExists(rsrConfig.stateFileName) then
        local _state = readStateFromDisk(rsrConfig.stateFileName)
        restoreFromState(rsrConfig, _state)
    else
        log:info("No state file exists - setting up from defaults in code")
        restoreFromState(rsrConfig, state)
    end

    -- register unpack callback so we can update our state
    ctld.addCallback(function(_args)
        if _args.action and _args.action == "unpack" then
            log:info('Unpacked: $1', _args)
            local groupName = _args.spawnedGroup:getName()
            M.pushSpawnQueue(groupName)
        end
    end)

    mist.scheduleFunction(persistState, { rsrConfig },
            timer.getTime() + rsrConfig.writeInterval, rsrConfig.writeInterval)
end

return M
