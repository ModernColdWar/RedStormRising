require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName)
    log:info("Spawning Logistics Centre Static Object for $1 as owned by $2", baseName, sideName)
	log:info("ctld.logisticCentreZones: $1",ctld.logisticCentreZones)
	local _availLogiZones = {}
	local _availLogiZonesCount = 0
    for _k, logisticsZoneName in ipairs(ctld.logisticCentreZones) do
        local zoneBaseName = utils.getBaseNameFromZoneName(logisticsZoneName, string.lower("RSRlogisticsZone")) --getBaseNameFromZoneName requires lowercase 
        if utils.matchesBaseName(baseName, zoneBaseName) then
			table.insert(_availLogiZones,logisticsZoneName)
        end
    end
	_availLogiZonesCount = #_availLogiZones
	if _availLogiZonesCount > 0 then
		-- math.randomseed(os.clock()) --not avail or needed: https://forums.eagle.ru/showthread.php?t=101098
		local _randomLogiZoneNumber = math.random (1, _availLogiZonesCount)
		local _selectedLogiZone = _availLogiZones[_randomLogiZoneNumber]
		local country = sideName == "red" and country.id.RUSSIA or country.id.USA --should RUSSIA be country.id.AGGRESSORS (USAF Aggressors)?
		local point = ZONE:New(_selectedLogiZone):GetPointVec2()
		--mr: add side to logistics centre name to allow static object to be neutral but be able to interogate name for coalition
		--(_country, _point, _name, _coalition)
		ctld.spawnLogisticsCentre(country, point, (baseName .. " Logistics Centre " .. string.upper(sideName)), utils.getSide(sideName)) 
		log:info("$1 Logistics Centre spawned at $2", sideName, _selectedLogiZone)
		return
	end
	
    log:warn("No logistics zone called for $1 found; no logistics building will spawn", baseName)
end

return M
