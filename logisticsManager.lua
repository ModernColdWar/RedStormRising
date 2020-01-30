require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName)
    log:info("Spawning Logistics Centre Static Object for $1 as owned by $2", baseName, sideName)
	log:info("ctld.logisticCentreZones: $1",ctld.logisticCentreZones)
    for _, logisticsZoneName in ipairs(ctld.logisticCentreZones) do
		--mr: edit to take into account incremantel names for logistics centre location randomization
		-- e.g. "MM75 RSRlogisticsZone 01", * = LUA string pattern match wildcard
        local zoneBaseName = utils.getBaseNameFromZoneName(logisticsZoneName, "rsrlogisticszone") --getBaseNameFromZoneName requires lowercase 
		
        if utils.matchesBaseName(baseName, zoneBaseName) then
            local country = sideName == "red" and country.id.RUSSIA or country.id.USA --should RUSSIA be country.id.AGGRESSORS (USAF Aggressors)?
            local point = ZONE:New(logisticsZoneName):GetPointVec2()
			--mr: add side to logistics centre name to allow static object to be neutral but be able to interogate name for coalition
            ctld.spawnLogisticsCentre(country, point, (baseName .. " Logistics Centre " .. string.upper(sideName)), utils.getSide(sideName)) --(_country, _point, _name, _coalition)
			-- ctld.spawnLogisticsCentre(country, point, logisticsZoneName, utils.getSide(sideName))
            log:info("Spawned $1 $2 Logistics Centre", sideName, logisticsZoneName)
            return
        end
    end
    log:warn("No logistics zone called for $1 found; no logistics building will spawn", baseName)
end

return M
