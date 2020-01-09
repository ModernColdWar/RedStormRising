local lu = require("tests.luaunit")
require("tests.dcs_stub")
local queryDcs = require("queryDcs")
local state = require("state")

TestState = {}

local _getGroupData = state.getGroupData
local _getAllBaseOwnershipFromDcs = state.getAllBaseOwnershipFromDcs

function TestState:setUp()
    -- reset state
    state.currentState = mist.utils.deepCopy(state.defaultState)
    state.spawnQueue = {}
    state.currentState.baseOwnership = {}
end

function TestState:tearDown()
    state.getGroupData = _getGroupData
    state.getAllBaseOwnershipFromDcs = _getAllBaseOwnershipFromDcs
end

local function stubDcsBaseOwnership(baseOwnership)
    state.getAllBaseOwnershipFromDcs = function()
        return baseOwnership
    end
end

function TestState:testPushSpawnQueue()
    lu.assertEquals(state.spawnQueue, {})
    state.pushSpawnQueue("group1")
    state.pushSpawnQueue("group2")
    lu.assertEquals(state.spawnQueue, { "group1", "group2" })
end

function TestState:testHandleSpawnQueueLeavesItemsInQueueIfNoGroupDataFromDcs()
    state.getGroupData = function(groupName)
        return nil
    end
    state.pushSpawnQueue("group1")
    state.pushSpawnQueue("group2")
    state.handleSpawnQueue()

    lu.assertEquals(state.spawnQueue, { "group1", "group2" })
end

function TestState:testHandleSpawnQueuePutsGroupDataIntoStateAndRemovesFromQueue()
    state.getGroupData = function(groupName)
        return { groupName = groupName, pos = { x = 1, y = 2 } }
    end
    state.pushSpawnQueue("group1")
    state.pushSpawnQueue("group2")
    state.handleSpawnQueue()

    lu.assertEquals(state.spawnQueue, {})
    lu.assertEquals(state.currentState.persistentGroupData, {
        { groupName = "group2", pos = { x = 1, y = 2 } },
        { groupName = "group1", pos = { x = 1, y = 2 } }
    })
end

function TestState:testRemoveGroupAndUnitIds()
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

    state.removeGroupAndUnitIds(groupData)
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

function TestState:testReadStateFromDisk()
    local _state = state.readStateFromDisk([[tests\test_state.json]])
    lu.assertEquals(_state.ctld.nextGroupId, 188)
    lu.assertEquals(_state.ctld.nextUnitId, 848)
end

function TestState:testReadCorruptStateFromDiskReturnsNil()
    local _state = state.readStateFromDisk([[tests\test_state_corrupt.json]])
    lu.assertIsNil(_state)
end

function TestState:testWriteStateToDisk()
    -- we're going to write the default state here
    local expectedState = state.defaultState
    local filename = os.tmpname()
    state.writeStateToDisk(filename)
    local actualState = state.readStateFromDisk(filename)
    lu.assertEquals(actualState, expectedState)
    os.remove(filename)
end

function TestState:testCopyToCtld()
    state.currentState.ctld.nextGroupId = 11
    state.currentState.ctld.nextUnitId = 22
    state.copyToCtld()
    lu.assertEquals(ctld.nextGroupId, 11)
    lu.assertEquals(ctld.nextUnitId, 22)
end

function TestState:testCopyFomCtld()
    ctld.nextGroupId = 111
    ctld.nextUnitId = 222
    state.copyFromCtld()
    lu.assertEquals(ctld.nextGroupId, 111)
    lu.assertEquals(ctld.nextUnitId, 222)
end

function TestState:testGetOwner()
    lu.assertIsNil(state.getOwner("foo"))
    state.currentState.baseOwnership = { airbases = { red = { "foo" } } }
    lu.assertEquals(state.getOwner("foo"), "red")
end

