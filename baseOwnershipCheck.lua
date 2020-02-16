env.info("RSR STARTUP: baseOwnershipCheck.LUA INIT")
local utils = require("utils")
local inspect = require("inspect")
local rsrConfig = require("RSR_config")
-- require("CTLD_config")
require ("Moose")
local bases = require("bases")
local missionUtils = require("missionUtils")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")

if baseOwnership == nil then
	log:info("baseOwnershipCheck.LUA START: baseOwnership is NIL") --most likely always will be NIL as baseOwnershipCheck.LUA starts before state.lua
	baseOwnership = 	
	{ 	
		Airbases = { red = {}, blue = {}, neutral = {} },
		FARPs = { red = {}, blue = {}, neutral = {} } 					
	}
end

function M.getAllBaseOwnership(_campaignStartSetup,_passedBase,_playerORunit)

	--mr: intercept first time campaign setup here to read FARP ownership from Trigger Zone Name or Color
	log:info("_campaignStartSetup: $1",_campaignStartSetup)
	log:info("_passedBase: $1",_passedBase)
	if _campaignStartSetup then
		
		-- wipe baseOwnership and reconstruct as checking all bases

		--mr: assign by Trigger Zone color, i.e.  RGB values 0 to 1: [1,0,0] = red, [0,1,0] = green (netural), [0,0,1] = blue
		--CTLD.LUA starts before baseOwnershipCheck.lua, therefore ctld.RSRbaseCaptureZones gloabal table should already be established
		--log:info("ctld.RSRbaseCaptureZones: $1",ctld.RSRbaseCaptureZones)
		for _k, _zone in ipairs(ctld.RSRbaseCaptureZones) do				
				local _baseNameSideType = utils.baseCaptureZoneToNameSideType(_zone) -- e.g. "MM75 RSRbaseCaptureZone FARP" zoneName
				local _RSRbaseCaptureZoneName = _baseNameSideType[1] --e.g. "MM75 RSRbaseCaptureZone FARP" = "MM75"
				local _baseSide = _baseNameSideType[2] --zone color translated to side
				local _baseTypes = _baseNameSideType[3] -- Airbase/FARP then adds "s"
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
		if _playerORunit ~= "none" and type(_playerORunit) ~= "string" then --playerName passed as string thus would cause error with ctld.getPlayerNameOrType
			_conqueringUnit = ctld.getPlayerNameOrType(_playerORunit) -- get type of ground vehicle if passed
		end
						
		--for _k, base in ipairs(AIRBASE.GetAllAirbases()) do --MOOSE: AIRBASE.GetAllAirbases(coalition, category): Get all airbases of the current map. This includes ships and FARPS.
		for _k, base in ipairs(world.getAirbases()) do -- WARNING: MOOSE will not return CONTESTED bases where side == nil
			
			--getName/getCoalition = DCS function, GetName/GetCoalition = MOOSE function
			local _baseName = base:getName()
			log:info("_baseName: $1", _baseName)
			local _DCScoalition = base:getCoalition()
			local _DCSsideName = utils.getSideName(_DCScoalition)  -- EVENTUALLY REPLACE WITH OUTCOME OF GROUD UNIT ENUMERATION
			if _DCSsideName == nil then
				log:info("No side returned for $1; setting to neutral", _baseName)
				_DCSsideName = "neutral"
			end
			local _DCSbaseCategory = base:getDesc().category
			
			--[[
				------------------------------------------------------------------------------------------------------------------------------------------------
			--]]
			-- feature? consider adding ~10min LOCKDOWN to prevent fast capture-recapture problems = base added to LOCKDOWN global array upon capture
			
			--[[
				will need friendly unit to set off DCS baseCapture and subsequent checks below
				>  Even with larger RSR radius checks, friendly unit will need to contest centre to set off DCS EH, whichh also makes tactical sense

				For Airbases:
				(D) Need to destroy current CC + clear radius around Airbase of enemy units and have friendly units present,
					to convert Airbase to teams side and subsequently allow capture.
				> Friendly CC presence doesn't matter to claim Airbases, only that previous enemy CC is dead.
			--]]
			if _DCSbaseCategory == Airbase.Category.AIRDROME then
				
				local _currABowner = utils.getCurrABside(_baseName)
				local _ABlogisticsCentre = ctld.logisticCentreObjects[_baseName]

				--debug
				local _debugABlogisticsCentreName = "NIL"
				if _ABlogisticsCentre ~= nil then
					_debugABlogisticsCentreName = _ABlogisticsCentre:getName()
				end
				log:info("_baseName: $1 _currABowner: $2, _debugABlogisticsCentreName: $3",_baseName,_currABowner,mist.utils.basicSerialize(_debugABlogisticsCentreName))

				local _ABlogisticsCentreName = "noNAME"
				local _ABlogisticsCentreSide = "noSIDE"
				local _ABlogisticsCentreCoalition = 4
				
				if _ABlogisticsCentre ~= nil then
				
					--interograte logistics centre static object to determine true RSR side
					_ABlogisticsCentreName = _ABlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
					_ABlogisticsCentreSide = string.match(_ABlogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
					_ABlogisticsCentreCoalition = utils.getSide(_ABlogisticsCentreSide)
					
					--ERROR: should not occur
					if _currABowner ~= _ABlogisticsCentreSide then
						log:error("$1: Current Airbase Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current Airbase owner does not match Logistics Centre owner!", _baseName,_currABowner,_ABlogisticsCentreSide,_DCSsideName)
					end
					
					if _currABowner ~= _DCSsideName then 
				
						if _currABowner == "neutral" then
							-- ctld.unpackLogisticsCentreCrates & ctld.loadUnloadLogisticsCrate = checks for friendly or neutral base before allowing logisitics centre crate unpack
							-- if logistics centre built on neutral AB, set ownership to side associated with logistics centre and notify side
							utils.removeABownership(_baseName)
							table.insert(baseOwnership.Airbases[_ABlogisticsCentreSide], _baseName)
							bases.configureForSide(_baseName, _ABlogisticsCentreSide)  --slotBlocker.lua & pickupZoneManager.lua
							log:info("$1 RESUPPLYING: _currABowner: $2, _DCSsideName: $3",_baseName,_currABowner,_DCSsideName)
							bases.resupply(_baseName, _ABlogisticsCentreSide, rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
							trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, _baseName .. " claimed by " .. _ABlogisticsCentreSide .. " team following construction of Logistics Centre.", 10)
						elseif _DCSsideName == nil then -- _DCSsideName == nil if contested
							-- Q: side specific notification that base being attacked?
							-- A: Yes.  Aligns with JTAC functionality for all bases upcoming feature: https://github.com/ModernColdWar/RedStormRising/issues/87
							trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, "ALERT - " .. _baseName .. " IS UNDER ATTACK!", 10)
							log:info("$1 owned by $2 (LC: $3) under attack by DCS side $4",_baseName,_currABowner,_ABlogisticsCentreSide,_DCSsideName)
						else
							trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, "ALERT - " .. _baseName .. " has no friendly ground units within 2km!", 10)
							log:info("$1 owned by $2 (LC $3) no friendly ground units within 2km.  DCS side $4",_baseName,_currABowner,_ABlogisticsCentreSide,_DCSsideName)
							
						end	
					end
				else
					--No logistics centre and base contested. IS BASE CAPTURED? 
				
					local _baseCaptureZoneName = _baseName .. " RSRbaseCaptureZone Airbase"
					log:info("_baseCaptureZoneName: $1",mist.utils.basicSerialize(_baseCaptureZoneName))
					local _baseCaptureZone = missionUtils.getSpecificZone(env.mission, string.lower(_baseCaptureZoneName))
					local _revBaseNameSideType = utils.baseCaptureZoneToNameSideType(_baseCaptureZone)
					local _zoneSideFromColor = _revBaseNameSideType[2] --zone color translated to side
					
					if _zoneSideFromColor == "neutral" then
					--if base was setup in MIZ as neutral then revert to neutral upon logisitics centre destruction i.e. airbase cannot be captured
						utils.removeABownership(_baseName)
						table.insert(baseOwnership.Airbases["neutral"], _baseName)
						bases.configureForSide(_baseName,"neutral") --slotBlocker.lua & pickupZoneManager.lua
						--no message = allow for sneaky tactics, but show status on Webmap?
						--trigger.action.outText(_currABowner, "ALERT - " .. _baseName .. " neutral airbase logisitics centre destroyed!  Reverting back to neutral ownership", 10)
						log:info("$1 reverting back to neutral as no logisitics centre.  DCSsideName: $2",_baseName,_DCSsideName)
					elseif _currABowner ~= _DCSsideName then	 
						
						if _DCSsideName == "red" or _DCSsideName == "blue" then
						-- BASE CAPTURED!
							utils.removeABownership(_baseName)
							table.insert(baseOwnership.Airbases[_DCSsideName], _baseName)
							bases.configureForSide(_baseName,_DCSsideName) --slotBlocker.lua & pickupZoneManager.lua
							log:info("$1 RESUPPLYING: _currABowner: $2, _DCSsideName: $3",_baseName,_currABowner,_DCSsideName)
							bases.resupply(_baseName,_DCSsideName, rsrConfig, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
							--trigger.action.outText(_baseName .. " HAS BEEN CAPTURED BY A " .. _DCSsideName .. _conqueringUnit, 10)  -don't let defending team know conquering unit!
							trigger.action.outText(_baseName .. " HAS BEEN CAPTURED BY " .. string.upper(_DCSsideName) .. "TEAM.", 10)
							log:info("$1 OWNED BY $2, CAPTURED BY $3 $4",_baseName,_currABowner,_DCSsideName,_conqueringUnit)
						elseif _DCSsideName == "neutral" then 
						-- Airbase converts back to MIZ warehouse setting i.e. neutral, if no ground units from either side present
							trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, "ALERT - " .. _baseName .. " has no friendly ground units within 2km!", 10)
							log:info("$1 owned by $2 (logisitics centre side: $3) no friendly ground units within 2km.  DCS side $4",_baseName,_currABowner,_ABlogisticsCentreSide,_DCSsideName)
						elseif _DCSsideName == nil then 
						--Check for contested status
							trigger.action.outTextForCoalition(_ABlogisticsCentreCoalition, "ALERT - " .. _baseName .. " IS UNDER ATTACK & HAS NO LOGISITICS CENTRE!", 10)
							log:info("$1 owned by $2 (no logisitics centre) under attack by DCS side $3",_baseName,_currABowner,_DCSsideName)
						end
					end
				end
			--[[
				--------------------------------------------------------------------------------------------------------------------------------------
			--]]
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
			-- CAUTION: Gas Platforms category == 2 off-line but == 1 during this script?! Therefore have Gas Platforms as a FARP seperate to Carriers?
			elseif _DCSbaseCategory == Airbase.Category.HELIPAD then

				local _currFARPowner = utils.getCurrFARPside(_baseName)
				local _FARPlogisticsCentre = ctld.logisticCentreObjects[_baseName]
				
				--debug
				local _debugFARPlogisticsCentreName = "NIL"
				if _FARPlogisticsCentre ~= nil then
					_debugFARPlogisticsCentreName = _FARPlogisticsCentre:getName()
				end
				log:info("_baseName: $1 _currFARPowner: $2, _debugFARPlogisticsCentreName: $3, _baseCategory: $4",_baseName,_currFARPowner,mist.utils.basicSerialize(_debugFARPlogisticsCentreName),mist.utils.basicSerialize(_DCSbaseCategory))
				
				local _FARPlogisticsCentreName = "noNAME"
				local _FARPlogisticsCentreSide = "noSIDE"
				local _FARPlogisticsCentreCoalition = 4

				if _FARPlogisticsCentre ~= nil then  --mr: IMPORTANT does an object == nil if destroyed?
						
					--interograte logistics centre static object to determine true RSR side
					_FARPlogisticsCentreName = _FARPlogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
					_FARPlogisticsCentreSide = string.match(_FARPlogisticsCentreName,("%w+$")) --"MM75 Logistics Centre #001 red" = "red"
					_FARPlogisticsCentreCoalition = utils.getSide(_FARPlogisticsCentreSide)
				
					--ERROR: should not occur
					if _currFARPowner ~= _FARPlogisticsCentreSide then
						log:error("$1: Current FARP Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current FARP owner does not match Logistics Centre owner!", _baseName,_currFARPowner,_FARPlogisticsCentreSide,_DCSsideName)
					end
			
					if _currFARPowner ~= _DCSsideName then
					
						if _currFARPowner == "neutral" then
							-- ctld.unpackLogisticsCentreCrates & ctld.loadUnloadLogisticsCrate = checks for friendly or neutral base before allowing logisitics centre crate unpack
							-- if logistics centre built on neutral FARP, set ownership to side associated with logistics centre and notify side
							utils.removeFARPownership(_baseName)
							table.insert(baseOwnership.FARPs[_FARPlogisticsCentreSide], _baseName)
							
							--mr: RSR TEAM = (option A) must clear FARP area.  Therefore allow attacking team to know when they capture the FARP, but not opposition to allow sneaky tactics
							-- no side claim message for mission init when FARP helipad is neutral when no units present but side logisitics centre exsits
							-- _conqueringUnit should be player and not friendly unit if FARP neutral
							if _conqueringUnit ~= "none" then
								trigger.action.outTextForCoalition(_DCScoalition, _baseName .. " FARP claimed by " .. _FARPlogisticsCentreSide
								.. " team following construction of Logistics Centre by " .. _conqueringUnit, 10) --_conqueringUnit = playerName
							end
							bases.configureForSide(_baseName, _FARPlogisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
							log:info("$1 RESUPPLYING: _currFARPowner: $2, _DCSsideName: $3",_baseName,_currFARPowner,_DCSsideName)
							bases.resupply(_baseName, _FARPlogisticsCentreSide, rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit

						else --if _DCSsideName ~= "neutral" then
							-- if contested then _DCSsideName == nil, do nothing
							-- if opposing team then _DCSsideName == opposing team, still do nothing as logisitics centre owner takes priority
							log:info("$1 FARP contested (DCSside: $2) but $3 Logistics Centre still present.", _baseName,_DCSsideName,_FARPlogisticsCentreSide)
						end
					else	
						-- only resupply if player repaired friendly base, otherwise checks for persistance will cause duplicate enteries in persistentGroupData within rsrState.json
						if _playerORunit ~= "none" then
							-- if repairing friendly FARP then ownership should already be correct, so only respawn base defences (FARP trucks)
							log:info("$1 RESUPPLYING: _currFARPowner: $2, _DCSsideName: $3",_baseName,_currFARPowner,_DCSsideName)
							bases.resupply(_baseName, _FARPlogisticsCentreSide, rsrConfig, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit
							trigger.action.outTextForCoalition(_FARPlogisticsCentreCoalition, _playerORunit .. " has repaired the Logistics Centre at " .. _baseName, 10)
						end
					end
				else
					--exclude red/blueStagingPoint as cannot distinguish from Helipad at the moment?
					--no logistics centre then set to owernship to neutral to block slot and other functions, as logisitics centre required for claim
					utils.removeFARPownership(_baseName)
					table.insert(baseOwnership.FARPs.neutral, _baseName)
					bases.configureForSide(_baseName, "neutral") --slotBlocker.lua & pickupZoneManager.lua
				end
			end
		end
	else -- _baseName passed
		--[[
			no need to check anything for campaign and mission init 
			do we need to check ownership when building a new CC?  Yes for FARP claim!
			if we pass the _baseName i.e. logisticsManager.lua -> spawnLogisticsCentre function in CTLD.lua, can we improve performance and if so, when?
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
