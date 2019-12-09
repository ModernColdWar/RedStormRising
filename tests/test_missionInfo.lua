local lu = require("tests.luaunit")
local restartInfo = require("missionInfo")

TestRestartInfo = {}

function TestRestartInfo:testGetNextRestartHour()
    lu.assertEquals(restartInfo.getNextRestartHour(0, { 1 }), 1)
    lu.assertEquals(restartInfo.getNextRestartHour(1, { 1 }), 1)
    lu.assertEquals(restartInfo.getNextRestartHour(2, { 1 }), 1)
    lu.assertEquals(restartInfo.getNextRestartHour(2, { 1, 5, 9 }), 5)
    lu.assertEquals(restartInfo.getNextRestartHour(5, { 1, 5, 9 }), 9)
    lu.assertEquals(restartInfo.getNextRestartHour(9, { 1, 5, 9 }), 1)
end

function TestRestartInfo:testGetSecondsUntilRestart()
    lu.assertEquals(restartInfo.getSecondsUntilRestart({ year = 2019, month = 9, day = 12, hour = 12, min = 59, sec = 15 }, { 13 }), 45)
    lu.assertEquals(restartInfo.getSecondsUntilRestart({ year = 2019, month = 9, day = 12, hour = 23, min = 59, sec = 0 }, { 1 }), 3660)
    lu.assertEquals(restartInfo.getSecondsUntilRestart({ year = 2019, month = 9, day = 12, hour = 12, min = 0, sec = 0 }, { 12 }), 86400)
end

function TestRestartInfo:testGetSecondsAsString()
    lu.assertEquals(restartInfo.getSecondsAsString(1), "00:00:01")
    lu.assertEquals(restartInfo.getSecondsAsString(60), "00:01:00")
    lu.assertEquals(restartInfo.getSecondsAsString(150), "00:02:30")
    lu.assertEquals(restartInfo.getSecondsAsString(900), "00:15:00")
    lu.assertEquals(restartInfo.getSecondsAsString(3600), "01:00:00")
    lu.assertEquals(restartInfo.getSecondsAsString(12345), "03:25:45")
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

