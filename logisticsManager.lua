require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName)
    log:info("Spawning logistics building for $1 as owned by $2", baseName, sideName)
    local country = sideName == "red" and country.id.RUSSIA or country.id.USA
    local spawnLogistics = SPAWNSTATIC:NewFromStatic("Logistics Template", country)
    local logisticsName = baseName .. " Logistics"
    local heading = ctld.logisticUnitsHeadings[logisticsName]
    local zone = ZONE:New(logisticsName)
    log:info("Spawning logistics building $1 with heading $2 for $3", logisticsName, heading, sideName)
    spawnLogistics:SpawnFromZone(zone, heading, logisticsName)
end

return M
