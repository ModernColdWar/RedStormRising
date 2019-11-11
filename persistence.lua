--- Saving/loading/updating code for managing "live" units and persisting them across server restarts
local utils = require("utils")

-- recently spawned units (from player unpacking via CTLD or via code)
local spawnQueue = {}

-- The initial configuration of the persistent data we save to disk
local state = {
    ctld = {
        nextGroupId = 1,
        nextUnitId = 1,
    },
    persistentGroupData = {},
}

local function readStateFromDisk(filename)
    log:info("Reading state from disk at $1", filename)
    local f = io.open(filename, "r")
    local stateJson = f:read("*all")
    f:close()
    local _state = JSON:decode(stateJson)
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
    local copiedState = mist.utils.deepCopy(_state)
    removeGroupAndUnitIds(copiedState.persistentGroupData)
    log:info("Writing state to disk at $1", filename)
    local f = io.open(filename, "w")
    f:write(JSON:encode(stateToWrite))
    f:close()
    log:info("Finished writing state to $1", filename)
end

local function handleSpawnQueue()
    -- get MIST group data for newly unpacked units (if it's available)
    for i = #spawnQueue, 1, -1 do
        local groupName = spawnQueue[i]
        log:info("Getting data for spawned group $1", groupName)
        local groupData = mist.getCurrentGroupData(groupName)
        if groupData ~= nil then
            log:info("Successfully got group data for $1", groupName)
            table.insert(state.persistentGroupData, groupData)
            table.remove(spawnQueue, i)
        else
            log:warn("Unable to get group data for $1", groupName)
        end
    end
end

local function updateGroupData(persistentGroupData)
    for i = #persistentGroupData, 1, -1 do
        local groupName = persistentGroupData["name"]
        log:info("Getting data for group $1", groupName)
        local groupData = mist.getCurrentGroupData(groupName)
        if groupData == nil then
            log:info("No group data found for $1", groupName)
            table.remove(persistentGroupData, i)
        else
            log:info("Updating group data for $1 to $2", groupName, groupData)
            table[i] = groupData
        end
    end
end

local function updateState()
    updateGroupData(state.persistentGroupData)
    handleSpawnQueue()
    state.ctld.nextGroupId = ctld.nextGroupId
    state.ctld.nextUnitId = ctld.nextUnitId
end

local function persistState()
    updateState()
    writeStateToDisk(_state, rsr.stateFileName)
end

local function restoreFromState(_state)
    --- Note that we don't directly update the state variable from here, this is done in handleSpawnQueue later
    log:info("Restoring from state")
    ctld.nextGroupId = _state.ctld.nextGroupId
    ctld.nextUnitId = _state.ctld.nextUnitId

    for _, groupData in ipairs(_state.persistentGroupData) do
        local groupName = groupData.groupName
        log:info("Spawning $1 from saved state $2", groupName, groupData)
        mist.dynAdd(groupData)
        table.insert(spawnQueue, groupData.groupName)
    end
    log:info("Restored from state")
end

if utils.runningInDcs() then
    if utils.fileExists(rsr.stateFileName) then
        local _state = readStateFromDisk(rsr.stateFileName)
        restoreFromState(_state)
    else
        log:info("No state file exists - setting up from scratch")
    end

    -- register unpack callback so we can update our state
    ctld.addCallback(function(_args)
        if _args.action and _args.action == "unpack" then
            log:info('Unpacked: $1', _args)
            local groupName = _args.spawnedGroup:getName()
            table.insert(spawnQueue, groupName)
        end
    end)

    mist.scheduleFunction(persistState, {}, timer.getTime() + rsr.writeInterval, rsr.writeInterval)
end