-- our global configuration namespace

local utils = require("utils")

rsr = {}
rsr.devMode = false  -- enables "developer only" marker features
rsr.stateFileName = utils.getFilePath("rsrState.json")  -- default name for state file
rsr.writeInterval = 5 -- how often to update and write the state to disk in seconds

