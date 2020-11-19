-- luacheck: no max line length
--[[
	Early Warning Radar Script - 1.5.3 - 07/11/2016

	Allows use of units with radars to provide Bearing Range and Altitude information via text display to player aircraft

	Features:
		- Uses in-game radar information to detect targets so terrain masking, beaming, low altitude flying, etc is effective for avoiding detection
		- Dynamic. If valid units with radar are created during a mission (eg. via chopper with CTLD), they will be added to the EWRS radar network
		- Can allow / disable BRA messages to fighters or sides
		- Uses player aircraft or mission bullseye for BRA reference, can be changed via F10 radio menu or restricted to one reference in the script settings
		- Can switch between imperial (feet, knots, NM) or metric (meters, km/h, km) measurements using F10 radio menu
		- Ability to change the message display time and automated update interval
		- Can choose to disable automated messages and allow players to request BRA from F10 menu
		- Can allow players to request Bogey Dope at any time through F10 radio menu

	Built and Tested in DCS 1.5 - See https://github.com/Bob7heBuilder/EWRS for the latest version

	This script uses MIST 4.0.57 or later - https://github.com/mrSkortch/MissionScriptingTools

	At the moment, because of limitations within DCS to not show messages to individual units, the reference, measurements, and messages
	are done per group. So a group of 4 fighters will each receive 4 BRA messages. Each message however, will have the player's name
	in it, that its refering to. Its unfortunate, but nothing I can do about it.

	Changes:
	- 1.3 - Added Option to allow picture report to be requested thru F10 menu instead of an automated display
			- Fixed bug where a known unit type would sometimes still display as ???
	- 1.4 - Added setting to be able to limit the amount of threats displayed in a picture report
			- Added option to enable Bogey Dopes
				* Mission designer can turn on / off in script settings
				* Pilots can request thru the F10 menu and it will show the BRA to the nearest hostile aircraft that has
				been detected. It will always reference the requesting pilot's own aircraft.
			- Finally implemented a cleaner workaround for some ground units being detected and listed in picture report
	- 1.4.1 - Added some ships to search radar list, you will need to remove the comment markers (--) at the start of the line to activate
	- 1.5 - Added ability to request picture of friendly aircraft positions referencing your own aircraft - Mission designer chooses if this feature is active or not
	- 1.5.1 - Added Gazelle to acCategories
	- 1.5.2 - Added F5E to acCategories
	- 1.5.3 - Fixed bug with maxThreatDisplay set at 0 not displaying any threats
			- Added Mistral Gazelle
			- Added C-101CC
]]
local utils = require("utils")

ewrs = {} --DO NOT REMOVE

----SCRIPT OPTIONS----

ewrs.messageUpdateInterval = 30 --How often EWRS will update automated BRA messages (seconds)
ewrs.messageDisplayTime = 20 --How long EWRS BRA messages will show for (seconds)
ewrs.useImprovedDetectionLogic = true --this makes the messages more realistic. If the radar doesn't know the type or distance to the detected threat, it will be reflected in the picture report / BRA message
ewrs.maxThreatDisplay = 1 -- Max amounts of threats to display on picture report (0 will display all)
ewrs.radarUnitsUpdateInterval = 60 -- minimum time between radar units update
ewrs.detectedTargetsUpdateInterval = ewrs.messageUpdateInterval -- minimum time between threat table updates


--[[
Units with radar to use as part of the EWRS radar network
If you want to shorten the range of SAM radar detection, use their track radars instead of their search radars
NOTE that track radars require a search radar to detect targets (but the search radars do not need to be included in the list)
I haven't tested detection with ships (that have radar), but should work.
]]
ewrs.validSearchRadars = {
    -- slingable radars
    "p-19 s-125 sr", --SA-2 Search Radar
    "Kub 1S91 str", -- Kub Search and Track Radar
    "SA-11 Buk SR 9S18M1", -- Buk search radar
    "Hawk sr", --Hawk SAM Search Radar
    "Roland Radar", --Roland Search Radar
    "1L13 EWR", --Early Warning Radar

    -- AWACS
    "A-50",
    "E-2C",
    "E-3A",

    -- Other items we could add (IDs to be verified)
    -- Big EWR ("55G6 EWR")
    -- SA-10 ("S-300PS 64H6E sr" and "S-300 PS 40B6MD sr")
    -- Patriot ("Patriot str")
    -- The ships
}

