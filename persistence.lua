--- Saving/loading/updating code for managing "live" units and persisting them across server restarts
require("mist_4_3_74")
require("CTLD")
require("MOOSE")
local bases = require("bases")
local state = require("state")
local utils = require("utils")

local log = mist.Logger:new("Persistence", "info")

local M = {}

-- recently spawned units (from player unpacking via CTLD or via code)
M.spawnQueue = {}

-- group ownerships by side and user - kept in memory only and updated in handleSpawnQueue
M.groupOwnership = {
    red = {},
    blue = {}
}

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
            table.insert(state.currentState.persistentGroupData, groupData)
            log:info("Removing $1 from spawn queue", groupName)
            table.remove(M.spawnQueue, i)
        else
            log:warn("Unable to get group data for $1; leaving in spawn queue", groupName)
        end
    end
    log:info("Spawn queue handling complete")
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
            local playerName = utils.getPlayerNameFromGroupName(groupName)
            if playerName ~= nil then
                M.removeGroupOwnership(M.groupOwnership, sideName, playerName, groupName)
            end
        end
    end
    log:info("Persistent group data update complete")
end

local function persistState(rsrConfig)
    M.updateGroupData(state.currentState.persistentGroupData)
    M.handleSpawnQueue()
    state.copyFromCtld()
    state.updateBaseOwnership()
    log:info("Number of persistent groups at save is $1", #state.currentState.persistentGroupData)
    utils.createBackup(rsrConfig.stateFileName)
    state.writeStateToDisk(rsrConfig.stateFileName)
end

function M.spawnGroup(groupData)
    -- Currently this code replicates the actions from ctld.unpackCrates
    local sideName = getSideNameFromGroupData(groupData)
    local groupName = groupData.groupName
    log:info("Spawning $1 $2 from groupData", sideName, groupName)
    local spawnedGroup = Group.getByName(mist.dynAdd(groupData).name)
    if ctld.isJTACUnitType(groupName) then
        local _code = ctld.getLaserCode(Group.getByName(groupName):getCoalition())
        log:info("Configuring group $1 to auto-lase on $2", groupName, _code)
        ctld.JTACAutoLase(groupName, _code)
    end
    if string.match("1L13 EWR", groupName) then
        log:info("Configuring group $1 as EWR", groupName)
        ctld.addEWRTask(spawnedGroup)
    end
    M.pushSpawnQueue(groupName)
    local playerName = utils.getPlayerNameFromGroupName(groupName)
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

-- Base defences are defined as late-activated group groups in proximity to an airbase or helipad
local function configureBasesAtStartup(rsrConfig, baseOwnership)
    for _, ownershipData in pairs(baseOwnership) do
        for sideName, baseNames in pairs(ownershipData) do
            for _, baseName in pairs(baseNames) do
                bases.onMissionStart(baseName, sideName, rsrConfig)
            end
        end
    end
end

function M.restoreFromState(rsrConfig)
    log:info("Restoring mission state")
    state.copyToCtld()

    -- We clear state.current.persistentGroupData here, as this is updated in handleSpawnQueue later
    -- This ensures the data we get from MIST is always consistent between a CTLD spawn and a reload from disk
    local persistentGroupData = state.currentState.persistentGroupData
    log:info("Number of persistent groups at restore is $1", #state.currentState.persistentGroupData)
    state.currentState.persistentGroupData = {}
    for _, groupData in ipairs(persistentGroupData) do
        M.spawnGroup(groupData)
    end

    configureBasesAtStartup(rsrConfig, state.currentState.baseOwnership)
    log:info("Mission state restored")
end

function M.onMissionStart(rsrConfig)
    state.setCurrentStateFromFile(rsrConfig.stateFileName)
    M.restoreFromState(rsrConfig)

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
