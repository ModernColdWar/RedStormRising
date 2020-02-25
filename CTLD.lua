--[[
    Combat Troop and Logistics Drop

    Allows Huey, Mi-8 and C130 to transport troops internally and Helicopters to transport Logistic / Vehicle units to the field via sling-loads
    without requiring external mods.

    Supports all of the original CTTS functionality such as AI auto troop load and unload as well as group spawning and preloading of troops into units.

    Supports deployment of Auto Lasing JTAC to the field

    See https://github.com/ciribob/DCS-CTLD for a user manual and the latest version

	Contributors:
	    - Steggles - https://github.com/Bob7heBuilder
	    - mvee - https://github.com/mvee
	    - jmontleon - https://github.com/jmontleon
	    - emilianomolina - https://github.com/emilianomolina

    Version: 1.73 - 15/04/2018
      - Allow minimum distance from friendly logistics to be set
 ]]
-- luacheck: no max line length
env.info("RSR STARTUP: CTLD.LUA INIT")
require("mist_4_3_74")
require("CTLD_config")
require ("Moose")
local inspect = require("inspect")
local utils = require("utils")
local rsrConfig = require("RSR_config")
local baseOwnershipCheck = require("baseOwnershipCheck")
local logisticsManager = require("logisticsManager")
--local playerDetails = require("playerDetails")

local log = mist.Logger:new("CTLD", "info")

ctld.nextUnitId = 1;
ctld.getNextUnitId = function()
    ctld.nextUnitId = ctld.nextUnitId + 1

    return ctld.nextUnitId
end

ctld.nextGroupId = 1;
ctld.getNextGroupId = function()
    ctld.nextGroupId = ctld.nextGroupId + 1
    return ctld.nextGroupId
end

ctld.nextLogisiticsCentreId = 1;
ctld.getNextLogisiticsCentreId = function()
    ctld.nextLogisiticsCentreId = ctld.nextLogisiticsCentreId + 1
    return ctld.nextLogisiticsCentreId
end

--check if neutralCountry set correctly in Mission Editor --mr: MOVE TO validateMissionFile.lua?
function ctld.checkNeutralCountry ()
	local _neutralCoalitionCountries = env.mission.coalition.neutrals.country
	local _neutralCountrySetCorrectly = false
	for _k, _country in ipairs(_neutralCoalitionCountries) do
		local _countryName = _country.name
		if _countryName == ctld.neutralCountry then
			_neutralCountrySetCorrectly = true
			return (env.info("RSR MIZ SETUP: CTLD_config.lua: " .. _countryName .. " assigned as neutral country correctly"))
		end
	end
	if not _neutralCountrySetCorrectly then
		retrun (env.error("RSR MIZ SETUP: CTLD_config.lua: " .. ctld.neutralCountry .. " not assigned to neutral coalition in Mission Editor"))
	end
end

-- ***************************************************************
-- **************** Mission Editor Functions *********************
-- ***************************************************************


-----------------------------------------------------------------
-- Spawn group at a trigger and set them as extractable. Usage:
-- ctld.spawnGroupAtTrigger("groupside", number, "triggerName", radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group description
-- "triggerName" = trigger name in mission editor between commas
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtTrigger("red", 2, "spawn1", 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtTrigger("blue", {mg=1,at=2,aa=3,inf=4,mortar=5},"spawn2", 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
--
function ctld.spawnGroupAtTrigger(_groupSide, _number, _triggerName, _searchRadius)
    local _spawnTrigger = trigger.misc.getZone(_triggerName) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find trigger called " .. _triggerName, 10)
        return
    end

    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_pos3, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end


-----------------------------------------------------------------
-- Spawn group at a Vec3 Point and set them as extractable. Usage:
-- ctld.spawnGroupAtPoint("groupside", number,Vec3 Point, radius)
-- Variables:
-- "groupSide" = "red" for Russia "blue" for USA
-- _number = number of groups to spawn OR Group Description
-- Vec3 Point = A vec3 point like {x=1,y=2,z=3}. Can be obtained from a unit like so: Unit.getName("Unit1"):getPoint()
-- _searchRadius = random distance for units to move from spawn zone (0 will leave troops at the spawn position - no search for enemy)
--
-- Example: ctld.spawnGroupAtPoint("red", 2, {x=1,y=2,z=3}, 1000)
--
-- This example will spawn 2 groups of russians at the specified point
-- and they will search for enemy or move randomly withing 1000m
-- OR
--
-- ctld.spawnGroupAtPoint("blue", {mg=1,at=2,aa=3,inf=4,mortar=5}, {x=1,y=2,z=3}, 2000)
-- Spawns 1 machine gun, 2 anti tank, 3 anti air, 4 standard soldiers and 5 mortars
function ctld.spawnGroupAtPoint(_groupSide, _number, _point, _searchRadius)

    local _country
    if _groupSide == "red" then
        _groupSide = 1
        _country = 0
    else
        _groupSide = 2
        _country = 2
    end

    if _searchRadius < 0 then
        _searchRadius = 0
    end

    local _groupDetails = ctld.generateTroopTypes(_groupSide, _number, _country)

    local _droppedTroops = ctld.spawnDroppedGroup(_point, _groupDetails, false, _searchRadius);

    if _groupSide == 1 then
        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
    else
        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
    end
end


-- Preloads a transport with troops or vehicles
-- replaces any troops currently on board
function ctld.preLoadTransport(_unitName, _number, _troops)

    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then

        -- will replace any units currently on board
        --        if not ctld.troopsOnboard(_unit,_troops)  then
        ctld.loadTroops(_unit, _troops, _number)
        --        end
    end
end


-- Continuously counts the number of crates in a zone and sets the value of the passed in flag
-- to the count amount
-- This means you can trigger actions based on the count and also trigger messages before the count is reached
-- Just pass in the zone name and flag number like so as a single (NOT Continuous) Trigger
-- This will now work for Mission Editor and Spawned Crates
-- e.g. ctld.cratesInZone("DropZone1", 5)
function ctld.cratesInZone(_zone, _flagNumber)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zone, 10)
        return
    end

    local _zonePos = mist.utils.zoneToVec3(_zone)

    --ignore side, if crate has been used its discounted from the count
    local _crateTables = { ctld.spawnedCratesRED, ctld.spawnedCratesBLUE, ctld.missionEditorCargoCrates }

    local _crateCount = 0

    for _, _crates in pairs(_crateTables) do

        for _crateName, _ in pairs(_crates) do

            --get crate
            local _crate = ctld.getCrateObject(_crateName)

            --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
            if _crate ~= nil and _crate:getLife() > 0
                    and (ctld.inAir(_crate) == false) then

                local _dist = ctld.getDistance(_crate:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then
                    _crateCount = _crateCount + 1
                end
            end
        end
    end

    --set flag stuff
    trigger.action.setUserFlag(_flagNumber, _crateCount)

    -- env.info("FLAG ".._flagNumber.." crates ".._crateCount)

    --retrigger in 5 seconds
    timer.scheduleFunction(function(_args)

        ctld.cratesInZone(_args[1], _args[2])
    end, { _zone, _flagNumber }, timer.getTime() + 5)
end

-- Creates an extraction zone
-- any Soldiers (not vehicles) dropped at this zone by a helicopter will disappear
-- and be added to a running total of soldiers for a set flag number
-- The idea is you can then drop say 20 troops in a zone and trigger an action using the mission editor triggers
-- and the flag value
--
-- The ctld.createExtractZone function needs to be called once in a trigger action do script.
-- if you dont want smoke, pass -1 to the function.
--Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4, NO SMOKE = -1
--
-- e.g. ctld.createExtractZone("extractzone1", 2, -1) will create an extraction zone at trigger zone "extractzone1", store the number of troops dropped at
-- the zone in flag 2 and not have smoke
--
--
--
function ctld.createExtractZone(_zone, _flagNumber, _smoke)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zone, 10)
        return
    end

    local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
    local _alt = land.getHeight(_pos2)
    local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

    trigger.action.setUserFlag(_flagNumber, 0) --start at 0

    local _details = { point = _pos3, name = _zone, smoke = _smoke, flag = _flagNumber, radius = _triggerZone.radius }

    ctld.extractZones[_zone .. "-" .. _flagNumber] = _details

    if _smoke ~= nil and _smoke > -1 then

        local _smokeFunction

        _smokeFunction = function(_args)

            local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]
            -- check zone is still active
            if _extractDetails == nil then
                -- stop refreshing smoke, zone is done
                return
            end

            trigger.action.smoke(_args.point, _args.smoke)
            --refresh in 5 minutes
            timer.scheduleFunction(_smokeFunction, _args, timer.getTime() + 300)
        end

        --run local function
        _smokeFunction(_details)
    end
end


-- Removes an extraction zone
--
-- The smoke will take up to 5 minutes to disappear depending on the last time the smoke was activated
--
-- The ctld.removeExtractZone function needs to be called once in a trigger action do script.
--
-- e.g. ctld.removeExtractZone("extractzone1", 2) will remove an extraction zone at trigger zone "extractzone1"
-- that was setup with flag 2
--
--
--
function ctld.removeExtractZone(_zone, _flagNumber)

    local _extractDetails = ctld.extractZones[_zone .. "-" .. _flagNumber]

    if _extractDetails ~= nil then
        --remove zone
        ctld.extractZones[_zone .. "-" .. _flagNumber] = nil

    end
end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- GROUPS in a zone and store the values in two flags
-- A group is only counted as being in a zone when the leader of that group
-- is in the zone
-- Use: ctld.countDroppedGroupsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedGroupsInZone(_zone, _blueFlag, _redFlag)

    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zone, 10)
        return
    end

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld.droppedVehiclesBLUE }
    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then
                local _zonePos = mist.utils.zoneToVec3(_zone)
                local _dist = ctld.getDistance(_groupUnits[1]:getPoint(), _zonePos)

                if _dist <= _triggerZone.radius then

                    if (_groupUnits[1]:getCoalition() == 1) then
                        _redCount = _redCount + 1;
                    else
                        _blueCount = _blueCount + 1;
                    end
                end
            end
        end
    end
    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --  env.info("Groups in zone ".._blueCount.." ".._redCount)

end

-- CONTINUOUS TRIGGER FUNCTION
-- This function will count the current number of extractable RED and BLUE
-- UNITS in a zone and store the values in two flags

-- Use: ctld.countDroppedUnitsInZone("Zone Name", flagBlue, flagRed)
function ctld.countDroppedUnitsInZone(_zone, _blueFlag, _redFlag)

    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zone, 10)
        return
    end

    local _redCount = 0;
    local _blueCount = 0;

    local _allGroups = { ctld.droppedTroopsRED, ctld.droppedTroopsBLUE, ctld.droppedVehiclesRED, ctld.droppedVehiclesBLUE }

    for _, _extractGroups in pairs(_allGroups) do
        for _, _groupName in pairs(_extractGroups) do
            local _groupUnits = ctld.getGroup(_groupName)

            if #_groupUnits > 0 then

                local _zonePos = mist.utils.zoneToVec3(_zone)
                for _, _unit in pairs(_groupUnits) do
                    local _dist = ctld.getDistance(_unit:getPoint(), _zonePos)

                    if _dist <= _triggerZone.radius then

                        if (_unit:getCoalition() == 1) then
                            _redCount = _redCount + 1;
                        else
                            _blueCount = _blueCount + 1;
                        end
                    end
                end
            end
        end
    end


    --set flag stuff
    trigger.action.setUserFlag(_blueFlag, _blueCount)
    trigger.action.setUserFlag(_redFlag, _redCount)

    --  env.info("Units in zone ".._blueCount.." ".._redCount)
end


-- Creates a radio beacon on a random UHF - VHF and HF/FM frequency for homing
-- This WILL NOT WORK if you dont add beacon.ogg and beaconsilent.ogg to the mission!!!
-- e.g. ctld.createRadioBeaconAtZone("beaconZone","red", 1440,"Waypoint 1") will create a beacon at trigger zone "beaconZone" for the Red side
-- that will last 1440 minutes (24 hours ) and named "Waypoint 1" in the list of radio beacons
--
-- e.g. ctld.createRadioBeaconAtZone("beaconZoneBlue","blue", 20) will create a beacon at trigger zone "beaconZoneBlue" for the Blue side
-- that will last 20 minutes
function ctld.createRadioBeaconAtZone(_zone, _coalition, _batteryLife, _name)
    local _triggerZone = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zone, 10)
        return
    end

    local _zonePos = mist.utils.zoneToVec3(_zone)

    ctld.beaconCount = ctld.beaconCount + 1

    if _name == nil or _name == "" then
        _name = "Beacon #" .. ctld.beaconCount
    end

    if _coalition == "red" then
        ctld.createRadioBeacon(_zonePos, 1, 0, _name, _batteryLife) --1440
    else
        ctld.createRadioBeacon(_zonePos, 2, 2, _name, _batteryLife) --1440
    end
end


-- Activates a pickup zone
-- Activates a pickup zone when called from a trigger
-- EG: ctld.activatePickupZone("pickzone3")
-- This is enable pickzone3 to be used as a pickup zone for the team set
function ctld.activatePickupZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end

    end

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone or ship called " .. _zoneName, 10)

    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do

        if _zoneName == _zoneDetails[1] then

            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[4] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                --trigger.action.outText("CTLD.lua ERROR: Pickup Zone already active: " .. _zoneName, 10)
                return
            end

            _zoneDetails[4] = 1 --activate zone

            if ctld.disableAllSmoke == true then
                --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then

                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end


-- Deactivates a pickup zone
-- Deactivates a pickup zone when called from a trigger
-- EG: ctld.deactivatePickupZone("pickzone3")
-- This is disables pickzone3 and can no longer be used to as a pickup zone
-- These functions can be called by triggers, like if a set of buildings is used, you can trigger the zone to be 'not operational'
-- once they are destroyed
function ctld.deactivatePickupZone(_zoneName)

    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end

    end

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zoneName, 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do

        if _zoneName == _zoneDetails[1] then

            -- i'd just ignore it if its already been deactivated
            --            if _zoneDetails[4] == 0 then --this really needed??
            --            trigger.action.outText("CTLD.lua ERROR: Pickup Zone already deactiveated: " .. _zoneName, 10)
            --            return
            --            end

            _zoneDetails[4] = 0 --deactivate zone
        end
    end
end

-- Change the remaining groups currently available for pickup at a zone
-- e.g. ctld.changeRemainingGroupsForPickupZone("pickup1", 5) -- adds 5 groups
-- ctld.changeRemainingGroupsForPickupZone("pickup1", -3) -- remove 3 groups
function ctld.changeRemainingGroupsForPickupZone(_zoneName, _amount)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position

    if _triggerZone == nil then
        local _ship = ctld.getTransportUnit(_triggerZone)

        if _ship then
            local _point = _ship:getPoint()
            _triggerZone = {}
            _triggerZone.point = _point
        end

    end

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ctld.changeRemainingGroupsForPickupZone ERROR: Cant find zone called " .. _zoneName, 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do

        if _zoneName == _zoneDetails[1] then
            ctld.updateZoneCounter(_zoneName, _amount)
        end
    end


end

-- Activates a Waypoint zone
-- Activates a Waypoint zone when called from a trigger
-- EG: ctld.activateWaypointZone("pickzone3")
-- This means that troops dropped within the radius of the zone will head to the center
-- of the zone instead of searching for troops
function ctld.activateWaypointZone(_zoneName)
    local _triggerZone = trigger.misc.getZone(_zoneName) -- trigger to use as reference position


    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone  called " .. _zoneName, 10)

        return
    end

    for _, _zoneDetails in pairs(ctld.wpZones) do

        if _zoneName == _zoneDetails[1] then

            --smoke could get messy if designer keeps calling this on an active zone, check its not active first
            if _zoneDetails[3] == 1 then
                -- they might have a continuous trigger so i've hidden the warning
                --trigger.action.outText("CTLD.lua ERROR: Pickup Zone already active: " .. _zoneName, 10)
                return
            end

            _zoneDetails[3] = 1 --activate zone

            if ctld.disableAllSmoke == true then
                --smoke disabled
                return
            end

            if _zoneDetails[2] >= 0 then

                -- Trigger smoke marker
                -- This will cause an overlapping smoke marker on next refreshsmoke call
                -- but will only happen once
                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end
end


-- Deactivates a Waypoint zone
-- Deactivates a Waypoint zone when called from a trigger
-- EG: ctld.deactivateWaypointZone("wpzone3")
-- This  disables wpzone3 so that troops dropped in this zone will search for troops as normal
-- These functions can be called by triggers
function ctld.deactivateWaypointZone(_zoneName)

    local _triggerZone = trigger.misc.getZone(_zoneName)

    if _triggerZone == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zoneName, 10)
        return
    end

    for _, _zoneDetails in pairs(ctld.pickupZones) do

        if _zoneName == _zoneDetails[1] then

            _zoneDetails[3] = 0 --deactivate zone
        end
    end
end

-- Continuous Trigger Function
-- Causes an AI unit with the specified name to unload troops / vehicles when
-- an enemy is detected within a specified distance
-- The enemy must have Line of Sight to the unit to be detected
function ctld.unloadInProximityToEnemy(_unitName, _distance)

    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil and _unit:getPlayerName() == nil then

        -- no player name means AI!
        -- the findNearest visible enemy you'd want to modify as it'll find enemies quite far away
        -- limited by  ctld.JTAC_maxDistance
        local _nearestEnemy = ctld.findNearestVisibleEnemy(_unit, "all", _distance)

        if _nearestEnemy ~= nil then

            if ctld.troopsOnboard(_unit, true) then
                ctld.deployTroops(_unit, true)
                return true
            end

            if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
                ctld.deployTroops(_unit, false)
                return true
            end
        end
    end

    return false

end



-- Unit will unload any units onboard if the unit is on the ground
-- when this function is called
function ctld.unloadTransport(_unitName)

    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then

        if ctld.troopsOnboard(_unit, true) then
            ctld.unloadTroops({ _unitName, true })
        end

        if ctld.unitCanCarryVehicles(_unit) and ctld.troopsOnboard(_unit, false) then
            ctld.unloadTroops({ _unitName, false })
        end
    end

end

-- Loads Troops and Vehicles from a zone or picks up nearby troops or vehicles
function ctld.loadTransport(_unitName)

    local _unit = ctld.getTransportUnit(_unitName)

    if _unit ~= nil then

        ctld.loadTroopsFromZone({ _unitName, true, "", true })

        if ctld.unitCanCarryVehicles(_unit) then
            ctld.loadTroopsFromZone({ _unitName, false, "", true })
        end

    end

end

-- adds a callback that will be called for many actions ingame
function ctld.addCallback(_callback)

    table.insert(ctld.callbacks, _callback)

end

-- Spawns a sling loadable crate at a Trigger Zone
--
-- Weights can be found in the ctld.spawnableCrates list
-- e.g. ctld.spawnCrateAtZone("red", 500,"triggerzone1") -- spawn a humvee at triggerzone 1 for red side
-- e.g. ctld.spawnCrateAtZone("blue", 505,"triggerzone1") -- spawn a tow humvee at triggerzone1 for blue side
--
function ctld.spawnCrateAtZone(_side, _weight, _zone)
    local _spawnTrigger = trigger.misc.getZone(_zone) -- trigger to use as reference position

    if _spawnTrigger == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find zone called " .. _zone, 10)
        return
    end

    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find crate with weight " .. _weight, 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _pos2 = { x = _spawnTrigger.point.x, y = _spawnTrigger.point.z }
    local _alt = land.getHeight(_pos2)
    local _point = { x = _pos2.x, y = _alt, z = _pos2.y }

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side)

end

-- Spawns a sling loadable crate at a Point
--
-- Weights can be found in the ctld.spawnableCrates list
-- Points can be made by hand or obtained from a Unit position by Unit.getByName("PilotName"):getPoint()
-- e.g. ctld.spawnCrateAtZone("red", 500,{x=1,y=2,z=3}) -- spawn a humvee at triggerzone 1 for red side at a specified point
-- e.g. ctld.spawnCrateAtZone("blue", 505,{x=1,y=2,z=3}) -- spawn a tow humvee at triggerzone1 for blue side at a specified point
--
--
function ctld.spawnCrateAtPoint(_side, _weight, _point)


    local _crateType = ctld.crateLookupTable[tostring(_weight)]

    if _crateType == nil then
        trigger.action.outText("CTLD.lua ERROR: Cant find crate with weight " .. _weight, 10)
        return
    end

    local _country
    if _side == "red" then
        _side = 1
        _country = 0
    else
        _side = 2
        _country = 2
    end

    local _unitId = ctld.getNextUnitId()

    local _name = string.format("%s #%i", _crateType.desc, _unitId)

    ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight, _side)

end

-- ***************************************************************
-- **************** BE CAREFUL BELOW HERE ************************
-- ***************************************************************

ctld.crateWait = {}
ctld.crateMove = {}

---------------- INTERNAL FUNCTIONS ----------------
function ctld.getTransportUnit(_unitName)

    if _unitName == nil then
        return nil
    end

    local _heli = Unit.getByName(_unitName)

    if _heli ~= nil and _heli:isActive() and _heli:getLife() > 0 then

        return _heli
    end

    return nil
end

function ctld.spawnCrateStatic(_country, _unitId, _point, _name, _weight, _side, _internal)
    --Ironwulf2000 added _internal for internal crate carriage support

    local _crate
    local _spawnedCrate
	
	--ctld.spawnCrate: local _name = string.format("%s #%i (%s)", _crateType.desc, _unitId, _nearestLogisticsCentreName)
	local _baseOfOriginFromName = string.match(_name, "%((.+)%)$")
	
    if ctld.staticBugWorkaround and ctld.slingLoad == false then --NOT USED FOR RSR
        local _groupId = ctld.getNextGroupId()
        local _groupName = "Crate Group #" .. _groupId

        local _group = {
            ["visible"] = false,
            -- ["groupId"] = _groupId,
            ["hidden"] = false,
            ["units"] = {},
            --        ["y"] = _positions[1].z,
            --        ["x"] = _positions[1].x,
            ["name"] = _groupName,
            ["task"] = {},
        }
		local _baseOfOriginRemovedFromName = string.gsub(_name, "%((.+)%)$", "") -- remove base from name to hide base of origin from unit name
		-- HUMVEE FOR BLUE IF TO USE FOR RSR
        _group.units[1] = ctld.createUnit(_point.x, _point.z, 0, { type = "UAZ-469", name = _baseOfOriginRemovedFromName, unitId = _unitId })

        --switch to MIST
        _group.category = Group.Category.GROUND;
        _group.country = _country;

        local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)

        -- Turn off AI
        trigger.action.setGroupAIOff(_spawnedGroup)

        _spawnedCrate = Unit.getByName(_baseOfOriginRemovedFromName)
    else

        if ctld.slingLoad and _internal ~= 1 then
            _crate = {
                ["category"] = "Cargos", --now plurar
                --["shape_name"] = "bw_container_cargo", --new slingloadable container
                --["type"] = "container_cargo", --new type
                ["shape_name"] = "iso_container_small_cargo",
                ["type"] = "iso_container_small",
                -- ["unitId"] = _unitId,
                ["y"] = _point.z,
                ["x"] = _point.x,
                ["mass"] = _weight,
                ["name"] = _name,
                ["canCargo"] = true,
                ["heading"] = 0,
                --            ["displayName"] = "name 2", -- getCargoDisplayName function exists but no way to set the variable
                --            ["DisplayName"] = "name 2",
                --            ["cargoDisplayName"] = "cargo123",
                --            ["CargoDisplayName"] = "cargo123",
            }

            --[[ Placeholder for different type of cargo containers. Let's say pipes and trunks, fuel for FOB building

                        ["shape_name"] = "ab-212_cargo",
                        ["type"] = "uh1h_cargo" --new type for the container previously used

                        ["shape_name"] = "ammo_box_cargo",
                        ["type"] = "ammo_cargo",

                        ["shape_name"] = "barrels_cargo",
                        ["type"] = "barrels_cargo",

                        ["shape_name"] = "bw_container_cargo",
                        ["type"] = "container_cargo",

                        ["shape_name"] = "f_bar_cargo",
                        ["type"] = "f_bar_cargo",

                        ["shape_name"] = "fueltank_cargo",
                        ["type"] = "fueltank_cargo",

                        ["shape_name"] = "iso_container_cargo",
                        ["type"] = "iso_container",

                        ["shape_name"] = "iso_container_small_cargo",
                        ["type"] = "iso_container_small",

                        ["shape_name"] = "oiltank_cargo",
                                    ["type"] = "oiltank_cargo",

                        ["shape_name"] = "pipes_big_cargo",
                                    ["type"] = "pipes_big_cargo",

                        ["shape_name"] = "pipes_small_cargo",
                        ["type"] = "pipes_small_cargo",

                        ["shape_name"] = "tetrapod_cargo",
                        ["type"] = "tetrapod_cargo",

                        ["shape_name"] = "trunks_long_cargo",
                        ["type"] = "trunks_long_cargo",

                        ["shape_name"] = "trunks_small_cargo",
                        ["type"] = "trunks_small_cargo",
            ]]--
        else
            _crate = {
                ["shape_name"] = "bw_container_cargo",
                ["type"] = "container_cargo",
                --   ["unitId"] = _unitId,
                ["y"] = _point.z,
                ["x"] = _point.x,
                ["name"] = _name,
                ["category"] = "Fortifications",
                ["canCargo"] = true,
                ["heading"] = 0,
                ["mass"] = _weight,
            }
        end

        _crate["country"] = _country
        mist.dynAddStatic(_crate)

        _spawnedCrate = StaticObject.getByName(_crate["name"])
    end
	
	-- { weight = 503, desc = "Logistics Centre crate", unit = "LogisticsCentre", internal = 1 }
    local _crateType = ctld.crateLookupTable[tostring(_weight)]
	_crateType.baseOfOrigin = _baseOfOriginFromName
	
    if _side == 1 then
        ctld.spawnedCratesRED[_name] = _crateType 
    else
        ctld.spawnedCratesBLUE[_name] = _crateType
    end
	log:info("_name: $1, _crateType: $2, _spawnedCrate: $3",_name,inspect(_crateType, { newline = " ", indent = "" }),inspect(_spawnedCrate, { newline = " ", indent = "" }))
    return _spawnedCrate
end

function ctld.spawnLogisticsCentreCrateStatic(_country, _point, _name)

    local _crate = {
        ["category"] = "Fortifications",
        ["shape_name"] = "konteiner_red1",
        ["type"] = "Container red 1",
        --   ["unitId"] = _unitId,
        ["y"] = _point.z,
        ["x"] = _point.x,
        ["name"] = _name,
        ["canCargo"] = false,
        ["heading"] = 0,
    }

    _crate["country"] = _country

    mist.dynAddStatic(_crate)

    local _spawnedCrate = StaticObject.getByName(_crate["name"])
    --local _spawnedCrate = coalition.addStaticObject(_country, _crate)

    return _spawnedCrate
end

function ctld.spawnLogisticsCentre(_point, _name, _coalition, _baseORfob, _baseORfobName, _isMissionInit,_constructingPlayerName)
	
	local _logiCentreType = ctld.logisticCentreL3 --bunker
	
	if _baseORfob == "FOB" then
		_logiCentreType = ctld.logisticCentreL2 --outpost
	end
	
	local _playerName = "none"
	if _constructingPlayerName ~= "none" then
		_playerName = _constructingPlayerName
	end
	
	local _logiCentre = 
	{
		["category"] = "Fortifications",
		["type"] = _logiCentreType,
		--  ["unitId"] = _unitId,
		["y"] = _point.z,
		["x"] = _point.x,
		["name"] = _name,
		["canCargo"] = false,
		["heading"] = 0,
		["country"] = ctld.neutralCountry --mr: need to ensure country is part of neutral coalition e.g. Greece = neutral static object
		
		--["RSRteam"] = utils.getSideName(_coalition) 
		--mr: use team so as not to be confused with other DCS settings. is it possible to assign are own tables within an DCS object's table?
		--mr: even if this is possible, would need to reassign this after server restart as custom entry for respawned static objects?
		--mr: >>> All logistics centred spawned using ctld.spawnLogisticsCentre, even at mission/campaign init!  Therefore this method would be great if works.	
	}
	
    mist.dynAddStatic(_logiCentre)
    local _spawnedLogiCentreObject = StaticObject.getByName(_logiCentre["name"])

	-- use baseName as index for logistic centres, as should only be 1 x logistics centre per airbase/FARP at one time
	-- use playerName as index for FOBs?  Limit 1 x FOB per player?s
	-- during normal gameplay, update pre-existing key for each base with new logistics centre
	ctld.logisticCentreObjects[_baseORfobName] = _spawnedLogiCentreObject

	-- Tank1:HandleEvent( EVENTS.Dead ) -- MOOSE DEAD eventHandler for logisitics centre -> baseOwnershipCheck -> no slot at neutral FARPs
	--[[
		mist.dynAddStatic => addStaticObject
					unitID required?  If not set, new static object of same name will overwrite (= delete? = advantageous for repair) old object
					> https://wiki.hoggitworld.com/view/DCS_func_addStaticObject
					>> Static Objects name cannot be shared with an existing object, if it is the existing object will be destroyed on the spawning of the new object.
					>> If unitId is not specified or matches an existing object, a new Id will be generated.
					>> Coalition of the object is defined based on the country the object is spawning to.
		
		["rate"] = number value for the "score" of the object when it is killed --mr: use to allow assigning points for logistic centre kills
	--]]
	local _LCmarkerID = UTILS.GetMarkID()
    trigger.action.markToCoalition(_LCmarkerID,_name,_point,_coalition,true)
	ctld.logisticCentreMarkerID[_baseORfobName] = _LCmarkerID
	
	--[[
		initate checking all bases for differences = 
			> baseOwnershipCheck.lua & Airbases: contruction of logistics centre should not produce any updates to ownership, only its absence when uncontested by enemy
			> baseOwnershipCheck.lua & FARPs: contructions of logistics centre claims uncontested FARP
		false = not campaignStartSetup which is only utilsed to setup base ownership from zone name and color
		_aircraft = for team notification of which friendly player captured FARP = encourage logisitics
		by-passed during campaign and mission init i.e. logisticsManager.lua -> spawnLogisticsCentre
		will also return baseOwnership table even though not needed
	--]]
	
	-- passing specific baseName prevents checking all bases in baseOwnershipCheck.lua
	-- at mission init do NOT check through all bases, just check that new logisitics centre side in name matches base side
	-- during mission check through all bases for as new logistics centres at FARPs claims FARP
	--
	local _checkWhichBases = "ALL"
	if _isMissionInit then
		_checkWhichBases = _baseORfobName
	end
	--(_passedBaseName,_playerORunit,_campaignStartSetup)
	baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership(_checkWhichBases,_playerName,false)
	log:info("_isMissionInit: $1, _checkWhichBases: $2, _spawnedLogiCentreObject: $3",_isMissionInit,_checkWhichBases,mist.utils.basicSerialize(_spawnedLogiCentreObject))
	
    return _spawnedLogiCentreObject
