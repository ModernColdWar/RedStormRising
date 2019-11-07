local stateFile = getFilePath("rsrState.json")

function writeState(state)
    log:info("Writing state to disk at $1", stateFile)
    local f = io.open(stateFile, "w")
    f:write(JSON:encode(state))
    f:close()
    log:info("Finished writing state")
end

function readState()
    log:info("Reading state from disk at $1", stateFile)
    local f = io.open(stateFile, "r")
    local stateJson = f:read("*all")
    f:close()
    local state = JSON:decode(stateJson)
    log:info("Finished reading state")
    return state
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
