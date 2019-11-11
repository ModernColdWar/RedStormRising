local lu = require("luaunit")
require("dcs_stub")
require("mist_4_3_74")

TestDcsStub = {}

function TestDcsStub:setUp()
    dcsStub.reset()
end

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

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
