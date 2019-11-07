local lu = require("luaunit")
dofile("RSR.lua")

TestPersistence = {}

function TestPersistence:testStateRoundtrip()
    local inputState = {foo=123, bar={bar=456}}
    writeState(inputState)
    local outputState = readState()
    lu.assertEquals(outputState, inputState)
end


local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
