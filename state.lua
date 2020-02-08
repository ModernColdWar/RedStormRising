env.info("RSR STARTUP: state.LUA INIT")
require("mist_4_3_74")
require("CTLD")
local inspect = require("inspect")
local JSON = require("JSON")
local utils = require("utils")
local baseOwnershipCheck = require("baseOwnershipCheck")
local updateSpawnQueue = require("updateSpawnQueue")

local log = mist.Logger:new("State", "info")

--luacheck: push no unused
function JSON:onDecodeError(message, text, location, etc)
    log:error("Unable to parse JSON: $1 at position $2: '$3'", message, location, text)
end
--luacheck: pop

local M = {}

-- The default state that should be set on a reset or if missing from the state we're restoring from
M.defaultState = {
    ctld = {
        nextGroupId = 1,
        nextUnitId = 1,
    },
    persistentGroupData = {}, -- updated by a scheduled task
    baseOwnership = {} -- populated from DCS API if zero-length
}

-- set in M.setCurrentState(stateFileName)
M.currentState = nil

-- used to mark whether base defences need to be spawned in at start (ie round reset)
M.missionInitSetup = false

-- mission init with no rsrState.json = campaign init = use zone name and color to determining starting base ownership
M.campaignStartSetup = false


function M.getGroupData(groupName)
    local group = Group.getByName(groupName)
    if group == nil then
        log:warn("Unable to find group '$1'", groupName)
        return nil
    end
    local firstUnit = group:getUnit(1)
    if firstUnit == nil then
        log:warn("Unable to find first unit in group '$1'", groupName)
        return nil
    end

    local coalitionId = group:getCoalition()
    local countryId = firstUnit:getCountry()

    local groupData = {
        category = "vehicle", -- don't need to call getCategory as we only save vehicles
        coalition = utils.getSideName(coalitionId),
        coalitionId = coalitionId,
        countryId = countryId,
        name = groupName,
        units = {}
    }

    for _, unit in pairs(group:getUnits()) do
        local position = unit:getPosition()
        local unitData = {
            heading = mist.getHeading(unit, true),
            skill = "Excellent",
            type = unit:getTypeName(),
            name = unit:getName(),
            x = position.p.x,
            y = position.p.z
        }
        table.insert(groupData.units, unitData)
    end
    --log:info("getGroupData($1) = $2", groupName, inspect(groupData))
    return groupData
end

