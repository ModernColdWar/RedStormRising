require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName)
    log:info("Spawning FOB building for $1 as owned by $2", baseName, sideName)
    for _, logisticsZoneName in ipairs(ctld.logisticUnits) do
        local zoneBaseName = utils.getBaseNameFromZoneName(logisticsZoneName, "logistics")
        if utils.matchesBaseName(baseName, zoneBaseName) then
            local country = sideName == "red" and country.id.RUSSIA or country.id.USA
            local point = ZONE:New(logisticsZoneName):GetPointVec2()
            ctld.spawnFOB(country, nil, point, logisticsZoneName, utils.getSide(sideName))
            log:info("Spawned $1 $2 FOB", sideName, logisticsZoneName)
            return
        end
    end
    log:warn("No logistics zone called for $1 found; no logistics building will spawn", baseName)
end

return M
