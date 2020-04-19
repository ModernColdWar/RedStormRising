local lu = require("tests.luaunit")
require("tests.dcs_stub")
local persistence = require("persistence")

TestPersistence = {}

function TestPersistence:setUp()
    dcsStub.reset()
end

function TestPersistence:testUpdateGroupDataWithEmptyData()
    local groupData = {}
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {})
end

function TestPersistence:testUpdateGroupDataSetsAltXY()
    local groupData = {
        { name = "groupName",
          units = {
              { name = "unitName1" },
              { name = "unitName2" }
          }
        }
    }
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {
        { name = "groupName",
          units = {
              { heading = 0, name = "unitName1", x = 1, y = 2 },
              { heading = 0, name = "unitName2", x = 1, y = 2 },
          }
        }
    })
end

function TestPersistence:testUpdateGroupDataRemovesDeadUnits()
    local groupData = {
        { name = "groupName",
          units = {
              { name = "unitName1" },
              { name = "deadUnit" }
          }
        }
    }
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {
        { name = "groupName",
          units = {
              { heading = 0, name = "unitName1", x = 1, y = 2 },
          }
        }
    })
end

function TestPersistence:testUpdateGroupDataRemovesGroupWithNoUnits()
    local groupData = { { name = "groupName", units = { { name = "deadUnit" } } } }
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {})
end

function TestPersistence:testSpawnGroup()
    local groupData = {
        ["country"] = "usa",
        ["coalitionId"] = 2,
        ["name"] = "CTLD_Tor 9A331_77 (Capt.Fdez)",
        ["units"] = {
            [1] = {
                ["alt"] = 5.0000045435017,
                ["heading"] = 2.7521738270529,
                ["y"] = 570413.97585701,
                ["x"] = -225602.16457669,
                ["speed"] = 0,
                ["name"] = "Unpacked Tor 9A331 #237",
                ["skill"] = "Excellent",
                ["type"] = "Tor 9A331", }
        },
        ["countryId"] = 2,
        ["category"] = "vehicle",
        ["coalition"] = "blue",
        ["hidden"] = false
    }
    persistence.spawnGroup(groupData)
    dcsStub.assertOneCallTo("coalition.addGroup")
    lu.assertEquals(persistence.groupOwnership.blue['Capt.Fdez'], { "CTLD_Tor 9A331_77 (Capt.Fdez)" })
end

function TestPersistence:testAddingGroupOwnership()
    local ownership = { red = {}, blue = {} }
    persistence.addGroupOwnership(ownership, "red", "Winston", "Amazeballs")
    persistence.addGroupOwnership(ownership, "red", "Winston", "Amazeballs #2")
    persistence.addGroupOwnership(ownership, "blue", "Winston", "Amazeballs #3")
    persistence.addGroupOwnership(ownership, "blue", "Bunty", "Hummer")
    persistence.addGroupOwnership(ownership, "red", "Slacker", "IGLA")

    lu.assertEquals(persistence.getOwnedGroupCount(ownership, "red", "Alan"), 0)
    lu.assertEquals(persistence.getOwnedGroupCount(ownership, "red", "Winston"), 2)
    lu.assertEquals(persistence.getOwnedGroupCount(ownership, "blue", "Winston"), 1)
    lu.assertEquals(persistence.getOwnedGroupCount(ownership, "blue", "Bunty"), 1)

    lu.assertEquals(persistence.getOwnedJtacCount(ownership, "blue", "Winston"), 0)
    lu.assertEquals(persistence.getOwnedJtacCount(ownership, "blue", "Bob"), 0)

    persistence.addGroupOwnership(ownership, "red", "Winston", "Tigr_233036")
    lu.assertEquals(persistence.getOwnedJtacCount(ownership, "red", "Winston"), 1)
end

function TestPersistence:testRemovingGroupOwnership()
    -- no record for user
    local ownership = { red = {}, blue = {} }
    persistence.removeGroupOwnership(ownership, "red", "Winston", "groupName")
    lu.assertEquals(ownership, { red = {}, blue = {} })

    -- no groups in record
    ownership = { red = { ["Winston"] = {} }, blue = {} }
    persistence.removeGroupOwnership(ownership, "red", "Winston", "groupName")
    lu.assertEquals(ownership, { red = { ["Winston"] = {} }, blue = {} })

    -- group not in record
    ownership = { red = { ["Winston"] = { "groupName" } }, blue = {} }
    persistence.removeGroupOwnership(ownership, "red", "Winston", "foo")
    lu.assertEquals(ownership, { red = { ["Winston"] = { "groupName" } }, blue = {} })

    -- actually doing a removal
    ownership = { red = { ["Winston"] = { "groupName" } }, blue = {} }
    persistence.removeGroupOwnership(ownership, "red", "Winston", "groupName")
    lu.assertEquals(ownership, { red = { ["Winston"] = {} }, blue = {} })
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
