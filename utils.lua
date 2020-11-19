local logging = require("logging")
local log = logging.Logger:new("utils")

local M = {}

function M.getFilePath(filename)
    if env ~= nil then
        return lfs.writedir() .. [[Scripts\RSR\]] .. filename
    else
        return filename
    end
end

local sideLookupTable

local function populateSideLookupTable()
    if sideLookupTable ~= nil then
        return
    end
    sideLookupTable = {
        bySide = {
            [coalition.side.RED] = "red",
            [coalition.side.BLUE] = "blue",
            [coalition.side.NEUTRAL] = "neutral",
        },
        byName = {
            red = coalition.side.RED,
            blue = coalition.side.BLUE,
            neutral = coalition.side.NEUTRAL,
        }
    }
end

function M.getSideName(side)
    populateSideLookupTable()
    return sideLookupTable.bySide[side]
end

function M.getSide(sideName)
    populateSideLookupTable()
    return sideLookupTable.byName[sideName]
end

function M.startswith(string, prefix)
    if string:sub(1, #prefix) == prefix then
        return true
    end
    return false
end

local function split(string, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string:gsub(pattern, function(c)
        fields[#fields + 1] = c
    end)
    return fields
end

-- Matches a base name against a prefix
-- is fairly generous in that you only need the distinguishing prefix on the group
-- with each word being treated independently
function M.matchesBaseName(baseName, prefix)
    if prefix == nil then
        return false
    end
    if M.startswith(baseName, prefix) then
        return true
    end

    -- special case for typos!
    if prefix == "Sukumi" and baseName == "Sukhumi-Babushara" then
        return true
    end

    local baseNameParts = split(baseName, "-")
    local prefixParts = split(prefix, "-")

    if #baseNameParts < #prefixParts then
        return false
    end
    for i = 1, #prefixParts do
        local baseNamePart = baseNameParts[i]
        local groupPrefixPart = prefixParts[i]
        if M.startswith(baseNamePart, groupPrefixPart) == false then
            return false
        end
    end
    return true
end

function M.getPlayerNameFromGroupName(groupName)
    -- match the inside of the part in parentheses at the end of the group name if present
    -- this is the other half of the _groupName construction in ctld.spawnCrateGroup
    return string.match(groupName, "%((.+)%)$")
end

function M.getBaseAndSideNamesFromGroupName(groupName)
    local blueIndex = string.find(groupName:lower(), " blue ")
    local redIndex = string.find(groupName:lower(), " red ")
    if blueIndex ~= nil then
        return groupName:sub(1, blueIndex - 1), "blue"
    end
    if redIndex ~= nil then
        return groupName:sub(1, redIndex - 1), "red"
    end
end

--extract base name from first character of zone name to first character of suffix - 1 (idx - 1, most likely white space)
function M.getBaseNameFromZoneName(zoneName, suffix)
    --mr: will LUA wildcard * work with when passed with suffix?
    -- e.g. logisticsManager.lua: utils.getBaseNameFromZoneName(logisticsZoneName, "RSRlogisticsZone*") = "MM75 RSRlogisticsZone 01" ?
    local idx = zoneName:lower():find(" " .. suffix:lower())
    if idx == nil then
        return nil
    end
    return zoneName:sub(1, idx - 1)
end

function M.getRestartHours(firstRestart, missionDuration)
    local restartHours = {}
    local nextRestart = firstRestart
    while nextRestart < 24 do
        table.insert(restartHours, nextRestart)
        nextRestart = nextRestart + missionDuration
    end
    return restartHours
end

function M.round(number, roundTo)
    return math.floor((number + 0.5 * roundTo) / roundTo) * roundTo
end

-- MGRS coordinate with no UTM and only 10km square e.g. LP49
function M.posToMapGrid(position)

    -- .p as coord.LOtoLL requires x,y,z format
    local _MGRStable = coord.LLtoMGRS(coord.LOtoLL(position.p))
    --log:info("_MGRStable: $1",_MGRStable)

    -- DCS drops leading 0 for 10km map grids
    -- e.g. Vazani @ NM00: MGRStable = { Easting = 2566, MGRSDigraph = "NM", Northing = 9426, UTMZone = "38T" }
    local _easting10kmGrid
    if string.len(_MGRStable.Easting) < 5 then
        _easting10kmGrid = 0
    else
        _easting10kmGrid = string.match(_MGRStable.Easting, "(%d)%d%d%d%d$")
    end

    local _northing10kmGrid
    if string.len(_MGRStable.Northing) < 5 then
        _northing10kmGrid = 0
    else
        _northing10kmGrid = string.match(_MGRStable.Northing, "(%d)%d%d%d%d$")
    end

    -- first digit of 5 digit MGRS Easting and Northing more accurate for 10km grid than MIST method of rounding-up MGRS coordinates
    local _MapGrid = _MGRStable.MGRSDigraph .. _easting10kmGrid .. _northing10kmGrid
    --log:info("_MapGrid: $1",_MapGrid)

    return _MapGrid
end

-- based on ctld.isInfantry
local function isInfantry(unit)
    local typeName = string.lower(unit:getTypeName() .. "")
    local soldierType = { "infantry", "paratrooper", "stinger", "manpad", "mortar" }

    for _, value in pairs(soldierType) do
        if string.match(typeName, value) then
            return true
        end
    end

    return false

end

function M.setGroupControllerOptions(group)
    -- delayed 2 second to work around bug (as per ctld.addEWRTask and ctld.orderGroupToMoveToPoint)
    timer.scheduleFunction(function(_group)
        -- make sure nothing "bad" happened in time since spawn
        if not _group:isExist() or #_group:getUnits() < 1 then
            return
        end
        local controller = _group:getController()
        controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
        controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
        controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, 0)
        local leader = group:getUnit(1)
        local position = leader:getPoint()
        local formation = isInfantry(leader) and AI.Task.VehicleFormation.CONE or AI.Task.VehicleFormation.OFF_ROAD
        local mission = {
            id = 'Mission',
            params = {
                route = {
                    points = {
                        [1] = {
                            action = formation,
                            x = position.x,
                            y = position.z,
                            type = 'Turning Point'
                        }
                    }
                },
            },
        }
        controller:setTask(mission)
        --env.info("Set controller options for " .. _group:getName())
    end, group, timer.getTime() + 2)
end


--searches for FARP name in baseOwnership nested table to determine currently assigned side
--mr: find more efficient way to transvere nested table
function M.getCurrFARPside (_FARPname)
    local _bOFARPside = "FARPnotFound"
    for _, _b in pairs(baseOwnership.FARPs.red) do
        if _b == _FARPname then
            _bOFARPside = "red"
            break
        end
    end

    if _bOFARPside == "FARPnotFound" then
        for _, _b in pairs(baseOwnership.FARPs.blue) do
            if _b == _FARPname then
                _bOFARPside = "blue"
                break
            end
        end
    end

    if _bOFARPside == "FARPnotFound" then
        --log:error("$1 FARP not found in 'baseOwnership.FARPs' sides.",_FARPname)
        for _, _b in pairs(baseOwnership.FARPs.neutral) do
            if _b == _FARPname then
                _bOFARPside = "neutral"
                break
            end
        end
    end

    return _bOFARPside
end

function M.getCurrABside (_ABname)
    local _bOABside = "ABnotFound"
    for _, _b in pairs(baseOwnership.Airbases.red) do
        if _b == _ABname then
            _bOABside = "red"
            break
        end
    end

    if _bOABside == "ABnotFound" then
        for _, _b in pairs(baseOwnership.Airbases.blue) do
            if _b == _ABname then
                _bOABside = "blue"
                break
            end
        end
    end

    if _bOABside == "ABnotFound" then
        --log:error("$1 Airbase not found in 'baseOwnership.Airbases' sides.",_ABname)
        for _, _b in pairs(baseOwnership.Airbases.neutral) do
            if _b == _ABname then
                _bOABside = "neutral"
                break
            end
        end
    end

    return _bOABside
end

function M.removeFARPownership (_FARPname)
    local _FARPremoved = false
    for _k, _b in pairs(baseOwnership.FARPs.red) do
        if _b == _FARPname then
            table.remove(baseOwnership.FARPs.red, _k)
            _FARPremoved = true
            break
        end
    end

    if not _FARPremoved then
        for _k, _b in pairs(baseOwnership.FARPs.blue) do
            if _b == _FARPname then
                table.remove(baseOwnership.FARPs.blue, _k)
                _FARPremoved = true
                break
            end
        end
    end

    if not _FARPremoved then
        for _k, _b in pairs(baseOwnership.FARPs.neutral) do
            if _b == _FARPname then
                table.remove(baseOwnership.FARPs.neutral, _k)
                _FARPremoved = true
                break
            end
        end
    end

    if not _FARPremoved then
        log:error("$1 FARP not found in 'baseOwnership.FARPs' sides. No ownership record to remove.", _FARPname)
    end
end

function M.removeABownership (_ABname)
    local _ABremoved = false
    for _k, _b in pairs(baseOwnership.Airbases.red) do
        if _b == _ABname then
            table.remove(baseOwnership.Airbases.red, _k)
            _ABremoved = true
            break
        end
    end

    if not _ABremoved then
        for _k, _b in pairs(baseOwnership.Airbases.blue) do
            if _b == _ABname then
                table.remove(baseOwnership.Airbases.blue, _k)
                _ABremoved = true
                break
            end
        end
    end

    if not _ABremoved then
        for _k, _b in pairs(baseOwnership.Airbases.neutral) do
            if _b == _ABname then
                table.remove(baseOwnership.Airbases.neutral, _k)
                _ABremoved = true
                break
            end
        end
    end

    if not _ABremoved then
        log:error("$1 Airbase not found in 'baseOwnership.Airbases' sides. No ownership record to remove.", _ABname)
    end
end

function M.baseCaptureZoneToNameSideType(_zone)
    local _zoneName = _zone.name
    --"MM75 RSRbaseCaptureZone FARP" = "MM75" i.e. from whitepace and RSR up
    local _RSRbaseCaptureZoneName = string.match(_zoneName, ("^(.+)%sRSR"))

    log:info("_RSRbaseCaptureZoneName: $1",_RSRbaseCaptureZoneName)

    --"MM75 RSRbaseCaptureZone FARP" = "FARP"
    local _baseType = string.match(_zoneName, ("%w+$"))
    local _baseTypes = ""

    if _baseType == nil then
        log:error("RSR MIZ SETUP: $1 RSRbaseCaptureZone Trigger Zone name does not contain 'Airbase' or 'FARP' e.g. 'MM75 RSRbaseCaptureZone FARP'", _RSRbaseCaptureZoneName)
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
    elseif _zoneColor[2] == 1 then
        --green
        _baseSide = "neutral"
        _whiteInitZoneCheck = _whiteInitZoneCheck + 1
    end

    if _baseSide == "ERROR" then
        if _whiteInitZoneCheck == 3 then
            log:error("RSR MIZ SETUP: $1 $2 Trigger Zone color not changed from white. Setting as neutral", _RSRbaseCaptureZoneName, _zoneColor)
        elseif _whiteInitZoneCheck > 1 then
            log:error("RSR MIZ SETUP: $1 $2 Trigger Zone color not correctly set to only red, blue or green. Setting as neutral", _RSRbaseCaptureZoneName, _zoneColor)
        end
        _baseSide = "neutral"
    end
    return { _RSRbaseCaptureZoneName, _baseSide, _baseTypes }
end

function M.carrierActivateForBaseWhenOwnedBySide(_zone)
    local _zoneName = _zone.name
    --"Novorossiysk RSRcarrierActivate Group1" = "Novorossiysk" i.e. from whitepace and RSR up
    local _RSRcarrierActivateForBase = string.match(_zoneName, ("^(.+)%sRSR"))

    --log:info("_RSRcarrierActivateForBase: $1",_RSRcarrierActivateForBase)

    --"Novorossiysk RSRcarrierActivate Group1" = "Group1"
    local _carrierGroup = string.match(_zoneName, ("%w+$"))

    local _zoneColor = _zone.color
    local _whenBaseOwnedBySide = "ERROR"

    local _whiteInitZoneCheck = 0
    if _zoneColor[1] == 1 then
        _whenBaseOwnedBySide = "red"
        _whiteInitZoneCheck = _whiteInitZoneCheck + 1
    elseif _zoneColor[3] == 1 then
        _whenBaseOwnedBySide = "blue"
        _whiteInitZoneCheck = _whiteInitZoneCheck + 1
    elseif _zoneColor[2] == 1 then
        --green
        _whenBaseOwnedBySide = "neutral"
        _whiteInitZoneCheck = _whiteInitZoneCheck + 1
    end

    if _whenBaseOwnedBySide == "ERROR" then
        if _whiteInitZoneCheck == 3 then
            log:error("RSR MIZ SETUP: $1 Trigger Zone color $2 not chnaged from white to only red or blue. Setting 'when owned by requirement' to neutral.  Carriers will NEVER activate.", _zoneName, _zoneColor)
        elseif _whiteInitZoneCheck > 1 then
            log:error("RSR MIZ SETUP: $1 Trigger Zone color $2 not correctly set to only red or blue. Setting 'when owned by requirement' to neutral.  Carriers will NEVER activate.", _zoneName, _zoneColor)
        end
        _whenBaseOwnedBySide = "neutral"
    end
    return { _carrierGroup, _RSRcarrierActivateForBase, _whenBaseOwnedBySide }
end

-- will check if LC alive not just nil i.e. StaticObject.getLife() and clean-up list if not alive
function M.getAliveLogisticsCentreforBase(_airbaseORfarpORfob)

    local _aliveLCobj
    local _LCfound = false
    local _foundLCbaseRef = "NoBase" --debug
    local _foundLCsideRef = "NoSide" --debug
    for _refLCsideName, _baseTable in pairs(ctld.logisticCentreObjects) do
        for _refLCbaseName, _LCobj in pairs(_baseTable) do
            if _refLCbaseName == _airbaseORfarpORfob then

                --log:info("_refLCbaseName: $1, _LCobj: $2",_refLCbaseName, _LCobj)

                if _LCobj ~= nil then

                    if StaticObject.getLife(_LCobj) == 0 then
                        --10000 = starting command centre static object life
                        ctld.logisticCentreObjects[_refLCsideName][_refLCbaseName] = nil
                        local _LCmarkerID = ctld.logisticCentreMarkerID[_refLCsideName][_refLCbaseName]
                        trigger.action.removeMark(_LCmarkerID)

                    else
                        if _LCfound then
                            -- should not occur
                            log:error("DUPLICATE LC record: _foundLCbaseRef: $1, _foundLCsideRef: $2, _refLCbaseName: $3, _refLCsideName: 4", _foundLCbaseRef, _foundLCsideRef, _refLCbaseName, _refLCsideName)
                        end

                        _aliveLCobj = _LCobj

                        --debug
                        _LCfound = true
                        _foundLCbaseRef = _refLCbaseName
                        _foundLCsideRef = _refLCsideName

                        local _LCname = _LCobj:getName()
                        --log:info("_LCname: $1",_LCname)

                        --"Krymsk Logistics Centre #001 red" = "red"
                        local _derivedLCsideName = string.match(_LCname, ("%w+$"))

                        --"Sochi Logistics Centre #001 red" = "Sochi" i.e. from whitepace and 'Log' up
                        local _derivedLCbaseNameOrGrid = string.match(_LCname, ("^(.+)%sLog"))

                        -- run checks
                        if _refLCsideName ~= _derivedLCsideName then
                            log:error("Reference LC side in ctld.logisticCentreObjects (_refLCsideName: $1) and derived LC side by name (_derivedLCsideName: $2) mistmatch", _refLCsideName, _derivedLCsideName)
                        end

                        if _airbaseORfarpORfob ~= _derivedLCbaseNameOrGrid then
                            log:error("Passed LC base (_airbaseORfarpORfob: $1) and derived base from LC name (_derivedLCbaseNameOrGrid: $2) mistmatch", _refLCsideName, _derivedLCsideName)
                        end
                    end
                end
            end
        end
    end
    return _aliveLCobj
end

return M