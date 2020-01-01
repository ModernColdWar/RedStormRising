local lu = require("tests.luaunit")
require("tests.dcs_stub")
local state = require("state")
local persistence = require("persistence")

TestPersistence = {}

local _getMistGroupData = persistence.getMistGroupData

function TestPersistence:setUp()
    dcsStub.reset()
    state.currentState = mist.utils.deepCopy(state.defaultState)
    persistence.spawnQueue = {}
    --persistence.resetState()
end

function TestPersistence:tearDown()
    persistence.getMistGroupData = _getMistGroupData
end

function TestPersistence:testPushSpawnQueue()
    lu.assertEquals(persistence.spawnQueue, {})
    persistence.pushSpawnQueue("group1")
    persistence.pushSpawnQueue("group2")
    lu.assertEquals(persistence.spawnQueue, { "group1", "group2" })
end

function TestPersistence:testHandleSpawnQueueLeavesItemsInQueueIfNoDataFromMist()
    persistence.pushSpawnQueue("group1")
    persistence.pushSpawnQueue("group2")
    persistence.handleSpawnQueue()

    lu.assertEquals(persistence.spawnQueue, { "group1", "group2" })
end

function TestPersistence:testHandleSpawnQueuePutsGroupDataIntoStateAndRemovesFromQueue()
    persistence.getMistGroupData = function(groupName)
        return { groupName = groupName, pos = { x = 1, y = 2 } }
    end
    persistence.pushSpawnQueue("group1")
    persistence.pushSpawnQueue("group2")
    persistence.handleSpawnQueue()

    lu.assertEquals(persistence.spawnQueue, {})
    lu.assertEquals(state.currentState.persistentGroupData, {
        { groupName = "group2", pos = { x = 1, y = 2 } },
        { groupName = "group1", pos = { x = 1, y = 2 } }
    })
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
              { unitName = "unitName1" },
              { unitName = "unitName2" }
          }
        }
    }
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {
        { name = "groupName",
          units = {
              { alt = 3, heading = 0, unitName = "unitName1", x = 1, y = 2 },
              { alt = 3, heading = 0, unitName = "unitName2", x = 1, y = 2 },
          }
        }
    })
end

function TestPersistence:testUpdateGroupDataRemovesDeadUnits()
    local groupData = {
        { name = "groupName",
          units = {
              { unitName = "unitName1" },
              { unitName = "deadUnit" }
          }
        }
    }
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {
        { name = "groupName",
          units = {
              { alt = 3, heading = 0, unitName = "unitName1", x = 1, y = 2 },
          }
        }
    })
end

function TestPersistence:testUpdateGroupDataRemovesGroupWithNoUnits()
    local groupData = { { name = "groupName", units = { { unitName = "deadUnit" } } } }
    persistence.updateGroupData(groupData)
    lu.assertEquals(groupData, {})
end

function TestPersistence:testSpawnGroup()
    local groupData = {
        ["country"] = "usa",
        ["coalitionId"] = 2,
        ["groupName"] = "CTLD_Tor 9A331_77 (Capt.Fdez)",
        ["units"] = {
            [1] = {
                ["alt"] = 5.0000045435017,
                ["heading"] = 2.7521738270529,
                ["y"] = 570413.97585701,
                ["x"] = -225602.16457669,
                ["speed"] = 0,
                ["unitName"] = "Unpacked Tor 9A331 #237",
                ["skill"] = "Excellent",
                ["type"] = "Tor 9A331", }
        },
        ["countryId"] = 2,
        ["timeAdded"] = 27000.091,
        ["name"] = "CTLD_Tor 9A331_77",
        ["category"] = "vehicle",
        ["coalition"] = "blue",
        ["startTime"] = 0,
        ["task"] = { },
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

    persistence.addGroupOwnership(ownership, "red", "Winston", "UAZ-469")
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
