local lu = require("tests.luaunit")
require("tests.dcs_stub")
local pickupZoneManager = require("pickupZoneManager")

TestPickupZoneManager = {}

function TestPickupZoneManager:testGetBaseNameFromZoneName()
    lu.assertEquals(pickupZoneManager.getBaseNameFromZoneName("Senaki PickUp"), "Senaki")
    lu.assertEquals(pickupZoneManager.getBaseNameFromZoneName("Krasnodar-Pashkovsky PickUp"), "Krasnodar-Pashkovsky")
    lu.assertEquals(pickupZoneManager.getBaseNameFromZoneName("Abu Dhabi PickUp"), "Abu Dhabi")
    lu.assertEquals(pickupZoneManager.getBaseNameFromZoneName("Abu Dhabi pickup zone"), "Abu Dhabi")
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

