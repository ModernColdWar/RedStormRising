local logging = require("logging")
local utils = require("utils")
local state = require("state")
local baseOwnershipCheck = require("baseOwnershipCheck")

local M = {}

local log = logging.Logger:new("BaseCapturedHandler")

function M.register()
    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.BaseCaptured)
    function M.eventHandler:OnEventBaseCaptured(event)
        self:I({ event = event })
        local baseName = event.PlaceName
        local capturingCoalition = event.IniCoalition
        if capturingCoalition == nil then
            capturingCoalition = AIRBASE.FindByName(baseName):GetCoalition()
            log:info("No IniCoalition on event, queried DCS for owner and got $1", capturingCoalition)
        end
        local sideName = utils.getSideName(capturingCoalition) --capturing side
        log:info("Base captured event for $1 captured by $2", baseName, sideName)
        --QUICK INITIAL CHECK: determines if base owner according to DCS differs from that according to RSR
        --mr: just because DCS EH = base owner changed doesn't mean base change according to RSR!
        local changedSide = state.checkBaseOwner(baseName, sideName)
        if changedSide == false then
            --false = no change in ownership
            log:info("Ignoring capture event for $1: no change of side ($2)", baseName, sideName)
            return
        end

        --[[
        -- mist.getUnitsInZones(unit_names, zone_names, zone_type) --need list of 'unit_names' first...
        -- ZONE_BASE:New(_triggerZone) --MOOSE: Adds zone to MOOSE system?
        -- ZONE_BASE.IsPointVec2InZone(_aircraft) -- MOOSE: Returns if a 2D point vector is within the zone
        --]]
        -- enumerate units within RSRbaseCaptureZones in-line with RSR radiuses
        if event.IniTypeName ~= nil then
            baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership("ALL", event.IniTypeName, false)
        else
            baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership("ALL", "none", false)
        end
        --baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership(baseName,"none",false)
        -- inefficient to check ALL bases given base known?  Should just pass base and update baseOwnershipCheck.lua for specific change

        --migrated to baseOwnershipCheck.lua
        --bases.configureForSide(baseName, sideName)
        --bases.resupply(baseName, sideName, rsrConfig)

    end
end

return M