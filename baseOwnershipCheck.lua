require ("Moose")
local inspect = require("inspect")
local utils = require("utils")
local bases = require("bases")
local rsrConfig = require("RSR_config")
-- require("CTLD_config")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")
--[[
local _firstTimeSetup = false
local _passedBase = "none"
local _playerORunit = "none"
local _conqueringUnit = "none"
--]]			
function M.getAllBaseOwnership(_firstTimeSetup,_passedBase,_playerORunit)

	if baseOwnership == nil then 
		baseOwnership = 	
		{ 	
			Airbases = { red = {}, blue = {}, neutral = {} },
			FOBs = { red = {}, blue = {}, neutral = {} } 
								
		}
	end
	--mr: intercept first time campaign setup here to read FOB ownership from Trigger Zone Name or Color
	log:info("firstTimeSetup: $1",_firstTimeSetup)
	log:info("_passedBase: $1",_passedBase)
	if _firstTimeSetup then

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
				table.insert(baseOwnership[_baseTypes][_baseSide],_RSRbaseCaptureZoneName)
			--end
		end
	--[[
		------------------------------------------------------------------------------------------------------------------------------------------------
	--]]
	elseif _passedBase == "none" then  --no base passsed, therefore search through all bases and check status
		if _playerORunit ~= "none" then 
			local _conqueringUnit = ctld.getPlayerNameOrType(_playerORunit)
		end	
		--MOOSE not working!
		--MOOSE: AIRBASE.GetAllAirbases(coalition, category): Get all airbases of the current map. This includes ships and FARPS.
		for _k, base in ipairs(AIRBASE.GetAllAirbases()) do
			env.info("baseOwnershipCheck: AIRBASE.GetAllAirbases: $1",AIRBASE.GetAllAirbases())
			env.info("baseOwnershipCheck: base: $1",base)	
			local baseName = base:GetName()
			local DCScoalition = base:GetCoalition()
			local DCSsideName = utils.getDCSsideName(DCScoalition)
			if DCSsideName == nil then
				log:info("No side returned for $1; setting to neutral", baseName)
				DCSsideName = "neutral"
			end
			-- feature? consider adding ~10min LOCKDOWN to prevent fast capture-recapture problems = base added to LOCKDOWN global array upon capture
			--if base:GetDesc().category == Airbase.Category.AIRDROME then
			if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
				
				local _currABowner = utils.getCurrABside(baseName)
				local _ABlogisticsCentre = ctld.logisticCentreObjects.baseName[1]
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
				--check DCSsideName as determined by DCS, against current baseOwnership setting determined by RSR.  If mismatch, then detect current CC owner to determine true owner.
				if _currABowner ~= DCSsideName then
					-- allows for neutral airbases!  but need to ensure they revert to neutral on CC destroy. 
					-- Check against RSRbaseCaptureZone color at campaign init
					if _currABowner == "neutral" then
						if _ABlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
							
							--interograte logistics centre static object to determine true RSR side
							_ABlogisticsCentreName = _ABlogisticsCentre:GetName()
							_ABlogisticsCentreSide = string.match(_ABlogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral AB, set ownership to side associated with logistics centre and notify side
							table.insert(baseOwnership.Airbases.neutral, baseName)
							table.insert(baseOwnership.Airbases[_ABlogisticsCentreSide], baseName)
							bases.configureForSide(baseName, _ABlogisticsCentreSide)  --slotBlocker.lua & pickupZoneManager.lua
							bases.resupply(baseName, _ABlogisticsCentreSide, rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
							trigger.action.outTextForCoalition(DCScoalition, baseName .. " claimed by " .. _ABlogisticsCentreSide .. " team following construction of Logistics Centre.", 10)
						end
					else
						if _ABlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_ABlogisticsCentreName = _ABlogisticsCentre:GetName()
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
								table.remove(baseOwnership.Airbases.blue, baseName)
								table.insert(baseOwnership.Airbases.red, baseName)
								bases.configureForSide(baseName, "red") --slotBlocker.lua & pickupZoneManager.lua
								bases.resupply(baseName, "red", rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
								trigger.action.outText(baseName .. " has been captured by a red " .. _conqueringUnit, 10)
							elseif DCSsideName == "blue" and _currABowner == "red" then
								table.remove(baseOwnership.Airbases.red, baseName)
								table.insert(baseOwnership.Airbases.blue, baseName)
								bases.configureForSide(baseName, "blue") --slotBlocker.lua & pickupZoneManager.lua
								bases.resupply(baseName, "blue", rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
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
				local _FOBlogisticsCentre = ctld.logisticCentreObjects.baseName[1]
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
							
							--[[
							local _logiCentreNamePrefix = baseName .. " Logistics Centre"
							-- find specific logistics centre object in all mission static objects to interogate for name and thus side
							local _logiCentreName = StaticObject.getByName("^" .. _logiCentreNamePrefix .. ".+")
							--]]
							
							--interograte logistics centre static object to determine true RSR side
							_FOBlogisticsCentreName = _FOBlogisticsCentre:GetName()
							_FOBlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							-- if logistics centre built on neutral FOB, set ownership to side associated with logistics centre and notify side
							table.remove(baseOwnership.FOBs.neutral, baseName)
							table.insert(baseOwnership.FOBs[_FOBlogisticsCentreSide], baseName)
							--mr: RSR TEAM = (A) must clear FOB area.  Therefore allow attacking team to know when they capture the FOB, but not opposition to allow sneaky tactics
							trigger.action.outTextForCoalition(DCScoalition, baseName .. " FOB claimed by " .. _FOBlogisticsCentreSide
							.. " team following construction of Logistics Centre by " .. _conqueringUnit, 10) --_conqueringUnit = playerName
							bases.configureForSide(baseName, _FOBlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
							bases.resupply(baseName, _FOBlogisticsCentreSide, rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit
								
						end
					else
						if _FOBlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
							--interograte logistics centre static object to determine true RSR side
							_FOBlogisticsCentreName = _FOBlogisticsCentre:GetName()
							_FOBlogisticsCentreSide = string.match(_FOBlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
							
							if _FOBlogisticsCentreSide ~= DCSsideName then
								log:info("$1 FOB contested but $2 Logistics Centre still present.", baseName,_FOBlogisticsCentreSide) -- stil allow spawn
							elseif _FOBlogisticsCentreSide == DCSsideName then
								log:error("$1: Current FOB Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current FOB owner doesn not match Logistics Centre owner!", baseName,_currFOBowner,_logiCentreSide,DCSsideName)
							end
						else
							--no logistics centre but FOB contested, therefore set to neutral
							table.remove(baseOwnership.FOBs[_currFOBowner], baseName)
							table.insert(baseOwnership.FOBs.neutral, baseName)
							bases.configureForSide(baseName, "neutral") --slotBlocker.lua & pickupZoneManager.lua
							-- bases.resupply(baseName, "neutral", rsrConfig, false, false) -- COMMENTED OUT = DO NOT spawn logistics and no neutral FARP trucks
							--trigger.action.outText(baseName .. " neutralized.", 10) --Should either or both teams receive a notification that FOB has been neutralized?
						end
					end
				end
			end
		end
		
	else -- baseName passed
		-- no need to check anything for campaign and mission init 
		-- do we need to check ownership when building a new CC?  Yes for FOB claim!
		-- if we pass the baseName i.e. logisticsManager.lua -> spawnLogisticsCentre function in CTLD.lua, can we improve performance?
		-- baseCapturedHandler.lua: _passedBase = "none" => check all bases due to DCS baseCaptured EH detecting base ownership change 
		-- CTLD.lua: ctld.spawnLogisticsCentre function: _passedBase = "none" =>

	end
    log:info("baseOwnership = $1", inspect(baseOwnership, { newline = " ", indent = "" }))
	env.info("baseOwnershipCheck: AIRBASE.GetAllAirbases: $1",AIRBASE.GetAllAirbases())
    return baseOwnership
end

return M