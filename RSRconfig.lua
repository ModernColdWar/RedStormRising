-- our main namespace
rsr = {}
rsr.devMode = false  -- enables "developer only" marker features
rsr.stateFileName = "rsrState.json"  -- default name for state file
rsr.loadStateFile = true -- whether to load from state if it exists

-- The initial configuration of the persistent data we save to disk
rsr.state = {
    persistentGroupData = {},
    ctldUnpackedGroupNames = {},
    ctld = {},
}


if rsr.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
end
