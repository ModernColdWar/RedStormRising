--- Saving/loading/updating code for managing "live" units and persisting them across server restarts
require("mist_4_3_74")
require("CTLD")
require("MOOSE")
local JSON = require("JSON")
local utils = require("utils")
local slotBlocker = require("slotBlocker")
local pickupZoneManager = require("pickupZoneManager")
local logisticsManager = require("logisticsManager")

local log = mist.Logger:new("Persistence", "info")

local M = {}

-- recently spawned units (from player unpacking via CTLD or via code)
M.spawnQueue = {}

-- group ownerships by side and user - kept in memory only and updated in handleSpawnQueue
M.groupOwnership = {
    red = {},
    blue = {}
}

-- The initial configuration of the persistent data we save to disk
M.defaultState = {
    ctld = {
        nextGroupId = 1,
        nextUnitId = 1,
    },
    persistentGroupData = {},
    baseOwnership = {} -- populated at startup if not from state file
}

-- The actual state we save to disk and hold at runtime
local state = mist.utils.deepCopy(M.defaultState)

function M.resetState()
    state = mist.utils.deepCopy(M.defaultState)
end

function M.getState()
    return mist.utils.deepCopy(state)
end

function M.pushSpawnQueue(groupName)
    log:info("Adding $1 to spawn queue", groupName)
    table.insert(M.spawnQueue, groupName)
end

-- wrapped so we can stub this out in the tests
function M.getMistGroupData(groupName)
    return mist.getGroupData(groupName)
end