function M.handleSpawnQueue()
    -- get MIST group data for newly unpacked units (if it's available)
    --log:info("Handling spawn queue (length $1)", #updateSpawnQueue.spawnQueue)
    for i = #updateSpawnQueue.spawnQueue, 1, -1 do
        local groupName = updateSpawnQueue.spawnQueue[i]
        --log:info("Getting group data for spawned group $1", groupName)
        local groupData = M.getGroupData(groupName)
        if groupData ~= nil then
            --log:info("Successfully got group data for $1", groupName)
            table.insert(M.currentState.persistentGroupData, groupData)
            --log:info("Removing $1 from spawn queue", groupName)
            table.remove(updateSpawnQueue.spawnQueue, i)
        else
            log:warn("Unable to get group data for $1; leaving in spawn queue", groupName)
        end
    end
    log:info("Spawn queue handling complete")
end

--- Removes groupId and unitId from data so that upon respawn, MIST assigns new IDs
-- Avoids accidental overwrite of units
-- This is called at write-to-disk time
-- Visible to allow testing
function M.removeGroupAndUnitIds(persistentGroupData)
    for _, groupData in ipairs(persistentGroupData) do
        groupData["groupId"] = nil
        for _, unitData in ipairs(groupData.units) do
            unitData["unitId"] = nil
        end
    end
end

function M.readStateFromDisk(filename)
    log:info("Reading state from disk at $1", filename)
    local f = io.open(filename, "r")
    local json = f:read("*all")
    f:close()
    local _state = JSON:decode(json)
    log:info("Finished reading state from disk at $1", filename)
    return _state
end

function M.writeStateToDisk(stateFileName)
    local stateToWrite = mist.utils.deepCopy(M.currentState)
    M.removeGroupAndUnitIds(stateToWrite.persistentGroupData)
    log:info("Writing state to disk at $1", stateFileName)
    local json = JSON:encode_pretty(stateToWrite)
    local f = io.open(stateFileName, "w")
    f:write(json)
    f:close()
    log:info("Finished writing state to $1", stateFileName)
end

function M.copyToCtld()
    ctld.nextGroupId = M.currentState.ctld.nextGroupId
    ctld.nextUnitId = M.currentState.ctld.nextUnitId
end

function M.copyFromCtld()
    M.currentState.ctld.nextGroupId = ctld.nextGroupId
    M.currentState.ctld.nextUnitId = ctld.nextUnitId
end

function M.updateBaseOwnership()
	--(_campaignStartSetup,_passedBase,_playerORunit)
	--_campaignStartSetup will take priority over next two args
	--_passedBase = "ALL" to initiate full check of all bases for persistance
	if M.campaignStartSetup then
		M.currentState.baseOwnership = baseOwnershipCheck.getAllBaseOwnership(M.campaignStartSetup,"ALL","none")
		M.campaignStartSetup = false -- only use map markers to setup bases ONCE, iterate through bases every other time
	else
		M.currentState.baseOwnership = baseOwnershipCheck.getAllBaseOwnership(M.campaignStartSetup,"ALL","none")
	end
	log:info("M.currentState.baseOwnership $1", M.currentState.baseOwnership)
end

function M.getOwner(passedBase)
    for _k, baseOwnership in pairs(M.currentState.baseOwnership) do
        for sideName, baseList in pairs(baseOwnership) do
            for _k, _baseName in ipairs(baseList) do
                if _baseName == passedBase then
                    return sideName
                end
            end
        end
    end
    return nil
end

--mr: just because DCS EH = base owner changed doesn't mean base change accoriding to RSR!
-- checkBaseOwner only utilsed by baseCapturedHandler.lua i.e. DCS baseCaptured eventHandler
function M.checkBaseOwner(baseName, sideName) 
    local currentOwner = M.getOwner(passedBase)
    if currentOwner == sideName then
        return false  --no change in DCS ownership
    end

    log:info("DCS EH ownership of $1 from $2 to $3", baseName, currentOwner, sideName)
    return true --change in DCS ownership
end

function M.getWinner()
    local redCount = #M.currentState.baseOwnership.Airbases.red
    local blueCount = #M.currentState.baseOwnership.Airbases.blue
    local neutralCount = #M.currentState.baseOwnership.Airbases.neutral
    if neutralCount > 0 or (redCount + blueCount + neutralCount == 0) then
        return nil
    end
    if redCount > 0 and blueCount == 0 then
        return "red"
    end
    if blueCount > 0 and redCount == 0 then
        return "blue"
    end
end

function M.setCurrentStateFromFile(stateFileName)
    local canUseStateFromFile = false
    if UTILS.FileExists(stateFileName) then
        local stateFromDisk = M.readStateFromDisk(stateFileName)
        if stateFromDisk == nil then
            return false
        end
        M.currentState = stateFromDisk
        if M.getWinner() == nil then
            canUseStateFromFile = true
        else
            log:info("State file is from a victory - will not use")
        end
    else
        log:info("No state file found")
    end

    if not canUseStateFromFile then
        log:info("Setting up from defaults in code, and base(airbase/FOB) ownership from 'RSRbaseCaptureZone Trigger' Zone color")
        M.missionInitSetup = true
		M.campaignStartSetup = true
        M.currentState = mist.utils.deepCopy(M.defaultState)
		M.updateBaseOwnership()
    end
    log:info("currentState = $1", inspect(M.currentState, { newline = " ", indent = "" }))
    return true
end
env.info("RSR STARTUP: state.LUA LOADED")
return M