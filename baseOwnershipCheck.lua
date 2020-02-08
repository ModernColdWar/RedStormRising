env.info("RSR STARTUP: baseOwnershipCheck.LUA INIT")
local utils = require("utils")
local inspect = require("inspect")
local rsrConfig = require("RSR_config")
-- require("CTLD_config")
require ("Moose")
local bases = require("bases")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")

local _newBaseOwnership = 	
{ 	
	Airbases = { red = {}, blue = {}, neutral = {} },
	FOBs = { red = {}, blue = {}, neutral = {} } 					
}

local _updatedBaseOwnership = 	
{ 	
	Airbases = { red = {}, blue = {}, neutral = {} },
	FOBs = { red = {}, blue = {}, neutral = {} } 					
}

function M.getAllBaseOwnership(_campaignStartSetup,_passedBase,_playerORunit)

	--mr: intercept first time campaign setup here to read FOB ownership from Trigger Zone Name or Color
	log:info("campaignSetup: $1",_campaignStartSetup)
	log:info("_passedBase: $1",_passedBase)
	if _campaignStartSetup then
		
		-- wipe baseOwnership and reconstruct as checking all bases

		--mr: assign by Trigger Zone color, i.e.  RGB values 0 to 1: [1,0,0] = red, [0,1,0] = green (netural), [0,0,1] = blue
		--CTLD.LUA starts before baseOwnershipCheck.lua, therefore ctld.RSRbaseCaptureZones gloabal table should already be established
		--log:info("ctld.RSRbaseCaptureZones: $1",ctld.RSRbaseCaptureZones)
		for _k, _zone in ipairs(ctld.RSRbaseCaptureZones) do
				local _zoneName  = _zone.name
				local _RSRbaseCaptureZoneName = string.match(_zoneName,("^(.+)%sRSR")) --"MM75 RSRbaseCaptureZone FOB" = "MM75" i.e. from whitepace and RSR up
				--log:info("_RSRbaseCaptureZoneName: $1",_RSRbaseCaptureZoneName)
				local _baseType = string.match(_zoneName,("%w+$")) --"MM75 RSRbaseCaptureZone FOB" = "FOB"
				local _baseTypes = ""
				if _baseType == nil then
					log:error("RSR MIZ SETUP: $1 RSRbaseCaptureZone Trigger Zone name does not contain 'Airbase' or 'FOB' e.g. 'MM75 RSRbaseCaptureZone FOB'",_RSRbaseCaptureZoneName)
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
				table.insert(_newBaseOwnership[_baseTypes][_baseSide],_RSRbaseCaptureZoneName)
			--end
		end
		baseOwnership = _newBaseOwnership --copy local newBaseOwnership table to global table baseOwnership
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
				--log:info("ctld.logisticCentreObjects $1", ctld.logisticCentreObjects)
				local _ABlogisticsCentre = ctld.logisticCentreObjects[baseName]
				--log:info("_currABowner = $1; DCSsideName = $2",_currABowner, DCSsideName)
				--log:info("_ABlogisticsCentre = $1",_ABlogisticsCentre)
				--log:info("_ABlogisticsCentre = $1", inspect(_ABlogisticsCentre, { newline = " ", indent = "" }))
				local _ABlogisticsCentreName = "noNAME"
				local _ABlogisticsCentreSide = "noSIDE"
				
				local _testABlogisticsCentreName = _ABlogisticsCentre:getName()
				log:info("_ABlogisticsCentreName = $1", _testABlogisticsCentreName)
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
							table.insert(_updatedBaseOwnership.Airbases[_ABlogisticsCentreSide], baseName)
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
								--table.remove(baseOwnership.Airbases.blue, baseName)
								table.insert(_updatedBaseOwnership.Airbases.red, baseName)
								bases.configureForSide(baseName, "red") --slotBlocker.lua & pickupZoneManager.lua
								bases.resupply(baseName, "red", rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
								trigger.action.outText(baseName .. " has been captured by a red " .. _conqueringUnit, 10)
							elseif DCSsideName == "blue" and _currABowner == "red" then
								--table.remove(baseOwnership.Airbases.red, baseName)
								table.insert(_updatedBaseOwnership.Airbases.blue, baseName)
								bases.configureForSide(baseName, "blue") --slotBlocker.lua & pickupZoneManager.lua
								bases.resupply(baseName, "blue", rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
								trigger.action.outText(baseName .. " has been captured by a blue " .. _conqueringUnit, 10)
							end
						end
					end
				else
					--respect previous owner regardless of logisitics centre presence
					_debugABlogisticsCentreName = _ABlogisticsCentre:getName()
					log:info("_debugABlogisticsCentreName $1", _debugABlogisticsCentreName)
					table.insert(_updatedBaseOwnership.Airbases[_currABowner], baseName)
				end
				
			--[[
				--------------------------------------------------------------------------------------------------------------------------------------
			--]]
			elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
				local baseName = base:GetName() --getName = DCS function, GetName = MOOSE function
				log:info("FOBs: baseOwnership = $1",inspect(baseOwnership, { newline = " ", indent = "" }))
				local _currFOBowner = utils.getCurrFOBside(baseName)
				log:info("baseName: $1 _currFOBowner $2",baseName, _currFOBowner)
				local _FOBlogisticsCentre = ctld.logisticCentreObjects[baseName]
				local _FOBlogisticsCentreName = "noNAME"
				local _FOBlogisticsCentreSide = "noSIDE"
				--[[
					will need friendly unit to set off DCS baseCapture to convert FOB to neutral (below),
					then new logistics centre spawning from CTLD.lua will reinitate check to claim, and convert from neutral to assoc. side.
					CTLD.lua should prevent logistics centre spawning if current logistics centre already exists for either side
					
					For FOBs:
					(A) Need to destroy current CC + clear radius around FOB of enemy units and have friendly units present, 
						to convert FOB to neutral to subsequently allow capture by building a CC.
					>>>>> CURRENT + VOTED BY RSR TEAM 28/01/20	
					OR
					(B) Need to destroy current CC + contest radius around FOB with friendly ground units, to convert FOB to neutral to subsequently allow capture by building a CC
					OR
					(C) Need to destroy current CC, then build your teams CC to claim FOB, regardless of ground unit composition, contest, etc. ala' DDCS style.
					>>>>> to change to (B), ignore _currFOBowner and just check if any logistics centre present at FOB
				--]]
				if _currFOBowner ~= DCSsideName then
					
					if _currFOBowner == "neutral" then
						if _FOBlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
							
							--interograte logistics centre static object to determine true RSR side
							_FOBlogisticsCentreName = _FOBlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
							_FOBlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral FOB, set ownership to side associated with logistics centre and notify side
							--table.remove(baseOwnership.FOBs.neutral, baseName)
							table.insert(_updatedBaseOwnership.FOBs[_FOBlogisticsCentreSide], baseName)
							--mr: RSR TEAM = (A) must clear FOB area.  Therefore allow attacking team to know when they capture the FOB, but not opposition to allow sneaky tactics
							
							-- no side claim message for mission init when FARP helipad is neutral when no units present but side logisitics centre exsits
							-- _conqueringUnit should be player and not friendly unit if FOB neutral -- TEST!
							if _conqueringUnit ~= "none" then
								trigger.action.outTextForCoalition(DCScoalition, baseName .. " FOB claimed by " .. _FOBlogisticsCentreSide
								.. " team following construction of Logistics Centre by " .. _conqueringUnit, 10) --_conqueringUnit = playerName
							end
							bases.configureForSide(baseName, _FOBlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
							bases.resupply(baseName, _FOBlogisticsCentreSide, rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit
								
						end
					else
						if _FOBlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_FOBlogisticsCentreName = _FOBlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
							_FOBlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							if _FOBlogisticsCentreSide ~= DCSsideName then
								
								--exisiting logistics centre present but DCS side = opposing team, then respect owner of existing logisitics centre
								--exisiting logistics centre present but DCS side = neutral, then respect owner of existing logisitics centre, as may be no friendly units in area
								table.insert(_updatedBaseOwnership.FOBs[_FOBlogisticsCentreSide], baseName)
								bases.configureForSide(baseName,_FOBlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
								
								if DCSsideName ~= "neutral" then
									log:info("$1 FOB contested but $2 Logistics Centre still present.", baseName,_FOBlogisticsCentreSide)
								end
								
							elseif _FOBlogisticsCentreSide == DCSsideName then -- note: _currFOBowner ~= DCSsideName above already
								--ERROR! this shouldn't happen, but correct it if it does i.e. always respect logisitics centre owner for FOBs
								table.insert(_updatedBaseOwnership.FOBs._FOBlogisticsCentreSide, baseName)
								bases.configureForSide(baseName,_FOBlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
								log:error("$1: Current FOB Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current FOB owner does not match Logistics Centre owner!  CORRECTING.", baseName,_currFOBowner,_logiCentreSide,DCSsideName)
							end
						else
							--no logistics centre but FOB contested, therefore set to neutral, as logisitics centre required for claim
							--table.remove(baseOwnership.FOBs[_currFOBowner], baseName)
							table.insert(_updatedBaseOwnership.FOBs.neutral, baseName)
							bases.configureForSide(baseName, "neutral") --slotBlocker.lua & pickupZoneManager.lua
							-- bases.resupply(baseName, "neutral", rsrConfig, false, false) -- COMMENTED OUT = DO NOT spawn logistics and no neutral FARP trucks
							--trigger.action.outText(baseName .. " neutralized.", 10) --Should either or both teams receive a notification that FOB has been neutralized?
						end
					end
				else
					if _FOBlogisticsCentre == nil then
						--no logistics centre then set FOB to neutral and prevent anyone spawning
						--table.remove(baseOwnership.FOBs[_currFOBowner], baseName)
						table.insert(_updatedBaseOwnership.FOBs.neutral, baseName)
					else
						--respect previous owner only if logisitics centre present
						_debugFOBlogisticsCentreName = _FOBlogisticsCentre:getName()
						log:info("_debugFOBlogisticsCentreName $1", _debugFOBlogisticsCentreName)
						table.insert(_updatedBaseOwnership.FOBs[_currFOBowner], baseName)
					end
				end
			end
		end
		log:info("ctld.logisticCentreObjects $1", ctld.logisticCentreObjects)
		baseOwnership = 	
		{ 	
			Airbases = { red = {}, blue = {}, neutral = {} },
			FOBs = { red = {}, blue = {}, neutral = {} } 					
		}
		baseOwnership = _updatedBaseOwnership --clear global baseOwnership table then copy local updatedBaseOwnership table
		
	else -- baseName passed
		--[[
			no need to check anything for campaign and mission init 
			do we need to check ownership when building a new CC?  Yes for FOB claim!
			if we pass the baseName i.e. logisticsManager.lua -> spawnLogisticsCentre function in CTLD.lua, can we improve performance and if so, when?
				baseCapturedHandler.lua: _passedBase = "ALL" => check all bases due to DCS baseCaptured EH detecting base ownership change
					> Yes. change to passing just base firing DCS EH
				CTLD.lua: ctld.spawnLogisticsCentre function: _passedBase = "Airbase/FARP name" => during mission init
					> No!  CANNOT search through logisitics centres that do not exist
				CTLD.lua: ctld.spawnLogisticsCentre function: _passedBase = "Airbase/FARP name" => during normal gameplay
					> Yes. change to passing just base being repaired
		--]]
		
	end
    log:info("baseOwnership (_passedBase: $1) = $2", _passedBase,inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end
env.info("RSR STARTUP: baseOwnershipCheck.LUA LOADED")
return M
