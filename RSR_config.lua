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
rsrConfig.awacsBases = { "Krasnodar-Center", "Vaziani" } -- bases with linked AWACS spawns

-- Windows task scheduler, schedules the DCSTask Kill batch file to execute on these hours. These hours are placed here to configure
-- the in-game message the players can query to find out the restart time
-- TODO: you also should change
--rsrConfig.restartHours = { 1, 5, 9, 13, 17, 21 } -- For restarts every 4 hours
--rsrConfig.restartHours = { 1, 7, 13, 19 } -- For restarts every 6 hours
rsrConfig.restartHours = { 1, 9, 17 } -- For restarts every 8 hours

return rsrConfig