--[[
Aircraft type list
This is used to restrict availability to just these types
]]
ewrs.enabledAircraftTypes = {
    ["A-10A"] = true,
    ["A-10C"] = true,
    ["AJS37"] = true,
    ["AV8BNA"] = true,
    ["AV8BNA"] = true,
    ["Bf-109K-4"] = true,
    ["C-101CC"] = true,
    ["F-5E-3"] = true,
    ["F-86F Sabre"] = true,
    ["FW-190A8"] = true,
    ["FW-190D9"] = true,
    ["I-16"] = true,
    ["Ka-50"] = true,
    ["L-39ZA"] = true,
    ["Mi-8MT"] = true,
    ["MiG-15bis"] = true,
    ["MiG-19P"] = true,
    ["MiG-21Bis"] = true,
    ["MiG-29A"] = true,
    ["MiG-29G"] = true,
    ["MiG-29S"] = true,
    ["P-51D"] = true,
    ["P-51D-30-NA"] = true,
    ["SA342L"] = true,
    ["SA342M"] = true,
    ["Su-25T"] = true,
    ["TF-51D"] = true,
    ["UH-1H"] = true,
}

----END OF SCRIPT OPTIONS----


----INTERNAL FUNCTIONS ***** Be Careful changing things below here ***** ----


function ewrs.getDistance(obj1PosX, obj1PosZ, obj2PosX, obj2PosZ)
    local xDiff = obj1PosX - obj2PosX
    local yDiff = obj1PosZ - obj2PosZ
    return math.sqrt(xDiff * xDiff + yDiff * yDiff) -- meters
end

function ewrs.getBearing(obj1PosX, obj1PosZ, obj2PosX, obj2PosZ)
    local bearing = math.atan2(obj2PosZ - obj1PosZ, obj2PosX - obj1PosX)
    if bearing < 0 then
        bearing = bearing + 2 * math.pi
    end
    bearing = bearing * 180 / math.pi
    return bearing    -- degrees
end

function ewrs.getHeading(vec)
    local heading = math.atan2(vec.z, vec.x)
    if heading < 0 then
        heading = heading + 2 * math.pi
    end
    heading = heading * 180 / math.pi
    return heading -- degrees
end

function ewrs.getSpeed(velocity)
    local speed = math.sqrt(velocity.x ^ 2 + velocity.y ^ 2 + velocity.z ^ 2) --m/s
    return speed -- m/s
end

function ewrs.buildThreatTable(activePlayer)
    local function sortRanges(v1, v2)
        return v1.range < v2.range
    end

    local targets
    if activePlayer.side == 2 then
        targets = ewrs.currentlyDetectedRedUnits
    else
        targets = ewrs.currentlyDetectedBlueUnits
    end

    local threatTable = {}

    local _self = Unit.getByName(activePlayer.unitname)
    if _self == nil then
        return threatTable
    end
    local selfpos = _self:getPosition()
    local referenceX = selfpos.p.x
    local referenceZ = selfpos.p.z

    for _, v in pairs(targets) do
        local velocity = v["object"]:getVelocity()
        local bogeypos = v["object"]:getPosition()
        local bogeyType
        if ewrs.useImprovedDetectionLogic then
            if v["type"] then
                bogeyType = v["object"]:getTypeName()
            else
                bogeyType = "unknown"
            end
        else
            bogeyType = v["object"]:getTypeName()
        end

        local bearing = ewrs.getBearing(referenceX, referenceZ, bogeypos.p.x, bogeypos.p.z)
        local heading = ewrs.getHeading(velocity)
        local range = ewrs.getDistance(referenceX, referenceZ, bogeypos.p.x, bogeypos.p.z) -- meters
        local altitude = bogeypos.p.y --meters
        local speed = ewrs.getSpeed(velocity) --m/s

        if ewrs.groupSettings[tostring(activePlayer.groupID)].measurements == "metric" then
            range = range / 1000 --change to KM
            speed = mist.utils.mpsToKmph(speed)
            --altitude already in meters
        else
            range = mist.utils.metersToNM(range)
            speed = mist.utils.mpsToKnots(speed)
            altitude = mist.utils.metersToFeet(altitude)
        end

        if ewrs.useImprovedDetectionLogic then
            if not v["distance"] then
                range = ewrs.notAvailable
            end
        end

        local j = #threatTable + 1
        threatTable[j] = {}
        threatTable[j].unitType = bogeyType
        threatTable[j].bearing = bearing
        threatTable[j].range = range
        threatTable[j].altitude = altitude
        threatTable[j].speed = speed
        threatTable[j].heading = heading
    end

    table.sort(threatTable, sortRanges)

    return threatTable
end

