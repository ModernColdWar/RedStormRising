require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName)
    log:info("Spawning FOB building for $1 as owned by $2", baseName, sideName)
    local country = sideName == "red" and country.id.RUSSIA or country.id.USA
    local logisticsName = baseName .. " Logistics"
    local heading = ctld.logisticUnitsHeadings[logisticsName]
    local point = ZONE:New(logisticsName):GetPointVec2()
    ctld.spawnFOB(country, nil, point, logisticsName, heading)
    log:info("Spawned $1 $2 FOB", sideName, logisticsName)
end

return M
