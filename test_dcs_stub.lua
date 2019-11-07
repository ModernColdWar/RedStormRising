local lu = require("luaunit")
dofile("dcs_stub.lua")

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

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
