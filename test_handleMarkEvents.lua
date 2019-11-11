local lu = require("luaunit")
dofile("dcs_stub.lua")
dofile("mist_4_3_74.lua")
dofile("CTLD.lua")
rsr = {}
rsr.devMode = true

dofile("handleMarkEvents.lua")

log = mist.Logger:new("TestHandleMarkEvents", "info")

TestMarkEvents = {}

function removeMarkWithText(text)
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = text,
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
end

function TestMarkEvents:setUp()
    dcsStub.reset()
end

function TestMarkEvents:testSpawnsCrate()
    removeMarkWithText("-crate 100")
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
