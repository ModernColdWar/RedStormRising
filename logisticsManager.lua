require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("LogisticsManager", "info")

function M.spawnLogisticsBuildingForBase(baseName, sideName, logisticsCentreName)
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
	
	-- logistics centre built at mission start are not numbered e.g. "MM34 Logistics Centre red"
	-- logistics centre built during mission are numbered e.g. "MM75 Logistics Centre #001 red".  Number set by ctld.getNextUnitId() in CTLD.lua.
	local _staticObjectName = baseName .. " Logistics Centre " .. string.upper(sideName)
	if logisticsCentreName ~= nil then
		_staticObjectName = logisticsCentreName
	end
	
	_availLogiZonesCount = #_availLogiZones
	if _availLogiZonesCount > 0 then
		-- math.randomseed(os.clock()) --not avail or needed: https://forums.eagle.ru/showthread.php?t=101098
		local _randomLogiZoneNumber = 1
		if _availLogiZonesCount > 1 then 
			 = math.random (1, _availLogiZonesCount)
		end
		local _selectedLogiZone = _availLogiZones[_randomLogiZoneNumber]
		local point = ZONE:New(_selectedLogiZone):GetPointVec2()
		--(_point, _name, _coalition, _baseORfarp, _baseORfarpName)
		ctld.spawnLogisticsCentre(point, _staticObjectName, utils.getSide(sideName), "BASE", baseName) 
		log:info("$1 Logistics Centre spawned at $2", sideName, _selectedLogiZone)
		return
	end
	
    log:warn("No logistics zone called for $1 found; no logistics building will spawn", baseName)
end

return M
