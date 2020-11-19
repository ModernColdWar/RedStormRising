local logging = require("logging")
local utils = require("utils")

local M = {}

local log = logging.Logger:new("PickupZoneManager", "info")

local function setPickupZoneSide(pickupZone, sideName)
    local _zoneName = pickupZone[1]
    local ctldSide = sideName == "red" and 1 or 2
    log:info("Setting pickupZone " .. _zoneName .. " active only for " .. sideName)
    pickupZone[4] = 1 -- set active (defaults to not active) (this must be 1)
    pickupZone[5] = ctldSide
end

function M.configurePickupZonesForBase(baseName, sideName)
    log:info("Configuring pickup zones for $1 as owned by $2", baseName, sideName)
    local foundZone = false
    for _, pickupZone in ipairs(ctld.pickupZones) do
        local zoneBaseName = utils.getBaseNameFromZoneName(pickupZone[1], "pickup")
        if utils.matchesBaseName(baseName, zoneBaseName) then
            setPickupZoneSide(pickupZone, sideName)
            foundZone = true
        end
    end
    if not foundZone then
        log:warn("No pickup zone for $1 found; no pickup at this base will be possible", baseName)
    end
end

return M
