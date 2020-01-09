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

function TestState:testUpdateBaseOwnershipChangingSides()
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi" }, red = { "Vaziani" }, neutral = {}} })
    state.updateBaseOwnership()
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi", "Vaziani" }, red = { }, neutral = {} } })
    state.updateBaseOwnership()

    lu.assertEquals(state.currentState.baseOwnership.airbases, { blue = { "Sochi", "Vaziani" }, neutral = {}, red = { } })
end

function TestState:testUpdateBaseOwnershipNeutralFirstTimeNeutralIsRespected()
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi" }, red = { "Vaziani" }, neutral = { "Batumi" } } })
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership.airbases,
            { blue = { "Sochi" }, red = { "Vaziani" }, neutral = { "Batumi" } })

    -- Batumi neutral -> red
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi" }, red = { "Vaziani", "Batumi" }, neutral = { } } })
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership.airbases,
            { blue = { "Sochi" }, red = { "Batumi", "Vaziani" }, neutral = { } })
end

function TestState:testUpdateBaseOwnershipGoingToNeutralFromCapturedIsIgnored()
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi" }, red = { "Vaziani" }, neutral = { } } })
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership.airbases,
            { blue = { "Sochi" }, red = { "Vaziani" }, neutral = { } })

    -- Vaziani red -> neutral
    stubDcsBaseOwnership({ airbases = { blue = { "Sochi" }, red = { }, neutral = { "Vaziani" } } })
    state.updateBaseOwnership()
    -- keeps Vaziani as red
    lu.assertEquals(state.currentState.baseOwnership.airbases,
            { blue = { "Sochi" }, red = { "Vaziani" }, neutral = { } })
end

function TestState:testUpdateBaseOwnershipWithLotsOfData()
    local baseOwnership1 = {
        airbases = { red = { "AB1", "AB2", "AB3" }, blue = { "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F2" }, blue = { "F3", "F4" }, neutral = {} }
    }

    stubDcsBaseOwnership(baseOwnership1)
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, baseOwnership1)

    -- AB2, F2, F3 and F4 go neutral - no change to their state
    -- AB3 goes from red to blue
    local baseOwnership2 = {
        airbases = { red = { "AB1" }, blue = { "AB3", "AB4", "AB5", "AB6" }, neutral = { "AB2" } },
        farps = { red = { "F1" }, blue = {}, neutral = { "F2", "F3", "F4" } }
    }
    stubDcsBaseOwnership(baseOwnership2)
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { red = { "AB1", "AB2" }, blue = { "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F2" }, blue = { "F3", "F4" }, neutral = {} }
    })

    -- AB2, F2, F4 go neutral to blue
    local baseOwnership3 = {
        airbases = { red = { "AB1" }, blue = { "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1" }, blue = { "F2", "F4" }, neutral = { "F3" } }
    }
    stubDcsBaseOwnership(baseOwnership3)
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { red = { "AB1" }, blue = { "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1" }, blue = { "F2", "F3", "F4" }, neutral = {} }
    })

    -- F3 goes neutral to red
    local baseOwnership4 = {
        airbases = { red = { "AB1" }, blue = { "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F3" }, blue = { "F2", "F4" }, neutral = {} }
    }
    stubDcsBaseOwnership(baseOwnership4)
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { red = { "AB1" }, blue = { "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F3" }, blue = { "F2", "F4" }, neutral = {} }
    })

    -- All airbases to blue, all FARPS to red
    local baseOwnership5 = {
        airbases = { red = {}, blue = { "AB1", "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F2", "F3", "F4" }, blue = {}, neutral = {} }
    }
    stubDcsBaseOwnership(baseOwnership5)
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { red = {}, blue = { "AB1", "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F2", "F3", "F4" }, blue = {}, neutral = {} }
    })

    -- Everything goes neutral; no change in state
    local baseOwnership6 = {
        airbases = { red = {}, blue = {}, neutral = {"AB1", "AB2", "AB3", "AB4", "AB5", "AB6" } },
        farps = { red = { }, blue = {}, neutral = {"F1", "F2", "F3", "F4" } }
    }
    stubDcsBaseOwnership(baseOwnership6)
    state.updateBaseOwnership()
    lu.assertEquals(state.currentState.baseOwnership, {
        airbases = { red = {}, blue = { "AB1", "AB2", "AB3", "AB4", "AB5", "AB6" }, neutral = {} },
        farps = { red = { "F1", "F2", "F3", "F4" }, blue = {}, neutral = {} }
    })
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

