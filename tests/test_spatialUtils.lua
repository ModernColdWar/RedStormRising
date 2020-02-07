local lu = require("tests.luaunit")
local spatialUtils = require("spatialUtils")

TestSpatialUtils = {}

local function timeFunction(iterationCount, fn)
    local clockBefore = os.clock()
    for _ = 1, iterationCount do
        fn()
    end
    return os.clock() - clockBefore
end

function TestSpatialUtils:testIsPointInZone()
    lu.assertIsTrue(spatialUtils.isPointInZone({ x = 0, z = 0 }, { x = 0, z = 0 }, 100))
    lu.assertIsFalse(spatialUtils.isPointInZone({ x = 100, z = 100 }, { x = 0, z = 0 }, 100))
    lu.assertIsTrue(spatialUtils.isPointInZone({ x = 70.7, z = 70.7 }, { x = 0, z = 0 }, 100))
    lu.assertIsFalse(spatialUtils.isPointInZone({ x = 70.8, z = 70.8 }, { x = 0, z = 0 }, 100))
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

