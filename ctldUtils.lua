require("mist_4_3_74")
local inspect = require("inspect")
local missionUtils = require("missionUtils")

local M = {}

local log = mist.Logger:new("CTLDUtils", "info")

function M.getLogisticCentreObjects(mission)
	--mr: edit to take into account incremantel names for logistics centre location randomization
    local zones = missionUtils.getZoneNames(mission, " RSRlogisticsZone$")
    log:info("RSRlogisticsZone zones in mission are $1", inspect(zones))
    return zones
end

function M.getRSRbaseCaptureZones (mission)
    local _bCzones = missionUtils.getZoneNames(mission, " RSRbaseCaptureZone")
    log:info("RSRbaseCaptureZone zones in mission are $1", inspect(zones))
    local RSRbaseCaptureZones = {}
    for _k, _z in ipairs(_bCzones) do
        table.insert(RSRbaseCaptureZones, _z)
    end
    return RSRbaseCaptureZones
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