function ewrs.outText(groupID, threatTable)
    local status, result = pcall(function()
        local altUnits
        local speedUnits
        local rangeUnits
        if ewrs.groupSettings[tostring(groupID)].measurements == "metric" then
            altUnits = "m"
            speedUnits = "km/h"
            rangeUnits = "km"
        else
            altUnits = "ft"
            speedUnits = "kts"
            rangeUnits = "nm"
        end

        if #threatTable >= 1 then
            local threat = threatTable[1]
            local message
            if threat.range == ewrs.notAvailable then
                message = "GCI: Nearest target position unknown"
            else
                message = string.format("GCI: Nearest target %03d for %d%s at %d%s, type %s, heading %03d at %d%s",
                        threat.bearing,
                        utils.round(threat.range, 1), rangeUnits,
                        utils.round(threat.altitude, 100), altUnits,
                        threat.unitType,
                        threat.heading,
                        utils.round(threat.speed, 10), speedUnits
                )
            end
            trigger.action.outTextForGroup(groupID, message, ewrs.messageDisplayTime)
        else
            trigger.action.outTextForGroup(groupID, "GCI: No targets detected", ewrs.messageDisplayTime)
        end
    end)
    if not status then
        env.error(string.format("EWRS outText Error: %s", result))
    end
end

function ewrs.onDemandMessage(groupID)
    local status, result = pcall(function()
        ewrs.findRadarUnits()
        ewrs.getDetectedTargets()
        local activePlayer = ewrs.activePlayers[tostring(groupID)]
        ewrs.outText(groupID, ewrs.buildThreatTable(activePlayer))
        if ewrs.groupSettings[tostring(groupID)].pictureUpdates then
            local unit = Unit.getByName(activePlayer.unitname)
            if unit ~= nil and unit:getPlayerName() ~= nil then
                timer.scheduleFunction(ewrs.onDemandMessage, groupID, timer.getTime() + ewrs.messageUpdateInterval)
            end
        end
    end)
    if not status then
        env.error(string.format("EWRS onDemandMessage Error: %s", result))
    end
end

function ewrs.addPlayer(playerName, groupID, unit)
    local status, result = pcall(function()
        local key = tostring(groupID)
        ewrs.activePlayers[key] = {}
        ewrs.activePlayers[key].player = playerName
        ewrs.activePlayers[key].groupID = groupID
        ewrs.activePlayers[key].unitname = unit:getName()
        ewrs.activePlayers[key].side = unit:getCoalition()

        -- add default settings to settings table if it hasn't been done yet
        if ewrs.groupSettings[key] == nil then
            ewrs.addGroupSettings(key, unit:getCoalition())
        end
    end)
    if not status then
        env.error(string.format("EWRS addPlayer Error: %s", result))
    end
end

-- filters units so ones detected by multiple radar sites still only get listed once
-- Filters out anything that isn't a plane or helicopter
function ewrs.filterUnits(units)
    local newUnits = {}
    for _, v in pairs(units) do
        local valid = true
        local object = v["object"]
        if object ~= nil and object:getCategory() ~= Object.Category.UNIT then
            --rare but i've had it detect missiles
            valid = false
        end
        if valid then
            --another check cause it seems AI radar can detected some ground units
            local category = v["object"]:getDesc().category
            if category ~= Unit.Category.AIRPLANE and category ~= Unit.Category.HELICOPTER then
                valid = false
            end
        end

        if valid then
            for _, nv in pairs(newUnits) do
                --recursive loop, can't see a way around this
                if v["object"]:getName() == nv["object"]:getName() then
                    valid = false
                    --update already found unit incase the first detection(s) didn't know type or distance
                    if v["type"] then
                        nv["type"] = true
                    end
                    if v["distance"] then
                        nv["distance"] = true
                    end
                end
            end
        end

        if valid then
            table.insert(newUnits, v)
        end
    end
    return newUnits
end

function ewrs.getDetectedTargets()
    if ewrs.lastDetectedTargetsUpdateTime ~= nil and timer.getTime() - ewrs.lastDetectedTargetsUpdateTime < ewrs.detectedTargetsUpdateInterval then
        env.info("EWRS: Not updating detected targets")
        return
    end

    if #ewrs.blueEwrUnits > 0 then
        ewrs.currentlyDetectedRedUnits = ewrs.findDetectedTargets("red")
    end
    if #ewrs.redEwrUnits > 0 then
        ewrs.currentlyDetectedBlueUnits = ewrs.findDetectedTargets("blue")
    end
    env.info("EWRS: Updated detected targets")
    ewrs.lastDetectedTargetsUpdateTime = timer.getTime()
end

function ewrs.findDetectedTargets(side)
    local units = {}
    local ewrUnits = {}

    if side == "red" then
        ewrUnits = ewrs.blueEwrUnits
    elseif side == "blue" then
        ewrUnits = ewrs.redEwrUnits
    end

    for n = 1, #ewrUnits do
        local ewrUnit = Unit.getByName(ewrUnits[n])
        if ewrUnit ~= nil then
            local ewrControl = ewrUnit:getGroup():getController()
            local detectedTargets = ewrControl:getDetectedTargets(Controller.Detection.RADAR)
            for _, v in pairs(detectedTargets) do
                table.insert(units, v)
            end
        end
    end
    return ewrs.filterUnits(units)
