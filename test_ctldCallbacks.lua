local lu = require("luaunit")
dofile("RSR.lua")

TestCtldCallbacks = {}

function TestCtldCallbacks:testUnpack()
    ctld.processCallback({ action = "unpack", spawnedGroup = Group.getByName("spawned")})
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())
