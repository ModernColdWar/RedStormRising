local lu = require("luaunit")
require("dcs_stub")
require("mist_4_3_74")
require("CTLD")
rsr = {}
rsr.devMode = true

local handleMarkEvents = require("handleMarkEvents")

log = mist.Logger:new("TestHandleMarkEvents", "info")

TestMarkEvents = {}

function removeMarkWithText(text)
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = text,
        pos = { x = 1, y = 2, z = 3 }
    }
    handleMarkEvents.markRemoved(event)
end

function TestMarkEvents:setUp()
    dcsStub.reset()
end

function TestMarkEvents:testSpawnsCrate()
    removeMarkWithText("-crate 501")
    dcsStub.assertOneCallTo("coalition.addStaticObject")
end

function TestMarkEvents:testInvalidWeightDisplaysMessage()
    removeMarkWithText("-crate 123")
    dcsStub.assertOneCallTo("trigger.action.outText")
end

function TestMarkEvents:testOtherTextDoesNothing()
    removeMarkWithText("tis is my message")
    dcsStub.assertNoCalls()
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
