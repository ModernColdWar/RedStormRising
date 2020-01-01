-- RSR's configuration object
local utils = require("utils")

local rsrConfig = {}

rsrConfig.devMode = false -- enables "developer mode"; extra logging, saving, menu options and debug features
rsrConfig.stateFileName = utils.getFilePath("rsrState.json") -- default name for state file
rsrConfig.writeInterval = rsrConfig.devMode and 10 or 300 -- how often to update and write the state to disk in seconds
rsrConfig.writeDelay = rsrConfig.devMode and 0 or 180  -- initial delay for persistence, to move last one closer to restart
rsrConfig.baseDefenceActivationRadiusAirbase = 5000
rsrConfig.baseDefenceActivationRadiusFarp = 2500
rsrConfig.hitMessageDelay = 30
rsrConfig.restartHours = { 1, 5, 9, 13, 17, 21}

return rsrConfig