end

--only helos should be able to spawn crates (check ctld.unitActions in CTLD_config.lua)
function ctld.spawnCrate(_arguments)

    local _status, _err = pcall(function(_args)

        -- use the cargo weight to guess the type of unit as no way to add description :(

        local _crateType = ctld.crateLookupTable[tostring(_args[2])]
        --Ironwulf2000 added
        local _internal = _args[3] == 1 and 1 or 0
        local _heli = ctld.getTransportUnit(_args[1])
		
		--{_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}
		local _baseProximity = ctld.baseProximity(_heli)
		local _inBaseZoneAndRSRrepairRadius = _baseProximity[1]
		local _inFOBexclusionZone = _baseProximity[2]
		local _closestBaseName = _baseProximity[3][1]
		local _closestBaseSide = _baseProximity[3][2]
		local _closestBaseDist = _baseProximity[3][3]
		local _baseType = _baseProximity[4]
		
		local _friendlyLogisticsCentreProximity = ctld.friendlyLogisticsCentreProximity(_heli)
		local _nearestLogisticsCentreName = _friendlyLogisticsCentreProximity[1] --(rare) if no friendly LC at all = "NoFriendlyLC"
		local _nearestLogisticsCentreDist = _friendlyLogisticsCentreProximity[2] --(rare) if no friendly LC at all = "NoDist"
		local _nearestLogisticsCentreBaseName = _friendlyLogisticsCentreProximity[3] --(rare) if no friendly LC at all = "NoBase"

        if _crateType ~= nil and _heli ~= nil and ctld.inAir(_heli) == false then
		
			local _logisticsCentreReq = true
			if _inBaseZoneAndRSRrepairRadius then
				-- airbases/FARPs that if within, do not require a logisitics centre to be present e.g. Gas Platforms
				-- ctld.logisticCentreNotReqInBase = {"RedStagingPoint", "BlueStagingPoint"}
				for _k, _base in pairs(ctld.logisticCentreNotReqInBase) do
					if _base == _closestBaseName then
						_logisticsCentreReq = false
					end
				end
			end
			
			if _logisticsCentreReq then
				if (_nearestLogisticsCentreDist <= ctld.maximumDistanceLogistic) == true and ctld.debug == false then
					ctld.displayMessageToGroup(_heli, "You are not close enough to friendly logistics to get a crate!", 10)
					return
				end
			end
			
			if not _logisticsCentreReq and _internal == 0 then
					ctld.displayMessageToGroup(_heli, "Only internal crates are available from " .. _closestBaseName, 10)
					return
			end		
			
			local _playerDetails = {} -- fill with dummy values for non-MP testing
			--[[
			if DCS.isMultiplayer() then
				_playerDetails = playerDetails.getPlayerDetails(_heli:getName())
			end
			--]]
			--[[
				'id'    : playerID
				'name'  : player name
				'side'  : 0 - spectators, 1 - red, 2 - blue
				'slot'  : slotID of the player or 
				'ping'  : ping of the player in ms
				'ipaddr': IP address of the player, SERVER ONLY
				'ucid'  : Unique Client Identifier, SERVER ONLY
			--]]
			local _playerUCID = _playerDetails['ucid']
		
			local _heliCoalition = _heli:getCoalition()

            if ctld.isJTACUnitType(_crateType.unit) then

                local _limitHit = false

                if _heliCoalition == 1 then

                    if ctld.JTAC_LIMIT_RED == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_RED = ctld.JTAC_LIMIT_RED - 1
                    end
                else
                    if ctld.JTAC_LIMIT_BLUE == 0 then
                        _limitHit = true
                    else
                        ctld.JTAC_LIMIT_BLUE = ctld.JTAC_LIMIT_BLUE - 1
                    end
                end

                if _limitHit then
                    ctld.displayMessageToGroup(_heli, "No more JTAC crates Left!", 10)
                    return
                end
			--[[
				-- give player warning if they have already reached their JTAC limit to prevent uncessary trips
				local _playerJTACsForSide = ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition]
				local _playerJTACsForSideCount = 0
				if _playerJTACsForSide ~= nil then
					for _k, _JTACgroup in ipairs (_playerJTACsForSide) do
						if (_JTACgroup:getUnit) == nil then
							table.remove(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],_k)
						else
							_playerJTACsForSideCount = _playerJTACsForSideCount + 1
						end
					end	
				end
				if ctld.JTAC_LIMIT_perPLAYER_perSIDE > _playerJTACsForSideCount then
					ctld.displayMessageToGroup(_heli, "WARNING - JTACs per player per side limit (" .. ctld.JTAC_LIMIT_perPLAYER_perSIDE .. ") reached. Unpacking this crate will delete the oldest JTAC you have deployed for this side.", 20)
				end
			--]]
            end

            -- check crate spam
            if _heli:getPlayerName() ~= nil and ctld.crateWait[_heli:getPlayerName()] and ctld.crateWait[_heli:getPlayerName()] > timer.getTime() then

                ctld.displayMessageToGroup(_heli, "Sorry you must wait " .. (ctld.crateWait[_heli:getPlayerName()] - timer.getTime()) .. " seconds before you can get another crate", 20)
                return
            end

            if _heli:getPlayerName() ~= nil then
                ctld.crateWait[_heli:getPlayerName()] = timer.getTime() + ctld.crateWaitTime
            end
            --   trigger.action.outText("Spawn Crate".._args[1].." ".._args[2],10)

			local _side = _heli:getCoalition()
			local _unitId = ctld.getNextUnitId()
			-- add _nearestLogisticsCentreBaseName to crate name for later origin checks
			-- _nameBaseHidden = string.gsub(_name, "%((.+)%)$", "")
            local _name = string.format("%s #%i (%s)", _crateType.desc, _unitId, _nearestLogisticsCentreBaseName) 

			if not _logisticsCentreReq and _internal == 1 then
				log:info ("spawnCrate: not _logisticsCentreReq: _crateType: $1",inspect(_crateType, { newline = " ", indent = "" }))
				
				local _crateDetails = _crateType
				_crateDetails.baseOfOrigin = _closestBaseName
				
				if _crateType.weight == 503 then
					ctld.inTransitLogisticsCentreCrates[_heli:getName()] = _crateDetails
					ctld.displayMessageToGroup(_heli, string.format("A %s crate has been provisioned and loaded", _crateType.desc), 20)
				elseif _crateType.weight == 501 or _crateType.weight == 502 then
					ctld.inTransitSlingLoadCrates[_heli:getName()] = _crateDetails
					ctld.displayMessageToGroup(_heli, string.format("A %s crate has been provisioned and loaded", _crateType.desc), 20)
				else
					env.info("Couldn't find internal crate to provision and load at " .. _closestBaseName)
				end

			else
				local _point = ctld.getPointAt12Oclock(_heli, 30)
				ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _crateType.weight, _side, _internal)

				-- add to move table
				ctld.crateMove[_name] = _name

				ctld.displayMessageToGroup(_heli, string.format("A %s crate weighing %s kg has been brought out and is at your 12 o'clock", _crateType.desc, _crateType.weight), 20)
			end

        else
            env.info("Couldn't find crate item to spawn")
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end

function ctld.getPointAt12Oclock(_unit, _offset)

    local _position = _unit:getPosition()
    local _angle = math.atan2(_position.x.z, _position.x.x)
    local _xOffset = math.cos(_angle) * _offset
    local _yOffset = math.sin(_angle) * _offset

    local _point = _unit:getPoint()
    return { x = _point.x + _xOffset, z = _point.z + _yOffset, y = _point.y }
end

function ctld.getPointAtXOclock(_unit, _oclock, _offset)
    -- Ironwulf2000 Added
    -- Returns a position at X O'clock from current position, at offset distance
    local _position = _unit:getPosition()
    local _angle = math.atan2(_position.x.z, _position.x.x)
    if _oclock == 12 then
        _oclock = 0
    end
    local _offsetangle = math.rad(_oclock / 12 * 360)

    local _xOffset = math.cos(_angle + _offsetangle) * _offset
    local _yOffset = math.sin(_angle + _offsetangle) * _offset

    local _point = _unit:getPoint()
    return { x = _point.x + _xOffset, z = _point.z + _yOffset, y = _point.y }

end

function ctld.troopsOnboard(_heli, _troops)

    if ctld.inTransitTroops[_heli:getName()] ~= nil then

        local _onboard = ctld.inTransitTroops[_heli:getName()]

        if _troops then

            if _onboard.troops ~= nil and _onboard.troops.units ~= nil and #_onboard.troops.units > 0 then
                return true
            else
                return false
            end
        else

            if _onboard.vehicles ~= nil and _onboard.vehicles.units ~= nil and #_onboard.vehicles.units > 0 then
                return true
            else
                return false
            end
        end

    else
        return false
    end
end

-- if its dropped by AI then there is no player name so return the type of unit
function ctld.getPlayerNameOrType(_heli)

    if _heli:getPlayerName() == nil then

        return _heli:getTypeName()
    else
        return _heli:getPlayerName()
    end
end

function ctld.inExtractZone(_heli)

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.extractZones) do

        --get distance to center
        local _dist = ctld.getDistance(_heliPoint, _zoneDetails.point)

        if _dist <= _zoneDetails.radius then
            return _zoneDetails
        end
    end

    return false
end

-- safe to fast rope if speed is less than 0.5 Meters per second
function ctld.safeToFastRope(_heli)

    if ctld.enableFastRopeInsertion == false then
        return false
    end

    --landed or speed is less than 8 km/h and height is less than fast rope height
    if (ctld.inAir(_heli) == false or (ctld.heightDiff(_heli) <= ctld.fastRopeMaximumHeight + 3.0 and mist.vec.mag(_heli:getVelocity()) < 2.2)) then
        return true
    end
end

function ctld.metersToFeet(_meters)

    local _feet = _meters * 3.2808399

    return mist.utils.round(_feet)
end

function ctld.inAir(_heli)

    if _heli:inAir() == false then
        return false
    end

    -- less than 5 cm/s a second so landed
    -- BUT AI can hold a perfect hover so ignore AI
    if mist.vec.mag(_heli:getVelocity()) < 0.05 and _heli:getPlayerName() ~= nil then
        return false
    end
    return true
end

function ctld.deployTroops(_heli, _troops)

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    -- deloy troops
    if _troops then
        if _onboard.troops ~= nil and #_onboard.troops.units > 0 then
            if ctld.inAir(_heli) == false or ctld.safeToFastRope(_heli) then

                -- check we're not in extract zone
                local _extractZone = ctld.inExtractZone(_heli)

                if _extractZone == false then

                    local _droppedTroops = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.troops, false)

                    if _heli:getCoalition() == 1 then

                        table.insert(ctld.droppedTroopsRED, _droppedTroops:getName())
                    else

                        table.insert(ctld.droppedTroopsBLUE, _droppedTroops:getName())
                    end

                    ctld.inTransitTroops[_heli:getName()].troops = nil

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " troops fast-ropped from " .. _heli:getTypeName() .. " into combat", 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " troops dropped from " .. _heli:getTypeName() .. " into combat", 10)
                    end

                    ctld.processCallback({ unit = _heli, unloaded = _droppedTroops, action = "dropped_troops" })


                else
                    --extract zone!
                    local _droppedCount = trigger.misc.getUserFlag(_extractZone.flag)

                    _droppedCount = (#_onboard.troops.units) + _droppedCount

                    trigger.action.setUserFlag(_extractZone.flag, _droppedCount)

                    ctld.inTransitTroops[_heli:getName()].troops = nil

                    if ctld.inAir(_heli) then
                        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " troops fast-ropped from " .. _heli:getTypeName() .. " into " .. _extractZone.name, 10)
                    else
                        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " troops dropped from " .. _heli:getTypeName() .. " into " .. _extractZone.name, 10)
                    end
                end
            else
                ctld.displayMessageToGroup(_heli, "Too high or too fast to drop troops into combat! Hover below " .. ctld.metersToFeet(ctld.fastRopeMaximumHeight) .. " feet or land.", 10)
            end
        end

    else
        if ctld.inAir(_heli) == false then
            if _onboard.vehicles ~= nil and #_onboard.vehicles.units > 0 then

                local _droppedVehicles = ctld.spawnDroppedGroup(_heli:getPoint(), _onboard.vehicles, true)

                if _heli:getCoalition() == 1 then

                    table.insert(ctld.droppedVehiclesRED, _droppedVehicles:getName())
                else

                    table.insert(ctld.droppedVehiclesBLUE, _droppedVehicles:getName())
                end

                ctld.inTransitTroops[_heli:getName()].vehicles = nil

                ctld.processCallback({ unit = _heli, unloaded = _droppedVehicles, action = "dropped_vehicles" })

                trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " dropped vehicles from " .. _heli:getTypeName() .. " into combat", 10)
            end
        end
    end
end

function ctld.insertIntoTroopsArray(_troopType, _count, _troopArray)

    for _ = 1, _count do
        local _unitId = ctld.getNextUnitId()
        table.insert(_troopArray, { type = _troopType, unitId = _unitId, name = string.format("Dropped %s #%i", _troopType, _unitId) })
    end

    return _troopArray

end

function ctld.generateTroopTypes(_side, _countOrTemplate, _country)

    local _troops = {}

    if type(_countOrTemplate) == "table" then

        if _countOrTemplate.aa then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Stinger manpad", _countOrTemplate.aa, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("SA-18 Igla-S manpad", _countOrTemplate.aa, _troops)
            end
        end

        if _countOrTemplate.inf then
            if _side == 2 then
                _troops = ctld.insertIntoTroopsArray("Soldier M4", _countOrTemplate.inf, _troops)
            else
                _troops = ctld.insertIntoTroopsArray("Infantry AK", _countOrTemplate.inf, _troops)
            end
        end

        if _countOrTemplate.mg then
            _troops = ctld.insertIntoTroopsArray("Soldier M249", _countOrTemplate.mg, _troops)
        end

        if _countOrTemplate.at then
            _troops = ctld.insertIntoTroopsArray("Paratrooper RPG-16", _countOrTemplate.at, _troops)
        end

        if _countOrTemplate.mortar then
            _troops = ctld.insertIntoTroopsArray("2B11 mortar", _countOrTemplate.mortar, _troops)
        end

    else
        for _i = 1, _countOrTemplate do

            -- luacheck: no unused
            local _unitType = "Soldier AK"

            if _side == 2 then
                _unitType = "Soldier M4"

                if _i <= 5 and ctld.spawnStinger then
                    _unitType = "Stinger manpad"
                end
                if _i <= 4 and ctld.spawnRPGWithCoalition then
                    _unitType = "Paratrooper RPG-16"
                end
                if _i <= 2 then
                    _unitType = "Soldier M249"
                end
            else
                _unitType = "Infantry AK"
                if _i <= 5 and ctld.spawnStinger then
                    _unitType = "SA-18 Igla manpad"
                end
                if _i <= 4 then
                    _unitType = "Paratrooper RPG-16"
                end
                if _i <= 2 then
                    _unitType = "Paratrooper AKS-74"
                end
            end

            local _unitId = ctld.getNextUnitId()

            _troops[_i] = { type = _unitType, unitId = _unitId, name = string.format("Dropped %s #%i", _unitType, _unitId) }
        end
    end

    local _groupId = ctld.getNextGroupId()
    local _details = { units = _troops, groupId = _groupId, groupName = string.format("Dropped Group %i", _groupId), side = _side, country = _country }

    return _details
end

--Special F10 function for players for troops
function ctld.unloadExtractTroops(_args)

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return false
    end

    local _extract = nil
    if not ctld.inAir(_heli) then
        if _heli:getCoalition() == 1 then
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end

    end

    if _extract ~= nil and not ctld.troopsOnboard(_heli, true) then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), true })
    else
        return ctld.unloadTroops({ _heli:getName(), true, true })
    end


end

-- load troops onto vehicle
function ctld.loadTroops(_heli, _troops, _numberOrTemplate)

    -- load troops + vehicles if c130 or herc
    -- "M1045 HMMWV TOW"
    -- "M1043 HMMWV Armament"
    local _onboard = ctld.inTransitTroops[_heli:getName()]

    --number doesnt apply to vehicles
    if _numberOrTemplate == nil or (type(_numberOrTemplate) ~= "table" and type(_numberOrTemplate) ~= "number") then
        --_numberOrTemplate = ctld.numberOfTroops
        _numberOrTemplate = ctld.getTransportLimit(_heli:getTypeName()) -- Ensure AI follow the rules on troop numbers
    end

    if _onboard == nil then
        _onboard = { troops = {}, vehicles = {} }
    end

    local _list
    if _heli:getCoalition() == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end

    if _troops then

        _onboard.troops = ctld.generateTroopTypes(_heli:getCoalition(), _numberOrTemplate, _heli:getCountry())

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded troops into " .. _heli:getTypeName(), 10)

        ctld.processCallback({ unit = _heli, onboard = _onboard.troops, action = "load_troops" })
    else

        _onboard.vehicles = ctld.generateVehiclesForTransport(_heli:getCoalition(), _heli:getCountry())

        local _count = #_list

        ctld.processCallback({ unit = _heli, onboard = _onboard.vehicles, action = "load_vehicles" })

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " loaded " .. _count .. " vehicles into " .. _heli:getTypeName(), 10)
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard
end

function ctld.generateVehiclesForTransport(_side, _country)

    local _vehicles = {}
    local _list
    if _side == 1 then
        _list = ctld.vehiclesForTransportRED
    else
        _list = ctld.vehiclesForTransportBLUE
    end

    for _i, _type in ipairs(_list) do

        local _unitId = ctld.getNextUnitId()

        _vehicles[_i] = { type = _type, unitId = _unitId, name = string.format("Dropped %s #%i", _type, _unitId) }
    end

    local _groupId = ctld.getNextGroupId()
    local _details = { units = _vehicles, groupId = _groupId, groupName = string.format("Dropped Group %i", _groupId), side = _side, country = _country }

    return _details
end

--CTLD_config.lua: ctld.interalCargoEnabled 
function ctld.loadUnloadLogisticsCrate(_aircraft,_LCreq) 

    local _aircraft = ctld.getTransportUnit(_args[1])
	local _logisticsCentreReq = true
	if _LCreq ~= nil then
		_logisticsCentreReq = _LCreq
	end

    if _aircraft == nil then
        return
    end
	
	local _playerName = ctld.getPlayerNameOrType(_aircraft)

    if ctld.inAir(_aircraft) == true then
		ctld.displayMessageToGroup(_aircraft,"You must land before commencing logistics operations", 10)
        return
    end

    local _aircraftSide = _aircraft:getCoalition()
	local _aircraftSideName = utils.getSideName(_aircraftSide)
	
	-- Group.Category = {AIRPLANE = 0, HELICOPTER = 1, GROUND = 2, SHIP = 3, TRAIN = 4}
	-- Unit.Category = {AIRPLANE,HELICOPTER,GROUND_UNIT,SHIP,STRUCTURE} --mr: player aircraft and ground units all = 1 = AIRPLANE!
	local _isPlane = false
	local _aircraftCategrory = _aircraft:getGroup():getCategory()
	if _aircraftCategrory == 0 then
		_isPlane = true --mr: to allow planes to load logistics centre crate from ramp i.e. outside of logistics centre zone
	end
	log:info("_isPlane: $1, _aircraftCategrory: $2",_isPlane,_aircraftCategrory)
	
	--{_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}
	local _baseProximity = ctld.baseProximity(_aircraft)
	local _inBaseZoneAndRSRrepairRadius = _baseProximity[1]
	local _inFOBexclusionZone = _baseProximity[2]
	local _closestBaseName = _baseProximity[3][1]
	local _closestBaseSide = _baseProximity[3][2]
	local _closestBaseDist = _baseProximity[3][3]
	local _baseType = _baseProximity[4]
	
	--[[
		(a) if _inBaseZoneAndRSRrepairRadius = true, then _inFOBexclusionZone = true, then close enough for base repair
		(b) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = false, then far enough for deployable 
		(c) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = then, then too far for base for repair AND too close for deployable 
	--]]
	
	local _RSRradius = 10000 -- RSRbaseCaptureZones FARP zones 5km in MIZ, most RSRbaseCaptureZones Airbase zones 10km in MIZ
	if _baseType == "Airbase" then
		_RSRradius = ctld.maximumDistFromAirbaseToRepair -- 5km
	elseif _baseType == "FARP" then
		_RSRradius = ctld.maximumDistFromFARPToRepair -- 3km
	end
	
	-- proximity to nearest logistics centre object NOT whether player in logisitics zone, and if logistics centre is friendly
    local _friendlyLogisticsCentreProximity = ctld.friendlyLogisticsCentreProximity(_aircraft)
	local _nearestLogisticsCentreName = _friendlyLogisticsCentreProximity[1] --(rare) if no friendly LC at all = "NoFriendlyLC"
	local _nearestLogisticsCentreDist = _friendlyLogisticsCentreProximity[2] --(rare) if no friendly LC at all = "NoDist"
	local _nearestLogisticsCentreBaseName = _friendlyLogisticsCentreProximity[3] --(rare) if no friendly LC at all = "NoBase"
	
	local _nearestLogisticsCentreSideName = "neutral"
	if (_nearestLogisticsCentreName ~= "NoFriendlyLC") then 
		_nearestLogisticsCentreSideName = _aircraftSideName
	end

    local _crateOnboard = ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] ~= nil
	
	--debug
	if _crateOnboard then
		log:info("_crateOnboard: $1",inspect(ctld.inTransitLogisticsCentreCrates[_aircraft:getName()], { newline = " ", indent = "" }))
	end
	log:info("_inFOBexclusionZone: $1, _inBaseZoneAndRSRrepairRadius: $2, _closestBaseSide: $3, _closestBaseName: $4, _aircraftSideName: $5, _nearestLogisticsCentreSideName: $6, _nearestLogisticsCentreBaseName: $7 ",_inFOBexclusionZone,_inBaseZoneAndRSRrepairRadius,_closestBaseSide,_closestBaseName,_aircraftSideName,_nearestLogisticsCentreSideName, _nearestLogisticsCentreBaseName)
	
	--Q: what about deployable FOBs?
	--mr: need to add checks for existance of logistics centre AND if it's friendly!
	if _crateOnboard == false then

		if -- load crate without requiring crate deployment, if no current crate onboard and close enough to command centre
			(_nearestLogisticsCentreDist <= ctld.maximumDistanceLogistic) and -- ctld.maximumDistanceLogistic = 200
			(_aircraftSideName == _nearestLogisticsCentreSideName) then

			-- { desc = "Logistics Centre crate", internal = 1, unit = "LogisticsCentre", weight = 503, baseOfOrigin = "MM75" }
			local _crateDetails = ctld.crateLookupTable[tostring(503)]
			_crateDetails.baseOfOrigin = _nearestLogisticsCentreBaseName
			ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] = _crateDetails
			
			ctld.displayMessageToGroup(_aircraft, "Logistics Centre crate loaded", 10)
			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " loaded a Logistics Centre crate for transport!", 10)
			
		elseif  -- planes only needs to be in a base with an alive logisitics centre
			_isPlane == true and 
			_inBaseZoneAndRSRrepairRadius == true and 
			(_nearestLogisticsCentreBaseName == _closestBaseName) and 
			(_aircraftSideName == _nearestLogisticsCentreSideName) then
		
			-- { desc = "Logistics Centre crate", internal = 1, unit = "LogisticsCentre", weight = 503, baseOfOrigin = "MM75" }
			local _crateDetails = ctld.crateLookupTable[tostring(503)]
			_crateDetails.baseOfOrigin = _nearestLogisticsCentreBaseName
			ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] = _crateDetails
			
			ctld.displayMessageToGroup(_aircraft, "Logistics Centre crate loaded", 10)
			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " loaded a Logistics Centre crate for transport!", 10)
		
		else
		-- search area for logistics centre crate and load, regardless of aircraft type
		-- mr: add checks that crate is from same side? Not required as already done in ctld.getCratesAndDistance
			-- nearest Crate
			local _crates = ctld.getCratesAndDistance(_aircraft)
			local _nearestCrate = ctld.getClosestCrate(_aircraft, _crates, "LogisticsCentre")

			if _nearestCrate ~= nil and _nearestCrate.dist < ctld.maximumCrateDistanceForLoading then
				
				
				-- { desc = "Logistics Centre crate", internal = 1, unit = "LogisticsCentre", weight = 503, baseOfOrigin = "MM75" }
				local _crateDetails = ctld.crateLookupTable[tostring(503)]
				_crateDetails.baseOfOrigin = _nearestLogisticsCentreBaseName
				ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] = _crateDetails
				
				ctld.displayMessageToGroup(_aircraft, "Logistics Centre crate loaded", 10)
				trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " loaded a Logistics Centre crate for transport!", 10)

				if _aircraftSide == 1 then
					ctld.droppedLogisticsCentreCratesRED[_nearestCrate.crateUnit:getName()] = nil
				else
					ctld.droppedLogisticsCentreCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
				end

				--remove
				_nearestCrate.crateUnit:destroy()

			else
				log:info("_isPlane: $1, _inBaseZoneAndRSRrepairRadius: $2, _nearestLogisticsCentreBaseName: $3, _closestBaseName: $4, _aircraftSideName: $5, _nearestLogisticsCentreSideName: $6 ",_isPlane,_inBaseZoneAndRSRrepairRadius,_nearestLogisticsCentreBaseName,_closestBaseName,_aircraftSideName,_nearestLogisticsCentreSideName)
				
				
				ctld.displayMessageToGroup(_aircraft, "No friendly Logistic Centre in this airbase/FARP, nearby (<" .. ctld.maximumDistanceLogistic .. "m), or Logistics Centre crates (<" .. ctld.maximumCrateDistanceForLoading .. "m) from which to load a Logistics Centre crate!", 10)
			end
		end	
    end

	if _crateOnboard == true then 
		--[[ 
			provide warnings but do not stop crate deploying as may be needed for unique circumstances 
			e.g. delivery by plane but later pickup by helo, pre-delivery to enemy base prior to capture
		--]]
		if _inFOBexclusionZone == true and _inBaseZoneAndRSRrepairRadius == false then
			local _aircraftDistRSR = _RSRradius - _closestBaseDist
			ctld.displayMessageToGroup(_aircraft, "WARNING: You are too far from " .. _closestBaseName .. mist.utils.round((_aircraftDistRSR/1000),1) 
			.. "for a repair and too close (<" .. mist.utils.round((ctld.exclusionZoneFromBasesForFOBs/1000),1) .. ") to deploy a !", 20)
			return
		end
		
		if _inBaseZoneAndRSRrepairRadius == true and (_closestBaseSide ~= _aircraftSideName) then
			if _closestBaseSide ~= "neutral" then
				ctld.displayMessageToGroup(_aircraft, "WARNING: You cannot repair " .. _closestBaseName .. " as it is not a friendly or neutral base!", 20)
				return
			end
		end
		------------------------------------------------------------------------------------
		local _unitId = ctld.getNextLogisiticsCentreId()
		
		local _crateInTransitDetails = ctld.inTransitLogisticsCentreCrates[_aircraft:getName()]
		--ctld.spawnCrate: local _name = string.format("%s #%i (%s)", _crateType.desc, _unitId, _nearestLogisticsCentreName)
		local _crateBaseOfOrigin = _crateInTransitDetails.baseOfOrigin
		
		if _inFOBexclusionZone == false then
		-- if not inFOBexclusionZone then should also not be base zone = deployable FOB or crate for others to pickup
		-- unpack command should be available to all members of ctld.vehicleTransportEnabled and ctld.interalCargoEnabled

			ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] = nil

			--try to spawn at 6 oclock to us
			local _position = _aircraft:getPosition()
			local _angle = math.atan2(_position.x.z, _position.x.x)
			local _xOffset = math.cos(_angle) * -60
			local _yOffset = math.sin(_angle) * -60
			local _point = _aircraft:getPoint()
			local _6oclockPos = { x = _point.x + _xOffset, z = _point.z + _yOffset }

			-- add _crateBaseOfOrigin to crate name for later base of origin checks
			local _newLCcrateName = string.format("Logistics Centre crate #%i (%s)", _unitId, _crateBaseOfOrigin)
			ctld.spawnLogisticsCentreCrateStatic(_aircraft:getCountry(), _6oclockPos, _newLCcrateName)

			if _side == 1 then
				ctld.droppedLogisticsCentreCratesRED[_newLCcrateName] = _newLCcrateName
			else
				ctld.droppedLogisticsCentreCratesBLUE[_newLCcrateName] = _newLCcrateName
			end

			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " delivered a Logistics Centre crate", 10)

			ctld.displayMessageToGroup(_aircraft, "Delivered Logistics Centre crate 60m at 6'oclock to you", 10)
			
		elseif 
		-- initiate immediate base repair, no need for crate spawn
			_inBaseZoneAndRSRrepairRadius == true and
			((_closestBaseSide == _aircraftSideName) or (_closestBaseSide == "neutral")) and
			(_nearestLogisticsCentreBaseName ~= _closestBaseName) then -- no logisitics centre at current base
			
			-- prevent repair if logisitics centre crate base of origin same as base to be repaired
			if _crateInTransitDetails.baseOfOrigin == _closestBaseName then
				ctld.displayMessageToGroup(_heli, "WARNING: logistics centre crate from " .. _crateInTransitDetails.baseOfOrigin .. ", cannot be unloaded and deployed within base of origin (nearest base: " .. _closestBaseName .. ")", 20)
				return
			end
			
			local _logisticsCentreName = ""
			_logisticsCentreName = _logisticsCentreName .. _closestBaseName .. " Logistics Centre #" .. _unitId .. " " .. _aircraftSideName -- "MM75 Logistics Centre #001 red"
			logisticsManager.spawnLogisticsBuildingForBase(_closestBaseName,_aircraftSideName,_logisticsCentreName,false,_playerName)
			--trigger.action.outTextForCoalition(_aircraft:getCoalition(), _playerName .. " has repaired the Logistics Centre at " .. _closestBaseName, 10) --moved to baseOwnershipCheck.lua
			
		elseif 
		-- return logistics crate to pool to prevent exploit of "backup repair crates"
			_inBaseZoneAndRSRrepairRadius == true and
			(_closestBaseSide == _aircraftSideName) and
			(_nearestLogisticsCentreBaseName == _closestBaseName) then
			
			ctld.displayMessageToGroup(_aircraft, "Logistics Centre already present.  Logistics Centre crate returned to base.", 10)
			ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] = nil
		end		
	end
