
if stateFileExists() then
    log:info("State file exists - will set up from saved state")
    local saved_state = readState()
else
    log:info("No state file exists - setting up from scratch")
end

mist.scheduleFunction(writeState, {rsrState}, timer.getTime() + 30, 30)
