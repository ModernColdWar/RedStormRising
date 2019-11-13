--- Saving/loading/updating code for managing "live" units and persisting them across server restarts
local utils = require("utils")
local JSON = require("JSON")

-- recently spawned units (from player unpacking via CTLD or via code)
local spawnQueue = {}

-- The initial configuration of the persistent data we save to disk
local state = {
    ctld = {
        nextGroupId = 1,
        nextUnitId = 1,
    },
    persistentGroupData = {},
    airbaseOwnership = {
        [coalition.side.RED] = { "Kobuleti", "Kutaisi", "Senaki-Kolkhi" },
        [coalition.side.BLUE] = { "Gudauta", "Sochi-Adler", "Sukhumi-Babushara" }
    },
}

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
function removeGroupAndUnitIds(persistentGroupData)
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

local function handleSpawnQueue()
    -- get MIST group data for newly unpacked units (if it's available)
    log:info("Handling spawn queue (length $1)", #spawnQueue)
    for i = #spawnQueue, 1, -1 do
        local groupName = spawnQueue[i]
        log:info("Getting group data for spawned group $1", groupName)
        local groupData = mist.getGroupData(groupName)
        if groupData ~= nil then
            log:info("Successfully got group data for $1", groupName)
            table.insert(state.persistentGroupData, groupData)
            log:info("Removing $1 from spawn queue", groupName)
            table.remove(spawnQueue, i)
        else
            log:warn("Unable to get group data for $1; leaving in spawn queue", groupName)
        end
    end
    log:info("Spawn queue handling complete")
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

local function getAirbaseOwnership()
    local airbaseOwnership = {}
    for _, side in ipairs({ coalition.side.RED, coalition.side.BLUE }) do
        airbaseOwnership[side] = {}
        for _, airbase in ipairs(AIRBASE.GetAllAirbases(side, Airbase.Category.AIRDROME)) do
            table.insert(airbaseOwnership[side], airbase:GetName())
        end
    end
    return airbaseOwnership
end

local function updateState()
    updateGroupData(state.persistentGroupData)
    handleSpawnQueue()
    state.ctld.nextGroupId = ctld.nextGroupId
    state.ctld.nextUnitId = ctld.nextUnitId
    state.airbaseOwnership = getAirbaseOwnership()
end

local function persistState()
    updateState()
    if utils.fileExists(rsr.stateFileName) then
        utils.createBackup(rsr.stateFileName)
    end
    writeStateToDisk(state, rsr.stateFileName)
end

local function pushSpawnQueue(groupName)
    log:info("Adding $1 to spawn queue", groupName)
    table.insert(spawnQueue, groupName)
end

local function spawnGroup(groupData)
    -- Currently this code replicates the actions from ctld.unpackCrates
    local groupName = groupData.groupName
    log:info("Spawning $1 from saved state $2", groupName, groupData)
    mist.dynAdd(groupData)
    if ctld.isJTACUnitType(groupName) then
        log:info("Configuring group $1 to auto-lase", groupName)
        local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
        --put to the end
        table.insert(ctld.jtacGeneratedLaserCodes, _code)
        ctld.JTACAutoLase(groupName, _code)
    end
    pushSpawnQueue(groupName)
end

local function isReplacementGroup(group)
    return string.find(group:GetName():lower(), "replacement")
end

local function activateBaseDefences(airbaseOwnership)
    for side, airbaseNames in pairs(airbaseOwnership) do
        local sideName = side == coalition.side.RED and "red" or "blue"
        local allBaseDefencesForSide = SET_GROUP:New()
                                                :FilterCoalitions(sideName)
                                                :FilterCategories("ground")
                                                :FilterActive(false)
                                                :FilterOnce()
        for _, airbaseName in pairs(airbaseNames) do
            local airbaseZone = ZONE_AIRBASE:New(airbaseName, rsr.airbaseZoneRadius)
            allBaseDefencesForSide:ForEachGroup(function(group)
                -- we can't use any of the GROUP:InZone as they filter for the unit being alive
                -- which it isn't, as it is late-actvated
                -- also ignore replacement units
                if airbaseZone:IsVec3InZone(group:GetVec3()) and not isReplacementGroup(group) then
                    log:info("Activating $1 $2 base defence group $3", airbaseName, sideName, group:GetName())
                    group:Activate()
                end
            end)
        end
    end
end

--- Note that we don't directly update the state variable from here, this is done in handleSpawnQueue later
local function restoreFromState(_state)
    log:info("Restoring mission state")

    ctld.nextGroupId = _state.ctld.nextGroupId
    ctld.nextUnitId = _state.ctld.nextUnitId

    for _, groupData in ipairs(_state.persistentGroupData) do
        spawnGroup(groupData)
    end

    -- use default ownerships if ownership is not in the passed state (ie it came from a file without airbaseOwnership)
    local airbaseOwnership = _state.airbaseOwnership or state.airbaseOwnership
    activateBaseDefences(airbaseOwnership)

    log:info("Mission state restored")
end

if utils.runningInDcs() then
    if utils.fileExists(rsr.stateFileName) then
        local _state = readStateFromDisk(rsr.stateFileName)
        restoreFromState(_state)
    else
        log:info("No state file exists - setting up from defaults in code")
        restoreFromState(state)
    end

    -- register unpack callback so we can update our state
    ctld.addCallback(function(_args)
        if _args.action and _args.action == "unpack" then
            log:info('Unpacked: $1', _args)
            local groupName = _args.spawnedGroup:getName()
            pushSpawnQueue(groupName)
        end
    end)

    mist.scheduleFunction(persistState, {}, timer.getTime() + rsr.writeInterval, rsr.writeInterval)
end