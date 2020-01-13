-- RSR's configuration object
local utils = require("utils")

local rsrConfig = {}

 -- enables "developer mode"; removes crate spawning/unpacking restrictions, more frequent saves
rsrConfig.devMode = false

-- state saving
rsrConfig.stateFileName = utils.getFilePath("rsrState.json") -- default name for state file
rsrConfig.writeInterval = rsrConfig.devMode and 10 or 300 -- how often to update and write the state to disk in seconds
rsrConfig.writeDelay = rsrConfig.devMode and 0 or 180  -- initial delay for persistence, to move last one closer to restart

-- base defences
rsrConfig.baseDefenceActivationRadiusAirbase = 5000
rsrConfig.baseDefenceActivationRadiusFarp = 2500

-- restart schedule
rsrConfig.firstRestartHour = 5
rsrConfig.missionDurationInHours = 8
rsrConfig.restartHours = utils.getRestartHours(rsrConfig.firstRestartHour, rsrConfig.missionDurationInHours)

-- life points configuration
rsrConfig.livesPerHour = 1.25
rsrConfig.maxLives = math.floor(rsrConfig.missionDurationInHours * rsrConfig.livesPerHour + 0.5)

-- global message configuration
rsrConfig.restartWarningMinutes = { 60, 45, 30, 20, 15, 10, 5, 3, 1 } -- times in minutes before restart to broadcast message
rsrConfig.hitMessageDelay = 30

-- AWACS configuration
rsrConfig.awacsBases = { "Krasnodar-Center", "Vaziani" } -- bases with linked AWACS spawns
rsrConfig.awacsSpawnLimit = math.floor(rsrConfig.missionDurationInHours / 2)


return rsrConfig
