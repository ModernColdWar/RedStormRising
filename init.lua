local stateFile = getFilePath(rsr.stateFileName)

if fileExists(stateFile) then
    log:info("State file exists - will set up from saved state")
    rsr.state = readState(stateFile)
    spawnFromState(rsr.state)
    ctld.nextGroupId = rsr.state.ctld.nextGroupId
    ctld.nextUnitId = rsr.state.ctld.nextUnitId
else
    log:info("No state file exists - setting up from scratch")
end

local function persistState()
    updateState(rsr.state)
    writeState(rsr.state, stateFile)
end

mist.scheduleFunction(persistState, {}, timer.getTime() + rsr.writeInterval, rsr.writeInterval)
