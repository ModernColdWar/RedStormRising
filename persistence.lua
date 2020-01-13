--- Saving/loading/updating code for managing "live" units and persisting them across server restarts
require("mist_4_3_74")
require("CTLD")
require("MOOSE")
local bases = require("bases")
local state = require("state")
local utils = require("utils")

local log = mist.Logger:new("Persistence", "info")

local M = {}


-- group ownerships by side and user - kept in memory only and updated in handleSpawnQueue
M.groupOwnership = {
    red = {},
    blue = {}
}

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
            local unitName = unitData.name
            local unit = Unit.getByName(unitName)
            if unit == nil then
                log:info("Removing persistent data for dead unit $1", unitName)
                table.remove(groupData.units, j)
            else
                log:info("Updating position information for unit $1", unitName)
                local position = unit:getPosition().p
                unitData.x = position.x
                unitData.y = position.z
                unitData.heading = mist.getHeading(unit, true)
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
    local status, err = pcall(function()
        M.updateGroupData(state.currentState.persistentGroupData)
        state.handleSpawnQueue()
        state.copyFromCtld()
        state.updateBaseOwnership()
    end)
    if status then
        log:info("Number of persistent groups at save is $1", #state.currentState.persistentGroupData)
        state.writeStateToDisk(rsrConfig.stateFileName)
    else
        log:error(string.format("Error while trying to update state: %s", err), false)
    end
    local winner = state.getWinner()
    if winner ~= nil then
        local message = "VICTORY for the " .. winner .. " side!  The map will reset at the next restart"
        log:info(message)
        trigger.action.outText(message, 30)
    end
end

function M.spawnGroup(groupData)
    -- Currently this code replicates the actions from ctld.unpackCrates
    local sideName = getSideNameFromGroupData(groupData)
    local groupName = groupData.name
    log:info("Spawning $1 $2 from groupData", sideName, groupName)
    -- Fix issue where mist group data doesn't contain playerCanDrive flag (it's always true for our persisted units)
    for _, unitData in pairs(groupData.units) do
        unitData.playerCanDrive = true
    end
    local spawnedGroup = Group.getByName(mist.dynAdd(groupData).name)
    if ctld.isJTACUnitType(groupName) then
        local _code = ctld.getLaserCode(Group.getByName(groupName):getCoalition())
        log:info("Configuring group $1 to auto-lase on $2", groupName, _code)
        ctld.JTACAutoLase(groupName, _code)
    end
    if string.match(groupName, "1L13 EWR") then
        log:info("Configuring group $1 as EWR", groupName)
        ctld.addEWRTask(spawnedGroup)
    end
    state.pushSpawnQueue(groupName)
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
local function configureBasesAtStartup(rsrConfig, baseOwnership, firstTimeSetup)
    for _, ownershipData in pairs(baseOwnership) do
        for sideName, baseNames in pairs(ownershipData) do
            for _, baseName in pairs(baseNames) do
                if AIRBASE:FindByName(baseName) == nil then
                    log:error("Unable to find base $1 on map but was in state file; skipping setup", baseName)
                else
                    bases.onMissionStart(baseName, sideName, rsrConfig, firstTimeSetup)
                end
            end
        end
    end
end

function M.restoreFromState(rsrConfig)
    log:info("Restoring mission state")
    state.copyToCtld()

    configureBasesAtStartup(rsrConfig, state.currentState.baseOwnership, state.firstTimeSetup)

    -- We clear state.current.persistentGroupData here, as this is updated in handleSpawnQueue later
    -- This ensures the data we get from MIST is always consistent between a CTLD spawn and a reload from disk
    local persistentGroupData = state.currentState.persistentGroupData
    log:info("Number of persistent groups at restore is $1", #state.currentState.persistentGroupData)
    state.currentState.persistentGroupData = {}
    for _, groupData in ipairs(persistentGroupData) do
        M.spawnGroup(groupData)
    end

    log:info("Mission state restored")
end

function M.onMissionStart(rsrConfig)
    if not state.setCurrentStateFromFile(rsrConfig.stateFileName) then
        log:error("Unable to load state from $1", rsrConfig.stateFileName)
        return
    end
    M.restoreFromState(rsrConfig)

    -- register unpack callback so we can update our state
    ctld.addCallback(function(_args)
        if _args.action and _args.action == "unpack" then
            local sideName = utils.getSideName(_args.unit:getCoalition())
            local playerName = ctld.getPlayerNameOrType(_args.unit)
            local groupName = _args.spawnedGroup:getName()
            log:info('Player $1 on $2 unpacked $3', playerName, sideName, groupName)
            state.pushSpawnQueue(groupName)
            M.addGroupOwnership(M.groupOwnership, sideName, playerName, groupName)
        end
    end)

    SCHEDULER:New(nil, persistState, { rsrConfig },
            rsrConfig.writeDelay, rsrConfig.writeInterval)
end

return M
