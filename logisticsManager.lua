require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName)
    log:info("Spawning Logistics Centre Static Object for $1 as owned by $2", baseName, sideName)
    for _, logisticsZoneName in ipairs(ctld.logisticCentreObjects) do
	
		--mr: edit to take into account incremantel names for logistics centre location randomization
        local zoneBaseName = utils.getBaseNameFromZoneName(logisticsZoneName, "RSRlogisticsZone") 
		
        if utils.matchesBaseName(baseName, zoneBaseName) then
            local country = sideName == "red" and country.id.RUSSIA or country.id.USA --should this be country.id.AGGRESSORS (USAF Aggressors)?
            local point = ZONE:New(logisticsZoneName):GetPointVec2()
			--mr: add side to logistics centre name to allow static object to be neutral but be able to interogate name for coalition
            ctld.spawnFOB(country, point, (logisticsZoneName .. " " .. string.upper(sideName)), utils.getSide(sideName)) --(_country, _point, _name, _coalition)
			-- ctld.spawnFOB(country, point, logisticsZoneName, utils.getSide(sideName))
            log:info("Spawned $1 $2 Logistics Centre", sideName, logisticsZoneName)
            return
        end
    end
    log:warn("No logistics zone called for $1 found; no logistics building will spawn", baseName)
end

return M