end

--CTLD_config.lua: ctld.interalCargoEnabled 
function ctld.loadUnloadJTACcrate(_args) 

    local _aircraft = ctld.getTransportUnit(_args[1])

    if _aircraft == nil then
        return
    end
	
	local _playerName = ctld.getPlayerNameOrType(_aircraft)

    if ctld.inAir(_aircraft) == true then
		ctld.displayMessageToGroup(_aircraft,"You must land before commencing logistics operations", 10)
        return
    end

    local _aircraftSide = _aircraft:getCoalition()
	local _aircraftSideName = utils.getSideName(_aircraftSide)

	-- check JTAC crate supply limit
	local _JTAClimitHit = false
	if _aircraftSide == 1 then

		if ctld.JTAC_LIMIT_RED == 0 then
			_JTAClimitHit = true
		else
			ctld.JTAC_LIMIT_RED = ctld.JTAC_LIMIT_RED - 1
		end
	else
		if ctld.JTAC_LIMIT_BLUE == 0 then
			_JTAClimitHit = true
		else
			ctld.JTAC_LIMIT_BLUE = ctld.JTAC_LIMIT_BLUE - 1
		end
	end

	if _JTAClimitHit then
		ctld.displayMessageToGroup(_aircraft, "No more JTAC crates Left!", 10)
		return
	end
--[[
	-- give player warning if they have already reached their JTAC limit to prevent uncessary trips
	local _playerJTACsForSide = ctld.JTACsPerUCIDPerSide[_playerUCID][_aircraftSide]
	local _playerJTACsForSideCount = 0
	if _playerJTACsForSide ~= nil then
		for _k, _JTACgroup in ipairs (_playerJTACsForSide) do
			if (_JTACgroup:getUnit) == nil then
				table.remove(ctld.JTACsPerUCIDPerSide[_playerUCID][_aircraftSide],_k)
			else
				_playerJTACsForSideCount = _playerJTACsForSideCount + 1
			end
		end	
	end
	if ctld.JTAC_LIMIT_perPLAYER_perSIDE > _playerJTACsForSideCount then
		ctld.displayMessageToGroup(_aircraft, "WARNING - JTACs per player per side limit (" .. ctld.JTAC_LIMIT_perPLAYER_perSIDE .. ") reached. Unpacking this crate will delete the oldest JTAC you have deployed for this side.", 20)
	end
--]]

	-- { weight = 502, desc = "UAZ - JTAC", unit = "UAZ-469", side = 1, cratesRequired = 1, internal = 1 }
	-- { weight = 501, desc = "HMMWV - JTAC", unit = "Hummer", side = 2, cratesRequired = 1, internal = 1 }
	local _JTACcrateWeightPerSide = 500
	local _JTACcrateUnit = "NoUnit"
	if _aircraftSide == 1 then
		_JTACcrateWeightPerSide = 502
		_JTACcrateUnit = "UAZ-469"
	elseif _aircraftSide == 2 then
		_JTACcrateWeightPerSide = 501
		_JTACcrateUnit = "Hummer"
	end
	
	-- Group.Category = {AIRPLANE = 0, HELICOPTER = 1, GROUND = 2, SHIP = 3, TRAIN = 4}
	-- Unit.Category = {AIRPLANE,HELICOPTER,GROUND_UNIT,SHIP,STRUCTURE} --mr: player aircraft and ground units all = 1 = AIRPLANE!
	local _isPlane = false
	if (_aircraft:getGroup():getCategory()) == 0 then
		_isPlane = true --mr: to allow planes to load logistics centre crate from ramp i.e. outside of logistics centre zone
	end
	
	--{_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}
	local _baseProximity = ctld.baseProximity(_aircraft)
	local _inBaseZoneAndRSRrepairRadius = _baseProximity[1]
	local _inFOBexclusionZone = _baseProximity[2]
	local _closestBaseName = _baseProximity[3][1]
	local _closestBaseSide = _baseProximity[3][2]
	local _closestBaseDist = _baseProximity[3][3]
	local _baseType = _baseProximity[4]
	
	--[[
		(a) if _inBaseZoneAndRSRrepairRadius = true, then _inFOBexclusionZone = true, then close enough for base repair
		(b) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = false, then far enough for deployable 
		(c) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = then, then too far for base for repair AND too close for deployable 
	--]]
	
	local _RSRradius = 10000 -- RSRbaseCaptureZones FARP zones 5km in MIZ, most RSRbaseCaptureZones Airbase zones 10km in MIZ
	if _baseType == "Airbase" then
		_RSRradius = ctld.maximumDistFromAirbaseToRepair -- 5km
	elseif _baseType == "FARP" then
		_RSRradius = ctld.maximumDistFromFARPToRepair -- 3km
	end
	
	-- proximity to nearest logistics centre object NOT whether player in logisitics zone, and if logistics centre is friendly
    local _friendlyLogisticsCentreProximity = ctld.friendlyLogisticsCentreProximity(_aircraft)
	local _nearestLogisticsCentreName = _friendlyLogisticsCentreProximity[1] --(rare) if no friendly LC at all = "NoFriendlyLC"
	local _nearestLogisticsCentreDist = _friendlyLogisticsCentreProximity[2] --(rare) if no friendly LC at all = "NoDist"
	local _nearestLogisticsCentreBaseName = _friendlyLogisticsCentreProximity[3] --(rare) if no friendly LC at all = "NoBase"
	
	local _nearestLogisticsCentreSideName = "neutral"
	if (_nearestLogisticsCentreName ~= "NoFriendlyLC") then 
		_nearestLogisticsCentreSideName = _aircraftSideName
	end

    local _crateOnboard = ctld.inTransitSlingLoadCrates[_aircraft:getName()] ~= nil
	
	--debug
	if _crateOnboard then
		log:info("_crateOnboard: $1",inspect(ctld.inTransitSlingLoadCrates[_aircraft:getName()], { newline = " ", indent = "" }))
	end
	log:info("_inFOBexclusionZone: $1, _inBaseZoneAndRSRrepairRadius: $2, _closestBaseSide: $3, _closestBaseName: $4, _aircraftSideName: $5, _nearestLogisticsCentreSideName: $6, _nearestLogisticsCentreBaseName: $7",_inFOBexclusionZone,_inBaseZoneAndRSRrepairRadius,_closestBaseSide,_closestBaseName,_aircraftSideName,_nearestLogisticsCentreSideName, _nearestLogisticsCentreBaseName)

	if _crateOnboard == false then

		if -- load crate without requiring crate deployment, if no current crate onboard and close enough to command centre
			(_nearestLogisticsCentreDist <= ctld.maximumDistanceLogistic) and -- ctld.maximumDistanceLogistic = 200
			(_aircraftSideName == _nearestLogisticsCentreSideName) then

			
			local _crateDetails = ctld.crateLookupTable[tostring(_JTACcrateWeightPerSide)]
			_crateDetails.baseOfOrigin = _nearestLogisticsCentreBaseName
			ctld.inTransitSlingLoadCrates[_aircraft:getName()] = _crateDetails
			
			ctld.displayMessageToGroup(_aircraft, "JTAC crate loaded", 10)
			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " loaded a JTAC crate for transport.", 10)
		
		elseif  -- planes only needs to be in a base with an alive logisitics centre
			_isPlane == true and 
			_inBaseZoneAndRSRrepairRadius == true and 
			(_nearestLogisticsCentreBaseName == _closestBaseName) and 
			(_aircraftSideName == _nearestLogisticsCentreSideName) then
		
			local _crateDetails = ctld.crateLookupTable[tostring(_JTACcrateWeightPerSide)]
			_crateDetails.baseOfOrigin = _nearestLogisticsCentreBaseName
			log:info("_crateDetails: $1",inspect(_crateDetails, { newline = " ", indent = "" }))
			ctld.inTransitSlingLoadCrates[_aircraft:getName()] = _crateDetails
			log:info("inTransitSlingLoadCrates: aircraft: $1",inspect(ctld.inTransitSlingLoadCrates[_aircraft:getName()], { newline = " ", indent = "" }))
			ctld.displayMessageToGroup(_aircraft, "JTAC crate loaded", 10)
			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " loaded a JTAC crate for transport!", 10)
		
		else
		-- search area for logistics centre crate and load, regardless of aircraft type
		-- mr: add checks that crate is from same side? Not required as already done in ctld.getCratesAndDistance
			-- nearest Crate
			local _crates = ctld.getCratesAndDistance(_aircraft)
			local _nearestCrate = ctld.getClosestCrate(_aircraft, _crates, _JTACcrateUnit)

			if _nearestCrate ~= nil and _nearestCrate.dist < ctld.maximumCrateDistanceForLoading then
				
				local _crateDetails = ctld.crateLookupTable[tostring(_JTACcrateWeightPerSide)]
				_crateDetails.baseOfOrigin = _nearestLogisticsCentreBaseName
				ctld.inTransitSlingLoadCrates[_aircraft:getName()] = _crateDetails
				
				ctld.displayMessageToGroup(_aircraft, "JTAC crate loaded", 10)
				trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " loaded a JTAC crate for transport!", 10)

				--remove
				_nearestCrate.crateUnit:destroy()

			else
				ctld.displayMessageToGroup(_aircraft, "No friendly Logistic Centre in this airbase/FARP, nearby (<" .. ctld.maximumDistanceLogistic .. "), or JTAC crates (<" .. ctld.maximumCrateDistanceForLoading .. "m) from which to load a JTAC crate!", 10)
			end
		end	
    end

	if _crateOnboard == true then 
	
		local _crateInTransitDetails = ctld.inTransitSlingLoadCrates[_aircraft:getName()]
		--ctld.spawnCrate: local _name = string.format("%s #%i (%s)", _crateType.desc, _unitId, _nearestLogisticsCentreName)
		local _crateBaseOfOrigin = _crateInTransitDetails.baseOfOrigin
	
		if _inBaseZoneAndRSRrepairRadius == false then
	
			-- if not _inBaseZoneAndRSRrepairRadius then allow JTAC crate unload for self/others others to unpack, or others to pickup
			-- unpack command should be available to all members of ctld.vehicleTransportEnabled and ctld.interalCargoEnabled
			ctld.inTransitSlingLoadCrates[_aircraft:getName()] = nil

			--try to spawn at 6 oclock to us
			local _position = _aircraft:getPosition()
			local _angle = math.atan2(_position.x.z, _position.x.x)
			local _xOffset = math.cos(_angle) * -60
			local _yOffset = math.sin(_angle) * -60
			local _point = _aircraft:getPoint()
			local _6oclockPos = { x = _point.x + _xOffset, z = _point.z + _yOffset }

			local _unitId = ctld.getNextUnitId()

			-- add _crateBaseOfOrigin to crate name for later origin checks
			-- local _crateName = string.format("%s #%i (%s)", _currentCrate.desc, _unitId, _crateBaseOfOrigin) 
			local _newJTACcrateName = string.format("JTAC crate #%i (%s)", _unitId, _crateBaseOfOrigin)
			ctld.spawnCrateStatic(_aircraft:getCountry(), _unitId, _6oclockPos, _newJTACcrateName, _JTACcrateWeightPerSide, _aircraftSide, 1)

			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " delivered a JTAC crate", 10)
			ctld.displayMessageToGroup(_aircraft, "Delivered JTAC crate 60m at 6'oclock to you", 10)
				
		elseif _inBaseZoneAndRSRrepairRadius == true then
		
			log:info("_crateInTransitDetails.baseOfOrigin: $1, _closestBaseName: $2, _closestBaseSide: $3,",_crateInTransitDetails.baseOfOrigin,_closestBaseName,_closestBaseSide)
			
			if (_closestBaseSide == _aircraftSideName) then
				-- prevent JTAC crate deployment base of origin same as base currently within, otherwise quick load+unload exploit to make JTACs
				if _crateInTransitDetails.baseOfOrigin == _closestBaseName then
					ctld.displayMessageToGroup(_aircraft, "WARNING: JTAC crate from " .. _crateInTransitDetails.baseOfOrigin .. ", cannot be unloaded within base of origin (nearest base: " .. _closestBaseName .. "). JTAC crate returned to base.", 20)
					ctld.inTransitSlingLoadCrates[_aircraft:getName()] = nil
					return
				end
			end
			
			-- if JTAC crate not from current base then allow JTAC crate unload for self/others others to unpack, or others to pickup
			-- unpack command should be available to all members of ctld.vehicleTransportEnabled and ctld.interalCargoEnabled
			ctld.inTransitSlingLoadCrates[_aircraft:getName()] = nil

			--try to spawn at 6 oclock to us
			local _position = _aircraft:getPosition()
			local _angle = math.atan2(_position.x.z, _position.x.x)
			local _xOffset = math.cos(_angle) * -60
			local _yOffset = math.sin(_angle) * -60
			local _point = _aircraft:getPoint()
			local _6oclockPos = { x = _point.x + _xOffset, z = _point.z + _yOffset }

			local _unitId = ctld.getNextUnitId()

			-- add _crateBaseOfOrigin to crate name for later origin checks
			local _newJTACcrateName = string.format("JTAC crate #%i (%s)", _unitId, _crateBaseOfOrigin)
			ctld.spawnCrateStatic(_aircraft:getCountry(), _unitId, _6oclockPos, _newJTACcrateName, _JTACcrateWeightPerSide, _aircraftSide, 1)
			log:info("_newJTACcrateName: $1",_newJTACcrateName)
			trigger.action.outTextForCoalition(_aircraft:getCoalition(), ctld.getPlayerNameOrType(_aircraft) .. " delivered a JTAC crate", 10)
			ctld.displayMessageToGroup(_aircraft, "Delivered JTAC crate 60m at 6'oclock to you", 10)
		end				
	end
end

function ctld.loadTroopsFromZone(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]
    local _groupTemplate = _args[3] or ""
    local _allowExtract = _args[4]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)

    if ctld.troopsOnboard(_heli, _troops) then

        if _troops then
            ctld.displayMessageToGroup(_heli, "You already have troops onboard.", 10)
        else
            ctld.displayMessageToGroup(_heli, "You already have vehicles onboard.", 10)
        end

        return false
    end

    if ctld.inTransitSlingLoadCrates[_args[1]] ~= nil then
        ctld.displayMessageToGroup(_heli, "You have a cargo container on board. There's no room!", 10)
        return false
    end

    local _extract

    if _allowExtract then
        -- first check for extractable troops regardless of if we're in a zone or not
        if _troops then
            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
            end
        else

            if _heli:getCoalition() == 1 then
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
            else
                _extract = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
            end
        end
    end

    if _extract ~= nil then
        -- search for nearest troops to pickup
        return ctld.extractTroops({ _heli:getName(), _troops })
    elseif _zone.inZone == true then

        if _zone.limit - 1 >= 0 then
            -- decrease zone counter by 1
            ctld.updateZoneCounter(_zone.index, -1)

            ctld.loadTroops(_heli, _troops, _groupTemplate)

            return true
        else
            ctld.displayMessageToGroup(_heli, "This area has no more reinforcements available!", 20)

            return false
        end

    else
        if _allowExtract then
            ctld.displayMessageToGroup(_heli, "You are not in a pickup zone and no one is nearby to extract", 10)
        else
            ctld.displayMessageToGroup(_heli, "You are not in a pickup zone", 10)
        end

        return false
    end
end

function ctld.unloadTroops(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    local _zone = ctld.inPickupZone(_heli)
    if not ctld.troopsOnboard(_heli, _troops) then

        ctld.displayMessageToGroup(_heli, "No one to unload", 10)

        return false
    else

        -- troops must be onboard to get here
        if _zone.inZone == true then

            if _troops then
                ctld.displayMessageToGroup(_heli, "Dropped troops back to base", 20)

                ctld.processCallback({ unit = _heli, unloaded = ctld.inTransitTroops[_heli:getName()].troops, action = "unload_troops_zone" })

                ctld.inTransitTroops[_heli:getName()].troops = nil

            else
                ctld.displayMessageToGroup(_heli, "Dropped vehicles back to base", 20)

                ctld.processCallback({ unit = _heli, unloaded = ctld.inTransitTroops[_heli:getName()].vehicles, action = "unload_vehicles_zone" })

                ctld.inTransitTroops[_heli:getName()].vehicles = nil
            end

            -- increase zone counter by 1
            ctld.updateZoneCounter(_zone.index, 1)

            return true

        elseif _zone.inZone == false and ctld.troopsOnboard(_heli, _troops) then

            return ctld.deployTroops(_heli, _troops)
        end
    end

end

function ctld.extractTroops(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _troops = _args[2]

    if _heli == nil then
        return false
    end

    if ctld.inAir(_heli) then
        return false
    end

    if ctld.troopsOnboard(_heli, _troops) then
        if _troops then
            ctld.displayMessageToGroup(_heli, "You already have troops onboard.", 10)
        else
            ctld.displayMessageToGroup(_heli, "You already have vehicles onboard.", 10)
        end

        return false
    end

    local _onboard = ctld.inTransitTroops[_heli:getName()]

    if _onboard == nil then
        _onboard = { troops = nil, vehicles = nil }
    end

    local _extracted = false

    if _troops then

        local _extractTroops

        if _heli:getCoalition() == 1 then
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsRED)
        else
            _extractTroops = ctld.findNearestGroup(_heli, ctld.droppedTroopsBLUE)
        end

        if _extractTroops ~= nil then

            local _limit = ctld.getTransportLimit(_heli:getTypeName())

            local _size = #_extractTroops.group:getUnits()

            if _limit < #_extractTroops.group:getUnits() then

                ctld.displayMessageToGroup(_heli, "Sorry - The group of " .. _size .. " is too large to fit. \n\nLimit is " .. _limit .. " for " .. _heli:getTypeName(), 20)

                return
            end

            _onboard.troops = _extractTroops.details

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " extracted troops in " .. _heli:getTypeName() .. " from combat", 10)

            if _heli:getCoalition() == 1 then
                ctld.droppedTroopsRED[_extractTroops.group:getName()] = nil
            else
                ctld.droppedTroopsBLUE[_extractTroops.group:getName()] = nil
            end

            ctld.processCallback({ unit = _heli, extracted = _extractTroops, action = "extract_troops" })

            --remove
            _extractTroops.group:destroy()

            _extracted = true
        else
            _onboard.troops = nil
            ctld.displayMessageToGroup(_heli, "No extractable troops nearby!", 20)
        end

    else

        local _extractVehicles

        if _heli:getCoalition() == 1 then

            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesRED)
        else

            _extractVehicles = ctld.findNearestGroup(_heli, ctld.droppedVehiclesBLUE)
        end

        if _extractVehicles ~= nil then
            _onboard.vehicles = _extractVehicles.details

            if _heli:getCoalition() == 1 then

                ctld.droppedVehiclesRED[_extractVehicles.group:getName()] = nil
            else

                ctld.droppedVehiclesBLUE[_extractVehicles.group:getName()] = nil
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " extracted vehicles in " .. _heli:getTypeName() .. " from combat", 10)

            ctld.processCallback({ unit = _heli, extracted = _extractVehicles, action = "extract_vehicles" })
            --remove
            _extractVehicles.group:destroy()
            _extracted = true

        else
            _onboard.vehicles = nil
            ctld.displayMessageToGroup(_heli, "No extractable vehicles nearby!", 20)
        end
    end

    ctld.inTransitTroops[_heli:getName()] = _onboard

    return _extracted
end

function ctld.checkCargoStatus(_args)

    --list onboard troops
    local _aircraft = ctld.getTransportUnit(_args[1])

    if _aircraft == nil then
        return
    end

    local _troopsORvehicles = ctld.inTransitTroops[_aircraft:getName()]

    if _troopsORvehicles == nil then
		
		local _currentCrate = ctld.inTransitSlingLoadCrates[_aircraft:getName()] -- JTAC crates
		if _currentCrate == nil then
			_currentCrate = ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] -- logistics centre crates
		end
		
		log:info("_currentCrate: $1",inspect(_currentCrate, { newline = " ", indent = "" })) --debug
		
        if _currentCrate ~= nil then
			ctld.displayMessageToGroup(_aircraft, "Currently Transporting: " .. _currentCrate.desc .. ".", 10)
        else
			ctld.displayMessageToGroup(_aircraft, "You are not currently transporting any troops or crates.", 10)
        end


    else
        local _troops = _troopsORvehicles.troops
        local _vehicles = _troopsORvehicles.vehicles

        local _txt = "Currently Transporting: "

        if _troops ~= nil and _troops.units ~= nil and #_troops.units > 0 then
            _txt = _txt .. " " .. #_troops.units .. " troops\n"
        end

        if _vehicles ~= nil and _vehicles.units ~= nil and #_vehicles.units > 0 then
            _txt = _txt .. " " .. #_vehicles.units .. " vehicles\n"
        end
		
        if ctld.inTransitSlingLoadCrates[_aircraft:getName()] == true then
            _txt = _txt .. "1 x " .. _currentCrate.desc .. " crate\n"
        end
		
        if ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] == true then
            _txt = _txt .. " 1 x Logistics Centre crate\n"
        end

        if _txt ~= "Currently Transporting: " then
            ctld.displayMessageToGroup(_aircraft, _txt, 10)
        else
		
			local _currentCrate = ctld.inTransitSlingLoadCrates[_aircraft:getName()] -- JTAC crates
			if _currentCrate ~= nil then
				_currentCrate = ctld.inTransitLogisticsCentreCrates[_aircraft:getName()] -- logistics centre crates
			end
			
			if _currentCrate ~= nil then
				ctld.displayMessageToGroup(_aircraft, "1 x " .. _currentCrate.desc .. " crate", 10)
			else
				ctld.displayMessageToGroup(_aircraft, "You are not currently transporting any troops or crates.", 10)
			end

        end
    end
end

-- Removes troops from transport when it dies
function ctld.checkTransportStatus()

    timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 3)

    for _, _name in ipairs(ctld.transportPilotNames) do

        local _transUnit = ctld.getTransportUnit(_name)

        if _transUnit == nil then
            --env.info("CTLD Transport Unit Dead event")
            ctld.inTransitTroops[_name] = nil
            ctld.inTransitLogisticsCentreCrates[_name] = nil
            ctld.inTransitSlingLoadCrates[_name] = nil
        end
    end
end

function ctld.checkHoverStatus()
    -- env.info("checkHoverStatus")
    timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1.0)

    local _status, _result = pcall(function()

        for _, _name in ipairs(ctld.transportPilotNames) do

            local _reset = true
            local _transUnit = ctld.getTransportUnit(_name)

            --only check transports that are hovering and not planes
            if _transUnit ~= nil and ctld.inTransitSlingLoadCrates[_name] == nil and ctld.inAir(_transUnit) and ctld.unitCanCarryVehicles(_transUnit) == false then

                local _crates = ctld.getCratesAndDistance(_transUnit)

                for _, _crate in pairs(_crates) do
                    --   env.info("CRATE: ".._crate.crateUnit:getName().. " ".._crate.dist)
                    if _crate.dist < ctld.maxDistanceFromCrate and _crate.details.unit ~= "LogisticsCentre" then

                        --check height!
                        local _height = _transUnit:getPoint().y - _crate.crateUnit:getPoint().y
                        --env.info("HEIGHT " .. _name .. " " .. _height .. " " .. _transUnit:getPoint().y .. " " .. _crate.crateUnit:getPoint().y)
                        --  ctld.heightDiff(_transUnit)
                        --env.info("HEIGHT ABOVE GROUD ".._name.." ".._height.." ".._transUnit:getPoint().y.." ".._crate.crateUnit:getPoint().y)

                        if _height > ctld.minimumHoverHeight and _height <= ctld.maximumHoverHeight then

                            local _time = ctld.hoverStatus[_transUnit:getName()]

                            if _time == nil then
                                ctld.hoverStatus[_transUnit:getName()] = ctld.hoverTime
                                _time = ctld.hoverTime
                            else
                                _time = ctld.hoverStatus[_transUnit:getName()] - 1
                                ctld.hoverStatus[_transUnit:getName()] = _time
                            end

                            if _time > 0 then
                                ctld.displayMessageToGroup(_transUnit, "Hovering above " .. _crate.details.desc .. " crate. \n\nHold hover for " .. _time .. " seconds! \n\nIf the countdown stops you're too far away!", 10, true)
                            else
                                ctld.hoverStatus[_transUnit:getName()] = nil
                                ctld.displayMessageToGroup(_transUnit, "Loaded " .. _crate.details.desc .. " crate!", 10, true)

                                --crates been moved once!
                                ctld.crateMove[_crate.crateUnit:getName()] = nil

                                if _transUnit:getCoalition() == 1 then
                                    ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                                else
                                    ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                                end

                                _crate.crateUnit:destroy()

                                ctld.inTransitSlingLoadCrates[_name] = _crate.details
                            end

                            _reset = false

                            break
                        elseif _height <= ctld.minimumHoverHeight then
                            ctld.displayMessageToGroup(_transUnit, "Too low to hook " .. _crate.details.desc .. " crate.\n\nHold hover for " .. ctld.hoverTime .. " seconds", 5, true)
                            break
                        else
                            ctld.displayMessageToGroup(_transUnit, "Too high to hook " .. _crate.details.desc .. " crate.\n\nHold hover for " .. ctld.hoverTime .. " seconds", 5, true)
                            break
                        end
                    end
                end
            end

            if _reset then
                ctld.hoverStatus[_name] = nil
            end
        end
    end)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _result))
    end
end

function ctld.loadNearbyCrate(_aircraft)
    local _transUnit = ctld.getTransportUnit(_aircraft)

    if _transUnit ~= nil then

        if ctld.inAir(_transUnit) then
            ctld.displayMessageToGroup(_transUnit, "You must land before you can load a crate!", 10, true)
            return
        end

        if ctld.troopsOnboard(_transUnit, true) then
            ctld.displayMessageToGroup(_transUnit, "You already have troops on board. There's no room!", 10, true)
            return
        end

        if ctld.unitCargoDoorsOpen(_transUnit) ~= true then
            ctld.displayMessageToGroup(_transUnit, "You must open, or remove, the cargo doors to load cargo", 10, true)
            return
        end

        if ctld.inTransitSlingLoadCrates[_aircraft] == nil then --loads internal cargo if pre-existing internal cargo not detected
			
			-- ctld.getCratesAndDistance: { crateUnit = _crate, dist = _dist, details = _details }
            local _crates = ctld.getCratesAndDistance(_transUnit)

            for _, _crate in pairs(_crates) do

                if (_crate.dist < 50.0) and (_crate.details.internal == 1) and (ctld.crateValidLoadPoint(_transUnit, _crate)) then
                    -- Ironwulf2000 Updated for Internal Cargo
                    ctld.displayMessageToGroup(_transUnit, "Loaded " .. _crate.details.desc .. " crate!", 10, true)

                    if _transUnit:getCoalition() == 1 then
                        ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
                    else
                        ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
                    end

                    ctld.crateMove[_crate.crateUnit:getName()] = nil

                    _crate.crateUnit:destroy()
					
					-- { desc = "Logistics Centre crate", internal = 1, unit = "LogisticsCentre", weight = 503, baseOfOrigin = "MM75" }
                    local _copiedCrate = mist.utils.deepCopy(_crate.details)
					log:info("_copiedCrate: $1",inspect(_copiedCrate, { newline = " ", indent = "" }))
                    ctld.inTransitSlingLoadCrates[_aircraft] = _copiedCrate --crate details copied and associated with player as internal cargo
                    return
                end
            end

            ctld.displayMessageToGroup(_transUnit, "No Crates within the vicinity of the cargo door load area to load!", 10, true)

        else
            -- crate onboard

            local _currentCrate = mist.utils.deepCopy(ctld.inTransitSlingLoadCrates[_aircraft])

            ctld.displayMessageToGroup(_transUnit, "You already have a " .. _currentCrate.desc .. " crate onboard!", 10, true)
        end
    end


end

--recreates beacons to make sure they work!
function ctld.refreshRadioBeacons()

    timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 30)

    for _index, _beaconDetails in ipairs(ctld.deployedRadioBeacons) do

        --trigger.action.outTextForCoalition(_beaconDetails.coalition,_beaconDetails.text,10)
        if ctld.updateRadioBeacon(_beaconDetails) == false then

            --search used frequencies + remove, add back to unused

            for _i, _freq in ipairs(ctld.usedUHFFrequencies) do
                if _freq == _beaconDetails.uhf then

                    table.insert(ctld.freeUHFFrequencies, _freq)
                    table.remove(ctld.usedUHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedVHFFrequencies) do
                if _freq == _beaconDetails.vhf then

                    table.insert(ctld.freeVHFFrequencies, _freq)
                    table.remove(ctld.usedVHFFrequencies, _i)
                end
            end

            for _i, _freq in ipairs(ctld.usedFMFrequencies) do
                if _freq == _beaconDetails.fm then

                    table.insert(ctld.freeFMFrequencies, _freq)
                    table.remove(ctld.usedFMFrequencies, _i)
                end
            end

            --clean up beacon table
            table.remove(ctld.deployedRadioBeacons, _index)
        end
    end
end

function ctld.getClockDirection(_heli, _crate)

    -- Source: Helicopter Script - Thanks!

    local _position = _crate:getPosition().p -- get position of crate
    local _playerPosition = _heli:getPosition().p -- get position of helicopter
    local _relativePosition = mist.vec.sub(_position, _playerPosition)

    local _playerHeading = mist.getHeading(_heli) -- the rest of the code determines the 'o'clock' bearing of the missile relative to the helicopter

    local _headingVector = { x = math.cos(_playerHeading), y = 0, z = math.sin(_playerHeading) }

    local _headingVectorPerpendicular = { x = math.cos(_playerHeading + math.pi / 2), y = 0, z = math.sin(_playerHeading + math.pi / 2) }

    local _forwardDistance = mist.vec.dp(_relativePosition, _headingVector)

    local _rightDistance = mist.vec.dp(_relativePosition, _headingVectorPerpendicular)

    local _angle = math.atan2(_rightDistance, _forwardDistance) * 180 / math.pi

    if _angle < 0 then
        _angle = 360 + _angle
    end
    _angle = math.floor(_angle * 12 / 360 + 0.5)
    if _angle == 0 then
        _angle = 12
    end

    return _angle
end

