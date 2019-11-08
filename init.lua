local writeInterval = 10

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

mist.scheduleFunction(writeState, { rsr.state, true, stateFile }, timer.getTime() + writeInterval, writeInterval)
