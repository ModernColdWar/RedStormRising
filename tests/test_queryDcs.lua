local lu = require("tests.luaunit")
require("tests.dcs_stub")
local baseOwnershipCheck = require("baseOwnershipCheck")

TestbaseOwnershipCheck = {}

function TestbaseOwnershipCheck:testGetAllBaseOwnership()
    local ownership = baseOwnershipCheck.getAllBaseOwnership()
    lu.assertEquals(ownership, {
        airbases = { blue = {}, red = {}, neutral = {} },
        farps = { blue = {}, red = {}, neutral = {} } }
    )
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