function ctld.getCompassBearing(_ref, _unitPos)

    _ref = mist.utils.makeVec3(_ref, 0) -- turn it into Vec3 if it is not already.
    _unitPos = mist.utils.makeVec3(_unitPos, 0) -- turn it into Vec3 if it is not already.

    local _vec = { x = _unitPos.x - _ref.x, y = _unitPos.y - _ref.y, z = _unitPos.z - _ref.z }

    local _dir = mist.utils.getDir(_vec, _ref)

    local _bearing = mist.utils.round(mist.utils.toDegree(_dir), 0)

    return _bearing
end

function ctld.listNearbyCrates(_args)

    local _message = ""

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then

        return -- no heli!
    end

    local _crates = ctld.getCratesAndDistance(_heli)

    --sort
    local _sort = function(a, b)
        return a.dist < b.dist
    end
    table.sort(_crates, _sort)

    for _, _crate in pairs(_crates) do

        if _crate.dist < 1000 and _crate.details.unit ~= "LogisticsCentre" then
            _message = string.format("%s\n%s crate - kg %i - %i m - %d o'clock", _message, _crate.details.desc, _crate.details.weight, _crate.dist, ctld.getClockDirection(_heli, _crate.crateUnit))
        end
    end

    local _logisticsCentreMsg = ""
    for _, _logisticsCentreCrate in pairs(_crates) do

        if _logisticsCentreCrate.dist < 1000 and _logisticsCentreCrate.details.unit == "LogisticsCentre" then
            _logisticsCentreMsg = _logisticsCentreMsg .. string.format("Logistics Center crate - %d m - %d o'clock\n", _logisticsCentreCrate.dist, ctld.getClockDirection(_heli, _logisticsCentreCrate.crateUnit))
        end
    end

    if _message ~= "" or _logisticsCentreMsg ~= "" then

        local _txt = ""

        if _message ~= "" then
            _txt = "Nearby Crates:\n" .. _message
        end

        if _logisticsCentreMsg ~= "" then

            if _message ~= "" then
                _txt = _txt .. "\n\n"
            end

            _txt = _txt .. "Nearby Logistics Centre crates (Not Slingloadable):\n" .. _logisticsCentreMsg
        end

        ctld.displayMessageToGroup(_heli, _txt, 20)

    else
        --no crates nearby

        local _txt = "No Nearby Crates"

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

--mr: Improve this list to be more informative i.e. logistics centres @ airbases Vs FARPs Vs FOBs + simple map grid or base name
function ctld.listFOBs(_args)

    local _msg = "FOB Positions:"

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then

        return -- no heli!
    end

    -- get fob positions

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do
        _msg = string.format("%s\nFOB @ %s", _msg, ctld.getPositionString(_fob))
    end

    if _msg == "FOB Positions:" then
        ctld.displayMessageToGroup(_heli, "Sorry, there are no active FOBs!", 20)
    else
        ctld.displayMessageToGroup(_heli, _msg, 20)
    end
end

function ctld.getPositionString(_fob)

    local _lat, _lon = coord.LOtoLL(_fob:getPosition().p)

    local _latLngStr = mist.tostringLL(_lat, _lon, 3, ctld.location_DMS)

    --   local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_fob:getPosition().p)), 5)

    local _message = _latLngStr

    local _beaconInfo = ctld.FOBbeacons[_fob:getName()]

    if _beaconInfo ~= nil then
        _message = string.format("%s - %.2f KHz ", _message, _beaconInfo.vhf / 1000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.uhf / 1000000)
        _message = string.format("%s - %.2f MHz ", _message, _beaconInfo.fm / 1000000)
    end

    return _message
end

function ctld.displayMessageToGroup(_unit, _text, _time, _clear)

    local _groupId = ctld.getGroupId(_unit)
    if _groupId then
        if _clear == true then
            trigger.action.outTextForGroup(_groupId, _text, _time, _clear)
        else
            trigger.action.outTextForGroup(_groupId, _text, _time)
        end
    end
end

function ctld.heightDiff(_unit)

    local _point = _unit:getPoint()

    -- env.info("heightunit " .. _point.y)
    --env.info("heightland " .. land.getHeight({ x = _point.x, y = _point.z }))

    return _point.y - land.getHeight({ x = _point.x, y = _point.z })
end

--includes logistics centre crates!
function ctld.getCratesAndDistance(_heli)

    local _crates = {}

    local _allCrates
    if _heli:getCoalition() == 1 then
        _allCrates = ctld.spawnedCratesRED  -- ctld.spawnedCratesRED[_crateName][ctld.crateLookupTable]
    else
        _allCrates = ctld.spawnedCratesBLUE
    end

    for _crateName, _details in pairs(_allCrates) do

        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
        if _crate ~= nil and _crate:getLife() > 0
                and (ctld.inAir(_crate) == false) then

            local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

            local _crateInfo = { name = _crateName, details = _details, dist = _dist, crateUnit = _crate }

            table.insert(_crates, _crateInfo)
        end
    end

    local _logisticsCentreCrates
    if _heli:getCoalition() == 1 then
        _logisticsCentreCrates = ctld.droppedLogisticsCentreCratesRED
    else
        _logisticsCentreCrates = ctld.droppedLogisticsCentreCratesBLUE
    end

    for _crateName, _ in pairs(_logisticsCentreCrates) do

        --get crate
        local _crate = ctld.getCrateObject(_crateName)

        if _crate ~= nil and _crate:getLife() > 0 then

            local _dist = ctld.getDistance(_crate:getPoint(), _heli:getPoint())

			-- { desc = "Logistics Centre crate", internal = 1, unit = "LogisticsCentre", weight = 503, baseOfOrigin = "MM75" }
			local _crateInfo = { name = _crateName, details = _details, dist = _dist, crateUnit = _crate } -- full details includes baseOfOrigin
            table.insert(_crates, _crateInfo)
        end
    end

    return _crates
end

-- luacheck: push no unused
function ctld.getClosestCrate(_heli, _crates, _type)

    local _closetCrate = nil
    local _shortestDistance = -1
    local _distance = 0

    for _, _crate in pairs(_crates) do

        if (_crate.details.unit == _type or _type == nil) then
            _distance = _crate.dist

            if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                _shortestDistance = _distance
                _closetCrate = _crate
            end
        end
    end

    return _closetCrate
end
-- luacheck: pop

function ctld.findNearestAASystem(_heli, _aaSystem)

    local _closestHawkGroup = nil
    local _shortestDistance = -1

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do

        local _hawkGroup = Group.getByName(_groupName)

        --  env.info(_groupName..": "..mist.utils.tableShow(_hawkDetails))
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() and _hawkDetails[1].system.name == _aaSystem.name then

            local _units = _hawkGroup:getUnits()

            for _, _leader in pairs(_units) do

                if _leader ~= nil and _leader:getLife() > 0 then

                    local _distance = ctld.getDistance(_leader:getPoint(), _heli:getPoint())

                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closestHawkGroup = _hawkGroup
                    end

                    break
                end
            end
        end
    end

    if _closestHawkGroup ~= nil then

        return { group = _closestHawkGroup, dist = _shortestDistance }
    end
    return nil
end

function ctld.getCrateObject(_name)
    local _crate

    if ctld.staticBugWorkaround then
        _crate = Unit.getByName(_name)
    else
        _crate = StaticObject.getByName(_name)
    end
    return _crate
end

function ctld.unpackCrates(_arguments)

    local _status, _err = pcall(function(_args)

        -- trigger.action.outText("Unpack Crates".._args[1],10)

        local _heli = ctld.getTransportUnit(_args[1])

        if _heli ~= nil and ctld.inAir(_heli) == false then
			

			local _playerDetails = {} -- fill with dummy values for non-MP testing
			--[[
			if DCS.isMultiplayer() then
				_playerDetails = playerDetails.getPlayerDetails(_heli:getName())
			end
			--]]
			--[[
				'id'    : playerID
				'name'  : player name
				'side'  : 0 - spectators, 1 - red, 2 - blue
				'slot'  : slotID of the player or 
				'ping'  : ping of the player in ms
				'ipaddr': IP address of the player, SERVER ONLY
				'ucid'  : Unique Client Identifier, SERVER ONLY
			--]]
			local _playerUCID = _playerDetails['ucid']

			local _heliCoalition = _heli:getCoalition()
			
            local _crates = ctld.getCratesAndDistance(_heli)
            local _crate = ctld.getClosestCrate(_heli, _crates)
			
			log:info("_crates: $1, _crate: $2",inspect(_crates, { newline = " ", indent = "" }),inspect(_crate, { newline = " ", indent = "" }))
			
			local _friendlyLogisticsCentreProximity = ctld.friendlyLogisticsCentreProximity(_heli)
			local _nearestLogisticsCentreName = _friendlyLogisticsCentreProximity[1] --(rare) if no friendly LC at all = "NoFriendlyLC"
			local _nearestLogisticsCentreDist = _friendlyLogisticsCentreProximity[2] --(rare) if no friendly LC at all = "NoDist"
			local _nearestLogisticsCentreBaseName = _friendlyLogisticsCentreProximity[3] --(rare) if no friendly LC at all = "NoBase"
			
			local _nearestLogisticsCentreSideName = "neutral"
			if (_nearestLogisticsCentreName ~= "NoFriendlyLC") then 
				_nearestLogisticsCentreSideName = _aircraftSideName
			end

            if (ctld.debug == false) then
                if (_nearestLogisticsCentreDist <= ctld.maximumDistanceLogistic) == true or ctld.farEnoughFromLogisticCentre(_heli) == false then
                    ctld.displayMessageToGroup(_heli, "You are too close to the Logistics Centre to unpack this crate!", 20)
                    return
                end
            end

            if _crate ~= nil and _crate.dist < 750
                    and (_crate.details.unit == "LogisticsCentre" or _crate.details.unit == "LogisticsCentre-SMALL") then
					
					if _nearestLogisticsCentreDist > ctld.friendlyLogisiticsCentreSpacing then
						ctld.unpackLogisticsCentreCrates(_crates, _heli) --will conduct FOB exclusion zone checks
					else
						ctld.displayMessageToGroup(_heli, "An existing friendly logisitics centre (" 
						.. mist.utils.round(((ctld.friendlyLogisiticsCentreSpacing - _nearestLogisticsCentreDist)/1000),1) .. "km)"
						.. " is too close to allow deploying this FOB!", 20)
					end
                return

            elseif _crate ~= nil and _crate.dist < 200 then

                if ctld.forceCrateToBeMoved and ctld.crateMove[_crate.crateUnit:getName()] then
                    ctld.displayMessageToGroup(_heli, "You must move this crate before you unpack it!", 20)
                    return
                end
				
				--check if logisitics centre of origin still alive
				_crateName = _crate.name
				
				log:info("_crate.name: $1, _crate: $2",_crate.name,inspect(_crate, { newline = " ", indent = "" }))
				
				_crateBaseOfOrigin = string.match(_crateName, "%((.+)%)$")
				if not ctld.isLogisticsCentreAliveAt(_crateBaseOfOrigin) then
					local _azToCrate = ctld.getCompassBearing(_heli:getPoint(),_crate.crateUnit:getPoint())
					ctld.displayMessageToGroup(_heli, "WARNING: " .. "supplying logisitics centre at " .. _crateBaseOfOrigin .. " for crate (" .. _azToCrate .. "," .. _nearbyCrate.dist .. "m) destroyed.  Unable to unpack crate.", 20)
					return
				end
		
                local _aaTemplate = ctld.getAATemplate(_crate.details.unit)

                if _aaTemplate then

                    if _crate.details.unit == _aaTemplate.repair then
                        ctld.repairAASystem(_heli, _crate, _aaTemplate)
                    else
                        ctld.unpackAASystem(_heli, _crate, _crates, _aaTemplate)
                    end

                    return -- stop processing
                    -- is multi crate?
                elseif _crate.details.cratesRequired ~= nil and _crate.details.cratesRequired > 1 then
                    -- multicrate

                    ctld.unpackMultiCrate(_heli, _crate, _crates)

                    return

                else
                    -- single crate
                    local _cratePoint = _crate.crateUnit:getPoint()
                    local _crateName = _crate.crateUnit:getName()

                    -- ctld.spawnCrateStatic( _heli:getCoalition(),ctld.getNextUnitId(),{x=100,z=100},_crateName,100)

                    --remove crate
                    --  if ctld.slingLoad == false then
                    _crate.crateUnit:destroy()
                    -- end

                    local _spawnedGroups = ctld.spawnCrateGroup(_heli, { _cratePoint }, { _crate.details.unit }, _crate.details.unitQuantity)

                    if _heliCoalition == 1 then
                        ctld.spawnedCratesRED[_crateName] = nil
                    else
                        ctld.spawnedCratesBLUE[_crateName] = nil
                    end
					
					--"unpack" callback from persistence.lua: adds new group to side ownership and table for state saving (rsrState.json)
                    ctld.processCallback({ unit = _heli, crate = _crate, spawnedGroup = _spawnedGroups, action = "unpack" })

                    if _crate.details.unit == "1L13 EWR" then
                        ctld.addEWRTask(_spawnedGroups)
                        --env.info("Added EWR")
                    end

                    local quantityTxt = ""
                    local plural = ""
                    if _crate.details.unitQuantity ~= nil and _crate.details.unitQuantity > 1 then
                        quantityTxt = tostring(_crate.details.unitQuantity) .. " "
                        plural = "s"
                    end
                    trigger.action.outTextForCoalition(_heliCoalition, ctld.getPlayerNameOrType(_heli) .. " successfully deployed " .. quantityTxt .. _crate.details.desc .. plural .. " to the field", 10)

                    if ctld.isJTACUnitType(_crate.details.unit) and ctld.JTAC_dropEnabled then
                        local _code = ctld.getLaserCode(_heliCoalition)
                        ctld.JTACAutoLase(_spawnedGroups:getName(), _code)
						--[[
						local _playerJTACsForSide = ctld.JTACsPerPlayerPerSide[_playerUCID][_heliCoalition]
						local _playerJTACsForSideCount = 0
						if _playerJTACsForSide ~= nil then
							for _k, _JTACgroup in ipairs (_playerJTACsForSide) do
								
								if _JTACgroup == nil then
									table.remove(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],_k)
								else
									_playerJTACsForSideCount = _playerJTACsForSideCount + 1
								end
							end	
						end
						
						if ctld.JTAC_LIMIT_perPLAYER_perSIDE > _playerJTACsForSideCount then
							ctld.displayMessageToGroup(_heli, "JTACs per player per side limit (" .. ctld.JTAC_LIMIT_perPLAYER_perSIDE .. ") reached.  Deleting oldest JTAC.", 20)
							-- newest JTAC always appended to end of table, therefore pos 1 JTAC = oldest
							table.remove(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],1)
						end
						-- newest JTAC always appended to end of table, therefore pos 2 JTAC = newest
						-- no position for insert given, therefore should append to end
						table.insert(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],_spawnedGroups:getName())
						--]]
                    end

                end

            else

                ctld.displayMessageToGroup(_heli, "No friendly crates close enough to unpack", 20)
            end
        end
    end, _arguments)

    if (not _status) then
        env.error(string.format("CTLD ERROR: %s", _err))
    end
end


--[[
	builds a logistics centre after unpacking a logistics centre crate
	after loading internal cargo, ctld.unloadInternalCrate will prevent unloading in base area that already has logistics centre
	after loading internal cargo, ctld.unloadInternalCrate will prevent unloading if too close to logistics centre
	below checks will prevent deploying FOB in FOB exclusion zone
--]]
function ctld.unpackLogisticsCentreCrates(_crates, _aircraft)

	if ctld.inAir(_aircraft) then
		ctld.displayMessageToGroup(_aircraft,"You must land before commencing logistics operations", 10)
        return
    end
	
	--mr: need to check repair crate being brought from different base!!!

	local _playerName = ctld.getPlayerNameOrType(_aircraft) --baseName = playerName for s
	local _baseORfob = "FOB"
	local _buildTime = ctld.buildTimeFOB

	--returns closest base to player and also if in repair radius or FOB exclusion zone
	--{_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}
	local _baseProximity = ctld.baseProximity(_aircraft)
	local _inBaseZoneAndRSRradius = _baseProximity[1]
	local _inFOBexclusionZone = _baseProximity[2]
	local _closestBaseName = _baseProximity[3][1]
	local _closestBaseSide = _baseProximity[3][2]
	local _closestBaseDist = _baseProximity[3][3]
	local _baseType = _baseProximity[4]
	
	local _baseName = _playerName
	if _inBaseZoneAndRSRradius then
		_baseName = _closestBaseName -- exchange playerName for baseName
		_baseORfob = _baseType --provides distinction between deploying or repairing airbase/FARP in below messages
		_buildTime = 1 --reduce build time for airbase/FARP as it's a repair + avoids problems with potentially multiple logistics centres! --uncessary
	end
	
	local _RSRradius = 10000 -- RSRbaseCaptureZones FARP zones 5km in MIZ, most RSRbaseCaptureZones Airbase zones 10km in MIZ
	if _baseType == "Airbase" then
		_RSRradius = ctld.maximumDistFromAirbaseToRepair -- 5km
	elseif _baseType == "FARP" then
		_RSRradius = ctld.maximumDistFromFARPToRepair -- 3km
	end
	
	--[[
		(a) if _inBaseZoneAndRSRradius = true, then _inFOBexclusionZone = true, then close enough for base repair
		(b) if _inBaseZoneAndRSRradius = false, and _inFOBexclusionZone = false, then far enough for deployable FOB
		(c) if _inBaseZoneAndRSRradius = false, and _inFOBexclusionZone = then, then too far for base for repair AND too close for deployable FOB
		> ctld.baseProximity will also provide message to player for (c)
	--]]
	
	local _abortUnpack = false
	if _inFOBexclusionZone then
		
		if not _inBaseZoneAndRSRradius then
			local _aircraftDistRSR = _RSRradius - _closestBaseDist
				-- log:info("$1 too close to $2 for FOB  but not close enough for repair",_baseNameORplayerName, _closestBase)
				ctld.displayMessageToGroup(_aircraft, "You are too far from " .. _baseName .. mist.utils.round((_aircraftDistRSR/1000),1) 
				.. "for a repair and too close (<" .. mist.utils.round((ctld.exclusionZoneFromBasesFors/1000),1) .. ") to deploy a FOB", 20)
				_abortUnpack = true
		end
		if _inBaseZoneAndRSRradius and((_closestBaseSide ~= _aircraftSideName) and (_closestBaseSide ~= "neutral")) then
			ctld.displayMessageToGroup(_aircraft, _baseName .. " is not a friendly or neutral base, and you cannot repair it", 20)
			_abortUnpack = true
		end
	end
	
	if _abortUnpack then
		return --abort logistics crate unpack
	end
	
    -- unpack multi crate
    local _nearbyMultiCrates = {}

    local _bigLogisticsCentreCrates = 0
    local _smallLogisticsCentreCrates = 0
    local _totalCrates = 0
	local _crateName = "NoCrateName"
	local _crateBaseOfOrigin = "AA00"
	
    for _, _nearbyCrate in pairs(_crates) do

        if _nearbyCrate.dist < 750 then
			
			_crateName = _nearbyCrate.details.name
			_crateBaseOfOrigin = string.match(_crateName, "%((.+)%)$")
			-- if logisitics centre crate base of origin same as base to be repaired, warn player that unpack will be prevented
			if _crateBaseOfOrigin == _closestBaseName then
				local _azToCrate = ctld.getCompassBearing(_heli:getPoint(),_crate.crateUnit:getPoint())
				ctld.displayMessageToGroup(_heli, "WARNING: " .. "logistics centre crate (" .. _azToCrate .. "," .. _nearbyCrate.dist .. "m)".. "from " .. _crateBaseOfOrigin .. ", cannot be unpacked at base of origin (nearest base: " .. _closestBaseName .. ")", 20)
			else
				if _nearbyCrate.details.unit == "LogisticsCentre" then
					_bigLogisticsCentreCrates = _bigLogisticsCentreCrates + 1
					table.insert(_nearbyMultiCrates, _nearbyCrate)
				elseif _nearbyCrate.details.unit == "-SMALL" then
					_smallLogisticsCentreCrates = _smallLogisticsCentreCrates + 1
					table.insert(_nearbyMultiCrates, _nearbyCrate)
				end
			end
			
            --catch divide by 0
            if _smallLogisticsCentreCrates > 0 then
                _totalCrates = _bigLogisticsCentreCrates + (_smallLogisticsCentreCrates / 3.0)
            else
                _totalCrates = _bigLogisticsCentreCrates
            end

				
            if _totalCrates >= ctld.cratesRequiredForLogisticsCentre then
                break
            end
        end

    end

    --- check crate count
    if _totalCrates >= ctld.cratesRequiredForLogisticsCentre then

        -- destroy crates

        local _points = {}

        for _, _crate in pairs(_nearbyMultiCrates) do

            if _aircraft:getCoalition() == 1 then
                ctld.droppedLogisticsCentreCratesRED[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.droppedLogisticsCentreCratesBLUE[_crate.crateUnit:getName()] = nil
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            table.insert(_points, _crate.crateUnit:getPoint())

            --destroy
            _crate.crateUnit:destroy()
        end

        local _centroid = ctld.getCentroid(_points)
		local _country = _aircraft:getCountry()
		local _coalition = _aircraft:getCoalition()
		local _side = utils.getSideName(_coalition)
		local _unitId = ctld.ctld.getNextLogisiticsCentreId()
		local _logisticsCentreName = ""
		
		if _baseORfob == "FOB" then
			--mr: feature: use deploying player name in FOB name
			_logisticsCentreName = _logisticsCentreName .. _playerName .. " FOB Logistics Centre #" .. _unitId .. " " .. _side 
			
			timer.scheduleFunction(function(_args)
				
				local _side = utils.getSideName(_args[3]) 

				--(_point, _name, _coalition (only for construction message), _baseORfob, _baseORfobName)
				local _newLogisticCentre = ctld.spawnLogisticsCentre(_args[1], _args[2], _args[3], "FOB", _args[4])

				--only deployed s get radio beacon
				ctld.beaconCount = ctld.beaconCount + 1
				local _radioBeaconName = " Beacon #" .. ctld.beaconCount
				local _radioBeaconDetails = ctld.createRadioBeacon(_args[1], _args[3], _args[5], _radioBeaconName, nil, true)
				ctld.FOBbeacons[_name] = { vhf = _radioBeaconDetails.vhf, uhf = _radioBeaconDetails.uhf, fm = _radioBeaconDetails.fm }

				if ctld.troopPickupAtFOB == true then
					table.insert(ctld.builtFOBs, _newLogisticCentre:getName())
					trigger.action.outTextForCoalition(_args[3], "Finished building Logistics Centre! Crates and Troops can now be picked up.", 10)
				else
					trigger.action.outTextForCoalition(_args[3], "Finished building Logistics Centre! Crates can now be picked up.", 10)
				end
			end, 
			{ 
				_centroid, --_args[1] = ignore for base (airbase/FARP) repair
				_logisticsCentreName, --_args[2] = name of logistics centre static object
				_coalition, --_args[3] = coalition for construction message locality
				_playerName, -- _args[4] = name FOB after player
				_country -- _args[5] = country of player, required for radioBeacon but NOT required for logisitics centre which is always neutral
			}, timer.getTime() + _buildTime)
		
			local _txt = string.format("%s started deploying a FOB using %d Logistics Centre crates and it will be finished in %d seconds.", ctld.getPlayerNameOrType(_heli), _totalCrates, _buildTime)
		
		else
			--[[
				Add side to logistics centre name to allow static object to be neutral but be able to interogate name for coalition
				As side in name of logistics centre utilised in baseOwnershipCheck.lua to recheck true RSR base owner, very important that side set in name
				
				unitID required?  If not set, new static object of same name will overwrite (= delete? = advantageous for repair) old object
				> https://wiki.hoggitworld.com/view/DCS_func_addStaticObject
				>> Static Objects name cannot be shared with an existing object, if it is the existing object will be destroyed on the spawning of the new object.
				>> If unitId is not specified or matches an existing object, a new Id will be generated.
				>> Coalition of the object is defined based on the country the object is spawning to.
				
				>>>>> logistic centre name will inlcude team name (red/blue) therefore 'replacement = destroy' with same name only useful for airbase "repair"
			--]]
			_logisticsCentreName = _logisticsCentreName .. _baseName .. " Logistics Centre #" .. _unitId .. " " .. _side -- "MM75 Logistics Centre #001 red"
			logisticsManager.spawnLogisticsBuildingForBase(_baseName,_aircraftSideName,_logisticsCentreName,false,_playerName)
			--trigger.action.outTextForCoalition(_aircraft:getCoalition(), _playerName .. " has repaired the Logistics Centre at " .. _closestBaseName, 10) --moved to baseOwnershipCheck.lua
		end

        ctld.processCallback({ unit = _aircraft, position = _centroid, action = "fob" }) --mr: what does this do?!

        -- RSR: remove green smoke on FOB spawn
        --trigger.action.smoke(_centroid, trigger.smokeColor.Green)

        trigger.action.outTextForCoalition(_aircraft:getCoalition(), _txt, 10)
    else
        local _txt = string.format("Cannot build Logistics Centre!\n\nIt requires %d Large Logistics Centre crates ( 3 small Logistics Centre crates equal 1 large Logistics Centre Crate) and there are the equivalent of %d large Logistics Centre crates nearby\n\nOr the crates are not within 750m of each other", ctld.cratesRequiredForLogisticsCentre, _totalCrates)
        ctld.displayMessageToGroup(_aircraft, _txt, 20)
    end
end

--copied from ctld.dropSlingCrate but without fake sling loading references
function ctld.unloadInternalCrate (_args)
	
	local _heli = ctld.getTransportUnit(_args[1])
	
    if _heli == nil then
        return
    end
	
	if ctld.inAir(_heli) then
		ctld.displayMessageToGroup(_aircraft,"You must land before commencing logistics operations", 10)
        return
    end
	
	if not ctld.unitCargoDoorsOpen(_heli) then
		ctld.displayMessageToGroup(_heli, "Cargo doors must be open, or removed, to unload cargo.", 10)
		return
	end
	
	-- ctld.loadNearbyCrate: ctld.inTransitSlingLoadCrates[_name] = _copiedCrate
    local _currentCrate = ctld.inTransitSlingLoadCrates[_heli:getName()]
	log:info("ctld.unloadInternalCrate: ctld.inTransitSlingLoadCrates: $1", inspect(ctld.inTransitSlingLoadCrates, { newline = " ", indent = "" }))
	
	if _currentCrate == nil then
		_currentCrate = ctld.inTransitLogisticsCentreCrates[_heli:getName()]
	end
	log:info("ctld.unloadInternalCrate: ctld.inTransitLogisticsCentreCrates: $1", inspect(ctld.inTransitLogisticsCentreCrates, { newline = " ", indent = "" }))
	
    if _currentCrate == nil then
		ctld.displayMessageToGroup(_heli, "You are not currently transporting any crates. \n\nTo Pickup a crate - land and use F10 Crate Commands to load one.", 10)
    else
	
		local _point = ctld.getCargoUnloadPoint(_heli, 30)
        local _unitId = ctld.getNextUnitId()
        local _heliSide = _heli:getCoalition()
		local _heliSideName = utils.getSideName(_heliSide)
		
		-- _currentCrate.details = { desc = "Logistics Centre crate", internal = 1, unit = "LogisticsCentre", weight = 503, baseOfOrigin = "MM75" }
		local _crateBaseOfOrigin = _currentCrate.baseOfOrigin
		-- ctld.spawnCrateStatic: local _baseOfOriginFromName = string.match(_name, "%((.+)%)$")
        local _crateName = string.format("%s #%i (%s)", _currentCrate.desc, _unitId, _crateBaseOfOrigin) 
		local _isLogisticsCentreCrate = (_currentCrate.unit == "LogisticsCentre" or _currentCrate.unit == "LogisticsCentre-SMALL") 
		
		--{_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}
		local _baseProximity = ctld.baseProximity(_heli)
		local _inBaseZoneAndRSRrepairRadius = _baseProximity[1]
		local _inFOBexclusionZone = _baseProximity[2]
		local _closestBaseName = _baseProximity[3][1]
		local _closestBaseSide = _baseProximity[3][2]
		local _closestBaseDist = _baseProximity[3][3]
		local _baseType = _baseProximity[4]
		
		--[[
			(a) if _inBaseZoneAndRSRrepairRadius = true, then _inFOBexclusionZone = true, then close enough for base repair
			(b) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = false, then far enough for deployable FOB
			(c) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = then, then too far for base for repair AND too close for deployable FOB 
		--]]
		
		local _RSRradius = 10000 -- RSRbaseCaptureZones FARP zones 5km in MIZ, most RSRbaseCaptureZones Airbase zones 10km in MIZ
		if _baseType == "Airbase" then
			_RSRradius = ctld.maximumDistFromAirbaseToRepair -- 5km
		elseif _baseType == "FARP" then
			_RSRradius = ctld.maximumDistFromFARPToRepair -- 3km
		end
		
		-- proximity to nearest logistics centre object NOT whether player in logisitics zone, and if logistics centre is friendly
		local _friendlyLogisticsCentreProximity = ctld.friendlyLogisticsCentreProximity(_heli)
		local _nearestLogisticsCentreName = _friendlyLogisticsCentreProximity[1] --(rare) if no friendly LC at all = "NoFriendlyLC"
		local _nearestLogisticsCentreDist = _friendlyLogisticsCentreProximity[2] --(rare) if no friendly LC at all = "NoDist"
		local _nearestLogisticsCentreBaseName = _friendlyLogisticsCentreProximity[3] --(rare) if no friendly LC at all = "NoBase"
		
		local _nearestLogisticsCentreSideName = "neutral" 
		if (_nearestLogisticsCentreName ~= "NoFriendlyLC") then 
			_nearestLogisticsCentreSideName = _heliSideName
		end
		
		
		local _noLogisticsCentreBase = false
		if _inBaseZoneAndRSRrepairRadius then
			-- airbases/FARPs that if within, do not require a logisitics centre to be present e.g. Gas Platforms
			-- ctld.logisticCentreNotReqInBase = {"RedStagingPoint", "BlueStagingPoint"}
			for _k, _base in pairs(ctld.logisticCentreNotReqInBase) do
				if _base == _closestBaseName then
					_noLogisticsCentreBase = true
				end
			end
		end
		
		if _noLogisticsCentreBase then
			-- return crate to base and do not allow crate deployment at 'logisitics centre not required' bases
			if _isLogisticsCentreCrate then
				ctld.displayMessageToGroup(_heli, "Crate unloading not allowed at " .. _closestBaseName .. ". Returning Logisitics Centre crate to base." , 10)
				ctld.inTransitLogisticsCentreCrates[_heli:getName()] = nil
			else
				ctld.displayMessageToGroup(_heli, "Crate unloading not allowed at " .. _closestBaseName .. ". Returning " .. _currentCrate.desc .. " crate to base." , 10)
				ctld.inTransitSlingLoadCrates[_heli:getName()] = nil
			end

		else
			--JTAC or any other internal crate
			if not _isLogisticsCentreCrate then
				if (_heli:getTypeName() == "Mi-8MT") then
					ctld.displayMessageToGroup(_heli, _currentCrate.desc .. " crate has been safely unloaded and is at your 6 o'clock", 10) -- Cargo is from Rear of Mi-8
				else
					ctld.displayMessageToGroup(_heli, _currentCrate.desc .. " crate has been safely unloaded from your cargo bay.", 10)
				end
				
				--unload internal crate
				ctld.inTransitSlingLoadCrates[_heli:getName()] = nil
				ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _crateName, _currentCrate.weight, _heliSide, _currentCrate.internal)
				
			else		
				--[[ 
					provide warnings but do not stop crate deploying as may be needed for unique circumstances 
					e.g. delivery by plane but later pickup by helo, pre-delivery to enemy base prior to capture
				--]]
				if _inFOBexclusionZone == true and _inBaseZoneAndRSRrepairRadius == false then
					local _aircraftDistRSR = _RSRradius - _closestBaseDist
					ctld.displayMessageToGroup(_heli, "WARNING: You are too far from " .. _closestBaseName .. mist.utils.round((_aircraftDistRSR/1000),1) 
					.. "for a repair and too close (<" .. (ctld.exclusionZoneFromBasesforFOBs/1000) .. ") to deploy a FOB!", 20)
				end
				
				-- if player not in FOB exclusion zone then proximity to base irrelevant as too far to matter
				if _inBaseZoneAndRSRrepairRadius == true and ((_closestBaseSide ~= _heliSideName) and (_closestBaseSide ~= "neutral")) then
					ctld.displayMessageToGroup(_heli, "WARNING: You cannot repair " .. _closestBaseName .. " as it is not a friendly or neutral base!", 20)
				end
				
				--log:info("_inBaseZoneAndRSRrepairRadius: $1, _closestBaseSide: $2, _heliSideName: $3, _crateBaseOfOrigin: $4",_inBaseZoneAndRSRrepairRadius,_closestBaseSide,_heliSideName, _crateBaseOfOrigin)
				
				-- if logisitics centre crate base of origin same as base to be repaired, warn player that unpack will be prevented
				if _crateBaseOfOrigin == _closestBaseName then
					ctld.displayMessageToGroup(_heli, "WARNING: " .. "logistics centre crate from " .. _crateBaseOfOrigin .. ", cannot be unloaded within base of origin (nearest base: " .. _closestBaseName .. ")", 20)
				end
				------------------------------------------------------------------------------------
				if 
				-- if logisitics centre already present, return logistics centre crate to base pool to prevent exploit of "backup repair crates"
					_inBaseZoneAndRSRrepairRadius == true and
					(_closestBaseSide == _heliSideName) and
					(_nearestLogisticsCentreBaseName == _closestBaseName) then
					
					ctld.displayMessageToGroup(_heli, "Logistics Centre already present.  Logistics Centre crate returned to base.", 10)
					ctld.inTransitLogisticsCentreCrates[_heli:getName()] = nil
				else
				--unload internal crate
					ctld.inTransitSlingLoadCrates[_heli:getName()] = nil
					ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _crateName, _currentCrate.weight, _heliSide, _currentCrate.internal)
				
				-- shouldn't be needed as planes will have unpack option of different combined option that unloads+unpacks at same time
				--[[
				elseif 
				-- initiate immediate base repair, no need for crate spawn
					_inBaseZoneAndRSRrepairRadius == true and
					(_closestBaseSide == _heliSideName) and
					(_nearestLogisticsCentreBaseName ~= _closestBaseName) then -- no logisitics centre at current base
					local _logisticsCentreName = ""
					_logisticsCentreName = _logisticsCentreName .. _baseNameORplayerName .. " Logistics Centre #" .. _unitId .. " " .. _heliSide -- "MM75 Logistics Centre #001 red"
					logisticsManager.spawnLogisticsBuildingForBase(_closestBaseName,_heliSideName,_logisticsCentreName,false, _playerName)
					trigger.action.outTextForCoalition(_heli:getCoalition(), _playerName .. " has repaired the Logistics Centre at " .. _closestBaseName, 10)
				--]]
				
				end	
			end
		end
    end