end

ewrs.ewrUnitSet = SET_UNIT:New()
                          :FilterActive()
                          :FilterCategories({ "plane", "ground", "ship" })
                          :FilterStart()

function ewrs.findRadarUnits()
    if ewrs.lastRadarUnitsUpdateTime ~= nil and timer.getTime() - ewrs.lastRadarUnitsUpdateTime < ewrs.radarUnitsUpdateInterval then
        env.info("EWRS: Not updating radar units")
        return
    end

    local all_vecs = {}
    ewrs.ewrUnitSet:ForEachUnit(function(u)
        table.insert(all_vecs, u:GetName())
    end)

    local redUnits = {}
    local blueUnits = {}

    for i = 1, #all_vecs do
        local vec = Unit.getByName(all_vecs[i])

        if vec ~= nil then
            if Unit.isActive(vec) then
                local vec_type = Unit.getTypeName(vec)
                for n = 1, #ewrs.validSearchRadars do
                    if ewrs.validSearchRadars[n] == vec_type and Unit.getCoalition(vec) == 2 then
                        table.insert(blueUnits, Unit.getName(vec))
                        break
                    end
                    if ewrs.validSearchRadars[n] == vec_type and Unit.getCoalition(vec) == 1 then
                        table.insert(redUnits, Unit.getName(vec))
                        break
                    end
                end --for n = 1, #ewrs.validSearchRadars do
            end --if Unit.isActive(vec) then
        end --if vec ~= nil then
    end --for i = 1, #all_vecs do
    ewrs.blueEwrUnits = blueUnits
    ewrs.redEwrUnits = redUnits
    env.info("EWRS: Updated radar units")
    ewrs.lastRadarUnitsUpdateTime = timer.getTime()
end

function ewrs.getDefaultMeasurements(side)
    return side == coalition.side.RED and "metric" or "imperial"
end

function ewrs.addGroupSettings(groupID, side)
    ewrs.groupSettings[groupID] = {}
    ewrs.groupSettings[groupID].measurements = ewrs.getDefaultMeasurements(side)
    ewrs.groupSettings[groupID].pictureUpdates = false
end

function ewrs.setGroupMeasurements(args)
    local groupID = args[1]
    ewrs.groupSettings[tostring(groupID)].measurements = args[2]
    trigger.action.outTextForGroup(groupID, "GCI: Measurement units changed to " .. args[2], ewrs.messageDisplayTime)
end

function ewrs.setGroupUpdates(args)
    local groupID = args[1]
    local onOff
    if args[2] then
        onOff = "on"
    else
        onOff = "off"
    end
    ewrs.groupSettings[tostring(groupID)].pictureUpdates = args[2]
    trigger.action.outTextForGroup(groupID, "GCI: Picture updates for group turned " .. onOff, ewrs.messageDisplayTime)
    if args[2] then
        ewrs.onDemandMessage(groupID)
    end
end

function ewrs.buildF10Menu(groupID)
    local rootPath = missionCommands.addSubMenuForGroup(groupID, "Automated GCI")

    missionCommands.addCommandForGroup(groupID, "Request picture", rootPath, ewrs.onDemandMessage, groupID)
    missionCommands.addCommandForGroup(groupID, "Start updates", rootPath, ewrs.setGroupUpdates, { groupID, true })
    missionCommands.addCommandForGroup(groupID, "Stop updates", rootPath, ewrs.setGroupUpdates, { groupID, false })

    local measurementsSetPath = missionCommands.addSubMenuForGroup(groupID, "Set measurement units", rootPath)
    missionCommands.addCommandForGroup(groupID, "Set to imperial (feet, kts)", measurementsSetPath, ewrs.setGroupMeasurements, { groupID, "imperial" })
    missionCommands.addCommandForGroup(groupID, "Set to metric (meters, km/h)", measurementsSetPath, ewrs.setGroupMeasurements, { groupID, "metric" })
end

--SCRIPT INIT
ewrs.currentlyDetectedRedUnits = {}
ewrs.currentlyDetectedBlueUnits = {}
ewrs.redEwrUnits = {}
ewrs.blueEwrUnits = {}
ewrs.activePlayers = {}
ewrs.groupSettings = {}
ewrs.notAvailable = 999999
ewrs.lastRadarUnitsUpdateTime = nil
ewrs.lastDetectedTargetsUpdateTime = nil

env.info("EWRS LUA File Loaded ... OK")

--[[
TODO:
	- Add check on friendly picture to not give one if no AWACS / EWR units are active. Doesn't use radar info anyway. Maybe just leave it to help out people with SA? Feedback Please!!
	- Clean up functions and arguments from bogeyDope and friendly picture additions
	- Threat based filtering if theres interest.
]]
