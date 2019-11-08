local lu = require("luaunit")
dofile("RSR.lua")

TestPersistence = {}

function TestPersistence:testStateRoundtrip()
    local expectedState = {foo=123, bar={bar=456}}
    writeState(expectedState,"rsrState_testPersistence_roundtrip.json")
    local loadedState = readState("rsrState_testPersistence_roundtrip.json")
    lu.assertEquals(loadedState, expectedState)
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