end

--unloads the sling crate when the helicopter is on the ground or between 4.5 - 10 meters
function ctld.dropSlingCrate(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return -- no heli!
    end

    local _currentCrate = ctld.inTransitSlingLoadCrates[_heli:getName()]

    if _currentCrate == nil then
        if ctld.hoverPickup then
            ctld.displayMessageToGroup(_heli, "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for " .. ctld.hoverTime .. " seconds above the crate", 10)
        else
            ctld.displayMessageToGroup(_heli, "You are not currently transporting any crates. \n\nTo Pickup a crate - land and use F10 Crate Commands to load one.", 10)
        end
    else

        -- local _point = _heli:getPoint()
        local _point = ctld.getCargoUnloadPoint(_heli, 30)
        local _unitId = ctld.getNextUnitId()

        local _side = _heli:getCoalition()

        local _name = string.format("%s #%i", _currentCrate.desc, _unitId)

        --local _heightDiff = ctld.heightDiff(_heli)

        -- Ironwulf2000 internal cargo
        if (ctld.inAir(_heli) == false) and (ctld.internalCargo == true) then
            if (_heli:getTypeName() == "Mi-8MT") then
                -- Cargo is from Rear of Mi-8
                if ctld.unitCargoDoorsOpen(_heli) then
                    ctld.displayMessageToGroup(_heli, _currentCrate.desc .. " crate has been safely unloaded and is at your 6 o'clock", 10)
                else
                    ctld.displayMessageToGroup(_heli, "Cargo doors must be open, or removed, to unload cargo.", 10)
                    return
                end
            elseif ctld.unitCargoDoorsOpen(_heli) then
                ctld.displayMessageToGroup(_heli, _currentCrate.desc .. " crate has been safely unloaded from your cargo bay.", 10)
            else
                ctld.displayMessageToGroup(_heli, "Cargo doors must be open, or removed, to unload cargo.", 10)
                return
            end
			--[[
				elseif ctld.inAir(_heli) == true and _heightDiff <= 2.0 then  -- Ironwulf2000 Modified
					ctld.displayMessageToGroup(_heli, _currentCrate.desc .. " crate has been safely unloaded and is at your 12 o'clock", 10)
					_point = ctld.getPointAt12Oclock(_heli, 30)
				--Ironwulf2000 removed
                elseif _heightDiff > 40.0 then
                        ctld.inTransitSlingLoadCrates[_heli:getName()] = nil
                        ctld.displayMessageToGroup(_heli, "You were too high! The crate has been destroyed", 10)
                        return
				elseif _heightDiff > 7.5 and _heightDiff <= 40.0 then
					ctld.displayMessageToGroup(_heli, _currentCrate.desc .. " crate has been safely dropped below you", 10)
			--]]
        else
			--[[
				_heightDiff > 40.0
				ctld.inTransitSlingLoadCrates[_heli:getName()] = nil
				ctld.displayMessageToGroup(_heli, "You were too high! The crate has been destroyed", 10)
			--]]
            ctld.displayMessageToGroup(_heli, "You must land to unload internal cargo", 10)
            return
        end
		
        --remove crate from cargo
        ctld.inTransitSlingLoadCrates[_heli:getName()] = nil

        ctld.spawnCrateStatic(_heli:getCountry(), _unitId, _point, _name, _currentCrate.weight, _side, _currentCrate.internal)
    end
end

-- shows the status of the current simulated cargo status
function ctld.slingCargoStatus(_args)
    local _heli = ctld.getTransportUnit(_args[1])

    if _heli == nil then
        return -- no heli!
    end

    local _currentCrate = ctld.inTransitSlingLoadCrates[_heli:getName()]

    if _currentCrate == nil then
        ctld.displayMessageToGroup(_heli, "You are not currently transporting any crates. \n\nTo Pickup a crate, hover for 10 seconds above the crate", 10)
    else
        ctld.displayMessageToGroup(_heli, "Currently Transporting: " .. _currentCrate.desc .. ".", 10)  --Ironwulf2000 fixed
    end
end

--spawns a radio beacon made up of two units,
-- one for VHF and one for UHF
-- The units are set to to NOT engage
function ctld.createRadioBeacon(_point, _coalition, _country, _name, _batteryTime, _isFOB)

    local _uhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, "UHF")
    local _vhfGroup = ctld.spawnRadioBeaconUnit(_point, _country, "VHF")
    local _fmGroup = ctld.spawnRadioBeaconUnit(_point, _country, "FM")

    local _freq = ctld.generateADFFrequencies()

    --create timeout
    local _battery

    if _batteryTime == nil then
        _battery = timer.getTime() + (ctld.deployedBeaconBattery * 60)
    else
        _battery = timer.getTime() + (_batteryTime * 60)
    end

    local _lat, _lon = coord.LOtoLL(_point)

    local _latLngStr = mist.tostringLL(_lat, _lon, 3, ctld.location_DMS)

    --local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_point)), 5)

    local _message = _name

    if _isFOB then
        --  _message = "FOB " .. _message
        _battery = -1 --never run out of power!
    end

    _message = _message .. " - " .. _latLngStr

    --  env.info("GEN UHF: ".. _freq.uhf)
    --  env.info("GEN VHF: ".. _freq.vhf)

    _message = string.format("%s - %.2f KHz", _message, _freq.vhf / 1000)

    _message = string.format("%s - %.2f MHz", _message, _freq.uhf / 1000000)

    _message = string.format("%s - %.2f MHz ", _message, _freq.fm / 1000000)

    local _beaconDetails = {
        vhf = _freq.vhf,
        vhfGroup = _vhfGroup:getName(),
        uhf = _freq.uhf,
        uhfGroup = _uhfGroup:getName(),
        fm = _freq.fm,
        fmGroup = _fmGroup:getName(),
        text = _message,
        battery = _battery,
        coalition = _coalition,
    }
    ctld.updateRadioBeacon(_beaconDetails)

    table.insert(ctld.deployedRadioBeacons, _beaconDetails)

    return _beaconDetails
end

function ctld.generateADFFrequencies()

    if #ctld.freeUHFFrequencies <= 3 then
        ctld.freeUHFFrequencies = ctld.usedUHFFrequencies
        ctld.usedUHFFrequencies = {}
    end

    --remove frequency at RANDOM
    local _uhf = table.remove(ctld.freeUHFFrequencies, math.random(#ctld.freeUHFFrequencies))
    table.insert(ctld.usedUHFFrequencies, _uhf)

    if #ctld.freeVHFFrequencies <= 3 then
        ctld.freeVHFFrequencies = ctld.usedVHFFrequencies
        ctld.usedVHFFrequencies = {}
    end

    local _vhf = table.remove(ctld.freeVHFFrequencies, math.random(#ctld.freeVHFFrequencies))
    table.insert(ctld.usedVHFFrequencies, _vhf)

    if #ctld.freeFMFrequencies <= 3 then
        ctld.freeFMFrequencies = ctld.usedFMFrequencies
        ctld.usedFMFrequencies = {}
    end

    local _fm = table.remove(ctld.freeFMFrequencies, math.random(#ctld.freeFMFrequencies))
    table.insert(ctld.usedFMFrequencies, _fm)

    return { uhf = _uhf, vhf = _vhf, fm = _fm }
    --- return {uhf=_uhf,vhf=_vhf}
end

function ctld.spawnRadioBeaconUnit(_point, _country, _type)

    local _groupId = ctld.getNextGroupId()

    local _unitId = ctld.getNextUnitId()

    local _radioGroup = {
        ["visible"] = false,
        -- ["groupId"] = _groupId,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["y"] = _point.z,
                ["type"] = "2B11 mortar",
                ["name"] = _type .. " Radio Beacon Unit #" .. _unitId,
                --   ["unitId"] = _unitId,
                ["heading"] = 0,
                ["playerCanDrive"] = true,
                ["skill"] = "Excellent",
                ["x"] = _point.x,
            }
        },
        --        ["y"] = _positions[1].z,
        --        ["x"] = _positions[1].x,
        ["name"] = _type .. " Radio Beacon Group #" .. _groupId,
        ["task"] = {},
        --added two fields below for MIST
        ["category"] = Group.Category.GROUND,
        ["country"] = _country
    }

    -- return coalition.addGroup(_country, Group.Category.GROUND, _radioGroup)
    return Group.getByName(mist.dynAdd(_radioGroup).name)
end

function ctld.updateRadioBeacon(_beaconDetails)

    local _vhfGroup = Group.getByName(_beaconDetails.vhfGroup)

    local _uhfGroup = Group.getByName(_beaconDetails.uhfGroup)

    local _fmGroup = Group.getByName(_beaconDetails.fmGroup)

    local _radioLoop = {}

    if _vhfGroup ~= nil and _vhfGroup:getUnits() ~= nil and #_vhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _vhfGroup, freq = _beaconDetails.vhf, silent = false, mode = 0 })
    end

    if _uhfGroup ~= nil and _uhfGroup:getUnits() ~= nil and #_uhfGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _uhfGroup, freq = _beaconDetails.uhf, silent = true, mode = 0 })
    end

    if _fmGroup ~= nil and _fmGroup:getUnits() ~= nil and #_fmGroup:getUnits() == 1 then
        table.insert(_radioLoop, { group = _fmGroup, freq = _beaconDetails.fm, silent = false, mode = 1 })
    end

    local _batLife = _beaconDetails.battery - timer.getTime()

    if (_batLife <= 0 and _beaconDetails.battery ~= -1) or #_radioLoop ~= 3 then
        -- ran out of batteries

        if _vhfGroup ~= nil then
            _vhfGroup:destroy()
        end
        if _uhfGroup ~= nil then
            _uhfGroup:destroy()
        end
        if _fmGroup ~= nil then
            _fmGroup:destroy()
        end

        return false
    end

    --fobs have unlimited battery life
    --    if _battery ~= -1 then
    --        _text = _text.." "..mist.utils.round(_batLife).." seconds of battery"
    --    end

    for _, _radio in pairs(_radioLoop) do

        local _groupController = _radio.group:getController()

        local _sound = ctld.radioSound
        if _radio.silent then
            _sound = ctld.radioSoundFC3
        end

        _sound = "l10n/DEFAULT/" .. _sound

        _groupController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)

        trigger.action.radioTransmission(_sound, _radio.group:getUnit(1):getPoint(), _radio.mode, false, _radio.freq, 1000)
        --This function doesnt actually stop transmitting when then sound is false. My hope is it will stop if a new beacon is created on the same
        -- frequency... OR they fix the bug where it wont stop.
        --        end

        --
    end

    return true

    --  trigger.action.radioTransmission(ctld.radioSound, _point, 1, true, _frequency, 1000)
end

function ctld.listRadioBeacons(_args)

    local _heli = ctld.getTransportUnit(_args[1])
    local _message = ""

    if _heli ~= nil then

        for _, _details in pairs(ctld.deployedRadioBeacons) do

            if _details.coalition == _heli:getCoalition() then
                _message = _message .. _details.text .. "\n"
            end
        end

        if _message ~= "" then
            ctld.displayMessageToGroup(_heli, "Radio Beacons:\n" .. _message, 20)
        else
            ctld.displayMessageToGroup(_heli, "No Active Radio Beacons", 20)
        end
    end
end

function ctld.dropRadioBeacon(_args)

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil and ctld.inAir(_heli) == false then

        --deploy 50 m infront
        --try to spawn at 12 oclock to us
        local _point = ctld.getPointAt12Oclock(_heli, 50)

        ctld.beaconCount = ctld.beaconCount + 1
        local _name = "Beacon #" .. ctld.beaconCount

        local _radioBeaconDetails = ctld.createRadioBeacon(_point, _heli:getCoalition(), _heli:getCountry(), _name, nil, false)

        -- mark with flare?

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " deployed a Radio Beacon.\n\n" .. _radioBeaconDetails.text, 20)

    else
        ctld.displayMessageToGroup(_heli, "You need to land before you can deploy a Radio Beacon!", 20)
    end
end

--remove closet radio beacon
function ctld.removeRadioBeacon(_args)

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil and ctld.inAir(_heli) == false then

        -- mark with flare?

        local _closetBeacon = nil
        local _shortestDistance = -1

        for _, _details in pairs(ctld.deployedRadioBeacons) do

            if _details.coalition == _heli:getCoalition() then

                local _group = Group.getByName(_details.vhfGroup)

                if _group ~= nil and #_group:getUnits() == 1 then

                    local _distance = ctld.getDistance(_heli:getPoint(), _group:getUnit(1):getPoint())
                    if _distance ~= nil and (_shortestDistance == -1 or _distance < _shortestDistance) then
                        _shortestDistance = _distance
                        _closetBeacon = _details
                    end
                end
            end
        end

        if _closetBeacon ~= nil and _shortestDistance then
            local _vhfGroup = Group.getByName(_closetBeacon.vhfGroup)

            local _uhfGroup = Group.getByName(_closetBeacon.uhfGroup)

            local _fmGroup = Group.getByName(_closetBeacon.fmGroup)

            if _vhfGroup ~= nil then
                _vhfGroup:destroy()
            end
            if _uhfGroup ~= nil then
                _uhfGroup:destroy()
            end
            if _fmGroup ~= nil then
                _fmGroup:destroy()
            end

            trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " removed a Radio Beacon.\n\n" .. _closetBeacon.text, 20)
        else
            ctld.displayMessageToGroup(_heli, "No Radio Beacons within 500m.", 20)
        end

    else
        ctld.displayMessageToGroup(_heli, "You need to land before remove a Radio Beacon", 20)
    end
end

-- gets the center of a bunch of points!
-- return proper DCS point with height
function ctld.getCentroid(_points)
    local _tx, _ty = 0, 0
    for _, _point in ipairs(_points) do
        _tx = _tx + _point.x
        _ty = _ty + _point.z
    end

    local _npoints = #_points

    local _point = { x = _tx / _npoints, z = _ty / _npoints }

    _point.y = land.getHeight({ _point.x, _point.z })

    return _point
end

function ctld.getAATemplate(_unitName)

    for _, _system in pairs(ctld.AASystemTemplate) do

        if _system.repair == _unitName then
            return _system
        end

        for _, _part in pairs(_system.parts) do

            if _unitName == _part.name then
                return _system
            end
        end
    end

    return nil

end

function ctld.getLauncherUnitFromAATemplate(_aaTemplate)
    for _, _part in pairs(_aaTemplate.parts) do

        if _part.launcher then
            return _part.name
        end
    end

    return nil
end

function ctld.getAASystemTypeFromAATemplate(_aaTemplate)
    for _, _part in pairs(_aaTemplate.parts) do

        if _part.launcher then
            return _part.systemType
        end
    end

    return nil
end

function ctld.aaGetLaunchersFromType(_aaTemplate)

    if _aaTemplate.systemType == "SR" then
        return ctld.aaSRLaunchers
    elseif _aaTemplate.systemType == "MR" then
        return ctld.aaMRLaunchers
    elseif _aaTemplate.systemType == "LR" then
        return ctld.aaLRLaunchers
    else
        return 1 -- in case system type is not included in template
    end

end

function ctld.rearmAASystem(_heli, _nearestCrate, _aaSystemTemplate)

    -- are we adding to existing aa system?
    -- check to see if the crate is a launcher
    if ctld.getLauncherUnitFromAATemplate(_aaSystemTemplate) == _nearestCrate.details.unit then

        -- find nearest COMPLETE AA system
        local _nearestSystem = ctld.findNearestAASystem(_heli, _aaSystemTemplate)

        if _nearestSystem ~= nil and _nearestSystem.dist < 300 then

            local _uniqueTypes = {} -- stores each unique part of system
            local _types = {}
            local _points = {}

            local _units = _nearestSystem.group:getUnits()

            if _units ~= nil and #_units > 0 then

                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then

                        --this allows us to count each type once
                        _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                        table.insert(_points, _units[x]:getPoint())
                        table.insert(_types, _units[x]:getTypeName())
                    end
                end
            end

            -- do we have the correct number of unique pieces and do we have enough points for all the pieces
            if ctld.countTableEntries(_uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then

                -- rearm aa system
                -- destroy old group
                ctld.completeAASystems[_nearestSystem.group:getName()] = nil

                _nearestSystem.group:destroy()

                local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types)

                ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystemTemplate)

                ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "rearm" })

                trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully rearmed a full " .. _aaSystemTemplate.name .. " in the field", 10)

                if _heli:getCoalition() == 1 then
                    ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
                else
                    ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
                end

                -- remove crate
                --     if ctld.slingLoad == false then
                _nearestCrate.crateUnit:destroy()
                --  end

                return true -- all done so quit
            end
        end
    end

    return false
end

function ctld.getAASystemDetails(_hawkGroup, _aaSystemTemplate)

    local _units = _hawkGroup:getUnits()

    local _hawkDetails = {}

    for _, _unit in pairs(_units) do
        table.insert(_hawkDetails, { point = _unit:getPoint(), unit = _unit:getTypeName(), name = _unit:getName(), system = _aaSystemTemplate })
    end

    return _hawkDetails
end

function ctld.countTableEntries(_table)

    if _table == nil then
        return 0
    end

    local _count = 0

    for _, _ in pairs(_table) do

        _count = _count + 1
    end

    return _count
end

function ctld.unpackAASystem(_heli, _nearestCrate, _nearbyCrates, _aaSystemTemplate)

    if ctld.rearmAASystem(_heli, _nearestCrate, _aaSystemTemplate) then
        -- rearmed hawk
        return
    end

    -- are there all the pieces close enough together
    local _systemParts = {}

    --initialise list of parts
    for _, _part in pairs(_aaSystemTemplate.parts) do
        _systemParts[_part.name] = { name = _part.name, desc = _part.desc, found = false }
    end

    -- find all nearest crates and add them to the list if they're part of the AA System
    for _, _nearbyCrate in pairs(_nearbyCrates) do

        if _nearbyCrate.dist < 500 then

            if _systemParts[_nearbyCrate.details.unit] ~= nil and _systemParts[_nearbyCrate.details.unit].found == false then
                local _foundPart = _systemParts[_nearbyCrate.details.unit]

                _foundPart.found = true
                _foundPart.crate = _nearbyCrate

                _systemParts[_nearbyCrate.details.unit] = _foundPart
            end
        end
    end

    local _txt = ""

    local _posArray = {}
    local _typeArray = {}
    for _name, _systemPart in pairs(_systemParts) do

        if _systemPart.found == false then
            _txt = _txt .. "Missing " .. _systemPart.desc .. "\n"
        else

            local _launcherPart = ctld.getLauncherUnitFromAATemplate(_aaSystemTemplate)

            --handle multiple launchers from one crate

            if (_launcherPart == _name and ctld.aaGetLaunchersFromType(_aaSystemTemplate) > 1) then
                -- Ironwulf2000 modified to remove Hawk as special case, use systemType variable instead


                --add multiple launcher
                local _launchers = ctld.aaGetLaunchersFromType(_aaSystemTemplate)

                --if _name == "Hawk ln" then
                --    _launchers = ctld.hawkLaunchers
                --end

                for _i = 1, _launchers do

                    -- spawn in a circle around the crate
                    local _angle = math.pi * 2 * (_i - 1) / _launchers
                    local _xOffset = math.cos(_angle) * ctld.launcherRadius
                    local _yOffset = math.sin(_angle) * ctld.launcherRadius

                    local _point = _systemPart.crate.crateUnit:getPoint()

                    _point = { x = _point.x + _xOffset, y = _point.y, z = _point.z + _yOffset }

                    table.insert(_posArray, _point)
                    table.insert(_typeArray, _name)
                end
            else
                table.insert(_posArray, _systemPart.crate.crateUnit:getPoint())
                table.insert(_typeArray, _name)
            end
        end
    end

    local _activeLaunchers = ctld.countCompleteAASystems(_heli)

    local _allowed = ctld.getAllowedAASystems(_heli)

    env.info("Active: " .. _activeLaunchers .. " Allowed: " .. _allowed)

    if _activeLaunchers + 1 > _allowed then
        trigger.action.outTextForCoalition(_heli:getCoalition(), "Out of parts for AA Systems. Current limit is " .. _allowed .. " \n", 10)
        return
    end

    if _txt ~= "" then
        ctld.displayMessageToGroup(_heli, "Cannot build " .. _aaSystemTemplate.name .. "\n" .. _txt .. "\n\nOr the crates are not close enough together", 20)
        return
    else

        -- destroy crates
        for _, _systemPart in pairs(_systemParts) do

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_systemPart.crate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_systemPart.crate.crateUnit:getName()] = nil
            end

            --destroy
            -- if ctld.slingLoad == false then
            _systemPart.crate.crateUnit:destroy()
            --end
        end

        -- HAWK / BUK READY!
        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _posArray, _typeArray)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystemTemplate)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully deployed a full " .. _aaSystemTemplate.name .. " to the field. \n\nAA Active System limit is: " .. _allowed .. "\nActive: " .. (_activeLaunchers + 1), 10)

    end
end

--count the number of captured cities, sets the amount of allowed AA Systems
function ctld.getAllowedAASystems(_heli)

    if _heli:getCoalition() == 1 then
        return ctld.AASystemLimitBLUE
    else
        return ctld.AASystemLimitRED
    end


end

function ctld.countCompleteAASystems(_heli)

    local _count = 0

    for _groupName, _hawkDetails in pairs(ctld.completeAASystems) do

        local _hawkGroup = Group.getByName(_groupName)

        --  env.info(_groupName..": "..mist.utils.tableShow(_hawkDetails))
        if _hawkGroup ~= nil and _hawkGroup:getCoalition() == _heli:getCoalition() then

            local _units = _hawkGroup:getUnits()

            if _units ~= nil and #_units > 0 then
                --get the system template
                local _aaSystemTemplate = _hawkDetails[1].system

                local _uniqueTypes = {} -- stores each unique part of system
                local _types = {}
                local _points = {}

                if _units ~= nil and #_units > 0 then

                    for x = 1, #_units do
                        if _units[x]:getLife() > 0 then

                            --this allows us to count each type once
                            _uniqueTypes[_units[x]:getTypeName()] = _units[x]:getTypeName()

                            table.insert(_points, _units[x]:getPoint())
                            table.insert(_types, _units[x]:getTypeName())
                        end
                    end
                end

                -- do we have the correct number of unique pieces and do we have enough points for all the pieces
                if ctld.countTableEntries(_uniqueTypes) == _aaSystemTemplate.count and #_points >= _aaSystemTemplate.count then
                    _count = _count + 1
                end
            end
        end
    end

    return _count
end

function ctld.repairAASystem(_heli, _nearestCrate, _aaSystem)

    -- find nearest COMPLETE AA system
    local _nearestHawk = ctld.findNearestAASystem(_heli, _aaSystem)

    if _nearestHawk ~= nil and _nearestHawk.dist < 300 then

        local _oldHawk = ctld.completeAASystems[_nearestHawk.group:getName()]

        --spawn new one

        local _types = {}
        local _points = {}

        for _, _part in pairs(_oldHawk) do
            table.insert(_points, _part.point)
            table.insert(_types, _part.unit)
        end

        --remove old system
        ctld.completeAASystems[_nearestHawk.group:getName()] = nil
        _nearestHawk.group:destroy()

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, _points, _types)

        ctld.completeAASystems[_spawnedGroup:getName()] = ctld.getAASystemDetails(_spawnedGroup, _aaSystem)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "repair" })

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " successfully repaired a full " .. _aaSystem.name .. " in the field", 10)

        if _heli:getCoalition() == 1 then
            ctld.spawnedCratesRED[_nearestCrate.crateUnit:getName()] = nil
        else
            ctld.spawnedCratesBLUE[_nearestCrate.crateUnit:getName()] = nil
        end

        -- remove crate
        -- if ctld.slingLoad == false then
        _nearestCrate.crateUnit:destroy()
        -- end

    else
        ctld.displayMessageToGroup(_heli, "Cannot repair  " .. _aaSystem.name .. ". No damaged " .. _aaSystem.name .. " within 300m", 10)
    end
end

