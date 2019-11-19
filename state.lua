require("mist_4_3_74")
require("CTLD")
require("MOOSE")
local JSON = require("JSON")
local queryDcs = require("queryDcs")

local log = mist.Logger:new("State", "info")

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
    M.currentState.baseOwnership = queryDcs.getAllBaseOwnership()
end

function M.getOwner(baseName)
    for _, baseOwnership in pairs(M.currentState.baseOwnership) do
        for sideName, baseList in pairs(baseOwnership) do
            for _, _baseName in ipairs(baseList) do
                if _baseName == baseName then
                    return sideName
                end
            end
        end
    end
    return nil
end

local function setOwner(baseOwnership, baseName, sideName)
    local found = false
    local changed = false
    for _sideName, baseList in pairs(baseOwnership) do
        for i = #baseList, 1, -1 do
            local _baseName = baseList[i]
            if _baseName == baseName then
                found = true
                if _sideName ~= sideName then
                    table.remove(baseList, i)
                    changed = true
                end
            end
        end
    end
    if found == false then
        return
    end
    if changed then
        table.insert(baseOwnership[sideName], baseName)
    end
end

function M.setBaseOwner(baseName, sideName)
    local currentOwner = M.getOwner(baseName)
    if currentOwner == sideName then
        return false
    end
    setOwner(M.currentState.baseOwnership.airbases, baseName, sideName)
    setOwner(M.currentState.baseOwnership.farps, baseName, sideName)
    return true
end

function M.setCurrentStateFromFile(stateFileName)
    if UTILS.FileExists(stateFileName) then
        M.currentState = M.readStateFromDisk(stateFileName)
    else
        log:info("No state file exists - setting up from defaults in code and base ownership from mission")
        M.currentState = mist.utils.deepCopy(M.defaultState)
        M.updateBaseOwnership()
    end
    log:info("Current state is:\n$1", mist.utils.tableShow(M.currentState))
end

return M