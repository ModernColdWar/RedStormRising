require("tests.dcs_stub")
require("mist_4_3_74")
local missionUtils = require("missionUtils")

local M = {}

local log = mist.Logger:new("CTLDUtils", "info")

function M.getLogisticUnits(mission)
    local zones = missionUtils.getZoneNames(mission, " logistics$")
    log:info("Logistics zones in mission are $1", mist.utils.oneLineSerialize(zones))
    return zones
end

function M.getPickupZones(mission)
    local zones = missionUtils.getZoneNames(mission, " pickup$")
    log:info("Pickup zones in mission are $1", mist.utils.oneLineSerialize(zones))
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
                table.insert(transportPilotNames, unit.name)
            end
        end
    end)
    table.sort(transportPilotNames)
    log:info("Transport pilot names are are $1", mist.utils.oneLineSerialize(transportPilotNames))
    return transportPilotNames
end

return M