function ctld.unpackMultiCrate(_heli, _nearestCrate, _nearbyCrates)

	local _playerDetails = {} -- fill with dummy values for non-MP testing
	--[[
	if DCS.isMultiplayer() then
		_playerDetails = playerDetails.getPlayerDetails(_heli:getName())
	end
	--]]
	--[[
		'id'    : playerID
		'name'  : player name
		'side'  : 0 - spectators, 1 - red, 2 - blue
		'slot'  : slotID of the player or 
		'ping'  : ping of the player in ms
		'ipaddr': IP address of the player, SERVER ONLY
		'ucid'  : Unique Client Identifier, SERVER ONLY
	--]]
	local _playerUCID = _playerDetails['ucid']

	local _heliCoalition = _heli:getCoalition()
	
    -- unpack multi crate
    local _nearbyMultiCrates = {}

    for _, _nearbyCrate in pairs(_nearbyCrates) do

        if _nearbyCrate.dist < 300 then

            if _nearbyCrate.details.unit == _nearestCrate.details.unit then

                table.insert(_nearbyMultiCrates, _nearbyCrate)

                if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then
                    break
                end
            end
        end
    end

    --- check crate count
    if #_nearbyMultiCrates == _nearestCrate.details.cratesRequired then

        local _point = _nearestCrate.crateUnit:getPoint()

        -- destroy crates
        for _, _crate in pairs(_nearbyMultiCrates) do

            if _point == nil then
                _point = _crate.crateUnit:getPoint()
            end

            if _heli:getCoalition() == 1 then
                ctld.spawnedCratesRED[_crate.crateUnit:getName()] = nil
            else
                ctld.spawnedCratesBLUE[_crate.crateUnit:getName()] = nil
            end

            --destroy
            --   if ctld.slingLoad == false then
            _crate.crateUnit:destroy()
            --   end
        end

        local _spawnedGroup = ctld.spawnCrateGroup(_heli, { _point }, { _nearestCrate.details.unit }, _nearestCrate.details.unitQuantity)

        ctld.processCallback({ unit = _heli, crate = _nearestCrate, spawnedGroup = _spawnedGroup, action = "unpack" })

        local quantityTxt = ""
        local plural = ""
        if _nearestCrate.details.unitQuantity ~= nil and _nearestCrate.details.unitQuantity > 1 then
            quantityTxt = tostring(_nearestCrate.details.unitQuantity) .. " "
            plural = "s"
        end
        local _txt = string.format("%s successfully deployed %s%s%s to the field using %d crates", ctld.getPlayerNameOrType(_heli), quantityTxt, _nearestCrate.details.desc, plural, #_nearbyMultiCrates)

        trigger.action.outTextForCoalition(_heliCoalition, _txt, 10)

        if ctld.isJTACUnitType(_nearestCrate.details.unit) and ctld.JTAC_dropEnabled then
            local _code = ctld.getLaserCode(_heliCoalition)
            ctld.JTACAutoLase(_spawnedGroup:getName(), _code)
			--[[
			local _playerJTACsForSide = ctld.JTACsPerPlayerPerSide[_playerUCID][_heliCoalition]
			local _playerJTACsForSideCount = 0
			if _playerJTACsForSide ~= nil then
					for _k, _JTACgroup in ipairs (_playerJTACsForSide) do
						
						if _JTACgroup == nil then
							table.remove(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],_k)
						else
							_playerJTACsForSideCount = _playerJTACsForSideCount + 1
						end
					end	
				end
			end
			
			if ctld.JTAC_LIMIT_perPLAYER_perSIDE > _playerJTACsForSideCount then
				ctld.displayMessageToGroup(_heli, "JTACs per player per side limit (" .. ctld.JTAC_LIMIT_perPLAYER_perSIDE .. ") reached.  Deleting oldest JTAC.", 20)
				-- newest JTAC always appended to end of table, therefore pos 1 JTAC = oldest
				table.remove(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],1)
			end
			-- newest JTAC always appended to end of table, therefore pos 2 JTAC = newest
			-- no position for insert given, therefore should append to end
			table.insert(ctld.JTACsPerUCIDPerSide[_playerUCID][_heliCoalition],_spawnedGroups:getName())
			--]]
        end

    else

        local _txt = string.format("Cannot build %s!\n\nIt requires %d crates and there are %d \n\nOr the crates are not within 300m of each other", _nearestCrate.details.desc, _nearestCrate.details.cratesRequired, #_nearbyMultiCrates)

        ctld.displayMessageToGroup(_heli, _txt, 20)
    end
end

function ctld.spawnCrateGroup(_heli, _positions, _types, _unitQuantity)
    _unitQuantity = _unitQuantity or 1

    local _id = ctld.getNextGroupId()

    local _playerName = ctld.getPlayerNameOrType(_heli)
    local _groupName = 'CTLD_' .. _types[1] .. '_' .. _id .. ' (' .. _playerName .. ')' -- encountered some issues with using "type #number" on some servers

    local _group = {
        ["visible"] = false,
        -- ["groupId"] = _id,
        ["hidden"] = false,
        ["units"] = {},
        --        ["y"] = _positions[1].z,
        --        ["x"] = _positions[1].x,
        ["name"] = _groupName,
        ["playerCanDrive"] = true,
        ["task"] = {},
    }

    if #_positions == 1 then
        for _i = 1, _unitQuantity do
            local _unitId = ctld.getNextUnitId()
            local _details = { type = _types[1], unitId = _unitId, name = string.format("Unpacked %s #%i", _types[1], _unitId) }
            local _offset = (_i - 1) * 40 + 10
            _group.units[_i] = ctld.createUnit(_positions[1].x + _offset, _positions[1].z + _offset, 120, _details)
        end

    else

        for _i, _pos in ipairs(_positions) do

            local _unitId = ctld.getNextUnitId()
            local _details = { type = _types[_i], unitId = _unitId, name = string.format("Unpacked %s #%i", _types[_i], _unitId) }

            _group.units[_i] = ctld.createUnit(_pos.x + 5, _pos.z + 5, 120, _details)
        end
    end

    --mist function
    _group.category = Group.Category.GROUND
    if _heli:getCoalition() == coalition.side.BLUE and _types[1] == "1L13 EWR" then
        -- EWRs need to be from a country with numeric callsigns
        -- see https://github.com/ModernColdWar/RedStormRising/issues/99
        -- also see https://forums.eagle.ru/showthread.php?t=130723&page=4
        _group.country = country.id.UKRAINE
    else
        _group.country = _heli:getCountry()
    end

    local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)

    --local _spawnedGroup = coalition.addGroup(_heli:getCountry(), Group.Category.GROUND, _group)

    --activate by moving and so we can set ROE and Alarm state

    --local _dest = _spawnedGroup:getUnit(1):getPoint()
    --_dest = { x = _dest.x + 0.5, _y = _dest.y + 0.5, z = _dest.z + 0.5 }

    utils.setGroupControllerOptions(_spawnedGroup)
    --ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _dest)

    return _spawnedGroup
end



-- spawn normal group
function ctld.spawnDroppedGroup(_point, _details, _spawnBehind, _maxSearch, _formation)

    local _groupName = _details.groupName
    if _formation == nil then
        -- luacheck: no unused
        _formation = "Off Road"
    end

    local _group = {
        ["visible"] = false,
        --  ["groupId"] = _details.groupId,
        ["hidden"] = false,
        ["units"] = {},
        --        ["y"] = _positions[1].z,
        --        ["x"] = _positions[1].x,
        ["name"] = _groupName,
        ["task"] = {},
        --		["action"] = _formation,
    }

    if _spawnBehind == false then

        -- spawn in circle around heli

        local _pos = _point

        for _i, _detail in ipairs(_details.units) do

            local _angle = math.pi * 2 * (_i - 1) / #_details.units
            local _xOffset = math.cos(_angle) * 30
            local _yOffset = math.sin(_angle) * 30

            _group.units[_i] = ctld.createUnit(_pos.x + _xOffset, _pos.z + _yOffset, _angle, _detail)
        end

    else

        local _pos = _point

        --try to spawn at 6 oclock to us
        local _angle = math.atan2(_pos.z, _pos.x)
        local _xOffset = math.cos(_angle) * -30
        local _yOffset = math.sin(_angle) * -30

        for _i, _detail in ipairs(_details.units) do
            _group.units[_i] = ctld.createUnit(_pos.x + (_xOffset + 10 * _i), _pos.z + (_yOffset + 10 * _i), _angle, _detail)
        end
    end

    --switch to MIST
    _group.category = Group.Category.GROUND;
    _group.country = _details.country;

    local _spawnedGroup = Group.getByName(mist.dynAdd(_group).name)

    --local _spawnedGroup = coalition.addGroup(_details.country, Group.Category.GROUND, _group)


    -- find nearest enemy and head there
    --if _maxSearch == nil then
    --    _maxSearch = ctld.maximumSearchDistance
    --end

    --local _wpZone = ctld.inWaypointZone(_point, _spawnedGroup:getCoalition())

    --if _wpZone.inZone then
    --    ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _wpZone.point)
    --    env.info("Heading to waypoint - In Zone " .. _wpZone.name)
    --else
    --    local _enemyPos = ctld.findNearestEnemy(_details.side, _point, _maxSearch)
    --
    --    ctld.orderGroupToMoveToPoint(_spawnedGroup:getUnit(1), _enemyPos)
    --end
    utils.setGroupControllerOptions(_spawnedGroup)

    return _spawnedGroup
end

function ctld.findNearestEnemy(_side, _point, _searchDistance)

    local _closestEnemy = nil

    local _groups

    local _closestEnemyDist = _searchDistance

    local _heliPoint = _point

    if _side == 2 then
        _groups = coalition.getGroups(1, Group.Category.GROUND)
    else
        _groups = coalition.getGroups(2, Group.Category.GROUND)
    end

    for _, _group in pairs(_groups) do

        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then

                local _leader = nil

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then
                        _leader = _units[x]
                        break
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestEnemyDist then
                        _closestEnemyDist = _dist
                        _closestEnemy = _leaderPos
                    end
                end
            end
        end
    end


    -- no enemy - move to random point
    if _closestEnemy ~= nil then

        -- env.info("found enemy")
        return _closestEnemy
    else

        local _x = _heliPoint.x + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _z = _heliPoint.z + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)
        local _y = _heliPoint.y + math.random(0, ctld.maximumMoveDistance) - math.random(0, ctld.maximumMoveDistance)

        return { x = _x, z = _z, y = _y }
    end
end

function ctld.findNearestGroup(_heli, _groups)

    local _closestGroupDetails = {}
    local _closestGroup = nil

    local _closestGroupDist = ctld.maxExtractDistance

    local _heliPoint = _heli:getPoint()

    for _, _groupName in pairs(_groups) do

        local _group = Group.getByName(_groupName)

        if _group ~= nil then
            local _units = _group:getUnits()

            if _units ~= nil and #_units > 0 then

                local _leader = nil

                local _groupDetails = { groupId = _group:getID(), groupName = _group:getName(), side = _group:getCoalition(), units = {} }

                -- find alive leader
                for x = 1, #_units do
                    if _units[x]:getLife() > 0 then

                        if _leader == nil then
                            _leader = _units[x]
                            -- set country based on leader
                            _groupDetails.country = _leader:getCountry()
                        end

                        local _unitDetails = { type = _units[x]:getTypeName(), unitId = _units[x]:getID(), name = _units[x]:getName() }

                        table.insert(_groupDetails.units, _unitDetails)
                    end
                end

                if _leader ~= nil then
                    local _leaderPos = _leader:getPoint()
                    local _dist = ctld.getDistance(_heliPoint, _leaderPos)
                    if _dist < _closestGroupDist then
                        _closestGroupDist = _dist
                        _closestGroupDetails = _groupDetails
                        _closestGroup = _group
                    end
                end
            end
        end
    end

    if _closestGroup ~= nil then

        return { group = _closestGroup, details = _closestGroupDetails }
    else

        return nil
    end
end

function ctld.createUnit(_x, _y, _angle, _details)

    local _newUnit = {
        ["y"] = _y,
        ["type"] = _details.type,
        ["name"] = _details.name,
        --  ["unitId"] = _details.unitId,
        ["heading"] = _angle,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = _x,
    }

    return _newUnit
end

function ctld.addEWRTask(_group)

    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_ewrGroup)
        local _grp = ctld.getAliveGroup(_ewrGroup)

        if _grp ~= nil then
            local _controller = _grp:getController();
            local _frequency = _grp:getCoalition() == 1 and ctld.ewrFrequencyRed or ctld.ewrFrequencyBlue
            local _EWR = {
                id = "ComboTask",
                params = {
                    tasks = { {
                                  auto = true,
                                  enabled = true,
                                  id = "EWR",
                                  number = 1,
                                  params = {}
                              }, {
                                  auto = false,
                                  enabled = true,
                                  id = "WrappedAction",
                                  number = 2,
                                  params = {
                                      action = {
                                          id = "SetFrequency",
                                          params = {
                                              frequency = _frequency * 1000000,
                                              modulation = 0,
                                              power = 10
                                          }
                                      }
                                  }
                              } }
                }
            }
            _controller:setTask(_EWR)
        end
    end
    , _group:getName(), timer.getTime() + 2)

end

function ctld.orderGroupToMoveToPoint(_leader, _destination)

    local _group = _leader:getGroup()

    local _path = {}

    if ctld.isInfantry(_leader) then
        -- If its infantry, put them in a wedge formation - Ironwulf2000 Modified
        table.insert(_path, mist.ground.buildWP(_leader:getPoint(), 'cone', 50))
        table.insert(_path, mist.ground.buildWP(_destination, 'cone', 50))
    else
        -- everything else set 'off road'
        table.insert(_path, mist.ground.buildWP(_leader:getPoint(), 'off road', 50))
        table.insert(_path, mist.ground.buildWP(_destination, 'off road', 50))
    end

    local _mission = {
        id = 'Mission',
        params = {
            route = {
                points = _path
            },
        },
    }


    -- delayed 2 second to work around bug
    timer.scheduleFunction(function(_arg)
        local _grp = ctld.getAliveGroup(_arg[1])

        if _grp ~= nil then
            local _controller = _grp:getController();
            Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
            Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
            Controller.setOption(_controller, AI.Option.Ground.id.DISPERSE_ON_ATTACK, 0)
            -- RSR: remove setting waypoints for newly spawned units
            --_controller:setTask(_arg[2])
        end
    end
    , { _group:getName(), _mission }, timer.getTime() + 2)

end

--mr: consider migrating function to utils.lua for use elsewhere
--returns closest base to player and also if in repair radius or FOB exclusion zone
function ctld.baseProximity(_aircraft) --{_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}

	local _inFOBexclusionZone = false
	local _inBaseZoneAndRSRrepairRadius = false
	
	local _aircraftPoint = _aircraft:getPoint()
	local _debugDistToTZcentroid = ctld.exclusionZoneFromBasesForFOBs
	local _debugBaseName = "NoBase"
	local _debugBaseSide = "NoSide"
	local _closestBaseSideDist = {_debugBaseName,_debugBaseSide,_debugDistToTZcentroid}
	
	--determine distance to each RSRbaseCaptureZones and find closest one
	local _triggerZoneName = "NoTrigger"
	local _triggerZonePoint = {x = 0, z = 0}
	local _distToTZcentroid = _debugDistToTZcentroid
	local _baseName = _debugBaseName
	local _baseType = "NoType"
    for _k, _triggerZone in pairs(ctld.RSRbaseCaptureZones) do
		_triggerZoneName = _triggerZone.name
		-- TriggerZone 2D coords xy, where y = z in Vec 3D coords e.g. _aircraft:getPoint()
		_triggerZonePoint = {x = _triggerZone.x, z = _triggerZone.y} 
		_distToTZcentroid = ctld.getDistance(_aircraftPoint, _triggerZonePoint)
		
		if _distToTZcentroid < _closestBaseSideDist[3] then
			_baseName = string.match(_triggerZoneName,("^(.+)%sRSR")) --"MM75 RSRbaseCaptureZone FARP" = "MM75"
			_baseType = string.match(_triggerZoneName,("%w+$")) --"MM75 RSRbaseCaptureZone FARP" = "FARP"
			_closestBaseSideDist[1] = _baseName
			_closestBaseSideDist[3] = _distToTZcentroid
			
		end
    end
	
	--determine RSR owner of closest base based on base name from closest zone
	local _matchedSide = _debugBaseSide
    for _k, _baseTypes in pairs(baseOwnershipCheck.baseOwnership) do
        for _sideName, _baseList in pairs(_baseTypes) do
			_matchedSide = _sideName
            for _k, _base in ipairs(_baseList) do
                if _base == _closestBaseSideDist[1] then
                    _closestBaseSideDist[2] = _matchedSide
					log:info("_matchedSide: $1",_matchedSide)
                end
            end
        end
    end
	
	log:info("ctld.baseProximity: _closestBaseSideDist: $1, _baseType: $2",inspect(_closestBaseSideDist, { newline = " ", indent = "" }),_baseType)
	
	-- determine type of base
	local _RSRradius = 10000 -- RSRbaseCaptureZones FARP zones 5km in MIZ, most RSRbaseCaptureZones Airbase zones 10km in MIZ
	if _baseType == "Airbase" then
		_RSRradius = ctld.maximumDistFromAirbaseToRepair -- 5km
	elseif _baseType == "FARP" then
		_RSRradius = ctld.maximumDistFromFARPToRepair -- 3km
	elseif _baseType == "NoType" then
		log:error("RSRbaseCaptureZone Trigger Zone $1 is not associated with an airbase or FARP", _triggerZoneName)
	end
	
	-- is player in possibly in FOB exlcusion zone?
	if _closestBaseSideDist[3] < ctld.exclusionZoneFromBasesForFOBs then
		_inFOBexclusionZone = true
	end
	
	if _inFOBexclusionZone then -- if player not in FOB exclusion zone then proximity to base irrelevant as too far to matter
		--check close enough to centre of airbase/FARPs
		local _aircraftDistRSR = _RSRradius - _closestBaseSideDist[3]
		if _aircraftDistRSR > 0 then
			_inBaseZoneAndRSRrepairRadius = true
		end
	end
	--[[
		(a) if _inBaseZoneAndRSRrepairRadius = true, then _inFOBexclusionZone = true, then close enough for base repair
		(b) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = false, then far enough for deployable FOB
		(c) if _inBaseZoneAndRSRrepairRadius = false, and _inFOBexclusionZone = then, then too far for base for repair AND too close for deployable 
	--]]
	
    return {_inBaseZoneAndRSRrepairRadius,_inFOBexclusionZone,_closestBaseSideDist,_baseType}
end

