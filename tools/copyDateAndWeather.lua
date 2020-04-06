require("tests.dcs_stub")
local missionUtils = require("missionUtils")
require("mist_4_3_74")
local inspect = require("inspect")

if #arg < 2 then
    print("Copies weather from inputMission to outputMission")
    print("Usage: lua copyDateAndWeather.lua <inputMission> <outputMission> [--write]")
    return
end

local inputMissionDir = arg[1]
local outputMissionDir = arg[2]
local write = #arg >= 3 and arg[3] == "--write"

-- luacheck: read_globals mission
missionUtils.loadMission(inputMissionDir)
print(" * Reading weather and date from " .. inputMissionDir)
local date = mist.utils.deepCopy(mission.date)
local weather = mist.utils.deepCopy(mission.weather)

missionUtils.loadMission(outputMissionDir)
print(" * Copying " .. inputMissionDir .. " weather to " .. outputMissionDir)
mission.date = date
mission.weather = weather

if write then
    missionUtils.serializeMission(outputMissionDir)
end
