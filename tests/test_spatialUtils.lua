local lu = require("tests.luaunit")
local spatialUtils = require("spatialUtils")

TestSpatialUtils = {}

--local function timeFunction(iterationCount, fn)
--    local clockBefore = os.clock()
--    for _ = 1, iterationCount do
--        fn()
--    end
--    return os.clock() - clockBefore
--end

function TestSpatialUtils:testIsPointInZone()
    lu.assertIsTrue(spatialUtils.isPointInZone({ x = 0, y = 0 }, { x = 0, y = 0 }, 100))
    lu.assertIsFalse(spatialUtils.isPointInZone({ x = 100, y = 100 }, { x = 0, y = 0 }, 100))
    lu.assertIsTrue(spatialUtils.isPointInZone({ x = 70.7, y = 70.7 }, { x = 0, y = 0 }, 100))
    lu.assertIsFalse(spatialUtils.isPointInZone({ x = 70.8, y = 70.8 }, { x = 0, y = 0 }, 100))
end

function TestSpatialUtils:testFindNearest()
    local points = { { x = 0, y = 0 }, { x = 1, y = 1 }, { x = 2, y = 2 } }

    local idx, minDist = spatialUtils.findNearest({ x = -1, y = -1 }, points)
    lu.assertEquals(idx, 1)
    lu.assertAlmostEquals(minDist, 1.414, 0.001)

    idx, minDist = spatialUtils.findNearest({ x = 0.4, y = 0.4 }, points)
    lu.assertEquals(idx, 1)
    lu.assertAlmostEquals(minDist, 0.566, 0.001)

    -- matches first found
    idx, minDist = spatialUtils.findNearest({ x = 0.5, y = 0.5 }, points)
    lu.assertEquals(idx, 1)
    lu.assertAlmostEquals(minDist, 0.707, 0.001)

    idx, minDist = spatialUtils.findNearest({ x = 0.9, y = 0.9 }, points)
    lu.assertEquals(idx, 2)
    lu.assertAlmostEquals(minDist, 0.1414, 0.001)

    idx, minDist = spatialUtils.findNearest({ x = 0, y = 0 }, {})
    lu.assertIsNil(idx)
    lu.assertIsNil(minDist)
end

local runner = lu.LuaUnit.new()
os.exit(runner:runSuite())

