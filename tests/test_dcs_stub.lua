local lu = require("tests.luaunit")
require("tests.dcs_stub")

TestDcsStub = {}

function TestDcsStub:testNewUnit()
    local u = Unit:new('unitname')
    lu.assertEquals(u:getName(), 'unitname')
    lu.assertIsTrue(u.active)
    lu.assertEquals(u:getLife(), 100)
    lu.assertEquals(u:inAir(), false)
end

function TestDcsStub:testUnitGetByName()
    local u = Unit.getByName('unitname')
    lu.assertEquals(u:getName(), 'unitname')
end

function TestDcsStub:testCallRecording()
    trigger.action.outText("Hello world")
    dcsStub.assertOneCallTo("trigger.action.outText")
end

function TestDcsStub:testGetTime()
    lu.assertIsTrue(timer.getTime() < 1)
end

function TestDcsStub:testSetTimeOffset()
    lu.assertIsTrue(timer.getTime() < 1)
    dcsStub.setTimeOffset(5)
    lu.assertIsTrue(timer.getTime() > 5)
    lu.assertIsTrue(timer.getTime() < 6)
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
