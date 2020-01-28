require ("Moose")
local inspect = require("inspect")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")

local _firstTimeSetup = false
local _playerORunit = "none"
local _conqueringUnit = "none"
			
function M.getAllBaseOwnership(_firstTimeSetup,_playerORunit)
    local baseOwnership = 	
	{ 	
		Airbases = { red = {}, blue = {}, neutral = {} },
		FOBs = { red = {}, blue = {}, neutral = {} } 
							
	}			
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
					local _baseTypes = _baseType .. "s"
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
		
		if _playerORunit ~= "none" then 
			local _conqueringUnit = ctld.getPlayerNameOrType(_playerORunit)
		end	
		
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
				
				local _currABowner = utils.getCurrFOBside(baseName)
				local _ABlogisticsCentre = ctld.logisticCentreObjects.Airbases.baseName[1]
				local _ABlogisticsCentreName = "noNAME"
				local _ABlogisticsCentreSide = "noSIDE"
				--[[
					will need friendly unit to set off DCS baseCapture and subsequent checks below
					>  Even with larger RSR radius checks, friendly unit will need to contest centre to set off DCS EH, whichh also makes tactical sense

					For Airbases:
					(D) Need to destroy current CC + clear radius around Airbase of enemy units and have friendly units present,
						to convert Airbase to teams side and subsequently allow capture.
					> Friendly CC presence doesn't matter to claim Airbases, only that previous enemy CC is dead.
				--]]
				if _currABowner ~= DCSsideName then
					
					if _currABowner == "neutral" then -- allows for neutral airbases!  but need to ensure they revert to neutral on CC destroy...
						if _ABlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
							
							--interograte logistics centre static object to determine true RSR side
							_ABlogisticsCentreName = _FOBlogisticsCentre:GetName()
							_ABlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral AB, set ownership to side associated with logistics centre and notify side
							table.insert(baseOwnership.FOBs[_FOBlogisticsCentreSide], baseName)
							trigger.action.outTextForCoalition(DCScoalition, baseName .. " claimed by " .. _FOBlogisticsCentreSide .. " team following construction of Logistics Centre.", 10)
						end
					else
						if _ABlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_ABlogisticsCentreName = _FOBlogisticsCentre:GetName()
							_ABlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
							local _ABlogisticsCentreCoalition = utils.getSide(_ABlogisticsCentreSide)
							
							if _ABlogisticsCentreSide ~= DCSsideName then
								--mr: side specific notification that base being attacked? 
								--mr: Yes.  Aligns with JTAC functionality for all bases upcoming feature: https://github.com/ModernColdWar/RedStormRising/issues/87
								trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, "ALERT - " .. baseName .. " IS UNDER ATTACK!", 10)
							elseif _ABlogisticsCentreSide == DCSsideName
								log:error("$1: Current Airbase Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current Airbase owner does not match Logistics Centre owner!", baseName,_currABowner,_ABlogisticsCentreSide,DCSsideName)
							end
						else
						--elseif _ABlogisticsCentre == nil then --necessary?
						
							--No logistices centre and base contested. IS BASE CAPTURED? 
							--Check for contested status c.f. uncontested
							--mr: Introduce RSR radiuses for additional checks HERE!
							if DCSsideName == "red" and _currABowner == "blue" then
								table.insert(baseOwnership.Airbases["red"], baseName)
								trigger.action.outText(baseName .. " has been captured by a red " .. _conqueringUnit, 10)
							elseif DCSsideName == "blue" and _currABowner == "red" then
								table.insert(baseOwnership.Airbases["blue"], baseName)
								trigger.action.outText(baseName .. " has been captured by a blue " .. _conqueringUnit, 10)
							end
						end
					end
				end
--[[
	--------------------------------------------------------------------------------------------------------------------------------------
--]]
			elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
				
				local _currFOBowner = utils.getCurrFOBside(baseName)
				local _FOBlogisticsCentre = ctld.logisticCentreObjects.FOBs.baseName[1]
				local _FOBlogisticsCentreName = "noNAME"
				local _FOBlogisticsCentreSide = "noSIDE"
				--[[
					will need friendly unit to set off DCS baseCapture to convert FOB to neutral (below),
					then new logistics centre spawning from CTLD.lua will reinitate check to claim, and convert from neutral to assoc. side.
					CTLD.lua should prevent logistics centre spawning if current logistics centre already exists for either side
					
					For FOBs:
					(A) Need to destroy current CC + clear radius around FOB of enemy units and have friendly units present, 
						to convert FOB to neutral to subsequently allow capture by building a CC.
					OR
					(B) Need to destroy current CC + contest radius around FOB with friendly ground units, to convert FOB to neutral to subsequently allow capture by building a CC
					OR
					(C) Need to destroy current CC, then build your teams CC to claim FOB, regardless of ground unit composition, contest, etc. ala' DDCS style.
					>>>>> to change to (B), ignore _currFOBowner and just check if any logistics centre present at FOB
				--]]
				if _currFOBowner ~= DCSsideName then
					
					if _currFOBowner == "neutral" then
						if _FOBlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
							
							--[[
							local _logiCentreNamePrefix = baseName .. " Logistics Centre"
							-- find specific logistics centre object in all mission static objects to interogate for name and thus side
							local _logiCentreName = StaticObject.getByName("^" .. _logiCentreNamePrefix .. ".+")
							--]]
							
							--interograte logistics centre static object to determine true RSR side
							_FOBlogisticsCentreName = _FOBlogisticsCentre:GetName()
							_FOBlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral FOB, set ownership to side associated with logistics centre and notify side
							table.insert(baseOwnership.FOBs[_FOBlogisticsCentreSide], baseName)
							trigger.action.outTextForCoalition(DCScoalition, baseName .. " FOB claimed by " .. _FOBlogisticsCentreSide 
								.. " team following construction of Logistics Centre by ." .. _conqueringUnit, 10) --_conqueringUnit = playerName
						end
					else
						if _FOBlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_FOBlogisticsCentreName = _FOBlogisticsCentre:GetName()
							_FOBlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							if _FOBlogisticsCentreSide ~= DCSsideName then
								log:info("$1 FOB contested but $2 Logistics Centre still present.", baseName,_FOBlogisticsCentreSide)
							elseif _FOBlogisticsCentreSide == DCSsideName
								log:error("$1: Current FOB Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current FOB owner doesn not match Logistics Centre owner!", baseName,_currFOBowner,_logiCentreSide,DCSsideName)
							end
						else
							--no logistics centre but FOB contested, therefore set to neutral and notify neutralizing side
							table.insert(baseOwnership.FOBs["neutral"], baseName)
							--trigger.action.outText(baseName .. " neutralized.", 10) --Should either or both teams receive a notification that FOB has been neutralized?
						end
					end
				end
			end
		end
	end
    log:info("baseOwnership = $1", inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end

return M