-- are we in pickup zone
function ctld.inPickupZone(_heli)

    if ctld.inAir(_heli) then
        return { inZone = false, limit = -1, index = -1 }
    end

    local _heliPoint = _heli:getPoint()

    for _i, _zoneDetails in pairs(ctld.pickupZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone == nil then
            local _ship = ctld.getTransportUnit(_zoneDetails[1])

            if _ship then
                local _point = _ship:getPoint()
                _triggerZone = {}
                _triggerZone.point = _point
                _triggerZone.radius = 200 -- should be big enough for ship
            end

        end

        if _triggerZone ~= nil then

            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                local _heliCoalition = _heli:getCoalition()
                if _zoneDetails[4] == 1 and (_zoneDetails[5] == _heliCoalition or _zoneDetails[5] == 0) then
                    return { inZone = true, limit = _zoneDetails[3], index = _i }
                end
            end
        end
    end

    local _fobs = ctld.getSpawnedFobs(_heli)

    -- now check spawned fobs
    for _, _fob in ipairs(_fobs) do

        --get distance to center

        local _dist = ctld.getDistance(_heliPoint, _fob:getPoint())

        if _dist <= 150 then
            return { inZone = true, limit = 10000, index = -1 }
        end
    end

    return { inZone = false, limit = -1, index = -1 }
end

function ctld.getSpawnedFobs(_heli)

    local _fobs = {}

    for _, _fobName in ipairs(ctld.builtFOBs) do

        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist() and _fob:getCoalition() == _heli:getCoalition() and _fob:getLife() > 0 then

            table.insert(_fobs, _fob)
        end
    end

    return _fobs
end

-- are we in a dropoff zone
function ctld.inDropoffZone(_heli)

    if ctld.inAir(_heli) then
        return false
    end

    local _heliPoint = _heli:getPoint()

    for _, _zoneDetails in pairs(ctld.dropOffZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        if _triggerZone ~= nil and (_zoneDetails[3] == _heli:getCoalition() or _zoneDetails[3] == 0) then

            --get distance to center

            local _dist = ctld.getDistance(_heliPoint, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return true
            end
        end
    end

    return false
end

-- are we in a waypoint zone
function ctld.inWaypointZone(_point, _coalition)

    for _, _zoneDetails in pairs(ctld.wpZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --right coalition and active?
        if _triggerZone ~= nil and (_zoneDetails[4] == _coalition or _zoneDetails[4] == 0) and _zoneDetails[3] == 1 then

            --get distance to center

            local _dist = ctld.getDistance(_point, _triggerZone.point)

            if _dist <= _triggerZone.radius then
                return { inZone = true, point = _triggerZone.point, name = _zoneDetails[1] }
            end
        end
    end

    return { inZone = false }
end
-- checks if logisitics centre still alive at a passed airbase/FARP
function ctld.isLogisticsCentreAliveAt(_passedLogisiticsCentreBase)

	local _LogisiticsCentreAlive = true
	local _logisticCentreObj = ctld.logisticCentreObjects[_passedLogisiticsCentreBase]
	if _logisticCentreObj == nil then
		_LogisiticsCentreAlive = false
	end
    return _LogisiticsCentreAlive
end

-- proximity to nearest FRIENDLY logistics centre object NOT whether player in logisitics zone
function ctld.friendlyLogisticsCentreProximity(_aircraft)

	local _aircraftPoint = _aircraft:getPoint()
	local _aircraftSide = _aircraft:getCoalition()
	local _aircraftSideName = utils.getSideName(_aircraftSide)
	
	local _logisticCentreProx = {"NoFriendlyLC","NoDist","NoBase"}
	local _logisticCentreName = _logisticCentreProx[1]
	local _logisticCentreDist = _logisticCentreProx[2]
	local _logisticsCentreBaseName = _logisticCentreProx[3]
	
	local _logisticsCentreSideName = "NoSide"
	local _logisticCentrePoint = {0,0,0}
	local _logisticCentreObj
	
	for _baseWithLC, _LC in pairs(ctld.logisticCentreObjects) do
	
		_logisticCentreObj = _LC
		--log:info("_baseWithLC: $1, _logisticCentreObj: $2",_baseWithLC, mist.utils.basicSerialize(_logisticCentreObj))
		
		if _logisticCentreObj ~= nil then
			_logisticCentreName = _logisticCentreObj:getName()
			_logisticCentrePoint = _logisticCentreObj:getPoint()
			--log:info("_logisticCentreName: $1, _logisticCentrePoint: $2",_logisticCentreName, mist.utils.basicSerialize(_logisticCentrePoint))
			 --"Krymsk Logistics Centre #001 red" = "red"
			_logisticsCentreSideName = string.match(_logisticCentreName,("%w+$"))
		
			--"Sochi Logistics Centre #001 red" = "Sochi" i.e. from whitepace and 'Log' up
			_logisticsCentreBaseName = string.match(_logisticCentreName,("^(.+)%sLog")) 
		end	
		
		--log:info("_logisticCentreObj: $1, _logisticsCentreSideName: $2, _logisticsCentreBaseName: $3",_logisticCentreObj,_logisticsCentreSideName,_logisticsCentreBaseName)
			
		
		if _logisticsCentreSideName == _aircraftSideName then
		
			--get distance
			_logisticCentreDist = ctld.getDistance(_aircraftPoint, _logisticCentrePoint)
			
			if _logisticCentreProx[2] == "NoDist" then
				_logisticCentreProx[1] = _logisticCentreName
				_logisticCentreProx[2] = _logisticCentreDist
				_logisticCentreProx[3] = _logisticsCentreBaseName
	
			elseif _logisticCentreDist < _logisticCentreProx[2] then
				_logisticCentreProx[1] = _logisticCentreName
				_logisticCentreProx[2] = _logisticCentreDist
				_logisticCentreProx[3] = _logisticsCentreBaseName
			end
			
		end
	end
	
	log:info("_logisticCentreProx: $1",inspect(_logisticCentreProx, { newline = " ", indent = "" }))
    return _logisticCentreProx
end


-- checks whether player is far away enough from FRIENDLY logistics centre object NOT whether player in logisitics zone
function ctld.farEnoughFromLogisticCentre(_heli)

    local _heliPoint = _heli:getPoint()

    local _farEnough = true
	for _baseWithLC, _LC in pairs(ctld.logisticCentreObjects) do
		local _logisticCentreObj = _LC
		if _logisticCentreObj ~= nil then
			local _logisticCentreName = _logisticCentreObj:getName()
			local _logisticsCentreSide = "none"
			_logisticsCentreSide = string.match(_logisticCentreName,("%w+$")) --"Krymsk Logistics Centre #001 red" = "red"
		end	
		if _logisticsCentreSide == _heli:getCoalition() then
			local _logisticCentreDist = ctld.getDistance(_heliPoint, _logisticCentreObj:getPoint()) --get distance
			if _logisticCentreDist <= ctld.minimumDeployDistance then
                _farEnough = false
            end
		end
	end

    return _farEnough
end

function ctld.refreshSmoke()

    if ctld.disableAllSmoke == true then
        return
    end

    for _, _zoneGroup in pairs({ ctld.pickupZones, ctld.dropOffZones }) do

        for _, _zoneDetails in pairs(_zoneGroup) do

            local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

            if _triggerZone == nil then
                local _ship = ctld.getTransportUnit(_triggerZone)

                if _ship then
                    local _point = _ship:getPoint()
                    _triggerZone = {}
                    _triggerZone.point = _point
                end

            end


            --only trigger if smoke is on AND zone is active
            if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[4] == 1 then

                -- Trigger smoke markers

                local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
                local _alt = land.getHeight(_pos2)
                local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

                trigger.action.smoke(_pos3, _zoneDetails[2])
            end
        end
    end

    --waypoint zones
    for _, _zoneDetails in pairs(ctld.wpZones) do

        local _triggerZone = trigger.misc.getZone(_zoneDetails[1])

        --only trigger if smoke is on AND zone is active
        if _triggerZone ~= nil and _zoneDetails[2] >= 0 and _zoneDetails[3] == 1 then

            -- Trigger smoke markers

            local _pos2 = { x = _triggerZone.point.x, y = _triggerZone.point.z }
            local _alt = land.getHeight(_pos2)
            local _pos3 = { x = _pos2.x, y = _alt, z = _pos2.y }

            trigger.action.smoke(_pos3, _zoneDetails[2])
        end
    end


    --refresh in 5 minutes
    timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 300)
end

function ctld.dropSmoke(_args)

    local _heli = ctld.getTransportUnit(_args[1])

    if _heli ~= nil then

        local _colour = ""

        if _args[2] == trigger.smokeColor.Red then

            _colour = "RED"
        elseif _args[2] == trigger.smokeColor.Blue then

            _colour = "BLUE"
        elseif _args[2] == trigger.smokeColor.Green then

            _colour = "GREEN"
        elseif _args[2] == trigger.smokeColor.Orange then

            _colour = "ORANGE"
        end

        local _point = _heli:getPoint()

        local _pos2 = { x = _point.x, y = _point.z }
        local _alt = land.getHeight(_pos2)
        local _pos3 = { x = _point.x, y = _alt, z = _point.z }

        trigger.action.smoke(_pos3, _args[2])

        trigger.action.outTextForCoalition(_heli:getCoalition(), ctld.getPlayerNameOrType(_heli) .. " dropped " .. _colour .. " smoke ", 10)
    end
end

function ctld.unitCanCarryVehicles(_unit)

    local _type = string.lower(_unit:getTypeName())

    for _, _name in ipairs(ctld.vehicleTransportEnabled) do
        local _nameLower = string.lower(_name)
        if string.match(_type, _nameLower) then
            return true
        end
    end

    return false
end

function ctld.isCargoPlane(_unit)

    local _type = string.lower(_unit:getTypeName())

    for _, _name in ipairs(ctld.cargoPlanes) do
        local _nameLower = string.lower(_name)
        if string.match(_type, _nameLower) then
            return true
        end
    end

    return false
end

function ctld.unitCargoDoorsOpen(_heli)
    -- Ironwulf2000 added - returns true if a cargo door is open on the helo

    if _heli:getTypeName() == "Mi-8MT" then

        if ((_heli:getDrawArgumentValue(250) == 1) or (_heli:getDrawArgumentValue(86) == 1)) then
            -- 250 is cargo door removed, argument 86 is 1 when cargo doors open
            return true
        else
            return false
        end
    elseif _heli:getTypeName() == "UH-1H" then
        if ((_heli:getDrawArgumentValue(43) == 1) or (_heli:getDrawArgumentValue(44) == 1)) then
            -- Argument 43 is left door, 44 is right
            return true
        else
            return false
        end
    else
        -- Some unit type we dont know about (yet), so dont break it.
        return true
    end
end

function ctld.getCargoUnloadPoint(_heli, _offset)
    -- Ironwulf2000 added - returns cargo unload point depending on helo type
    if _heli:getTypeName() == "Mi-8MT" then
        return ctld.getPointAtXOclock(_heli, 6, 20)
    elseif _heli:getTypeName() == "UH-1H" then
        if ((_heli:getDrawArgumentValue(43) == 1) and (_heli:getDrawArgumentValue(44) ~= 1)) then
            -- Left door is open but Right door is not
            return ctld.getPointAtXOclock(_heli, 9, 10)
        end
        return ctld.getPointAtXOclock(_heli, 3, 10)
    else
        -- in case of unit we havent thought of yet
        return ctld.getPointAt12Oclock(_heli, _offset)
    end
end

function ctld.crateValidLoadPoint(_heli, _crate)
    -- Ironwulf2000 added - returns true if cargo is in a valid load area
    local _clockdirection = ctld.getClockDirection(_heli, _crate.crateUnit)

    ctld.displayMessageToGroup(_heli, "Clock Direction: " .. _clockdirection .. ".", 10, true)

    if _heli:getTypeName() == "Mi-8MT" then
        if ((_clockdirection < 4) or (_clockdirection > 8)) then
            return false
        end
    elseif _heli:getTypeName() == "UH-1H" then
        -- Huey is a special case as it can be loaded from either side
        if (((_clockdirection > 1) and (_clockdirection < 5) and (_heli:getDrawArgumentValue(44) == 1)) or ((_clockdirection > 7) and (_clockdirection < 11) and (_heli:getDrawArgumentValue(43) == 1))) then
            -- exclude quadrants where the door is closed too!
            return true
        else
            return false
        end
    end

    return true -- Covers models we dont know about yet so they dont break
end

function ctld.isJTACUnitType(_type)

    _type = string.lower(_type)

    for _, _name in ipairs(ctld.jtacUnitTypes) do
        local _nameLower = string.lower(_name)
        if string.match(_type, _nameLower) then
            return true
        end
    end

    return false
end

function ctld.updateZoneCounter(_index, _diff)

    if ctld.pickupZones[_index] ~= nil then

        ctld.pickupZones[_index][3] = ctld.pickupZones[_index][3] + _diff

        if ctld.pickupZones[_index][3] < 0 then
            ctld.pickupZones[_index][3] = 0
        end

        if ctld.pickupZones[_index][6] ~= nil then
            trigger.action.setUserFlag(ctld.pickupZones[_index][6], ctld.pickupZones[_index][3])
        end
        --  env.info(ctld.pickupZones[_index][1].." = " ..ctld.pickupZones[_index][3])
    end
end

function ctld.processCallback(_callbackArgs)

    for _, _callback in pairs(ctld.callbacks) do

        local _status, _result = pcall(function()

            _callback(_callbackArgs)

        end)

        if (not _status) then
            env.error(string.format("CTLD Callback Error: %s", _result))
        end
    end
end


-- checks the status of all AI troop carriers and auto loads and unloads troops
-- as long as the troops are on the ground
function ctld.checkAIStatus()

    timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 2)

    for _, _unitName in pairs(ctld.transportPilotNames) do
        local status, error = pcall(function()

            local _unit = ctld.getTransportUnit(_unitName)

            -- no player name means AI!
            if _unit ~= nil and _unit:getPlayerName() == nil then
                local _zone = ctld.inPickupZone(_unit)
                --  env.error("Checking.. ".._unit:getName())
                if _zone.inZone == true and not ctld.troopsOnboard(_unit, true) then
                    --   env.error("in zone, loading.. ".._unit:getName())

                    if ctld.allowRandomAiTeamPickups == true then
                        -- Random troop pickup implementation
                        if _unit:getCoalition() == 1 then
                            local _team = math.floor((math.random(#ctld.redTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.redTeams[_team]], true })
                        else
                            local _team = math.floor((math.random(#ctld.blueTeams * 100) / 100) + 1)
                            ctld.loadTroopsFromZone({ _unitName, true, ctld.loadableGroups[ctld.blueTeams[_team]], true })
                        end
                    else
                        ctld.loadTroopsFromZone({ _unitName, true, "", true })
                    end

                elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, true) then
                    --     env.error("in dropoff zone, unloading.. ".._unit:getName())
                    ctld.unloadTroops({ _unitName, true })
                end

                if ctld.unitCanCarryVehicles(_unit) then

                    if _zone.inZone == true and not ctld.troopsOnboard(_unit, false) then

                        ctld.loadTroopsFromZone({ _unitName, false, "", true })

                    elseif ctld.inDropoffZone(_unit) and ctld.troopsOnboard(_unit, false) then

                        ctld.unloadTroops({ _unitName, false })
                    end
                end
            end
        end)

        if (not status) then
            env.error(string.format("Error with ai status: %s", error), false)
        end
    end


end

function ctld.getTransportLimit(_unitType)

    if ctld.unitLoadLimits[_unitType] then

        return ctld.unitLoadLimits[_unitType]
    end

    return ctld.numberOfTroops

end

function ctld.getUnitActions(_unitType)

    if ctld.unitActions[_unitType] then
        return ctld.unitActions[_unitType]
    end

    return { crates = true, troops = true, internal = true }

end

-- add menu for spawning crates
function ctld.addCrateMenu(_rootPath, _crateTypeDescription, _unit, _groupId, _spawnableCrates, _weightMultiplier)
    local _crateRootPath = missionCommands.addSubMenuForGroup(_groupId, _crateTypeDescription, _rootPath)
    for _subMenuName, _crates in pairs(_spawnableCrates) do
        local _cratePath = missionCommands.addSubMenuForGroup(_groupId, _subMenuName, _crateRootPath)
        for _, _crate in pairs(_crates) do

            if ctld.isJTACUnitType(_crate.unit) == false or (ctld.isJTACUnitType(_crate.unit) == true and ctld.JTAC_dropEnabled) then
                if _crate.side == nil or (_crate.side == _unit:getCoalition()) then

                    local _crateRadioMsg = ""

                    --add details of crate count and unit quantity
                    local _requiresMultipleCrates = _crate.cratesRequired ~= nil and _crate.cratesRequired > 1
                    local _hasMultipleUnits = _crate.unitQuantity ~= nil and _crate.unitQuantity > 1
                    if (_requiresMultipleCrates or _hasMultipleUnits) then
                        _crateRadioMsg = _crateRadioMsg .. "["
                        if _requiresMultipleCrates then
                            _crateRadioMsg = _crateRadioMsg .. _crate.cratesRequired .. "C"
                            if _hasMultipleUnits then
                                _crateRadioMsg = _crateRadioMsg .. "," .. _crate.unitQuantity .. "Q"
                            end
                        else
                            if _hasMultipleUnits then
                                _crateRadioMsg = _crateRadioMsg .. "1C," .. _crate.unitQuantity .. "Q"
                            end
                        end
                        _crateRadioMsg = _crateRadioMsg .. "] "
                    else
						_crateRadioMsg = _crateRadioMsg .. "[1C,1Q] "
					end
					
					_crateRadioMsg = _crateRadioMsg .. _crate.desc --add unit description to end of crate and quantity prefix e.g. "[1C,1Q] Avenger"
					
                    missionCommands.addCommandForGroup(_groupId, _crateRadioMsg, _cratePath, ctld.spawnCrate, { _unit:getName(), _crate.weight * _weightMultiplier, _crate.internal })
                end
            end
        end
    end
end

function ctld.addF10MenuOptions(_unitName)
    local status, error = pcall(function()

        local _unit = ctld.getTransportUnit(_unitName)

        if _unit ~= nil then

            local _groupId = ctld.getGroupId(_unit)

            if _groupId then

                if ctld.addedTo[tostring(_groupId)] == nil then

                    local _rootPath = missionCommands.addSubMenuForGroup(_groupId, "Cargo Menu")
                    local _unitActions = ctld.getUnitActions(_unit:getTypeName())

                    if _unitActions.troops then

                        local _troopCommandsPath = missionCommands.addSubMenuForGroup(_groupId, "Troop Transport", _rootPath)
                        missionCommands.addCommandForGroup(_groupId, "Unload / Extract Troops", _troopCommandsPath, ctld.unloadExtractTroops, { _unitName })
                        missionCommands.addCommandForGroup(_groupId, "Check Cargo", _troopCommandsPath, ctld.checkCargoStatus, { _unitName })

                        -- local _loadPath = missionCommands.addSubMenuForGroup(_groupId, "Load From Zone", _troopCommandsPath)
                        for _, _loadGroup in pairs(ctld.loadableGroups) do
                            if not _loadGroup.side or _loadGroup.side == _unit:getCoalition() then

                                -- check size & unit
                                if ctld.getTransportLimit(_unit:getTypeName()) >= _loadGroup.total then
                                    missionCommands.addCommandForGroup(_groupId, "Load " .. _loadGroup.name, _troopCommandsPath, ctld.loadTroopsFromZone, { _unitName, true, _loadGroup, false })
                                end
                            end
                        end
					end
					
					if ctld.unitCanCarryVehicles(_unit) then

						local _vehicleCommandsPath = missionCommands.addSubMenuForGroup(_groupId, "Vehicle / Logistics Centre Transport", _rootPath)

						missionCommands.addCommandForGroup(_groupId, "Unload Vehicles", _vehicleCommandsPath, ctld.unloadTroops, { _unitName, false })
						missionCommands.addCommandForGroup(_groupId, "Load / Extract Vehicles", _vehicleCommandsPath, ctld.loadTroopsFromZone, { _unitName, false, "", true })

						if ctld.enabledFOBBuilding and ctld.staticBugWorkaround == false then
							missionCommands.addCommandForGroup(_groupId, "Load / Unload Logistics Centre crate", _vehicleCommandsPath, ctld.loadUnloadLogisticsCrate, { _unitName })
							missionCommands.addCommandForGroup(_groupId, "List FOBs", _vehicleCommandsPath, ctld.listFOBs, { _unitName })
						end
						missionCommands.addCommandForGroup(_groupId, "Load / Unload JTAC crate", _vehicleCommandsPath, ctld.loadUnloadJTACcrate, { _unitName })
						missionCommands.addCommandForGroup(_groupId, "List Nearby Crates", _vehicleCommandsPath, ctld.listNearbyCrates, { _unitName })
						missionCommands.addCommandForGroup(_groupId, "Unpack Nearby Crate", _vehicleCommandsPath, ctld.unpackCrates, { _unitName }) --needed for FOB deployment
						missionCommands.addCommandForGroup(_groupId, "Check Cargo", _vehicleCommandsPath, ctld.checkCargoStatus, { _unitName })
					end
						
					if ctld.isCargoPlane(_unit) and not ctld.unitCanCarryVehicles(_unit) then --avoid duplication
					
						local _internalCargoCommandsPath = missionCommands.addSubMenuForGroup(_groupId, "Internal Cargo", _rootPath)
						if ctld.enabledFOBBuilding and ctld.staticBugWorkaround == false then
							missionCommands.addCommandForGroup(_groupId, "Load / Unload Logistics Centre crate", _internalCargoCommandsPath, ctld.loadUnloadLogisticsCrate, { _unitName })
							missionCommands.addCommandForGroup(_groupId, "List FOBs", _internalCargoCommandsPath, ctld.listFOBs, { _unitName })
						end
						missionCommands.addCommandForGroup(_groupId, "Load / Unload JTAC crate", _internalCargoCommandsPath, ctld.loadUnloadJTACcrate, { _unitName })
						missionCommands.addCommandForGroup(_groupId, "List Nearby Crates", _internalCargoCommandsPath, ctld.listNearbyCrates, { _unitName })
						missionCommands.addCommandForGroup(_groupId, "Unpack Nearby Crate", _internalCargoCommandsPath, ctld.unpackCrates, { _unitName }) --needed for FOB deployment
						missionCommands.addCommandForGroup(_groupId, "Check Cargo", _internalCargoCommandsPath, ctld.checkCargoStatus, { _unitName })
					end

					--------------------------------------------------------------------------------------------
					-- helos
					if _unitActions.crates then
					
						if ctld.enableCrates then

							if ctld.unitCanCarryVehicles(_unit) == false then
								ctld.addCrateMenu(_rootPath, "Light crates", _unit, _groupId, ctld.spawnableCrates, 1)
								ctld.addCrateMenu(_rootPath, "Heavy crates", _unit, _groupId, ctld.spawnableCrates, ctld.heavyCrateWeightMultiplier)
							end
						end

						if (ctld.enabledFOBBuilding or ctld.enableCrates) then 
							local _crateCommands = missionCommands.addSubMenuForGroup(_groupId, "Cargo Actions", _rootPath)
							if ctld.hoverPickup == false then
								if ((ctld.slingLoad == false) or ((ctld.internalCargo == true) and (_unitActions.internal == true))) then
									missionCommands.addCommandForGroup(_groupId, "Load Nearby Crate", _crateCommands, ctld.loadNearbyCrate, _unitName)
								end
							end
							missionCommands.addCommandForGroup(_groupId, "Unpack Nearby Crate", _crateCommands, ctld.unpackCrates, { _unitName })

							if (ctld.slingLoad == false) or (ctld.internalCargo == true) then
								missionCommands.addCommandForGroup(_groupId, "Unload Internal Crate", _crateCommands, ctld.unloadInternalCrate, { _unitName })
								missionCommands.addCommandForGroup(_groupId, "Current Cargo Status", _crateCommands, ctld.slingCargoStatus, { _unitName })
							end

							missionCommands.addCommandForGroup(_groupId, "List Nearby Crates", _crateCommands, ctld.listNearbyCrates, { _unitName })

							if ctld.enabledFOBBuilding then
								missionCommands.addCommandForGroup(_groupId, "List FOBs", _crateCommands, ctld.listFOBs, { _unitName })
							end
						end
                    end

                    if ctld.enableSmokeDrop then
                        local _smokeMenu = missionCommands.addSubMenuForGroup(_groupId, "Smoke Markers", _rootPath)
                        missionCommands.addCommandForGroup(_groupId, "Drop Red Smoke", _smokeMenu, ctld.dropSmoke, { _unitName, trigger.smokeColor.Red })
                        missionCommands.addCommandForGroup(_groupId, "Drop Blue Smoke", _smokeMenu, ctld.dropSmoke, { _unitName, trigger.smokeColor.Blue })
                        missionCommands.addCommandForGroup(_groupId, "Drop Orange Smoke", _smokeMenu, ctld.dropSmoke, { _unitName, trigger.smokeColor.Orange })
                        missionCommands.addCommandForGroup(_groupId, "Drop Green Smoke", _smokeMenu, ctld.dropSmoke, { _unitName, trigger.smokeColor.Green })
                    end

                    if ctld.enabledRadioBeaconDrop then
                        local _radioCommands = missionCommands.addSubMenuForGroup(_groupId, "Radio Beacons", _rootPath)
                        missionCommands.addCommandForGroup(_groupId, "List Beacons", _radioCommands, ctld.listRadioBeacons, { _unitName })
                        missionCommands.addCommandForGroup(_groupId, "Drop Beacon", _radioCommands, ctld.dropRadioBeacon, { _unitName })
                        missionCommands.addCommandForGroup(_groupId, "Remove Closest Beacon", _radioCommands, ctld.removeRadioBeacon, { _unitName })
                    elseif ctld.deployedRadioBeacons ~= {} then
                        local _radioCommands = missionCommands.addSubMenuForGroup(_groupId, "Radio Beacons", _rootPath)
                        missionCommands.addCommandForGroup(_groupId, "List Beacons", _radioCommands, ctld.listRadioBeacons, { _unitName })
                    end

                    ctld.addedTo[tostring(_groupId)] = true
                end
            end
        end
    end)

    if (not status) then
        env.error(string.format("Error adding f10 to transport: %s", error), false)
    end

    -- RSR: these menus added in birthEventHandler
    --local status, error = pcall(function()
    --
    --    -- now do any player controlled aircraft that ARENT transport units
    --    if ctld.enabledRadioBeaconDrop then
    --        -- get all BLUE players
    --        ctld.addRadioListCommand(2)
    --
    --        -- get all RED players
    --        ctld.addRadioListCommand(1)
    --    end
    --
    --    if ctld.JTAC_jtacStatusF10 then
    --        -- get all BLUE players
    --        ctld.addJTACRadioCommand(2)
    --
    --        -- get all RED players
    --        ctld.addJTACRadioCommand(1)
    --    end
    --
    --end)
    --
    --if (not status) then
    --    env.error(string.format("Error adding f10 to other players: %s", error), false)
    --end


end

--add to all players that arent transport
function ctld.addRadioListCommand(_side)

    local _players = coalition.getPlayers(_side)

    if _players ~= nil then

        for _, _playerUnit in pairs(_players) do

            local _groupId = ctld.getGroupId(_playerUnit)

            if _groupId then

                if ctld.addedTo[tostring(_groupId)] == nil then
                    missionCommands.addCommandForGroup(_groupId, "List Radio Beacons", nil, ctld.listRadioBeacons, { _playerUnit:getName() })
                    ctld.addedTo[tostring(_groupId)] = true
                end
            end
        end
    end
end

function ctld.addJTACRadioCommand(_side)

    local _players = coalition.getPlayers(_side)

    if _players ~= nil then

        for _, _playerUnit in pairs(_players) do

            local _groupId = ctld.getGroupId(_playerUnit)

            if _groupId then
                -- Ironwulf2000 modified for AutoLase script
                --   env.info("adding command for "..index)
                if ctld.jtacRadioAdded[tostring(_groupId)] == nil then
                    -- env.info("about command for "..index)
                    missionCommands.addCommandForGroup(_groupId, "JTAC Status", nil, ctld.getJTACStatus, { _playerUnit:getName() })
                    ctld.jtacRadioAdded[tostring(_groupId)] = true
                    -- env.info("Added command for " .. index)
                end
            end


        end
    end
end

function ctld.getGroupId(_unit)
    local Unit = UNIT:Find(_unit)
    if Unit ~= nil then
        local Group = Unit:GetGroup()
        if Group ~= nil then
            return Group:GetID()
        end
    end

    return nil
end

--get distance in meters assuming a Flat world
function ctld.getDistance(_point1, _point2)

    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end


------------ JTAC -----------


ctld.jtacLaserPoints = {}
ctld.jtacIRPoints = {}
ctld.jtacSmokeMarks = {}
ctld.jtacUnits = {} -- list of JTAC units for f10 command
ctld.jtacStop = {} -- jtacs to tell to stop lasing
ctld.jtacCurrentTargets = {}
ctld.jtacRadioAdded = {} --keeps track of who's had the radio command added
ctld.jtacGeneratedLaserCodes = {} -- keeps track of generated codes, cycles when they run out
ctld.jtacLaserPointCodes = {}

function ctld.getLaserCode(_coalition)
    return _coalition == coalition.side.RED and ctld.JTAC_laserCode_RED or ctld.JTAC_laserCode_BLUE
end

function ctld.JTACAutoLase(_jtacGroupName, _laserCode, _smoke, _lock, _colour)

    if ctld.jtacStop[_jtacGroupName] == true then
        ctld.jtacStop[_jtacGroupName] = nil -- allow it to be started again
        ctld.cleanupJTAC(_jtacGroupName)
        return
    end

    if _lock == nil then

        _lock = ctld.JTAC_lock
    end

    ctld.jtacLaserPointCodes[_jtacGroupName] = _laserCode

    local _jtacGroup = ctld.getGroup(_jtacGroupName)
    local _jtacUnit
	local _jtacOwner = utils.getPlayerNameFromGroupName(_jtacGroupName)

    if _jtacGroup == nil or #_jtacGroup == 0 then

        --check not in a heli
        for _, _onboard in pairs(ctld.inTransitTroops) do
            if _onboard ~= nil then
                if _onboard.troops ~= nil and _onboard.troops.groupName ~= nil and _onboard.troops.groupName == _jtacGroupName then

                    --jtac soldier being transported by heli
                    ctld.cleanupJTAC(_jtacGroupName)

                    env.info(_jtacGroupName .. ' in Transport - Waiting 10 seconds')
                    timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 10)
                    return
                end

                if _onboard.vehicles ~= nil and _onboard.vehicles.groupName ~= nil and _onboard.vehicles.groupName == _jtacGroupName then
                    --jtac vehicle being transported by heli
                    ctld.cleanupJTAC(_jtacGroupName)

                    env.info(_jtacGroupName .. ' in Transport - Waiting 10 seconds')
                    timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 10)
                    return
                end
            end
        end

        if ctld.jtacUnits[_jtacGroupName] ~= nil then
            ctld.notifyCoalition("JTAC Group " .. _jtacGroupName .. " KIA!", 10, ctld.jtacUnits[_jtacGroupName].side)
        end

        --remove from list
        ctld.jtacUnits[_jtacGroupName] = nil

        ctld.cleanupJTAC(_jtacGroupName)

        return
    else

        _jtacUnit = _jtacGroup[1]
        --add to list
        ctld.jtacUnits[_jtacGroupName] = { name = _jtacUnit:getName(), side = _jtacUnit:getCoalition() }

        -- work out smoke colour
        if _colour == nil then

            if _jtacUnit:getCoalition() == 1 then
                _colour = ctld.JTAC_smokeColour_RED
            else
                _colour = ctld.JTAC_smokeColour_BLUE
            end
        end

        if _smoke == nil then

            if _jtacUnit:getCoalition() == 1 then
                _smoke = ctld.JTAC_smokeOn_RED
            else
                _smoke = ctld.JTAC_smokeOn_BLUE
            end
        end
    end


    -- search for current unit

    if _jtacUnit:isActive() == false then

        ctld.cleanupJTAC(_jtacGroupName)

        env.info(_jtacGroupName .. ' Not Active - Waiting 30 seconds')
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 30)

        return
    end

    local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)

    if _enemyUnit == nil and ctld.jtacCurrentTargets[_jtacGroupName] ~= nil then

        local _tempUnitInfo = ctld.jtacCurrentTargets[_jtacGroupName]

        --      env.info("TEMP UNIT INFO: " .. tempUnitInfo.name .. " " .. tempUnitInfo.unitType)

        local _tempUnit = Unit.getByName(_tempUnitInfo.name)

        if _tempUnit ~= nil and _tempUnit:getLife() > 0 and _tempUnit:isActive() == true then

			local _unit = _tempUnit --mr: only exploitable if spammable JTAC STATUS menu and reporting distance
			--local _unit = _jtacUnit
			local _mapGrid = utils.tostringMGRSnoUTM(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), -1)
			--Moose.lua: line 7723: playerMenu unit selection and accuracy
			--[[
				if MOOSE = x then
					_mapGrid = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_enemyUnit:getPosition().p)), 1)
				end
			--]]
			ctld.notifyCoalition("JTAC - enemy target lost: " .. _tempUnitInfo.unitType .. ", Grid: " .. _mapGrid .. ", JTAC: " .. _jtacOwner .. ". Rescanning area.", 10, _jtacUnit:getCoalition())
        else
			ctld.notifyCoalition("JTAC - enemy target destroyed: " .. _tempUnitInfo.unitType .. ", Grid: " .. _mapGrid .. ", JTAC: " .. _jtacOwner .. ". Rescanning area.", 10, _jtacUnit:getCoalition())
        end

        --remove from smoke list
        ctld.jtacSmokeMarks[_tempUnitInfo.name] = nil

        -- remove from target list
        ctld.jtacCurrentTargets[_jtacGroupName] = nil

        --stop lasing
        ctld.cancelLase(_jtacGroupName)
    end

    if _enemyUnit == nil then
        _enemyUnit = ctld.findNearestVisibleEnemy(_jtacUnit, _lock)

        if _enemyUnit ~= nil then

            -- store current target for easy lookup
            ctld.jtacCurrentTargets[_jtacGroupName] = { name = _enemyUnit:getName(), unitType = _enemyUnit:getTypeName(), unitId = _enemyUnit:getID() }
			
			local _targetName = _enemyUnit:getTypeName()
			
			local _unit = _enemyUnit --mr: only exploitable if spammable JTAC STATUS menu and reporting distance
			--local _unit = _jtacUnit
			local _mapGrid = utils.tostringMGRSnoUTM(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), -1)
			--Moose.lua: line 7723: playerMenu unit selection and accuracy
			--[[
				if Moose = x then
					_mapGrid = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_enemyUnit:getPosition().p)), 1)
				end
			--]]
			
			ctld.notifyCoalition("JTAC - new enemy target: " .. _targetName .. ", Grid: " .. _mapGrid .. ", JTAC: " .. _jtacOwner .. ", Laser Code: " .. _laserCode, 10, _jtacUnit:getCoalition())

            -- create smoke
            if _smoke == true then

                --create first smoke
                ctld.createSmokeMarker(_enemyUnit, _colour)
            end
        end
    end

    if _enemyUnit ~= nil then

        ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)

        --   env.info('Timer timerSparkleLase '..jtacGroupName.." "..laserCode.." "..enemyUnit:getName())
        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 1)

        if _smoke == true then
            local _nextSmokeTime = ctld.jtacSmokeMarks[_enemyUnit:getName()]

            --recreate smoke marker after 5 mins
            if _nextSmokeTime ~= nil and _nextSmokeTime < timer.getTime() then

                ctld.createSmokeMarker(_enemyUnit, _colour)
            end
        end

    else
        -- env.info('LASE: No Enemies Nearby')

        -- stop lazing the old spot
        ctld.cancelLase(_jtacGroupName)
        --  env.info('Timer Slow timerSparkleLase '..jtacGroupName.." "..laserCode.." "..enemyUnit:getName())

        timer.scheduleFunction(ctld.timerJTACAutoLase, { _jtacGroupName, _laserCode, _smoke, _lock, _colour }, timer.getTime() + 5)
    end
end

function ctld.JTACAutoLaseStop(_jtacGroupName)
    ctld.jtacStop[_jtacGroupName] = true
end

-- used by the timer function
function ctld.timerJTACAutoLase(_args)

    ctld.JTACAutoLase(_args[1], _args[2], _args[3], _args[4], _args[5])
end

function ctld.cleanupJTAC(_jtacGroupName)
    -- clear laser - just in case
    ctld.cancelLase(_jtacGroupName)

    -- Cleanup
    ctld.jtacUnits[_jtacGroupName] = nil

    ctld.jtacCurrentTargets[_jtacGroupName] = nil
end

function ctld.notifyCoalition(_message, _displayFor, _side)


    trigger.action.outTextForCoalition(_side, _message, _displayFor)
    trigger.action.outSoundForCoalition(_side, "radiobeep.ogg")
end

function ctld.createSmokeMarker(_enemyUnit, _colour)

    --recreate in 5 mins
    ctld.jtacSmokeMarks[_enemyUnit:getName()] = timer.getTime() + 300.0

    -- move smoke 2 meters above target for ease
    local _enemyPoint = _enemyUnit:getPoint()
    trigger.action.smoke({ x = _enemyPoint.x, y = _enemyPoint.y + 2.0, z = _enemyPoint.z }, _colour)
end

function ctld.cancelLase(_jtacGroupName)

    --local index = "JTAC_"..jtacUnit:getID()

    local _tempLase = ctld.jtacLaserPoints[_jtacGroupName]

    if _tempLase ~= nil then
        Spot.destroy(_tempLase)
        ctld.jtacLaserPoints[_jtacGroupName] = nil

        --      env.info('Destroy laze  '..index)
    end

    local _tempIR = ctld.jtacIRPoints[_jtacGroupName]

    if _tempIR ~= nil then
        Spot.destroy(_tempIR)
        ctld.jtacIRPoints[_jtacGroupName] = nil

        --  env.info('Destroy laze  '..index)
    end
end

function ctld.laseUnit(_enemyUnit, _jtacUnit, _jtacGroupName, _laserCode)

    --cancelLase(jtacGroupName)

    local _spots = {}

    local _enemyVector = _enemyUnit:getPoint()
    local _enemyVectorUpdated = { x = _enemyVector.x, y = _enemyVector.y + 2.0, z = _enemyVector.z }

    local _oldLase = ctld.jtacLaserPoints[_jtacGroupName]
    local _oldIR = ctld.jtacIRPoints[_jtacGroupName]

    if _oldLase == nil or _oldIR == nil then

        -- create lase

        local _status, _result = pcall(function()
            _spots['irPoint'] = Spot.createInfraRed(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated)
            _spots['laserPoint'] = Spot.createLaser(_jtacUnit, { x = 0, y = 2.0, z = 0 }, _enemyVectorUpdated, _laserCode)
            return _spots
        end)

        if not _status then
            env.error('ERROR: ' .. _result, false)
        else
            if _result.irPoint then

                --    env.info(jtacUnit:getName() .. ' placed IR Pointer on '..enemyUnit:getName())

                ctld.jtacIRPoints[_jtacGroupName] = _result.irPoint --store so we can remove after
            end
            if _result.laserPoint then

                --  env.info(jtacUnit:getName() .. ' is Lasing '..enemyUnit:getName()..'. CODE:'..laserCode)

                ctld.jtacLaserPoints[_jtacGroupName] = _result.laserPoint
            end
        end

    else

        -- update lase

        if _oldLase ~= nil then
            _oldLase:setPoint(_enemyVectorUpdated)
        end

        if _oldIR ~= nil then
            _oldIR:setPoint(_enemyVectorUpdated)
        end
    end
end

-- get currently selected unit and check they're still in range
function ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)


    local _unit = nil

    if ctld.jtacCurrentTargets[_jtacGroupName] ~= nil then
        _unit = Unit.getByName(ctld.jtacCurrentTargets[_jtacGroupName].name)
    end

    local _jtacPoint = _jtacUnit:getPoint()

    if _unit ~= nil and _unit:getLife() > 0 and _unit:isActive() == true then

        -- calc distance
        local _tempPoint = _unit:getPoint()
        --   tempPosition = unit:getPosition()

        local _tempDist = ctld.getDistance(_unit:getPoint(), _jtacUnit:getPoint())
        if _tempDist < ctld.JTAC_maxDistance then
            -- calc visible

            -- check slightly above the target as rounding errors can cause issues, plus the unit has some height anyways
            local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }
            local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

            if land.isVisible(_offsetEnemyPos, _offsetJTACPos) then
                return _unit
            end
        end
    end
    return nil
end


-- Find nearest enemy to JTAC that isn't blocked by terrain --mr: from CTLD GitHub: LOS doesn't include buildings or trees
function ctld.findNearestVisibleEnemy(_jtacUnit, _targetType, _distance)

    --local startTime = os.clock()

    local _maxDistance = _distance or ctld.JTAC_maxDistance

    local _jtacPoint = _jtacUnit:getPoint()
    local _coa = _jtacUnit:getCoalition()

    local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

    local _volume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _offsetJTACPos,
            radius = _maxDistance
        }
    }

    local _unitList = {}

    local _search = function(_unit, _coalition)
        pcall(function()
			
			local _playerControlledUnit = false
			--inclue if AI unit but it's player controlled
			--DCS func getPlayerName: AI units don't have names BUT "Returns a string value of the name of the player if the unit is currently controlled by a player. If a unit is controlled by AI the function returns nil."
			-- Group.Category = {AIRPLANE = 0, HELICOPTER = 1, GROUND = 2, SHIP = 3, TRAIN = 4}
			-- Unit.Category = {AIRPLANE,HELICOPTER,GROUND_UNIT,SHIP,STRUCTURE} --mr: player aircraft and ground units all = 1 = AIRPLANE!
			-- KNOWN BUG: Unit.getPlayerName() doesnt work on client controlled CA units.  Therefore _playerControlledUnit check probably unnecessary.
			if _unit:getPlayerName() ~= nil then
				if (_enemyUnit:getGroup():getCategory()) == 2 then
					_playerControlledUnit = true
				end
			end
-- env.info ("mrDEBUG31 _playerControlledUnit " .. (_playerControlledUnit and 'true' or 'false')) --mrDEBUG31		
            if _unit ~= nil
                    and _unit:getLife() > 0
                    and _unit:isActive()
                    and _unit:getCoalition() ~= _coalition
                    and not _unit:inAir() --not enough to exclude player aircraft on ground e.g. landed helo, plane on ramp
					and (_unit:getPlayerName() == nil or _playerControlledUnit)
                    and not ctld.alreadyTarget(_unit) then

                local _tempPoint = _unit:getPoint()
                local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }

                if land.isVisible(_offsetJTACPos, _offsetEnemyPos) then

                    local _dist = ctld.getDistance(_offsetJTACPos, _offsetEnemyPos)

                    if _dist < _maxDistance then
                        table.insert(_unitList, { unit = _unit, dist = _dist })

                    end
                end
            end
        end)

        return true
    end

    world.searchObjects(Object.Category.UNIT, _volume, _search, _coa)

    --log.info(string.format("JTAC Search elapsed time: %.4f\n", os.clock() - startTime))

    -- generate list order by distance & visible

    -- first check
    -- hpriority
    -- priority
    -- vehicle
    -- unit

    local _sort = function(a, b)
        return a.dist < b.dist
    end
    table.sort(_unitList, _sort)
    -- sort list

    -- check for hpriority
    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()

        if string.match(_enemyName, "hpriority") then
            return _enemyUnit.unit
        end
    end

    for _, _enemyUnit in ipairs(_unitList) do
        local _enemyName = _enemyUnit.unit:getName()

        if string.match(_enemyName, "priority") then
            return _enemyUnit.unit
        end
    end

    for _, _enemyUnit in ipairs(_unitList) do
        if (_targetType == "vehicle" and ctld.isVehicle(_enemyUnit.unit)) or _targetType == "all" then
            return _enemyUnit.unit

        elseif (_targetType == "troop" and ctld.isInfantry(_enemyUnit.unit)) or _targetType == "all" then
            return _enemyUnit.unit
        end
    end

    return nil

end

