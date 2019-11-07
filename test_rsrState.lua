local lu = require("luaunit")
require("rsrState.lua")

TestRsrState = {}


function TestRsrState:testInitialState()
    lu.assertEquals(rsrState.CTLD, {})
end


local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
