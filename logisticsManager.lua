local logging = require("logging")
local utils = require("utils")

local M = {}

local log = logging.Logger:new("LogisticsManager")

function M.spawnLogisticsBuildingForBase(baseName, sideName, logisticsCentreName, isMissionInit, constructingPlayerName)

    local _playerName = "none"
    if constructingPlayerName ~= "none" then
        _playerName = constructingPlayerName
    end

    log:info("Spawning Logistics Centre Static Object for $1 as owned by $2.  _playerName: $3", baseName, sideName, _playerName)
    --log:info("ctld.logisticCentreZones: $1",ctld.logisticCentreZones)
    local _availLogiZones = {}
    for _, logisticsZoneName in ipairs(ctld.logisticCentreZones) do
        local zoneBaseName = utils.getBaseNameFromZoneName(logisticsZoneName, string.lower("RSRlogisticsZone")) --getBaseNameFromZoneName requires lowercase
        if utils.matchesBaseName(baseName, zoneBaseName) then
            table.insert(_availLogiZones, logisticsZoneName)
        end
    end

    -- logistics centre built at mission start are not numbered e.g. "MM34 Logistics Centre red"
    -- logistics centre built during mission are numbered e.g. "MM75 Logistics Centre #001 red".  Number set by ctld.getNextUnitId() in CTLD.lua.
    local _staticObjectName = baseName .. " Logistics Centre #000 " .. string.lower(sideName)
    if logisticsCentreName ~= "none" then
        _staticObjectName = logisticsCentreName
    end
    log:info("Logistics Centre Name: $1", _staticObjectName)
    local _availLogiZonesCount = #_availLogiZones
    if _availLogiZonesCount > 0 then
        -- math.randomseed(os.clock()) --not avail or needed: https://forums.eagle.ru/showthread.php?t=101098
        local _randomLogiZoneNumber = 1
        if _availLogiZonesCount > 1 then
            _randomLogiZoneNumber = math.random(1, _availLogiZonesCount)
        end
        --log:info("Base: $1, availLogiZonesCount: $2, randomLogiZoneNumber: $3", baseName,_availLogiZonesCount,_randomLogiZoneNumber)
        local _selectedLogiZoneName = _availLogiZones[_randomLogiZoneNumber]
        local _position = trigger.misc.getZone(_selectedLogiZoneName)
        log:info("isMissionInit: $1", isMissionInit)
        --(_point, _name, _coalition, _baseORfarp, _baseORfarpName)
        ctld.spawnLogisticsCentre(_position.point, _staticObjectName, sideName, "BASE", baseName, isMissionInit, _playerName)
        log:info("$1 Logistics Centre spawned at $2", sideName, _selectedLogiZoneName)
        return
    end
    log:warn("No logistics zone called for $1 found; no logistics building will spawn", baseName)

end

return M
