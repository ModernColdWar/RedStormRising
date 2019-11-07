local lu = require("luaunit")
dofile("RSR.lua")

TestPersistence = {}

function TestPersistence:testStateRoundtrip()
    local expectedState = {foo=123, bar={bar=456}}
    rsrState = mist.utils.deepCopy(expectedState)
    writeState()
    rsrState = {}
    readState()
    lu.assertEquals(rsrState, expectedState)
end


local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
