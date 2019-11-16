local lu = require("tests.luaunit")
require("tests.dcs_stub")
local slotBlocker = require("slotBlocker")

TestSlotBlocker = {}

function TestSlotBlocker:testGetBaseAndSideNames()
    local baseName, sideName = slotBlocker.getBaseAndSideNames("Gudauta Red Helos #001")
    lu.assertEquals(baseName, "Gudauta")
    lu.assertEquals(sideName, "red")

    baseName, sideName = slotBlocker.getBaseAndSideNames("S-K blUe")
    lu.assertEquals(baseName, "S-K")
    lu.assertEquals(sideName, "blue")
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

