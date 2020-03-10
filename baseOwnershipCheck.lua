env.info("RSR STARTUP: baseOwnershipCheck.LUA INIT")
local utils = require("utils")
local inspect = require("inspect")
local rsrConfig = require("RSR_config")
-- require("CTLD_config")
require("Moose")
local bases = require("bases")
local missionUtils = require("missionUtils")

local M = {}

local log = mist.Logger:new("baseOwnershipCheck", "info")

--most likely always will be NIL as baseOwnershipSetup.LUA starts before state.lua
if baseOwnership == nil then
    log:info("baseOwnershipCheck.LUA START: baseOwnership is NIL")
    baseOwnership = {
        Airbases = { red = {}, blue = {}, neutral = {} },
        FARPs = { red = {}, blue = {}, neutral = {} },
        Ships = { }
    }
end

function M.getAllBaseOwnership(_passedBaseName, _playerORunit, _campaignStartSetup)
    --mr: intercept first time campaign setup here to read FARP ownership from Trigger Zone Name or Color
    log:info("_passedBaseName: $1, _playerORunit: $2, _campaignStartSetup: $3", _passedBaseName, _playerORunit, _campaignStartSetup)
	log:info("ctld.logisticCentreObjects $1", ctld.logisticCentreObjects)
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
            table.insert(baseOwnership[_baseTypes][_baseSide], _RSRbaseCaptureZoneName)

        end
        --[[
        for _k, _zone in ipairs(ctld.RSRcarrierActivateZones) do
            -- e.g. "Novorossiysk RSRcarrierActivateZone Group1" zoneName
            local _carrierGroupBaseOwnedBySide = utils.carrierActivateForBaseWhenOwnedBySide(_zone)
            local _carrierGroup = _carrierGroupBaseOwnedBySide[1] --e.g. "Novorossiysk RSRcarrierActivateZone Group1" = "Group1"
            local _carrierActivateForBase = _carrierGroupBaseOwnedBySide[2] --"Novorossiysk RSRcarrierActivateZone Group1" = "Novorossiysk"
            local _whenBaseOwnedBySide = _carrierGroupBaseOwnedBySide[3] --zone color translated to 'when owned by side'
            --log:info("baseTypes: $1, baseSide: $2, RSRbaseCaptureZoneName: $3",_baseTypes,_baseSide,_RSRbaseCaptureZoneName)
            baseOwnership.Ships[_carrierGroup][_carrierActivateForBase] = _whenBaseOwnedBySide
        end
        --]]
        --[[
            ------------------------------------------------------------------------------------------------------------------------------------------------
        --]]
    elseif _passedBaseName == "ALL" then
        --search through ALL bases and check status
        log:info("ctld.logisticCentreObjects $1", ctld.logisticCentreObjects)
        local _conqueringUnit = "none"
        if _playerORunit ~= "none" and _playerORunit ~= "LCdead" and type(_playerORunit) ~= "string" then
            --_playerORunit not passed as string to ctld.getPlayerNameOrType would cause an error
            _conqueringUnit = ctld.getPlayerNameOrType(_playerORunit) -- get type of ground vehicle if passed
        end

        for _k, base in pairs(world.getAirbases()) do
            -- WARNING: MOOSE: AIRBASE.GetAllAirbases will not return CONTESTED bases where side == nil

            --getName/getCoalition = DCS function, GetName/GetCoalition = MOOSE function
            local _baseName = base:getName()
            log:info("_baseName: $1", _baseName)
			
            local _DCScoalition = base:getCoalition()
            local _DCSsideName = utils.getSideName(_DCScoalition)  -- EVENTUALLY REPLACE WITH OUTCOME OF GROUD UNIT ENUMERATION

            -- _DCSsideName == nil if contested
            if _DCSsideName == nil then
                log:info("No side returned for $1; setting to CONTESTED", _baseName)
                _DCSsideName = "CONTESTED"
            end

            local _DCSbaseCategory = base:getDesc().category
            local _RSRowner = "NoRSRowner"
            local _RSRcoalition = "NoRSRcoalition"

            --get logistics centre deails if present
            local _logisticsCentre = ctld.logisticCentreObjects[_baseName]
            local _logisticsCentreName = "NoLCname"
            local _logisticsCentreSide = "NoLCside"
            local _logisticsCentreCoalition = 4
            local _logisiticsCentreLife = 0 --10000 = starting command centre static object life
            local _logisticsCentreMarkerID = 0
            if _logisticsCentre ~= nil then
                --interograte logistics centre static object to determine true RSR side
                _logisticsCentreName = _logisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
                _logisticsCentreSide = string.match(_logisticsCentreName, ("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
                _logisticsCentreCoalition = utils.getSide(_logisticsCentreSide)
                _logisiticsCentreLife = StaticObject.getLife(_logisticsCentre)
            end
            log:info("_baseName: $1 _logisticsCentreName: $2, _logisiticsCentreLife: $3", _baseName, _logisticsCentreName, _logisiticsCentreLife)

            --clean dead logisitics centres from ctld.logisticCentreObjects but shouldn't be required as handled by deadEventHandler.lua
            if _logisticsCentre ~= nil then
                if _logisiticsCentreLife == 0 then
                    ctld.logisticCentreObjects[_baseName] = nil

                    _logisticsCentreMarkerID = ctld.logisticCentreMarkerID[_baseName]
                    trigger.action.removeMark(_logisticsCentreMarkerID)
                end
            end

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

                _RSRowner = utils.getCurrABside(_baseName)
                _RSRcoalition = utils.getSide(_RSRowner)

                local _baseCaptureZoneName = _baseName .. " RSRbaseCaptureZone Airbase"
                log:info("_baseCaptureZoneName: $1", mist.utils.basicSerialize(_baseCaptureZoneName))
                local _baseCaptureZone = missionUtils.getSpecificZone(env.mission, string.lower(_baseCaptureZoneName))
                local _revBaseNameSideType = utils.baseCaptureZoneToNameSideType(_baseCaptureZone)
                local _zoneSideFromColor = _revBaseNameSideType[2] --zone color translated to side

                if _logisticsCentre ~= nil and _logisiticsCentreLife > 0 then


                    -- should only occur during claiming of neutral airfield with newly built logisitics centre
                    if _RSRowner ~= _logisticsCentreSide then
                        log:error("$1: Current Airbase Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current Airbase owner does not match Logistics Centre owner!", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
                    end

					-- neutral airbases
					-- _DCSsideName irrelevant in these cases
					if _zoneSideFromColor == "neutral" then
						
						--required if neutral airbase has no units on it but player builds logisitics centre
						if _RSRowner ~= _logisticsCentreSide then
                        
							if _RSRowner == "neutral" then
								log:info("$1 OWNERSHIP CHANGE (no LC): [Neutral Airbase] _zoneSideFromColor: $2 | CURRENT OWNER: _RSRowner: $3, NEW OWNER: _logisticsCentreSide: $4 | DCSsideName: $5", _baseName, _zoneSideFromColor, _RSRowner, _logisticsCentreSide, _DCSsideName)

								-- ctld.unpackLogisticsCentreCrates & ctld.loadUnloadLogisticsCrate = checks for OWNED friendly or neutral base before allowing logisitics centre crate unpack
								-- if logistics centre built on neutral AB, set ownership to side associated with logistics centre and notify side
								utils.removeABownership(_baseName)
								table.insert(baseOwnership.Airbases[_logisticsCentreSide], _baseName)

								bases.configureForSide(_baseName, _logisticsCentreSide)  --slotBlocker.lua & pickupZoneManager.lua
								-- (baseName, sideName, rsrConfig, spawnLC, missionInit, campaignStartSetup)
								bases.resupply(_baseName, _logisticsCentreSide, rsrConfig, false, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
								trigger.action.outTextForCoalition(_logisticsCentreCoalition, _baseName .. " claimed by " .. _logisticsCentreSide .. " team following construction of a Logistics Centre.", 10)
							end
							-- do NOT provide warning for neutral bases at campaign setup as no base defences associated, capture not based on ground vehicles, and likely message spam
						end 
					
					-- capturable airbases ALERTS only, as no capture can occur until defending side logistic centre destroyed
					elseif _zoneSideFromColor ~= "neutral" then
					
						-- Q: side specific notification that base being attacked?
						-- A: Yes.  Aligns with JTAC functionality for all bases upcoming feature: https://github.com/ModernColdWar/RedStormRising/issues/87
						
						if _RSRowner ~= _DCSsideName then
							
							if _DCSsideName == "CONTESTED" then

								trigger.action.outTextForCoalition(_RSRcoalition, "ALERT - " .. _baseName .. " IS UNDER ATTACK!", 10)
								log:info("ALERT MSG: $1 owned by $2 (LC: $3) under attack by DCS side $4", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
							
							
							elseif _DCSsideName == "neutral" then
								--disable alert for now to prevent message spam due to DCSside reporting issue: https://github.com/ModernColdWar/RedStormRising/issues/157
								--trigger.action.outTextForCoalition(_RSRcoalition, "ALERT - " .. _baseName .. " has no friendly ground units within 2km!", 10)
								log:info("ALERT MSG: $1 owned by $2 (LC $3) no friendly ground units within 2km.  DCS side $4", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
							
							else -- if not contested or neutral but RSRowner not matching DCSside, then enemy must be holding base
							
								trigger.action.outTextForCoalition(_RSRcoalition, "ALERT - " .. _baseName .. " IS BEING HELD BY THE ENEMY! Friendly logistics centre still present.", 10)
								log:info("ALERT MSG: $1 owned by $2 (LC: $3) held by DCS side $4", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
								
							end

						end
						
					end

                else
                    --No logistics centre and base contested. IS BASE CAPTURED?

                    --if base was setup in MIZ as neutral then revert to neutral upon logisitics centre destruction i.e. airbase cannot be captured
                    if _zoneSideFromColor == "neutral" and _RSRowner ~= "neutral" then
						log:info("$1 OWNERSHIP CHANGE (no LC): [Neutral Airbase] _zoneSideFromColor: $2 | CURRENT OWNER: _RSRowner: $3, NEW OWNER: neutral | DCSsideName: $4", _baseName, _zoneSideFromColor, _RSRowner, _DCSsideName)
                        utils.removeABownership(_baseName)
                        table.insert(baseOwnership.Airbases["neutral"], _baseName)
                        bases.configureForSide(_baseName, "neutral") --slotBlocker.lua & pickupZoneManager.lua

                        --no message = allow for sneaky tactics, but show status on Webmap?
                        --trigger.action.outText(_RSRowner, "ALERT - " .. _baseName .. " neutral airbase logisitics centre destroyed!  Reverting back to neutral ownership", 10)
                        log:info("$1 reverting back to neutral as no logisitics centre.  DCSsideName: $2", _baseName, _DCSsideName)

                    elseif _zoneSideFromColor ~= "neutral" and _RSRowner ~= _DCSsideName then

                        if _DCSsideName == "red" or _DCSsideName == "blue" then
							log:info("$1 OWNERSHIP CHANGE (no LC): [Capturable Airbase] | CURRENT OWNER: _RSRowner: $2, NEW OWNER: DCSsideName: $3 | _conqueringUnit: $4", _baseName, _RSRowner, _DCSsideName, _conqueringUnit)
							
                            -- BASE CAPTURED!
                            utils.removeABownership(_baseName)
                            table.insert(baseOwnership.Airbases[_DCSsideName], _baseName)

                            bases.configureForSide(_baseName, _DCSsideName) --slotBlocker.lua & pickupZoneManager.lua
                            -- (baseName, sideName, rsrConfig, spawnLC, missionInit, campaignStartSetup)
                            bases.resupply(_baseName, _DCSsideName, rsrConfig, false, false, false) --activate base defences but DO NOT spawn logistics and NOT missionInit
							
							if _playerORunit == "LCdead" then
								trigger.action.outTextForCoalition(_DCSsideName, _baseName .. " was held by  " .. _DCSsideName .. " ground units, and captured following destruction of the " .. _RSRowner .. " Logistics Centre", 10)
							else
								trigger.action.outTextForCoalition(_DCSsideName, _baseName .. " was captured by a " .. _DCSsideName .. " " .. _conqueringUnit, 10)
							end
                            trigger.action.outText(_baseName .. " HAS BEEN CAPTURED BY " .. string.upper(_DCSsideName) .. " TEAM", 10)

                        elseif _DCSsideName == "neutral" then
                            -- Airbase converts back to MIZ warehouse setting i.e. neutral, if no ground units from either side present
                            trigger.action.outTextForCoalition(_RSRcoalition, "ALERT - " .. _baseName .. " has no friendly ground units within 2km and has no Logisitics Centre!", 10)
                            log:info("ALERT MSG: $1 owned by $2 no friendly ground units within 2km and no logisitics centre.  DCS side $3", _baseName, _RSRowner, _DCSsideName)

                        elseif _DCSsideName == "CONTESTED" then
                            --Check for contested status
                            trigger.action.outTextForCoalition(_RSRcoalition, "ALERT - " .. _baseName .. " is under attack and has no logisitics centre!", 10)
                            log:info("ALERT MSG: $1 owned by $2 (no logisitics centre) under attack by DCS side $3", _baseName, _RSRowner, _DCSsideName)
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
                    >>>>> to change to (B), ignore _RSRowner and just check if any logistics centre present at FARP
                --]]

                -- CAUTION: Gas Platforms category == 2 off-line but == 1 during this script?! Therefore have Gas Platforms as a FARP seperate to Carriers?
            elseif _DCSbaseCategory == Airbase.Category.HELIPAD then

                _RSRowner = utils.getCurrFARPside(_baseName)
                _RSRcoalition = utils.getSide(_RSRowner)

                if _logisticsCentre ~= nil and _logisiticsCentreLife > 0 then

                    -- should only occur during claiming of FARP with newly built logisitics centre
                    if _RSRowner ~= _logisticsCentreSide then
                        log:info("$1: Current FARP Owner: $2. Logistics Centre Owner: $3.  DCSside: $4. Current FARP owner does not match Logistics Centre owner.", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
                    end

                    if _RSRowner ~= _DCSsideName then

                        if _RSRowner == "neutral" and _RSRowner ~= _logisticsCentreSide then
							-- if logistics centre built on neutral FARP, set ownership to side associated with logistics centre and notify side
							-- ctld.unpackLogisticsCentreCrates & ctld.loadUnloadLogisticsCrate = checks for friendly or neutral base before allowing logisitics centre crate unpack
							 
							log:info("$1 OWNERSHIP CHANGE (alive LC): [FARP] | CURRENT OWNER: _RSRowner: $2, NEW OWNER: _logisticsCentreSide: $3 | _DCSsideName: $4", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)

                            utils.removeFARPownership(_baseName)
                            table.insert(baseOwnership.FARPs[_logisticsCentreSide], _baseName)

                            --mr: RSR TEAM = (option A) must clear FARP area.  Therefore allow attacking team to know when they capture the FARP, but not opposition to allow sneaky tactics
                            if _conqueringUnit ~= "none" then
                                -- _conqueringUnit should be player and not friendly unit if FARP neutral
                                trigger.action.outTextForCoalition(_DCScoalition, _baseName .. " FARP claimed by " .. _logisticsCentreSide
                                        .. " team following construction of Logistics Centre by " .. _conqueringUnit, 10) --_conqueringUnit = playerName
                            end

                            bases.configureForSide(_baseName, _logisticsCentreSide) --slotBlocker.lua & pickupZoneManager.lua
                            -- (baseName, sideName, rsrConfig, spawnLC, missionInit, campaignStartSetup)
                            bases.resupply(_baseName, _logisticsCentreSide, rsrConfig, false, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit

                        else
                            --if _DCSsideName ~= "neutral" then --unnecessary
                            -- if contested then _DCSsideName == nil, do nothing
                            -- if opposing team then _DCSsideName == opposing team, still do nothing as logisitics centre owner takes priority
							log:info("$1 CONTESTED (alive LC): [FARP] | CURRENT OWNER: _RSRowner: $2, _logisticsCentreSide: $3, _DCSsideName: $4", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
                        end

                    elseif _RSRowner ~= _logisticsCentreSide then
						-- only resupply if FARP 'attacked and being held' then logisitics centre built by attacking player (_playerORunit ~= "none")
						
						log:info("$1 OWNERSHIP CHANGE (alive LC): [FARP] | CURRENT OWNER: _RSRowner: $2, NEW OWNER: _logisticsCentreSide: $3 | _DCSsideName: $4", _baseName, _RSRowner, _logisticsCentreSide, _DCSsideName)
                        
                        utils.removeFARPownership(_baseName)
                        table.insert(baseOwnership.FARPs[_logisticsCentreSide], _baseName)

                        -- (baseName, sideName, rsrConfig, spawnLC, missionInit, campaignStartSetup)
                        bases.resupply(_baseName, _logisticsCentreSide, rsrConfig, false, false, false) --activate base defences (FARP trucks) but DO NOT spawn logistics and NOT missionInit

                        if _conqueringUnit ~= "none" then
                            trigger.action.outTextForCoalition(_DCScoalition, _baseName .. " FARP claimed by " .. _logisticsCentreSide
                                    .. " team following construction of Logistics Centre by " .. _conqueringUnit, 10) --_conqueringUnit = playerName
                        end

                    end
                else
                    --exclude red/blueStagingPoint as cannot distinguish from FARP helipad, cannot hold logisitics centre and never change side
                    local _isStagingBase = false
                    for _k, _stagingBaseName in ipairs(rsrConfig.stagingBases) do
                        if _baseName == _stagingBaseName then
                            _isStagingBase = true
                        end
                    end

                    if not _isStagingBase then

                        if _RSRowner ~= "neutral" then
							--no logistics centre then set to owernship to neutral to block slot and other functions, as logisitics centre required for claim
							log:info("$1 OWNERSHIP CHANGE (no LC): [FARP] | CURRENT OWNER: _RSRowner: $2, NEW OWNER: neutral | _DCSsideName: $3", _baseName, _RSRowner, _DCSsideName)
							
                            utils.removeFARPownership(_baseName)
                            table.insert(baseOwnership.FARPs.neutral, _baseName)
                            bases.configureForSide(_baseName, "neutral") --slotBlocker.lua & pickupZoneManager.lua

                            if _conqueringUnit ~= "none" then
                                --trigger.action.outTextForCoalition(_FARPlogisticsCentreCoalition,_baseName .. " has been neutralized by " .. _conqueringUnit, 10)
                            end
                        end
                    end
                end

            elseif _DCSbaseCategory == Airbase.Category.SHIP then

                --[[
                local _shipName = _baseName
                local _shipGroup = base:getGroup
                -- e.g. Red Admiral Kuznetsov Carrier Group1 = "Group1"
                local _shipCarrierGroup = string.match(_shipName,("%w+$"))

                --get ship dependencies
                local _carrierGroupBaseOwnedBySide = utils.carrierActivateForBaseWhenOwnedBySide(_zone)
                local _carrierGroupActivationBase = baseOwnership.Ships[_carrierGroup]
                local _whenActivationBaseOwnedBySide = _carrierGroupActivationBase[_carrierActivateForBase]

                --determine activation base owner
                local _currActivationBaseOwner = utils.getCurrABside(_carrierGroupActivationBase)
                if _currActivationBaseOwner == "ABnotFound" then
                    _currActivationBaseOwner = utils.getCurrFARPside(_carrierGroupActivationBase)
                end
                if _currActivationBaseOwner == "FARPnotFound" then
                    log:error("$1 not found in 'baseOwnership.Airbases' or 'baseOwnership.FARPs' sides.",_carrierGroupActivationBase)
                end

                if _whenActivationBaseOwnedBySide == _currActivationBaseOwner then
                    -- activate ship and slots if part of carrier group with associated activation base owned by designated side
                    _shipGroup:activate() --mr: activate all ships but block slots instead?
                    bases.configureForSide(_shipName, _DCSsideName) --slotBlocker.lua & pickupZoneManager.lua
                else
                    -- block slots if part of carrier group with associated activation base owned by designated side
                    -- trigger.action.deactivateGroup -> Group.destroy = Destroys the object, physically removing it from the game world without creating an event
                    bases.configureForSide(_shipName, "neutral") --slotBlocker.lua & pickupZoneManager.lua
                end
                --]]
            end
        end
    else
        -- _baseName passed
        --[[
            no need to check everything for campaign and mission init
            do we need to check ownership when building a new CC?  Yes for FARP claim!

            if we pass the _baseName i.e. logisticsManager.lua -> spawnLogisticsCentre function in CTLD.lua, can we improve performance and if so, when?
                baseCapturedHandler.lua: _passedBaseName = "ALL" => check all bases due to DCS baseCaptured EH detecting base ownership change
                    > Yes. change to passing base as only that base firing DCS EH
                CTLD.lua: ctld.spawnLogisticsCentre function: _passedBaseName = "Airbase/FARP name" => during mission init
                    > No!  CANNOT search through logisitics centres that do not exist
                    > They should exist!
                CTLD.lua: ctld.spawnLogisticsCentre function: _passedBaseName = "Airbase/FARP name" => during normal gameplay
                    > Yes. change to passing base as only that base being repaired
        --]]
        local _baseName = "NoBaseName"
        local _passedBase = "NoPassedBase"
        for _k, base in ipairs(world.getAirbases()) do
            _baseName = base:getName()
            if _baseName == _passedBaseName then
                _passedBase = base
            end
        end

        local _DCScoalition = _passedBase:getCoalition()
        local _DCSsideName = utils.getSideName(_DCScoalition)  -- EVENTUALLY REPLACE WITH OUTCOME OF GROUD UNIT ENUMERATION
        if _DCSsideName == nil then
            log:info("No side returned for $1; setting to neutral", _baseName)
            _DCSsideName = "neutral"
        end
        local _DCSbaseCategory = _passedBase:getDesc().category
        local _RSRowner = "NoRSRowner"
        local _RSRcoalition = "NoRSRcoalition"

        --get logistics centre deails if present
        log:info("ctld.logisticCentreObjects $1", ctld.logisticCentreObjects)
        local _logisticsCentre = ctld.logisticCentreObjects[_baseName]
        local _logisticsCentreName = "noNAME"
        local _logisticsCentreSide = "noSIDE"
        local _logisticsCentreCoalition = 4
        if _logisticsCentre ~= nil then
            --interograte logistics centre static object to determine true RSR side
            _logisticsCentreName = _logisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
            _logisticsCentreSide = string.match(_logisticsCentreName, ("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
            _logisticsCentreCoalition = utils.getSide(_logisticsCentreSide)
        end
        log:info("_baseName: $1 _logisticsCentreName: $2", _baseName, _logisticsCentreName)
    end
    log:info("baseOwnership (_passedBaseName: $1) = $2", _passedBaseName, inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end
env.info("RSR STARTUP: baseOwnershipCheck.LUA LOADED")
return M
