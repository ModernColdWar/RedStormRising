local lu = require("tests.luaunit")
require("tests.dcs_stub")
local queryDcs = require("queryDcs")

TestQueryDcs = {}

function TestQueryDcs:testGetAllBaseOwnership()
    local ownership = queryDcs.getAllBaseOwnership()
    lu.assertEquals(ownership, {
        airbases = { blue = {}, red = {}, neutral = {} },
        farps = { blue = {}, red = {}, neutral = {} } }
    )
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

