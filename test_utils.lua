local lu = require("luaunit")
require("dcs_stub")
local utils = require("utils")

TestUtils = {}

function TestUtils:testGetSideName()
    lu.assertEquals(utils.getSideName(coalition.side.RED), "red")
    lu.assertEquals(utils.getSideName(coalition.side.BLUE), "blue")
    lu.assertEquals(utils.getSideName(coalition.side.NEUTRAL), "neutral")
end

function TestUtils:testGetSide()
    lu.assertEquals(utils.getSide("red"), coalition.side.RED)
    lu.assertEquals(utils.getSide("blue"), coalition.side.BLUE)
    lu.assertEquals(utils.getSide("neutral"), coalition.side.NEUTRAL)
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

