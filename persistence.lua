rsrState = {
    persistentGroupData = {},
    ctldUnpackedGroupNames = {},
}

function updateState()
    rsrState.persistentUnits = {}
    for i, groupName in ipairs(rsrState.ctldUnpackedGroupNames) do
        log:info("Getting data for unpacked CTLD unit: $1", groupName)
        table.insert(rsrState.persistentGroupData, mist.getGroupData(groupName))
    end
end

local stateFile = getFilePath("rsrState.json")

function writeState(updateFirst)
    if updateFirst then
        updateState()
    end
    log:info("Writing state to disk at $1", stateFile)
    local f = io.open(stateFile, "w")
    f:write(JSON:encode(rsrState))
    f:close()
    log:info("Finished writing state")
end

function readState()
    log:info("Reading state from disk at $1", stateFile)
    local f = io.open(stateFile, "r")
    local stateJson = f:read("*all")
    f:close()
    rsrState = JSON:decode(stateJson)
    log:info("Finished reading state")
end

function stateFileExists()
    local f = io.open(stateFile, "r")
    if f == nil then
        return false
    else
        f:close()
        return true
    end
end

function spawnFromState()
    for _i, groupData in ipairs(rsrState.persistentGroupData) do
        log:info("Spawning $1 from saved state", groupData.groupName)
        mist.dynAdd(groupData)
    end
end