function TestState:testUpdateBaseOwnershipFirstTime()
    state.currentState.baseOwnership = nil
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi" }, red = { "Vaziani" } } })
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, { airbases = { blue = { "Sochi" }, red = { "Vaziani" } } })
end

function TestState:testSetBaseOwnerAirbaseChanged()
    state.currentState.baseOwnership = {
        airbases = { blue = { "Guduata" }, neutral = {}, red = { "A", "B" } },
        farps = { blue = {}, neutral = {}, red = {} } }

    lu.assertIsTrue(state.setBaseOwner("Guduata", "red"))

    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { blue = { }, neutral = {}, red = { "A", "B", "Guduata" } },
        farps = { blue = {}, neutral = {}, red = {} } })

    -- second event has no effect
    lu.assertIsFalse(state.setBaseOwner("Guduata", "red"))
end

function TestState:testSetBaseOwnerFarpChanged()
    state.currentState.baseOwnership = {
        airbases = { blue = { }, neutral = {}, red = {} },
        farps = { blue = {}, neutral = {}, red = { "Guduata", "Kutaisi" } } }

    lu.assertIsTrue(state.setBaseOwner("Guduata", "blue"))

    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { blue = { }, neutral = {}, red = {} },
        farps = { blue = { "Guduata" }, neutral = {}, red = { "Kutaisi" } } })
end

function TestState:testSetBaseOwnerNoChange()
    state.currentState.baseOwnership = {
        airbases = { blue = { }, neutral = {}, red = {} },
        farps = { blue = {}, neutral = {}, red = { "Guduata", "Kutaisi" } } }

    lu.assertIsFalse(state.setBaseOwner("Guduata", "red"))

    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { blue = { }, neutral = {}, red = {} },
        farps = { blue = { }, neutral = {}, red = { "Guduata", "Kutaisi" } } })
end

function TestState:testSetCurrentStateFromFileWithNoFileLoadsBaseOwnershipFromDcs()
    state.setCurrentStateFromFile([[filedoesnotexist.json]])
    local expectedState = mist.utils.deepCopy(state.defaultState)
    expectedState.baseOwnership = queryDcs.getAllBaseOwnership()
    lu.assertEquals(state.currentState, expectedState)
    lu.assertEquals(#state.currentState.persistentGroupData, 0)
end

function TestState:testSetCurrentStateFromFile()
    state.setCurrentStateFromFile([[tests\test_state.json]])
    lu.assertEquals(state.currentState.ctld.nextGroupId, 188)
    lu.assertEquals(state.currentState.ctld.nextUnitId, 848)
    lu.assertEquals(#state.currentState.baseOwnership.airbases.red, 3)
    lu.assertEquals(#state.currentState.baseOwnership.airbases.blue, 4)
    lu.assertEquals(#state.currentState.baseOwnership.farps.red, 0)
    lu.assertEquals(#state.currentState.baseOwnership.farps.blue, 2)
    lu.assertEquals(#state.currentState.persistentGroupData, 1)
end

function TestState:testWinnerNoOwnership()
    state.currentState.baseOwnership = queryDcs.getAllBaseOwnership()
    lu.assertIsNil(state.getWinner())
end

function TestState:testWinnerWasNeutral()
    state.currentState.baseOwnership = { airbases = { red = { "A" }, blue = {}, neutral = { "B" } } }
    lu.assertIsNil(state.getWinner())
end

function TestState:testWinnerWithMixedOwnership()
    state.currentState.baseOwnership = { airbases = { red = { "A" }, blue = { "B" }, neutral = {} } }
    lu.assertIsNil(state.getWinner())
end

function TestState:testWinnerRed()
    state.currentState.baseOwnership = { airbases = { red = { "A", "B" }, blue = {}, neutral = {} } }
    lu.assertEquals(state.getWinner(), "red")
end

function TestState:testWinnerBlue()
    state.currentState.baseOwnership = { airbases = { red = {}, blue = { "A", "B" }, neutral = {} } }
    lu.assertEquals(state.getWinner(), "blue")
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