function ctld.listNearbyEnemies(_jtacUnit)

    local _maxDistance = ctld.JTAC_maxDistance

    local _jtacPoint = _jtacUnit:getPoint()
    local _coa = _jtacUnit:getCoalition()

    local _offsetJTACPos = { x = _jtacPoint.x, y = _jtacPoint.y + 2.0, z = _jtacPoint.z }

    local _volume = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _offsetJTACPos,
            radius = _maxDistance
        }
    }
    local _enemies = nil

    local _search = function(_unit, _coalition)
        pcall(function()
			
			local _playerControlledUnit = false
			--inclue if AI unit but it's player controlled
			--DCS func getPlayerName: AI units don't have names BUT "Returns a string value of the name of the player if the unit is currently controlled by a player. If a unit is controlled by AI the function returns nil."
			-- Group.Category = {AIRPLANE = 0, HELICOPTER = 1, GROUND = 2, SHIP = 3, TRAIN = 4}
			-- Unit.Category = {AIRPLANE,HELICOPTER,GROUND_UNIT,SHIP,STRUCTURE} --mr: player aircraft and ground units all = 1 = AIRPLANE!
			if _unit:getPlayerName() ~= nil then
				if (_enemyUnit:getGroup():getCategory()) == 2 then
					_playerControlledUnit = true
				end
			end

            if _unit ~= nil
                    and _unit:getLife() > 0
                    and _unit:isActive()
					
                    and _unit:getCoalition() ~= _coalition
                    and not _unit:inAir() --not enough to exclude player aircraft on ground e.g. landed helo, plane on ramp
					and (_unit:getPlayerName() == nil or _playerControlledUnit)
			    then 

                local _tempPoint = _unit:getPoint()
                local _offsetEnemyPos = { x = _tempPoint.x, y = _tempPoint.y + 2.0, z = _tempPoint.z }

                if land.isVisible(_offsetJTACPos, _offsetEnemyPos) then

                    if not _enemies then
                        _enemies = {}
                    end

                    _enemies[_unit:getTypeName()] = _unit:getTypeName()

                end
            end
        end)

        return true
    end

    world.searchObjects(Object.Category.UNIT, _volume, _search, _coa)

    return _enemies
end

-- tests whether the unit is targeted by another JTAC
function ctld.alreadyTarget(_enemyUnit)

    for _, _jtacTarget in pairs(ctld.jtacCurrentTargets) do

        if _jtacTarget.unitId == _enemyUnit:getID() then
            -- env.info("ALREADY TARGET")
            return true
        end
    end

    return false
end


-- Returns only alive units from group but the group / unit may not be active

function ctld.getGroup(groupName)

    local _groupUnits = Group.getByName(groupName)

    local _filteredUnits = {} --contains alive units
    if _groupUnits ~= nil and _groupUnits:isExist() then

        _groupUnits = _groupUnits:getUnits()

        if _groupUnits ~= nil and #_groupUnits > 0 then
            for _x = 1, #_groupUnits do
                if _groupUnits[_x]:getLife() > 0 then
                    -- removed and _groupUnits[_x]:isExist() as isExist doesnt work on single units!
                    table.insert(_filteredUnits, _groupUnits[_x])
                end
            end
        end
    end

    return _filteredUnits
end

function ctld.getAliveGroup(_groupName)

    local _group = Group.getByName(_groupName)

    if _group and _group:isExist() == true and #_group:getUnits() > 0 then
        return _group
    end

    return nil
end

-- gets the JTAC status and displays to coalition units
function ctld.getJTACStatus(_args)

    --returns the status of all JTAC units

    local _playerUnit = ctld.getTransportUnit(_args[1])

    if _playerUnit == nil then
        return
    end

    local _side = _playerUnit:getCoalition()
	local _JTACsMSGtitle = "STATUS OF JTACs: \n"
	local _message = ""
	
	local _discoveredJTACsCount = 0 --count of JTACs that have discovered a target
	local _discoveredJTACsUnsorted = {} --intiial nested table of JTACs that have discovered a target: {Reference #,JTAC, message, distance to player}
	local _discoveredJTACs = {} --nested table of JTACs ranked from closest to furthest from player
	
	local _searchingJTACsCount = 0 --count of JTACs that are still searching for a target
	local _searchingJTACsUnsorted = {} --intiial nested table of JTACs that are still searching for a target: {Reference #, JTACS, message, distance to player}
	local _searchingJTACs = {} --nested table of JTACs ranked from closest to furthest from player
	
	local _activeJTACsCount = 0
	
	local _azFromPlayer = -1 --set to -1 for debug
	local _distToPlayer = -1 --set to -1 for debug
	local _distToPlayerKm = -1 --set to -1 for debug
	local _roundedDist = -1 --set to -1 for debug
	local _mapGrid = "AA11" --set for debug
	local _coordinateTitle =  "Grid"
	local _JTACref = -1 --set to -1 for debug
	
    for _jtacGroupName, _jtacDetails in pairs(ctld.jtacUnits) do

        --look up units
        local _jtacUnit = Unit.getByName(_jtacDetails.name)
		local _jtacOwner = utils.getPlayerNameFromGroupName(_jtacGroupName) --_groupName = 'CTLD_' .. _types[1] .. '_' .. _id .. ' (' .. _playerName .. ')'

        if _jtacUnit ~= nil and _jtacUnit:getLife() > 0 and _jtacUnit:isActive() == true and _jtacUnit:getCoalition() == _side then

            local _enemyUnit = ctld.getCurrentUnit(_jtacUnit, _jtacGroupName)

            local _laserCode = ctld.jtacLaserPointCodes[_jtacGroupName]

            if _laserCode == nil then
                _laserCode = "UNKNOWN"
            end

            if _enemyUnit ~= nil and _enemyUnit:getLife() > 0 and _enemyUnit:isActive() == true then
			
				_discoveredJTACsCount = _discoveredJTACsCount + 1
				
				--Visual On = list of targets within minimum JTAC range and not blocked by LOS
				local _visualOnMsg = ""
				--mr:Remove this listing from JTAC STATUS as too powerful! Player should only know about the target being marked.
				--[[
                local _list = ctld.listNearbyEnemies(_jtacUnit)
                if _list then
                    _visualOnMsg = _visualOnMsg .. "\n Visual On: "

                    for _, _type in pairs(_list) do
                        _visualOnMsg = _visualOnMsg .. _type .. " "
                    end
                end
				--]]
				
-- env.info ("mrDEBUG23 GROUP CATEGORY: " .. "EnemyUnit-Grp-Cat: " .. (_enemyUnit:getGroup():getCategory()) .. ";  PlayerUnit-Grp-Cat: " .. (_playerUnit:getGroup():getCategory())) --mrDEBUG23
-- env.info ("mrDEBUG24 UNIT CATEGORY: " .. "EnemyUnit-Unit-Cat: " .. (_enemyUnit:getCategory()) .. ";  PlayerUnit-Unit-Cat: " .. (_playerUnit:getCategory())) --mrDEBUG24
				
				--Discovered JTAC Format: [180 : 55.3km] Grid: MN61, Target: M1A2, JTAC: mad rabbit --one line per JTAC
				-- local _unit = _enemyUnit --mr: possible exploit with JTAC STATUS spam whilst flying over moving target
				local _unit = _jtacUnit
				_distToPlayer = ctld.getDistance(_playerUnit:getPoint(),_unit:getPoint()) --distance in metres assuming flat worl 
				_distToPlayerKm = _distToPlayer/1000 --convert from metres to km -- line 1176: function ctld.metersToFeet(_meters)
				_roundedDist = mist.utils.round(_distToPlayerKm,1) -- function mist.utils.round(num, idp) -- +idp for after decimal, -idp for before decimal
				_azFromPlayer = ctld.getCompassBearing(_playerUnit:getPoint(),_unit:getPoint()) --player first = azimuth from player to target/JTAC
				local _azFromPlayerStr = tostring(_azFromPlayer)
				if _azFromPlayer < 100 then --add preceding 0 to azimuth when <100 or <10 for easier reading
					if _azFromPlayer < 10 then
						_azFromPlayerStr = "00" .. _azFromPlayerStr
					else
						_azFromPlayerStr = "0" .. _azFromPlayerStr
					end
				end
				local _targetName = _enemyUnit:getTypeName()
				
				_mapGrid = utils.tostringMGRSnoUTM(coord.LLtoMGRS(coord.LOtoLL(_enemyUnit:getPosition().p)), -1) --coordinate spam should not be exploitable
				
				---[[
				-- env.info("mrDEBUG011: Moose playerMenu enabled: " .. tostring(SETTINGS.ShowPlayerMenu)) --mrDEBUG011
				-- ":" = self, needed as settings client specific
				-- dedicated server test: GetMGRS_Accuracy = 5 (default setting) even when client radio specifies 2.  Need to test further.
				-- mrDEBUG13 ore mrDEBUG14 = nothing seems to be getting set by MOOSE player menu...
--env.info("mrDEBUG12: Moose MenuMGRS_Accuracy: " .. (SETTINGS:GetMGRS_Accuracy())) --mrDEBUG12 
--env.info("mrDEBUG13: Moose SETTINGS:IsMetric: " .. (SETTINGS:IsMetric() and 'true' or 'false')) --mrDEBUG13
--env.info("mrDEBUG14: Moose SETTINGS:IsImperial: " .. (SETTINGS:IsImperial() and 'true' or 'false')) --mrDEBUG14
				--Moose.lua: line 7723: playerMenu unit selection and accuracy
		
				if (SETTINGS.ShowPlayerMenu ~= nil and SETTINGS.ShowPlayerMenu == true) then
					_mapGrid = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_enemyUnit:getPosition().p)), SETTINGS:GetMGRS_Accuracy())
					_coordinateTitle = "@"
				else
					_mapGrid = utils.tostringMGRSnoUTM(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), -1)
				end
				--]]
				
				-- can't use utf8.char(730) for degree symbol as DCS = LUA v5.2 not v5.3
				_discoveredJTACsUnsorted[_discoveredJTACsCount] = {_jtacUnit,_distToPlayer,_JTACref,"" .. "[" .. _azFromPlayerStr --[[.. utf8.char(730)]] .. " : " .. _roundedDist .. "km] " .. _coordinateTitle .. ": " .. _mapGrid .. ", Target: " .. _targetName .. ", JTAC: " .. _jtacOwner .. _visualOnMsg}--DCS = LUA 5.2, UTF-8 support = LUA 5.3

            else
				_searchingJTACsCount = _searchingJTACsCount + 1
				
				--Searching JTAC Format: [180 : 55.3km] Grid: MN61, JTAC: mad rabbit | [270 : 65.8km] Grid: MM75, JTAC: mad rabbit --sharing same line
				_distToPlayer = ctld.getDistance(_playerUnit:getPoint(),_jtacUnit:getPoint())
				_distToPlayerKm = _distToPlayer/1000
				_roundedDist = mist.utils.round(_distToPlayerKm,1)
				_azFromPlayer = ctld.getCompassBearing(_playerUnit:getPoint(),_jtacUnit:getPoint())
				local _azFromPlayerStr = tostring(_azFromPlayer)
				if _azFromPlayer < 100 then
					if _azFromPlayer < 10 then
						_azFromPlayerStr = "00" .. _azFromPlayerStr
					else
						_azFromPlayerStr = "0" .. _azFromPlayerStr
					end
				end
				-- _mapGrid = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_jtacUnit:getPosition().p)), 1)
				_mapGrid = utils.tostringMGRSnoUTM(coord.LLtoMGRS(coord.LOtoLL(_jtacUnit:getPosition().p)), -1) --Moose.lua: line 7723: playerMenu unit selection and accuracy
				
				_searchingJTACsUnsorted[_searchingJTACsCount] = {_jtacUnit,_distToPlayer,_JTACref,"" .. "[" .. _azFromPlayerStr --[[.. utf8.char(730)]] .. " : " .. _roundedDist .. "km] Grid: " .. _mapGrid .. ", JTAC: " .. _jtacOwner .. " | "} --DCS = LUA 5.2, UTF-8 support = LUA 5.3

            end
        end
    end
	
	_activeJTACsCount = _discoveredJTACsCount + _searchingJTACsCount
    if _activeJTACsCount < 1 then
	
		_message = _message .. _JTACsMSGtitle .. "No Active JTACs"
		
	else
		--sort JTACs by distance to player  --mr: Add to utils.lua for use elsewhere?
		
		--sort table of JTACs that have discovered targets by distance to player
		if _discoveredJTACsCount > 0 then	
			local _dist = {}
			for _jT in ipairs(_discoveredJTACsUnsorted) do table.insert(_dist,_jT) end
			table.sort (_dist, function (_Ja,_Jb) return _discoveredJTACsUnsorted[_Ja][2] < _discoveredJTACsUnsorted[_Jb][2] end) -- closest to furtherest by "<"
			for _key,_jT in ipairs(_dist) do --_dist table now represents table keys for _discoveredJTACsUnsorted ordered from closest to furtherest
				table.insert(_discoveredJTACs,_key,_discoveredJTACsUnsorted[_jT]) --set JTAC table _jT from sorted _keys in _dist to empty table _discoveredJTACs
				_discoveredJTACs[_key][3] = tonumber(_key) --change original reference number now that table is sorted, tonumber to ensure integer
			end
		end
		
		--sort table of JTACs that are still searching for a target by distance to player
		if _searchingJTACsCount > 0 then	
			local _dist = {}
			for _jT in ipairs(_searchingJTACsUnsorted) do table.insert(_dist,_jT) end
			table.sort (_dist, function (_Ja,_Jb) return _searchingJTACsUnsorted[_Ja][2] < _searchingJTACsUnsorted[_Jb][2] end) -- closest to furtherest by "<"
			for _key,_jT in ipairs(_dist) do --_dist table now represents table keys for _searchingJTACsUnsorted ordered from closest to furtherest
				table.insert(_searchingJTACs,_key,_searchingJTACsUnsorted[_jT])
				_searchingJTACs[_key][3] = tonumber(_key) + _discoveredJTACsCount --ref # for JTACs still searching not as important but set anyway
			end
		end

		--Compile final message for display. Do this after distance ranking so that discovered JTACs are placed above searhcing JTACs in STATUS
		local _laserCodeTitle = UTILS.GetCoalitionName(_side) .. " Team Laser Code: "  --UTILS.GetCoalitionName from MOOSE
		local _sideLaserCode = ctld.getLaserCode(_playerUnit:getCoalition())
		_message = _message .. _JTACsMSGtitle .. "Detection Range: " .. mist.utils.round((ctld.JTAC_maxDistance/1000),1) .. "km , " .. _laserCodeTitle .. _sideLaserCode .. "\n"
		
		if _discoveredJTACsCount > 0 then
		
			_message = _message .. "\n" ..  "JTACs with Targets [" .. _discoveredJTACsCount .. "of" .. _activeJTACsCount ..  "] : \n"
			local _dJTACref = ""
			for _key,_jT in ipairs(_discoveredJTACs) do
				-- local _dJTACref = "J" .. _discoveredJTACs[_key][3] .. " - " -- ref# designation for better re-refrencing?
				_message = _message .. _dJTACref .. _discoveredJTACs[_key][4] .. "\n"
			end
		end
		
		if _searchingJTACsCount > 0 then
		
			_message = _message .. "\n" ..  "JTACs Searching for Targets [" .. _searchingJTACsCount .. "of" .. _activeJTACsCount .. "] : \n"
			local _sJTACref = ""
			for _key,_jT in ipairs(_searchingJTACs) do
				-- local _sJTACref = "J" .. _searchingJTACs[_key][3] .. " - " -- ref# designation for better re-refrencing esp. when not targeting anything?
				_message = _message .. _sJTACref .. _searchingJTACs[_key][4]
			end
		end
    end

    ctld.displayMessageToGroup(_playerUnit, _message, 10)
end

function ctld.isInfantry(_unit)

    local _typeName = _unit:getTypeName()

    --type coerce tostring
    _typeName = string.lower(_typeName .. "")

    local _soldierType = { "infantry", "paratrooper", "stinger", "manpad", "mortar" }

    for _, _value in pairs(_soldierType) do
        if string.match(_typeName, _value) then
            return true
        end
    end

    return false
end

-- assume anything that isnt soldier is vehicle
function ctld.isVehicle(_unit)

    if ctld.isInfantry(_unit) then
        return false
    end

    return true
end

-- The entered value can range from 1111 - 1788,
-- -- but the first digit of the series must be a 1 or 2
-- -- and the last three digits must be between 1 and 8.
--  The range used to be bugged so its not 1 - 8 but 0 - 7.
-- function below will use the range 1-7 just incase
function ctld.generateLaserCode()

    ctld.jtacGeneratedLaserCodes = {}

    -- generate list of laser codes
    local _code = 1111

    local _count = 1

    while _code < 1777 and _count < 30 do

        while true do

            _code = _code + 1

            if not ctld.containsDigit(_code, 8)
                    and not ctld.containsDigit(_code, 9)
                    and not ctld.containsDigit(_code, 0) then

                table.insert(ctld.jtacGeneratedLaserCodes, _code)

                --env.info(_code.." Code")
                break
            end
        end
        _count = _count + 1
    end
end

function ctld.containsDigit(_number, _numberToFind)

    local _thisNumber = _number

    while _thisNumber ~= 0 do

        local _thisDigit = _thisNumber % 10
        _thisNumber = math.floor(_thisNumber / 10)

        if _thisDigit == _numberToFind then
            return true
        end
    end

    return false
end

-- 200 - 400 in 10KHz
-- 400 - 850 in 10 KHz
-- 850 - 1250 in 50 KHz
function ctld.generateVHFrequencies()

    --ignore list
    --list of all frequencies in KHZ that could conflict with
    -- 191 - 1290 KHz, beacon range
    local _skipFrequencies = {
        745, --Astrahan
        381,
        384,
        300.50,
        312.5,
        1175,
        342,
        735,
        300.50,
        353.00,
        440,
        795,
        525,
        520,
        690,
        625,
        291.5,
        300.50,
        435,
        309.50,
        920,
        1065,
        274,
        312.50,
        580,
        602,
        297.50,
        750,
        485,
        950,
        214,
        1025, 730, 995, 455, 307, 670, 329, 395, 770,
        380, 705, 300.5, 507, 740, 1030, 515,
        330, 309.5,
        348, 462, 905, 352, 1210, 942, 435,
        324,
        320, 420, 311, 389, 396, 862, 680, 297.5,
        920, 662,
        866, 907, 309.5, 822, 515, 470, 342, 1182, 309.5, 720, 528,
        337, 312.5, 830, 740, 309.5, 641, 312, 722, 682, 1050,
        1116, 935, 1000, 430, 577,
        326 -- Nevada
    }

    ctld.freeVHFFrequencies = {}
    local _start = 200000

    -- first range
    while _start < 400000 do

        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 10000
    end

    _start = 400000
    -- second range
    while _start < 850000 do

        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 10000
    end

    _start = 850000
    -- third range
    while _start <= 1250000 do

        -- skip existing NDB frequencies
        local _found = false
        for _, value in pairs(_skipFrequencies) do
            if value * 1000 == _start then
                _found = true
                break
            end
        end

        if _found == false then
            table.insert(ctld.freeVHFFrequencies, _start)
        end

        _start = _start + 50000
    end
end

-- 220 - 399 MHZ, increments of 0.5MHZ
function ctld.generateUHFrequencies()

    ctld.freeUHFFrequencies = {}
    local _start = 220000000

    while _start < 399000000 do
        table.insert(ctld.freeUHFFrequencies, _start)
        _start = _start + 500000
    end
end


-- 220 - 399 MHZ, increments of 0.5MHZ
--    -- first digit 3-7MHz
--    -- second digit 0-5KHz
--    -- third digit 0-9
--    -- fourth digit 0 or 5
--    -- times by 10000
--
function ctld.generateFMFrequencies()

    ctld.freeFMFrequencies = {}
    local _start = 220000000

    while _start < 399000000 do

        _start = _start + 500000
    end

    for _first = 3, 7 do
        for _second = 0, 5 do
            for _third = 0, 9 do
                local _frequency = ((100 * _first) + (10 * _second) + _third) * 100000 --extra 0 because we didnt bother with 4th digit
                table.insert(ctld.freeFMFrequencies, _frequency)
            end
        end
    end
end

function ctld.getPositionString(_unit)

    if ctld.JTAC_location == false then
        return ""
    end

    local _lat, _lon = coord.LOtoLL(_unit:getPosition().p)

    local _latLngStr = mist.tostringLL(_lat, _lon, 3, ctld.location_DMS)

    local _mgrsString = mist.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(_unit:getPosition().p)), 5)

    return " @ " .. _latLngStr .. " - MGRS " .. _mgrsString
end


-- ***************** SETUP SCRIPT ****************

assert(mist ~= nil, "\n\n** HEY MISSION-DESIGNER! **\n\nMiST has not been loaded!\n\nMake sure MiST 3.6 or higher is running\n*before* running this script!\n")

ctld.addedTo = {}
ctld.spawnedCratesRED = {} -- use to store crates that have been spawned
ctld.spawnedCratesBLUE = {} -- use to store crates that have been spawned

ctld.droppedTroopsRED = {} -- stores dropped troop groups
ctld.droppedTroopsBLUE = {} -- stores dropped troop groups

ctld.droppedVehiclesRED = {} -- stores vehicle groups for c-130 / hercules
ctld.droppedVehiclesBLUE = {} -- stores vehicle groups for c-130 / hercules

ctld.inTransitTroops = {}

ctld.inTransitLogisticsCentreCrates = {}

ctld.inTransitSlingLoadCrates = {} -- stores crates that are being transported by helicopters for alternative to real slingload

ctld.droppedLogisticsCentreCratesRED = {}
ctld.droppedLogisticsCentreCratesBLUE = {}

ctld.builtFOBs = {} -- stores fully built fobs

ctld.completeAASystems = {} -- stores complete spawned groups from multiple crates

ctld.FOBbeacons = {} -- stores FOB radio beacon details, refreshed every 60 seconds

ctld.deployedRadioBeacons = {} -- stores details of deployed radio beacons

ctld.beaconCount = 1

ctld.usedUHFFrequencies = {}
ctld.usedVHFFrequencies = {}
ctld.usedFMFrequencies = {}

ctld.freeUHFFrequencies = {}
ctld.freeVHFFrequencies = {}
ctld.freeFMFrequencies = {}

--used to lookup what the crate will contain
ctld.crateLookupTable = {}

ctld.extractZones = {} -- stored extract zones

ctld.missionEditorCargoCrates = {} --crates added by mission editor for triggering cratesinzone
ctld.hoverStatus = {} -- tracks status of a helis hover above a crate

ctld.callbacks = {} -- function callback


-- Remove intransit troops when heli / cargo plane dies
--ctld.eventHandler = {}
--function ctld.eventHandler:onEvent(_event)
--
--    if _event == nil or _event.initiator == nil then
--        env.info("CTLD null event")
--    elseif _event.id == 9 then
--        -- Pilot dead
--        ctld.inTransitTroops[_event.initiator:getName()] = nil
--
--    elseif world.event.S_EVENT_EJECTION == _event.id or _event.id == 8 then
--        -- env.info("Event unit - Pilot Ejected or Unit Dead")
--        ctld.inTransitTroops[_event.initiator:getName()] = nil
--
--        -- env.info(_event.initiator:getName())
--    end
--
--end

-- create crate lookup table
for _, _crates in pairs(ctld.spawnableCrates) do

    for _, _crate in pairs(_crates) do
        -- convert number to string otherwise we'll have a pointless giant
        -- table. String means 'hashmap' so it will only contain the right number of elements
        local key = tostring(_crate.weight)
        local heavyKey = tostring(_crate.weight * ctld.heavyCrateWeightMultiplier)

        if ctld.crateLookupTable[key] ~= nil then
            error("Cannot add crate with weight " .. key .. " as one already exists")
        end
        if ctld.crateLookupTable[heavyKey] ~= nil then
            error("Cannot add heavy crate with weight " .. heavyKey .. " as one already exists")
        end

        ctld.crateLookupTable[key] = _crate
        local _heavyCrate = mist.utils.deepCopy(_crate)
        _heavyCrate.weight = _heavyCrate.weight * ctld.heavyCrateWeightMultiplier
        ctld.crateLookupTable[heavyKey] = _heavyCrate
    end
end


--sort out pickup zones
for _, _zone in pairs(ctld.pickupZones) do

    local _zoneColor = _zone[2]
    local _zoneActive = _zone[4]

    if _zoneColor == "green" then
        _zone[2] = trigger.smokeColor.Green
    elseif _zoneColor == "red" then
        _zone[2] = trigger.smokeColor.Red
    elseif _zoneColor == "white" then
        _zone[2] = trigger.smokeColor.White
    elseif _zoneColor == "orange" then
        _zone[2] = trigger.smokeColor.Orange
    elseif _zoneColor == "blue" then
        _zone[2] = trigger.smokeColor.Blue
    else
        _zone[2] = -1 -- no smoke colour
    end

    -- add in counter for troops or units
    if _zone[3] == -1 then
        _zone[3] = 10000;
    end

    -- change active to 1 / 0
    if _zoneActive == "yes" then
        _zone[4] = 1
    else
        _zone[4] = 0
    end
end

--sort out dropoff zones
for _, _zone in pairs(ctld.dropOffZones) do

    local _zoneColor = _zone[2]

    if _zoneColor == "green" then
        _zone[2] = trigger.smokeColor.Green
    elseif _zoneColor == "red" then
        _zone[2] = trigger.smokeColor.Red
    elseif _zoneColor == "white" then
        _zone[2] = trigger.smokeColor.White
    elseif _zoneColor == "orange" then
        _zone[2] = trigger.smokeColor.Orange
    elseif _zoneColor == "blue" then
        _zone[2] = trigger.smokeColor.Blue
    else
        _zone[2] = -1 -- no smoke colour
    end

    --mark as active for refresh smoke logic to work
    _zone[4] = 1
end

--sort out waypoint zones
for _, _zone in pairs(ctld.wpZones) do

    local _zoneColor = _zone[2]

    if _zoneColor == "green" then
        _zone[2] = trigger.smokeColor.Green
    elseif _zoneColor == "red" then
        _zone[2] = trigger.smokeColor.Red
    elseif _zoneColor == "white" then
        _zone[2] = trigger.smokeColor.White
    elseif _zoneColor == "orange" then
        _zone[2] = trigger.smokeColor.Orange
    elseif _zoneColor == "blue" then
        _zone[2] = trigger.smokeColor.Blue
    else
        _zone[2] = -1 -- no smoke colour
    end

    --mark as active for refresh smoke logic to work
    -- change active to 1 / 0
    if _zone[3] == "yes" then
        _zone[3] = 1
    else
        _zone[3] = 0
    end
end

-- Sort out extractable groups
for _, _groupName in pairs(ctld.extractableGroups) do

    local _group = Group.getByName(_groupName)

    if _group ~= nil then

        if _group:getCoalition() == 1 then
            table.insert(ctld.droppedTroopsRED, _group:getName())
        else
            table.insert(ctld.droppedTroopsBLUE, _group:getName())
        end
    end
end


-- Seperate troop teams into red and blue for random AI pickups
if ctld.allowRandomAiTeamPickups == true then
    ctld.redTeams = {}
    ctld.blueTeams = {}
    for _, _loadGroup in pairs(ctld.loadableGroups) do
        if not _loadGroup.side then
            table.insert(ctld.redTeams, _)
            table.insert(ctld.blueTeams, _)
        elseif _loadGroup.side == 1 then
            table.insert(ctld.redTeams, _)
        elseif _loadGroup.side == 2 then
            table.insert(ctld.blueTeams, _)
        end
    end
end

-- add total count

for _, _loadGroup in pairs(ctld.loadableGroups) do

    _loadGroup.total = 0
    if _loadGroup.aa then
        _loadGroup.total = _loadGroup.aa + _loadGroup.total
    end

    if _loadGroup.inf then
        _loadGroup.total = _loadGroup.inf + _loadGroup.total
    end

    if _loadGroup.mg then
        _loadGroup.total = _loadGroup.mg + _loadGroup.total
    end

    if _loadGroup.at then
        _loadGroup.total = _loadGroup.at + _loadGroup.total
    end

    if _loadGroup.mortar then
        _loadGroup.total = _loadGroup.mortar + _loadGroup.total
    end

end


-- Scheduled functions (run cyclically) -- but hold execution for a second so we can override parts

timer.scheduleFunction(ctld.checkAIStatus, nil, timer.getTime() + 1)
timer.scheduleFunction(ctld.checkTransportStatus, nil, timer.getTime() + 5)

timer.scheduleFunction(function()

    timer.scheduleFunction(ctld.refreshRadioBeacons, nil, timer.getTime() + 5)
    timer.scheduleFunction(ctld.refreshSmoke, nil, timer.getTime() + 5)
    --timer.scheduleFunction(ctld.addF10MenuOptions, nil, timer.getTime() + 5)

    if ctld.enableCrates == true and ctld.slingLoad == false and ctld.hoverPickup == true then
        timer.scheduleFunction(ctld.checkHoverStatus, nil, timer.getTime() + 1)
    end

end, nil, timer.getTime() + 1)

--event handler for deaths
--world.addEventHandler(ctld.eventHandler)

--env.info("CTLD event handler added")

env.info("Generating Laser Codes")
ctld.generateLaserCode()
env.info("Generated Laser Codes")

env.info("Generating UHF Frequencies")
ctld.generateUHFrequencies()
env.info("Generated  UHF Frequencies")

env.info("Generating VHF Frequencies")
ctld.generateVHFrequencies()
env.info("Generated VHF Frequencies")

env.info("Generating FM Frequencies")
ctld.generateFMFrequencies()
env.info("Generated FM Frequencies")

-- Search for crates
-- Crates are NOT returned by coalition.getStaticObjects() for some reason
-- Search for crates in the mission editor instead
env.info("Searching for Crates")
for _coalitionName, _coalitionData in pairs(env.mission.coalition) do

    if (_coalitionName == 'red' or _coalitionName == 'blue')
            and type(_coalitionData) == 'table' then
        if _coalitionData.country then
            --there is a country table
            for _, _countryData in pairs(_coalitionData.country) do

                if type(_countryData) == 'table' then
                    for _objectTypeName, _objectTypeData in pairs(_countryData) do
                        if _objectTypeName == "static" then

                            if ((type(_objectTypeData) == 'table')
                                    and _objectTypeData.group
                                    and (type(_objectTypeData.group) == 'table')
                                    and (#_objectTypeData.group > 0)) then

                                for _, _group in pairs(_objectTypeData.group) do
                                    if _group and _group.units and type(_group.units) == 'table' then
                                        for _, _unit in pairs(_group.units) do
                                            if _unit.canCargo == true then
                                                local _cargoName = env.getValueDictByKey(_unit.name)
                                                ctld.missionEditorCargoCrates[_cargoName] = _cargoName
                                                env.info("Crate Found: " .. _unit.name .. " - Unit: " .. _cargoName)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
env.info("END search for crates")

env.info("RSR STARTUP: CTLD.LUA LOADED")
trigger.action.outText("CTLD.LUA LOADED", 10)


--DEBUG FUNCTION
--        for key, value in pairs(getmetatable(_spawnedCrate)) do
--            env.info(tostring(key))
--            env.info(tostring(value))
--        end
