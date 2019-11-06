local lu = require("luaunit")

dofile("RSR.lua")

TestMarkRemoved = {}

function removeMarkWithText(text)
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = text,
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
end

function TestMarkRemoved:setUp()
    dcsStub.recordedCalls = {}
end

function TestMarkRemoved:testSpawnsCrate()
    removeMarkWithText("-crate 100")
    dcsStub.assertOneCallTo("coalition.addStaticObject")
end

function TestMarkRemoved:testInvalidWeightDisplaysMessage()
    removeMarkWithText("-crate 123")
    dcsStub.assertOneCallTo("trigger.action.outText")
end

function TestMarkRemoved:testOtherTextDoesNothing()
    removeMarkWithText("tis is my message")
    dcsStub.assertNoCalls()
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
