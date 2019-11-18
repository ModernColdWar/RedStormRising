require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("PickupZoneManager", "info")

function setPickupZoneSide(pickupZone, sideName)
    local _zoneName = pickupZone[1]
    local ctldSide = sideName == "red" and 1 or 2
    log:info("Setting pickupZone " .. _zoneName .. " active only for " .. sideName)
    pickupZone[4] = 1 -- set active (defaults to not active) (this must be 1)
    pickupZone[5] = ctldSide
end

function M.getBaseNameFromZoneName(zoneName)
    local idx = zoneName:lower():find(" pickup")
    if idx == nil then
        return zoneName
    end
    return zoneName:sub(1, idx - 1)
end

function M.configurePickupZonesForBase(baseName, sideName)
    log:info("Configuring pickup zones for $1 as owned by $2", baseName, sideName)
    for _, pickupZone in ipairs(ctld.pickupZones) do
        local zoneBaseName = M.getBaseNameFromZoneName(pickupZone[1])
        if utils.matchesBaseName(baseName, zoneBaseName) then
            setPickupZoneSide(pickupZone, sideName)
        end
    end
end

return M
