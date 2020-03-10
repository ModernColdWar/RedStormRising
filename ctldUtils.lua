require("mist_4_3_74")
local inspect = require("inspect")
local missionUtils = require("missionUtils")

local M = {}

local log = mist.Logger:new("CTLDUtils", "info")

function M.getLogisticCentreZones(mission)
    --mr: edit to take into account incrementel zone names for logistics centre location randomization e.g. "MM75 RSRlogisticsZone 02"
    -- * = LUA string pattern match wildcard should work with missionUtils.getZoneNames() as function uses string.match
    local zones = missionUtils.getZoneNames(mission, string.lower("RSRlogisticsZone")) --getZoneNames fucntion requires lowercase
    --log:info("RSRlogisticsZone zones in mission are $1", inspect(zones))
    return zones
end

function M.getRSRbaseCaptureZones (mission)
    -- DCS getZone function only returns zone position and radius based on name, therefore store complete zone details i.e. color
    local _bCzones = missionUtils.getZones(mission, string.lower("RSRbaseCaptureZone")) --getZoneNames function requires lowercase
    local RSRbaseCaptureZoneNames = {}
    for _, _z in ipairs(_bCzones) do
        table.insert(RSRbaseCaptureZoneNames, _z)
    end
    --log:info("RSRbaseCaptureZone names (not reporting other zone details) in mission are $1", inspect(RSRbaseCaptureZoneNames))
    return _bCzones
end

function M.getRSRcarrierActivateZones (mission)
    -- DCS getZone function only returns zone position and radius based on name, therefore store complete zone details i.e. color
    local _cAzones = missionUtils.getZones(mission, string.lower("RSRcarrierActivateZone")) --getZoneNames function requires lowercase
    local RSRcarrierActivateZoneNames = {}
    for _, _z in ipairs(_cAzones) do
        table.insert(RSRcarrierActivateZoneNames, _z)
    end
    --log:info("RSRcarrierActivateZone names (not reporting other zone details) in mission are $1", inspect(RSRcarrierActivateZoneNames))
    return _cAzones
end

function M.getPickupZones(mission)
    local zones = missionUtils.getZoneNames(mission, " pickup$")
    log:info("Pickup zones in mission are $1", inspect(zones))
    local pickupZones = {}
    for _, zone in ipairs(zones) do
        table.insert(pickupZones, { zone, "none", -1, "no", 0 })
    end
    return pickupZones
end

function M.getTransportPilotNames(mission)
    local transportPilotNames = {}
    missionUtils.iterGroups(mission, function(group)
        if missionUtils.isClientGroup(group) then
            local unit = group.units[1]
            if missionUtils.isTransportType(unit.type) then
                table.insert(transportPilotNames, env.getValueDictByKey(unit.name))
            end
        end
    end)
    table.sort(transportPilotNames)
    log:info("Transport pilot names are are $1", inspect(transportPilotNames))
    return transportPilotNames
end

return M