function M.handleSpawnQueue()
    -- get MIST group data for newly unpacked units (if it's available)
    log:info("Handling spawn queue (length $1)", #M.spawnQueue)
    for i = #M.spawnQueue, 1, -1 do
        local groupName = M.spawnQueue[i]
        log:info("Getting group data for spawned group $1", groupName)
        local groupData = M.getMistGroupData(groupName)
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

function M.getPersistentGroupData()
    return mist.utils.deepCopy(state.persistentGroupData)
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
    M.removeGroupAndUnitIds(stateToWrite.persistentGroupData)
    log:info("Writing state to disk at $1", filename)
    local json = JSON:encode_pretty(stateToWrite)
    local f = io.open(filename, "w")
    f:write(json)
    f:close()
    log:info("Finished writing state to $1", filename)
end

local function getSideNameFromGroupData(groupData)
    return utils.getSideName(tonumber(groupData.coalitionId))
end

function M.updateGroupData(persistentGroupData)
    log:info("Updating persistent group data")
    for i = #persistentGroupData, 1, -1 do
        local groupData = persistentGroupData[i]
        local groupName = groupData.name
        log:info("Processing units in group $1", groupName)
        for j = #groupData.units, 1, -1 do
            local unitData = groupData.units[j]
            local unitName = unitData.unitName
            local unit = Unit.getByName(unitName)
            if unit == nil then
                log:info("Removing persistent data for dead unit $1", unitName)
                table.remove(groupData.units, j)
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
            local sideName = getSideNameFromGroupData(groupData)
            local playerName = M.getPlayerNameFromGroupName(groupName)
            if playerName ~= nil then
                M.removeGroupOwnership(M.groupOwnership, sideName, playerName, groupName)
            end
        end
    end
    log:info("Persistent group data update complete")
end

function M.getBaseOwnership(category)
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

function M.getAllBaseOwnership()
    return {
        airbases = M.getBaseOwnership(Airbase.Category.AIRDROME),
        farps = M.getBaseOwnership(Airbase.Category.HELIPAD)
    }
end

function M.updateState()
    M.updateGroupData(state.persistentGroupData)
    M.handleSpawnQueue()
    state.ctld.nextGroupId = ctld.nextGroupId
    state.ctld.nextUnitId = ctld.nextUnitId
    state.baseOwnership = M.getAllBaseOwnership()
end

local function persistState(rsrConfig)
    M.updateState()
    if UTILS.FileExists(rsrConfig.stateFileName) then
        utils.createBackup(rsrConfig.stateFileName)
    end
    writeStateToDisk(state, rsrConfig.stateFileName)
end

function M.getPlayerNameFromGroupName(groupName)
    -- match the inside of the part in parentheses at the end of the group name if present
    -- this is the other half of the _groupName construction in ctld.spawnCrateGroup
    return string.match(groupName, "%((.+)%)$")
end

function M.spawnGroup(groupData)
    -- Currently this code replicates the actions from ctld.unpackCrates
    local sideName = getSideNameFromGroupData(groupData)
    local groupName = groupData.groupName
    log:info("Spawning $1 $2 from groupData", sideName, groupName)
    mist.dynAdd(groupData)
    if ctld.isJTACUnitType(groupName) then
        local _code = ctld.getLaserCode(Group.getByName(groupName):getCoalition())
        log:info("Configuring group $1 to auto-lase on $2", groupName, _code)
        ctld.JTACAutoLase(groupName, _code)
    end
    M.pushSpawnQueue(groupName)
    local playerName = M.getPlayerNameFromGroupName(groupName)
    if playerName ~= nil then
        -- we have "old" groups without player names present
        M.addGroupOwnership(M.groupOwnership, sideName, playerName, groupName)
    end
end

function M.addGroupOwnership(groupOwnership, sideName, playerName, groupName)
    if groupOwnership[sideName][playerName] == nil then
        groupOwnership[sideName][playerName] = {}
    end
    table.insert(groupOwnership[sideName][playerName], groupName)
end

function M.removeGroupOwnership(groupOwnership, sideName, playerName, groupName)
    local groupListForPlayer = groupOwnership[sideName][playerName]
    if not groupListForPlayer then
        return
    end
    for i, currentGroupName in ipairs(groupListForPlayer) do
        if currentGroupName == groupName then
            log:info("Removing ownership of $1 $2 from $3", sideName, groupName, playerName)
            table.remove(groupListForPlayer, i)
            return
        end
    end
end

function M.getOwnedGroupCount(groupOwnership, sideName, playerName)
    return groupOwnership[sideName][playerName] == nil and 0 or #groupOwnership[sideName][playerName]
end

function M.getOwnedJtacCount(groupOwnership, sideName, playerName)
    if groupOwnership[sideName][playerName] == nil then
        return 0
    end
    local count = 0
    for _, groupName in ipairs(groupOwnership[sideName][playerName]) do
        if ctld.isJTACUnitType(groupName) then
            count = count + 1
        end
    end
    return count
end

local function isReplacementGroup(group)
    return string.find(group:GetName():lower(), "replacement")
end

-- Base defences are defined as late-activated group groups in proximity to an airbase or helipad
local function activateBaseDefencesAndSlots(rsrConfig, baseOwnership)
    log:info("Activating all base defences and slots")
    local allLateActivatedGroundGroups = SET_GROUP:New()
                                                  :FilterCategories("ground")
                                                  :FilterActive(false)
                                                  :FilterOnce()

    for baseType, ownershipData in pairs(baseOwnership) do
        for sideName, baseNames in pairs(ownershipData) do
            local side = utils.getSide(sideName)
            for _, baseName in pairs(baseNames) do
                log:info("Activating base defences and slots for $1 base $2", sideName, baseName)
                local radius = baseType == "airbases" and rsrConfig.baseDefenceActivationRadiusAirbase or rsrConfig.baseDefenceActivationRadiusFarp
                local activationZone = ZONE_AIRBASE:New(baseName, radius)
                allLateActivatedGroundGroups:ForEachGroup(function(group)
                    -- we can't use any of the GROUP:InZone methods as these are late activated units
                    if group:GetCoalition() == side and activationZone:IsVec3InZone(group:GetVec3()) and not isReplacementGroup(group) then
                        log:info("Activating $1 $2 base defence group $3", baseName, sideName, group:GetName())
                        group:Activate()
                    end
                end)
                slotBlocker.configureSlotsForBase(baseName, sideName)
                pickupZoneManager.configurePickupZonesForBase(baseName, sideName)
                logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName)
            end
        end
    end
end

function M.restoreFromState(rsrConfig, _state)
    log:info("Restoring mission state")

    ctld.nextGroupId = _state.ctld ~= nil and _state.ctld.nextGroupId or 1
    ctld.nextUnitId = _state.ctld ~= nil and _state.ctld.nextUnitId or 1

    -- Note that we don't directly update persistentGroupData here, this is done in handleSpawnQueue later
    -- This ensures the data we get from MIST is always consistent between a CTLD spawn and a reload from disk
    local persistentGroupData = _state.persistentGroupData or {}
    for _, groupData in ipairs(persistentGroupData) do
        M.spawnGroup(groupData)
    end

    -- use default ownerships if ownership is not in the passed state (ie it came from a file without baseOwnership)
    local baseOwnership = _state.baseOwnership
    if baseOwnership == nil or #baseOwnership == 0 then
        baseOwnership = M.getAllBaseOwnership()
    end
    activateBaseDefencesAndSlots(rsrConfig, baseOwnership)

    log:info("Mission state restored")
end

function M.restore(rsrConfig)
    if UTILS.FileExists(rsrConfig.stateFileName) then
        local _state = readStateFromDisk(rsrConfig.stateFileName)
        M.restoreFromState(rsrConfig, _state)
    else
        log:info("No state file exists - setting up from defaults in code")
        M.restoreFromState(rsrConfig, state)
    end

    -- register unpack callback so we can update our state
    ctld.addCallback(function(_args)
        if _args.action and _args.action == "unpack" then
            local sideName = utils.getSideName(_args.unit:getCoalition())
            local playerName = ctld.getPlayerNameOrType(_args.unit)
            local groupName = _args.spawnedGroup:getName()
            log:info('Player $1 on $2 unpacked $3', playerName, sideName, groupName)
            M.pushSpawnQueue(groupName)
            M.addGroupOwnership(M.groupOwnership, sideName, playerName, groupName)
        end
    end)

    mist.scheduleFunction(persistState, { rsrConfig },
            timer.getTime() + rsrConfig.writeInterval, rsrConfig.writeInterval)
end

return M
