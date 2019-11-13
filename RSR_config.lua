-- our global configuration namespace

local utils = require("utils")

rsr = {}
rsr.devMode = false  -- enables "developer mode"; extra logging, saving, menu options and debug features
rsr.stateFileName = utils.getFilePath("rsrState.json")  -- default name for state file
rsr.writeInterval = rsr.devMode and 10 or 300 -- how often to update and write the state to disk in seconds

rsr.airbaseZoneRadius = 4000 -- radius for base defence spawning zone
