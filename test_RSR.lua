local lu = require("luaunit")

dofile("RSR.lua")

TestMarkRemoved = {}

function TestMarkRemoved:setUp()
    dcsStub.recordedCalls = {}
end

function TestMarkRemoved:testSpawnsCrate()
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = "-crate 100",
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
    dcsStub.assertOneCallTo("coalition.addStaticObject")
end

function TestMarkRemoved:testInvalidWeightDisplaysMessage()
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = "-crate 123",
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
    dcsStub.assertOneCallTo("trigger.action.outText")
end

function TestMarkRemoved:testOtherTextDoesNothing()
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = "this is my message",
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
    dcsStub.assertNoCalls()
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
