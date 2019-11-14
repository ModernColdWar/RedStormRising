local lu = require("luaunit")
require("dcs_stub")
local persistence = require("persistence")

TestPersistence = {}

function TestPersistence:setUp()
    persistence.spawnQueue = {}
end

function TestPersistence:testPushSpawnQueue()
    lu.assertEquals(persistence.spawnQueue, {})
    persistence.pushSpawnQueue("group1")
    persistence.pushSpawnQueue("group2")
    lu.assertEquals(persistence.spawnQueue, { "group1", "group2"})
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

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
