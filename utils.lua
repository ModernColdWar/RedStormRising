require("mist_4_3_74")

local log = mist.Logger:new("utils", "info")

local M = {}

local function runningInDcs()
    -- luacheck: globals dcsStub
    return dcsStub == nil
end

function M.getFilePath(filename)
    if runningInDcs() then
        return lfs.writedir() .. [[Scripts\RSR\]] .. filename
    else
        return filename
    end
end

local sideLookupTable = {
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

function M.getSideName(side)
    return sideLookupTable.bySide[side]
end

function M.getSide(sideName)
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

--mr: copied from MIST
-- acc the accuracy of each easting/northing. Can be: 0, 1, 2, 3, 4, or 5.
-- added -1 as additional accuracy setting to remove UTMZone and condense to simple grid e.g. MN61
function M.tostringMGRSnoUTM(MGRS, acc)
    if acc == -1 then
        local _gridAcc = 1
        return MGRS.MGRSDigraph .. string.format('%0' .. _gridAcc .. 'd', mist.utils.round(MGRS.Easting / (10 ^ (5 - _gridAcc)), 0))
                .. string.format('%0' .. _gridAcc .. 'd', mist.utils.round(MGRS.Northing / (10 ^ (5 - _gridAcc)), 0))
    end

    if acc == 0 then
        return MGRS.MGRSDigraph
    else
        return MGRS.MGRSDigraph .. ' ' .. string.format('%0' .. acc .. 'd', mist.utils.round(MGRS.Easting / (10 ^ (5 - acc)), 0))
                .. ' ' .. string.format('%0' .. acc .. 'd', mist.utils.round(MGRS.Northing / (10 ^ (5 - acc)), 0))
    end
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
    for _k, _b in pairs(baseOwnership.FARPs.red) do
        if _b == _FARPname then
            _bOFARPside = "red"
            break
        end
    end

    if _bOFARPside == "FARPnotFound" then
        for _k, _b in pairs(baseOwnership.FARPs.blue) do
            if _b == _FARPname then
                _bOFARPside = "blue"
                break
            end
        end
    end

    if _bOFARPside == "FARPnotFound" then
        for _k, _b in pairs(baseOwnership.FARPs.neutral) do
            if _b == _FARPname then
                _bOFARPside = "neutral"
                break
            end
        end
    end

    if _bOFARPside == "FARPnotFound" then
        --log:error("$1 FARP not found in 'baseOwnership.FARPs' sides.",_FARPname)
    end
    return _bOFARPside
end
function M.getCurrABside (_ABname)
    local _bOABside = "ABnotFound"
    for _k, _b in pairs(baseOwnership.Airbases.red) do
        if _b == _ABname then
            _bOABside = "red"
            break
        end
    end

    if _bOABside == "ABnotFound" then
        for _k, _b in pairs(baseOwnership.Airbases.blue) do
            if _b == _ABname then
                _bOABside = "blue"
                break
            end
        end
    end

    if _bOABside == "ABnotFound" then
        for _k, _b in pairs(baseOwnership.Airbases.neutral) do
            if _b == _ABname then
                _bOABside = "neutral"
                break
            end
        end
    end

    if _bOABside == "ABnotFound" then
        --log:error("$1 Airbase not found in 'baseOwnership.Airbases' sides.",_ABname)
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

    --log:info("_RSRbaseCaptureZoneName: $1",_RSRbaseCaptureZoneName)

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
            log:error("RSR MIZ SETUP: $1 $2 Trigger Zone color not changed from white. Setting as neutral", _RSRbaseCaptureZoneName, inspect(_zoneColor, { newline = " ", indent = "" }))
        elseif _whiteInitZoneCheck > 1 then
            log:error("RSR MIZ SETUP: $1 $2 Trigger Zone color not correctly set to only red, blue or green. Setting as neutral", _RSRbaseCaptureZoneName, inspect(_zoneColor, { newline = " ", indent = "" }))
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
            log:error("RSR MIZ SETUP: $1 Trigger Zone color $2 not chnaged from white to only red or blue. Setting 'when owned by requirement' to neutral.  Carriers will NEVER activate.", _zoneName, inspect(_zoneColor, { newline = " ", indent = "" }))
        elseif _whiteInitZoneCheck > 1 then
            log:error("RSR MIZ SETUP: $1 Trigger Zone color $2 not correctly set to only red or blue. Setting 'when owned by requirement' to neutral.  Carriers will NEVER activate.", _zoneName, inspect(_zoneColor, { newline = " ", indent = "" }))
        end
        _whenBaseOwnedBySide = "neutral"
    end
    return { _carrierGroup, _RSRcarrierActivateForBase, _whenBaseOwnedBySide }
end

return M
