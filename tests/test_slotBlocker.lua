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

function TestSlotBlocker:testMatchesBaseName()
    lu.assertIsFalse(slotBlocker.matchesBaseName("foo", nil))
    lu.assertIsFalse(slotBlocker.matchesBaseName("foo", "bar"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Senaki", "Senaki"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Senaki-Kolkhi", "Senaki"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Senaki", "Sen"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Senaki", "S"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "Krasnodar-Pashkovsky"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "Krasnodar-P"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "Kras-P"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "K-P"))
    lu.assertIsTrue(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "K-Pash"))
    lu.assertIsFalse(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "Kras-C"))
    lu.assertIsFalse(slotBlocker.matchesBaseName("Krasnodar-Pashkovsky", "Kras-P-D"))
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

