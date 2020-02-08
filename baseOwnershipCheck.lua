env.info("RSR STARTUP: baseOwnershipCheck.LUA INIT")
local utils = require("utils")
local inspect = require("inspect")
local rsrConfig = require("RSR_config")
-- require("CTLD_config")
require ("Moose")
local bases = require("bases")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")

baseOwnership = 	
{ 	
	Airbases = { red = {}, blue = {}, neutral = {} },
	FARPs = { red = {}, blue = {}, neutral = {} } 					
}

function M.getAllBaseOwnership(_campaignStartSetup,_passedBase,_playerORunit)

	--mr: intercept first time campaign setup here to read FARP ownership from Trigger Zone Name or Color
	log:info("campaignSetup: $1",_campaignStartSetup)
	log:info("_passedBase: $1",_passedBase)
	if _campaignStartSetup then
		
		-- wipe baseOwnership and reconstruct as checking all bases

		--mr: assign by Trigger Zone color, i.e.  RGB values 0 to 1: [1,0,0] = red, [0,1,0] = green (netural), [0,0,1] = blue
		--CTLD.LUA starts before baseOwnershipCheck.lua, therefore ctld.RSRbaseCaptureZones gloabal table should already be established
		--log:info("ctld.RSRbaseCaptureZones: $1",ctld.RSRbaseCaptureZones)
		for _k, _zone in ipairs(ctld.RSRbaseCaptureZones) do
				local _zoneName  = _zone.name
				local _RSRbaseCaptureZoneName = string.match(_zoneName,("^(.+)%sRSR")) --"MM75 RSRbaseCaptureZone FARP" = "MM75" i.e. from whitepace and RSR up
				--log:info("_RSRbaseCaptureZoneName: $1",_RSRbaseCaptureZoneName)
				local _baseType = string.match(_zoneName,("%w+$")) --"MM75 RSRbaseCaptureZone FARP" = "FARP"
				local _baseTypes = ""
				if _baseType == nil then
					log:error("RSR MIZ SETUP: $1 RSRbaseCaptureZone Trigger Zone name does not contain 'Airbase' or 'FARP' e.g. 'MM75 RSRbaseCaptureZone FARP'",_RSRbaseCaptureZoneName)
				else
					_baseTypes = _baseTypes .. _baseType .. "s"
				end

				local _zoneColor = _zone.color
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
				--log:info("baseTypes: $1, baseSide: $2, RSRbaseCaptureZoneName: $3",_baseTypes,_baseSide,_RSRbaseCaptureZoneName)			
				table.insert(baseOwnership[_baseTypes][_baseSide],_RSRbaseCaptureZoneName)
			--end
		end
	--[[
		------------------------------------------------------------------------------------------------------------------------------------------------
	--]]
	elseif _passedBase == "ALL" then  --search through ALL bases and check status
		log:info("ctld.logisticCentreObjects $1", ctld.logisticCentreObjects)
		local _conqueringUnit = "none"
		if _playerORunit ~= "none" then 
			_conqueringUnit = ctld.getPlayerNameOrType(_playerORunit)
		end	
		--MOOSE: AIRBASE.GetAllAirbases(coalition, category): Get all airbases of the current map. This includes ships and FARPS.
		for _k, base in ipairs(AIRBASE.GetAllAirbases()) do
			local baseName = base:GetName() --getName = DCS function, GetName = MOOSE function
			log:info("All bases: baseName: $1", baseName)
			local DCScoalition = base:GetCoalition()
			local DCSsideName = utils.getSideName(DCScoalition)
			if DCSsideName == nil then
				log:info("No side returned for $1; setting to neutral", baseName)
				DCSsideName = "neutral"
			end
			-- feature? consider adding ~10min LOCKDOWN to prevent fast capture-recapture problems = base added to LOCKDOWN global array upon capture
			--if base:GetDesc().category == Airbase.Category.AIRDROME then
			if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
				
				local _currABowner = utils.getCurrABside(baseName)
				local _ABlogisticsCentre = ctld.logisticCentreObjects[baseName]

				local _ABlogisticsCentreName = "noNAME"
				local _ABlogisticsCentreSide = "noSIDE"
				
				local _testABlogisticsCentreName = _ABlogisticsCentre:getName()

				--[[
					will need friendly unit to set off DCS baseCapture and subsequent checks below
					>  Even with larger RSR radius checks, friendly unit will need to contest centre to set off DCS EH, whichh also makes tactical sense

					For Airbases:
					(D) Need to destroy current CC + clear radius around Airbase of enemy units and have friendly units present,
						to convert Airbase to teams side and subsequently allow capture.
					> Friendly CC presence doesn't matter to claim Airbases, only that previous enemy CC is dead.
				--]]
				--check DCSsideName as determined by DCS, against current baseOwnership setting determined by RSR.  If mismatch, then detect current CC owner to determine true owner.
				if _currABowner ~= DCSsideName then
					-- allows for neutral airbases!  but need to ensure they revert to neutral on CC destroy. 
					-- Check against RSRbaseCaptureZone color at campaign init
					if _currABowner == "neutral" then
						if _ABlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
							
							--interograte logistics centre static object to determine true RSR side
							_ABlogisticsCentreName = _ABlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
							_ABlogisticsCentreSide = string.match(_ABlogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral AB, set ownership to side associated with logistics centre and notify side
							utils.removeABownership(baseName)
							table.insert(baseOwnership.Airbases[_ABlogisticsCentreSide], baseName)
							bases.configureForSide(baseName, _ABlogisticsCentreSide)  --slotBlocker.lua & pickupZoneManager.lua
							bases.resupply(baseName, _ABlogisticsCentreSide, rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
							trigger.action.outTextForCoalition(DCScoalition, baseName .. " claimed by " .. _ABlogisticsCentreSide .. " team following construction of Logistics Centre.", 10)
						end
					else
						if _ABlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_ABlogisticsCentreName = _ABlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
							_ABlogisticsCentreSide = string.match(_ABlogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
							local _ABlogisticsCentreCoalition = utils.getSide(_ABlogisticsCentreSide)
							
							if _ABlogisticsCentreSide ~= DCSsideName then
								--mr: side specific notification that base being attacked? 
								--mr: Yes.  Aligns with JTAC functionality for all bases upcoming feature: https://github.com/ModernColdWar/RedStormRising/issues/87
								trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, "ALERT - " .. baseName .. " IS UNDER ATTACK!", 10)
							elseif _ABlogisticsCentreSide == DCSsideName then
								log:error("$1: Current Airbase Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current Airbase owner does not match Logistics Centre owner!", baseName,_currABowner,_ABlogisticsCentreSide,DCSsideName)
							end
						else
						--elseif _ABlogisticsCentre == nil then --necessary?
						
							--No logistices centre and base contested. IS BASE CAPTURED? 
							--Check for contested status c.f. uncontested
							--mr: Introduce RSR radiuses for additional checks here or baseCapturedHandler.lua?
							if DCSsideName == "red" and _currABowner == "blue" then
								utils.removeABownership(baseName)
								table.insert(baseOwnership.Airbases.red, baseName)
								bases.configureForSide(baseName, "red") --slotBlocker.lua & pickupZoneManager.lua
								bases.resupply(baseName, "red", rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
								trigger.action.outText(baseName .. " has been captured by a red " .. _conqueringUnit, 10)
							elseif DCSsideName == "blue" and _currABowner == "red" then
								utils.removeABownership(baseName)
								table.insert(baseOwnership.Airbases.blue, baseName)
								bases.configureForSide(baseName, "blue") --slotBlocker.lua & pickupZoneManager.lua
								bases.resupply(baseName, "blue", rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
								trigger.action.outText(baseName .. " has been captured by a blue " .. _conqueringUnit, 10)
							end
						end
					end
				else
					--respect previous owner of airbase, even if logisitics centre absent
					utils.removeABownership(baseName)
					table.insert(baseOwnership.Airbases[_currABowner], baseName)
					bases.configureForSide(baseName, _currABowner) --slotBlocker.lua & pickupZoneManager.lua
					bases.resupply(baseName, _currABowner, rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
				end
				
			--[[
				--------------------------------------------------------------------------------------------------------------------------------------
			--]]
			elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
				local baseName = base:GetName() --getName = DCS function, GetName = MOOSE function
				log:info("FARPs: baseOwnership = $1",inspect(baseOwnership, { newline = " ", indent = "" }))
				local _currFARPowner = utils.getCurrFARPside(baseName)
				log:info("baseName: $1 _currFARPowner $2",baseName, _currFARPowner)
				local _FARPlogisticsCentre = ctld.logisticCentreObjects[baseName]
				local _FARPlogisticsCentreName = "noNAME"
				local _FARPlogisticsCentreSide = "noSIDE"
				--[[
					will need friendly unit to set off DCS baseCapture to convert FARP to neutral (below),
					then new logistics centre spawning from CTLD.lua will reinitate check to claim, and convert from neutral to assoc. side.
					CTLD.lua should prevent logistics centre spawning if current logistics centre already exists for either side
					
					For FARPs:
					(A) Need to destroy current CC + clear radius around FARP of enemy units and have friendly units present, 
						to convert FARP to neutral to subsequently allow capture by building a CC.
					>>>>> CURRENT + VOTED BY RSR TEAM 28/01/20	
					OR
					(B) Need to destroy current CC + contest radius around FARP with friendly ground units, to convert FARP to neutral to subsequently allow capture by building a CC
					OR
					(C) Need to destroy current CC, then build your teams CC to claim FARP, regardless of ground unit composition, contest, etc. ala' DDCS style.
					>>>>> to change to (B), ignore _currFARPowner and just check if any logistics centre present at FARP
				--]]
				if _currFARPowner ~= DCSsideName then
					
					if _currFARPowner == "neutral" then
						if _FARPlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
							
							--interograte logistics centre static object to determine true RSR side
							_FARPlogisticsCentreName = _FARPlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
							_FARPlogisticsCentreSide = string.match(_FARPlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral FARP, set ownership to side associated with logistics centre and notify side
							utils.removeFARPownership(baseName)
							table.insert(baseOwnership.FARPs[_FARPlogisticsCentreSide], baseName)
							--mr: RSR TEAM = (A) must clear FARP area.  Therefore allow attacking team to know when they capture the FARP, but not opposition to allow sneaky tactics
							
							-- no side claim message for mission init when FARP helipad is neutral when no units present but side logisitics centre exsits
							-- _conqueringUnit should be player and not friendly unit if FARP neutral -- TEST!
							if _conqueringUnit ~= "none" then
								trigger.action.outTextForCoalition(DCScoalition, baseName .. " FARP claimed by " .. _FARPlogisticsCentreSide
								.. " team following construction of Logistics Centre by " .. _conqueringUnit, 10) --_conqueringUnit = playerName
							end
							bases.configureForSide(baseName, _FARPlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
							bases.resupply(baseName, _FARPlogisticsCentreSide, rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit
								
						end
					else
						if _FARPlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_FARPlogisticsCentreName = _FARPlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
							_FARPlogisticsCentreSide = string.match(_FARPlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							if _FARPlogisticsCentreSide ~= DCSsideName then
								
								--exisiting logistics centre present but DCS side = opposing team, then respect owner of existing logisitics centre
								--exisiting logistics centre present but DCS side = neutral, then respect owner of existing logisitics centre, as may be no friendly units in area
								utils.removeFARPownership(baseName)
								table.insert(baseOwnership.FARPs[_FARPlogisticsCentreSide], baseName)
								bases.configureForSide(baseName,_FARPlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
								
								if DCSsideName ~= "neutral" then
									log:info("$1 FARP contested but $2 Logistics Centre still present.", baseName,_FARPlogisticsCentreSide)
								end
								
							elseif _FARPlogisticsCentreSide == DCSsideName then -- note: _currFARPowner ~= DCSsideName above already
								--ERROR! this shouldn't happen, but correct it if it does i.e. always respect logisitics centre owner for FARPs
								utils.removeFARPownership(baseName)
								table.insert(baseOwnership.FARPs[_FARPlogisticsCentreSide], baseName)
								bases.configureForSide(baseName,_FARPlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
								--bases.resupply(baseName, _FARPlogisticsCentreSide, rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit
								log:error("$1: Current FARP Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current FARP owner does not match Logistics Centre owner!  CORRECTING.", baseName,_currFARPowner,_logiCentreSide,DCSsideName)
							end
						else
							--no logistics centre but FARP contested, therefore set to neutral, as logisitics centre required for claim
							utils.removeFARPownership(baseName)
							table.insert(baseOwnership.FARPs.neutral, baseName)
							bases.configureForSide(baseName, "neutral") --slotBlocker.lua & pickupZoneManager.lua
							--bases.resupply(baseName, "neutral", rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit
							--trigger.action.outText(baseName .. " neutralized.", 10) --Should either or both teams receive a notification that FARP has been neutralized?
						end
					end
				else
					if _FARPlogisticsCentre == nil then
						--no logistics centre then set FARP to neutral and prevent anyone spawning
						utils.removeFARPownership(baseName)
						table.insert(baseOwnership.FARPs.neutral, baseName)
					else
						--respect previous owner only if logisitics centre present
						utils.removeFARPownership(baseName)
						table.insert(baseOwnership.FARPs[_currFARPowner], baseName)
					end
				end
			end
		end
	else -- baseName passed
		--[[
			no need to check anything for campaign and mission init 
			do we need to check ownership when building a new CC?  Yes for FARP claim!
			if we pass the baseName i.e. logisticsManager.lua -> spawnLogisticsCentre function in CTLD.lua, can we improve performance and if so, when?
				baseCapturedHandler.lua: _passedBase = "ALL" => check all bases due to DCS baseCaptured EH detecting base ownership change
					> Yes. change to passing just base firing DCS EH
				CTLD.lua: ctld.spawnLogisticsCentre function: _passedBase = "Airbase/FARP name" => during mission init
					> No!  CANNOT search through logisitics centres that do not exist
					> They should exist!
				CTLD.lua: ctld.spawnLogisticsCentre function: _passedBase = "Airbase/FARP name" => during normal gameplay
					> Yes. change to passing just base being repaired
		--]]
		
	end
    log:info("baseOwnership (_passedBase: $1) = $2", _passedBase,inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end
env.info("RSR STARTUP: baseOwnershipCheck.LUA LOADED")
return M
