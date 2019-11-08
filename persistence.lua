function updateState(state)
    state.persistentGroupData = {}
    for i, groupName in ipairs(state.ctldUnpackedGroupNames) do
        log:info("Getting data for unpacked CTLD unit: $1", groupName)
        local groupData = removeGroupAndUnitIds(mist.getGroupData(groupName))
        table.insert(state.persistentGroupData, groupData)
    end
    state.ctld.nextGroupId = ctld.nextGroupId
    state.ctld.nextUnitId = ctld.nextUnitId
end

--- Removes groupId and unitId from data so that upon respawn, MIST assigns new IDs
--- Avoids accidental overwrite of units
function removeGroupAndUnitIds(groupData)
    groupData["groupId"] = nil
    for _, unitData in ipairs(groupData.units) do
        unitData["unitId"] = nil
    end
    return groupData
end

function writeState(state, updateFirst, filename)
    if updateFirst then
        updateState(state)
    end
    filename = filename or stateFile
    log:info("Writing state to disk at $1", filename)
    local f = io.open(filename, "w")
    f:write(JSON:encode(state))
    f:close()
    log:info("Finished writing state")
end

function readState(filename)
    filename = filename or stateFile
    log:info("Reading state from disk at $1", filename)
    local f = io.open(filename, "r")
    local stateJson = f:read("*all")
    f:close()
    local state = JSON:decode(stateJson)
    log:info("Finished reading state")
    return state
end

function fileExists(filename)
    local f = io.open(filename, "r")
    if f == nil then
        return false
    else
        f:close()
        return true
    end
end

function spawnFromState(state)
    for _i, groupData in ipairs(state.persistentGroupData) do
        log:info("Spawning $1 from saved state", groupData.groupName)
        mist.dynAdd(groupData)
    end
end