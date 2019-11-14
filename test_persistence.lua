local lu = require("luaunit")
require("dcs_stub")
local persistence = require("persistence")

TestPersistence = {}

local _getMistGroupData = persistence.getMistGroupData

function TestPersistence:setUp()
    persistence.spawnQueue = {}
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
    lu.assertEquals(persistence.getPersistentGroupData(), {
        { groupName = "group2", pos = { x = 1, y = 2 } },
        { groupName = "group1", pos = { x = 1, y = 2 } }
    })
end

function TestPersistence:testRemoveGroupAndUnitIds()
    local groupData = {
        [1] = {
            ["visible"] = false,
            ["name"] = "groupName",
            ["groupId"] = 1001,
            ["units"] = {
                [1] = {
                    ["x"] = 1,
                    ["y"] = 2,
                    ["name"] = "unitName",
                    ["unitId"] = 1002,
                }
            },
        }
    }

    persistence.removeGroupAndUnitIds(groupData)
    lu.assertEquals(groupData, {
        [1] = {
            ["visible"] = false,
            ["name"] = "groupName",
            ["units"] = {
                [1] = {
                    ["x"] = 1,
                    ["y"] = 2,
                    ["name"] = "unitName",
                }
            },
        }
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

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
