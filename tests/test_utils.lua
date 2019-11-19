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

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

