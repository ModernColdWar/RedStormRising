local lu = require("tests.luaunit")
require("tests.dcs_stub")
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

function TestUtils:testMatchesBaseName()
    lu.assertIsFalse(utils.matchesBaseName("foo", nil))
    lu.assertIsFalse(utils.matchesBaseName("foo", "bar"))
    lu.assertIsTrue(utils.matchesBaseName("Senaki", "Senaki"))
    lu.assertIsTrue(utils.matchesBaseName("Senaki-Kolkhi", "Senaki"))
    lu.assertIsTrue(utils.matchesBaseName("Senaki", "Sen"))
    lu.assertIsTrue(utils.matchesBaseName("Senaki", "S"))
    lu.assertIsTrue(utils.matchesBaseName("Krasnodar-Pashkovsky", "Krasnodar-Pashkovsky"))
    lu.assertIsTrue(utils.matchesBaseName("Krasnodar-Pashkovsky", "Krasnodar-P"))
    lu.assertIsTrue(utils.matchesBaseName("Krasnodar-Pashkovsky", "Kras-P"))
    lu.assertIsTrue(utils.matchesBaseName("Krasnodar-Pashkovsky", "K-P"))
    lu.assertIsTrue(utils.matchesBaseName("Krasnodar-Pashkovsky", "K-Pash"))
    lu.assertIsFalse(utils.matchesBaseName("Krasnodar-Pashkovsky", "Kras-C"))
    lu.assertIsFalse(utils.matchesBaseName("Krasnodar-Pashkovsky", "Kras-P-D"))

    lu.assertTrue(utils.matchesBaseName("Sukhumi-Babushara", "Sukumi"))
end

function TestUtils:testGetPlayerNameFromGroupName()
    lu.assertEquals(utils.getPlayerNameFromGroupName("CTLD_Tor 9A331_77 (Capt.Fdez)"), "Capt.Fdez")
    lu.assertIsNil(utils.getPlayerNameFromGroupName("CTLD_Tor 9A331_77"))
end

function TestUtils:testGetBaseAndSideNamesFromGroupName()
    local baseName, sideName = utils.getBaseAndSideNamesFromGroupName("Gudauta Red Helos #001")
    lu.assertEquals(baseName, "Gudauta")
    lu.assertEquals(sideName, "red")

    baseName, sideName = utils.getBaseAndSideNamesFromGroupName("S-K blUe plane")
    lu.assertEquals(baseName, "S-K")
    lu.assertEquals(sideName, "blue")

    baseName, sideName = utils.getBaseAndSideNamesFromGroupName("FARP ABC2 Blue Helos #002")
    lu.assertEquals(baseName, "FARP ABC2")
    lu.assertEquals(sideName, "blue")
end

function TestUtils:testGetBaseNameFromZoneName()
    lu.assertEquals(utils.getBaseNameFromZoneName("Senaki PickUp", "PickUp"), "Senaki")
    lu.assertEquals(utils.getBaseNameFromZoneName("Krasnodar-Pashkovsky PickUp", "pickup"), "Krasnodar-Pashkovsky")
    lu.assertEquals(utils.getBaseNameFromZoneName("Abu Dhabi Logistics", "LOGISTICS"), "Abu Dhabi")
    lu.assertEquals(utils.getBaseNameFromZoneName("Abu Dhabi pickup zone", "pickup"), "Abu Dhabi")
end

function TestUtils:testGetRestartHours()
    lu.assertEquals(utils.getRestartHours(0, 8), { 0, 8, 16 })
    lu.assertEquals(utils.getRestartHours(5, 8), { 5, 13, 21 })
    lu.assertEquals(utils.getRestartHours(1, 4), { 1, 5, 9, 13, 17, 21 })
end

function TestUtils:testRound()
    lu.assertEquals(utils.round(1234.49, 1), 1234)
    lu.assertEquals(utils.round(1234.51, 1), 1235)
    lu.assertEquals(utils.round(1234.56, 10), 1230)
    lu.assertEquals(utils.round(1234.56, 100), 1200)
    lu.assertEquals(utils.round(7899.56, 100), 7900)
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

