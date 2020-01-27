require ("Moose")
local inspect = require("inspect")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")

local _firstTimeSetup = false

function M.getAllBaseOwnership(_firstTimeSetup)
    local baseOwnership = { Airbases = { red = {}, blue = {}, neutral = {} },
                            FOBs = { red = {}, blue = {}, neutral = {} } }

	--mr: intercept first time campaign setup here to read FOB ownership from Trigger Zone Name or Color
	if _firstTimeSetup then

		--mr: assign by Trigger Zone color, i.e.  RGB values 0 to 1: [1,0,0] = red, [0,1,0] = green (netural), [0,0,1] = blue
		for _k, _anyZone in ipairs(env.mission.triggers.zones) do
			local _RSRbaseCaptureZoneNameContains = "RSRbaseCaptureZone" --mr: combined use of "RSRbaseCaptureZone" Trigger Zones for inZone checks
			local _zoneName = _anyZone.name
			if string.match(_zoneName, _RSRbaseCaptureZoneNameContains) then
			
				local _RSRbaseCaptureZoneName = string.match(_zoneName,("^%w+")) --"MM75 RSRbaseCaptureZone FOB" = "MM75"
				local _baseType = string.match(_zoneName,("%w+$")) --"MM75 RSRbaseCaptureZone FOB" = "FOB"
				
				if _baseType == nil then
					log:error("RSR MIZ SETUP: $1 RSRbaseCaptureZone Trigger Zone name does not contain 'Airbase' or 'FOB' e.g. 'MM75 RSRbaseCaptureZone FOB'",_RSRbaseCaptureZoneName)
				else
					local _baseTypes = _baseType .."s"
				end
				
				local _zoneColor = _anyZone.color
				local _baseSide = "ERROR"
				local _whiteInitZoneCheck = 0
				if _zoneColor[1] == 1 then 
					_baseSide = "red" 
					_whiteInitZoneCheck = _whiteInitZoneCheck + 1
				elseif _zoneColor[3] == 1 then 
					_baseSide = "blue"
					_whiteInitZoneCheck = _whiteInitZoneCheck + 1
				elseif _zoneColor[2] == 1 then --green
					_baseSide = "neutral"
					_whiteInitZoneCheck = _whiteInitZoneCheck + 1
				end
				
				if _baseSide == "ERROR" then
					if _whiteInitZoneCheck == 3 then
						log:error("RSR MIZ SETUP: $1 $2 Trigger Zone color not changed from white. Setting as neutral",_RSRbaseCaptureZoneName, _RSRbaseCaptureZoneNameContains)
					elseif _whiteInitZoneCheck > 1 then
						log:error("RSR MIZ SETUP: $1 $2 Trigger Zone color not correctly set to only red, blue or green. Setting as neutral",_RSRbaseCaptureZoneName, _RSRbaseCaptureZoneNameContains)
					end
					_baseSide = "neutral"
				end
				
				table.insert(baseOwnership._baseTypes[_baseSide], _RSRbaseCaptureZoneName)
			end
		end
	else
		--[[
			RECONFIGURE CAPTURE FLOW SCRIPTS
			state.lua: initiates baseOwnersip query only for campaign start or persistance
			baseOwnershipCheck.lua: baseOwnersip campaign setup and side owner in relation to command centre owernship or presence + capture messages
			baseCapturedHandler.lua: DCS EH = RSR radius checks = initate baseOwnershipCheck.lua
			
			feature? consider adding ~10min LOCKDOWN to prevent fast capture-recapture problems = base added to LOCKDOWN global array upon capture
		--]]
		
		for _, base in ipairs(AIRBASE.GetAllAirbases()) do
			local baseName = base:GetName()
			local DCScoalition = base:GetCoalition()
			local DCSsideName = utils.getDCSsideName(DCScoalition)
			if DCSsideName == nil then
				log:info("No side returned for $1; setting to neutral", baseName)
				DCSsideName = "neutral"
			end
			
			--mr: intercept to respect previous logistics centre ownership for all bases (airbase/FOB) = allow spawning (no slot blocking) even when base contested
			--mr: check DCSsideName as determined by DCS, against current baseOwnership setting determined by RSR.  If mismatch, then detect current CC owner to determine true owner.
			if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
				table.insert(baseOwnership.airbases[DCSsideName], baseName)

			elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
				
				local _currFOBowner = utils.getCurrFOBside(baseName)
				
				if _currFOBowner ~= DCSsideName then
					if _currFOBowner == "neutral" then
						--mr: >>> need construction of logistics centre to trigger baseOwnershipCheck.lua check
						table.insert(baseOwnership.FOBs[DCSsideName], baseName)
						trigger.action.outTextForCoalition(DCScoalition, baseName .. " FOB claimed by " .. DCSsideName .. " team following construction of Logistics Centre.", 10)
					else
						--mr: interograte logistics centre static object to determine true RSR side
						local _logiCentreNamePrefix = baseName .. " Logistics Centre"
						
						--[[
							potentially very performance intensive. Construct airbase and FOB logistics centre sub-table in CTLD during construction?
							ctld.logisticCentreObjects = all logistics centres, new from CTLD.lua and persitent from logisticsManager.lua
							convert logistics centre name capture from baseOwnershipCheck.lua to determine side from name into function for utils.lua
								> required for CTLD.lua for allow crate deploying
								> will need to use function to replace an instance in current code where side assoc. logistics centre is interograted for side as they will all be neutral!
						--]]
						local _logiCentreName = StaticObject.getByName("^" .. _logiCentreNamePrefix .. ".+")
						local _logiCentreSide = string.match(_logiCentreName,("%w+$"))
						
						if _logiCentreSide ~= nil then
							local _logiCentreCoalition = utils.getSide(_logiCentreSide)
							if _logiCentreSide == _currFOBowner then
								--mr: side specific notification that base being attacked? 
								--mr: Yes.  Aligns with JTAC functionality for all bases upcoming feature: https://github.com/ModernColdWar/RedStormRising/issues/87
								trigger.action.outTextForCoalition(_logiCentreCoalition, "ALERT - " .. baseName .. " IS UNDER ATTACK!", 10)
							elseif _logiCentreSide == DCSsideName
								
							end
						else
							log:error("No side found for $1 Logistics Centre, Side: $2", baseName,_logiCentreSide)
						end
					end
				end
				
				--mr: side specific notification that base being attacked? 
				--mr: Yes.  Aligns with JTAC functionality for all bases upcoming feature: https://github.com/ModernColdWar/RedStormRising/issues/87
				table.insert(baseOwnership.FOBs[DCSsideName], baseName) 
				
			end
		end
	end
    log:info("baseOwnership = $1", inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end

return M