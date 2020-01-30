require("mist_4_3_74")
local bases = require("bases")
local utils = require("utils")
local state = require("state")  --mr: redirect baseCapturedHandler.lua to baseOwnershipCheck.lua and make this obsolete
-- local rsrConfig = require("RSR_config")

local M = {}

local log = mist.Logger:new("BaseCapturedHandler", "info")

--[[
	RECONFIGURE CAPTURE FLOW SCRIPTS
	state.lua: initiates baseOwnersip query only for campaign start or persistance
	baseOwnershipCheck.lua: baseOwnersip campaign setup and side owner in relation to command centre owernship or presence + capture messages
	baseCapturedHandler.lua: DCS EH = RSR radius checks = initate baseOwnershipCheck.lua
	
	feature? consider adding ~10min LOCKDOWN to prevent fast capture-recapture problems = base added to LOCKDOWN global array upon capture
--]]

function M.register()
    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.BaseCaptured)
    function M.eventHandler:OnEventBaseCaptured(event)
        self:I({ event = event })
        local baseName = event.PlaceName
        local sideName = utils.getSideName(event.IniCoalition)
        log:info("DCS baseCapturedHandler = $1 captured by $2", baseName, sideName)
		
        local changedSide = state.checkBaseOwner(baseName, sideName) --mr: redirect baseCapturedHandler.lua to baseOwnershipCheck.lua and make this obsolete
        if changedSide == false then
            log:info("Ignoring capture event for $1: no change of side ($2)", baseName, sideName)
            return
        end
		
		--[[
		-- mist.getUnitsInZones(unit_names, zone_names, zone_type) --need list of 'unit_names' first...
		-- ZONE_BASE:New(_triggerZone) --MOOSE: Adds zone to MOOSE system?
		-- ZONE_BASE.IsPointVec2InZone(_aircraft) -- MOOSE: Returns if a 2D point vector is within the zone
		-- enumerate units within RSRbaseCaptureZones in-line with RSR radiuses
		
		
		
		
		--]]
		
		-- baseOwner check: baseCapturedHandle.lua -> state.lua -> baseOwnershipCheck.lua = all base side setting and capture messages
		--[[
        local message = baseName .. " has been captured by a " .. sideName .. " " .. event.IniTypeName
        self:I(message)
        trigger.action.outText(message, 10)
		--]]
		
		--migrated to baseOwnershipCheck.lua
		--[[
        bases.configureForSide(baseName, sideName)
        bases.resupply(baseName, sideName, rsrConfig)
		--]]
    end
end

return M