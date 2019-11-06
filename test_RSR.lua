local lu = require("luaunit")

dofile("RSR.lua")

function test_markRemoved_addsCrate()
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = "-crate 100",
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
end

function test_markRemoved_withInvalidWeight_displaysMessage()
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = "-crate 123",
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
end

function test_markRemoved_withOtherTextDoesNothing()
    event = {
        id = world.event.S_EVENT_MARK_REMOVED,
        text = "this is my message",
        pos = { x = 1, y = 2, z = 3 }
    }
    markRemoved(event)
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
