local lu = require("tests.luaunit")
require("tests.dcs_stub")
local slotBlocker = require("slotBlocker")

TestSlotBlocker = {}

function TestSlotBlocker:testGetBaseAndSideNamesFromGroup()
    local baseName, sideName = slotBlocker.getBaseAndSideNamesFromGroup("Gudauta Red Helos #001")
    lu.assertEquals(baseName, "Gudauta")
    lu.assertEquals(sideName, "red")

    baseName, sideName = slotBlocker.getBaseAndSideNamesFromGroup("S-K blUe plane")
    lu.assertEquals(baseName, "S-K")
    lu.assertEquals(sideName, "blue")

    baseName, sideName = slotBlocker.getBaseAndSideNamesFromGroup("FARP ABC2 Blue Helos #002")
    lu.assertEquals(baseName, "FARP ABC2")
    lu.assertEquals(sideName, "blue")
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

