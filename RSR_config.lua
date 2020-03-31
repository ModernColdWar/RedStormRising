-- RSR's configuration object
local utils = require("utils")

local rsrConfig = {}

-- enables "developer mode"; removes crate spawning/unpacking restrictions, more frequent saves
rsrConfig.devMode = false

-- Event reporting for the n0xy bot
rsrConfig.udpEventReporting = true
rsrConfig.udpEventHost = "walsh.systems"
rsrConfig.udpEventPort = 9696

-- state saving
rsrConfig.stateFileName = utils.getFilePath("rsrState.json") -- default name for state file
rsrConfig.writeInterval = rsrConfig.devMode and 30 or 300 -- how often to update and write the state to disk in seconds
rsrConfig.writeDelay = rsrConfig.devMode and 10 or 180  -- initial delay for persistence, to move last one closer to restart

-- base defences
--mr: ensure that associated RSRbaseCaptureZone zone, which is used as a pre-filter, is larger than these values
-- CTLD_config.lua: ctld.RSRbaseCaptureZones = ctldUtils.getRSRbaseCaptureZones(env.mission)
rsrConfig.baseDefenceActivationRadiusAirbase = 5000
rsrConfig.baseDefenceActivationRadiusFARP = 2500

-- restart schedule
rsrConfig.firstRestartHour = 5
rsrConfig.missionDurationInHours = 6
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

-- staging bases that never change side, never have logisitics centres and cannot be distinguished from FARP helipads
rsrConfig.stagingBases = { "RedStagingPoint", "BlueStagingPoint" }

return rsrConfig
