require("mist_4_3_74")

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

function M.getBaseNameFromZoneName(zoneName, suffix)
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
		return MGRS.MGRSDigraph .. string.format('%0' .. _gridAcc .. 'd', mist.utils.round(MGRS.Easting/(10^(5-_gridAcc)), 0))
		.. string.format('%0' .. _gridAcc .. 'd', mist.utils.round(MGRS.Northing/(10^(5-_gridAcc)), 0))
	end
	
	if acc == 0 then
		return MGRS.MGRSDigraph
	else
		return MGRS.MGRSDigraph .. ' ' .. string.format('%0' .. acc .. 'd', mist.utils.round(MGRS.Easting/(10^(5-acc)), 0))
		.. ' ' .. string.format('%0' .. acc .. 'd', mist.utils.round(MGRS.Northing/(10^(5-acc)), 0))
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
        env.info("Set controller options for " .. _group:getName())
    end, group, timer.getTime() + 2)
end

--searches for FOB name in baseOwnership nested table to determine currently assigned side
--mr: find more efficient way to transvere nested table

function M.getCurrFOBside (_FOBname)
	local _bOFOBside = "ERROR"
	for _k, _b in pairs(baseOwnership.FOBs.red) do
	  if _b == _FOBname then
		_bOFOBside = "red"
		break
	  end
	end

	if _bOFOBside == "ERROR" then
		for _k, _b in pairs(baseOwnership.FOBs.blue) do
		  if _b == _FOBname then
			_bOFOBside = "blue"
			break
		  end
		end
	end
	
	if _bOFOBside == "ERROR" then
		for _k, _b in pairs(baseOwnership.FOBs.neutral) do
		  if _b == _FOBname then
			_bOFOBside = "neutral"
			break
		  end
		end
	end
	
	if _bOFOBside == "ERROR" then 
		log=error("$1 FOB not found in 'baseOwnership.FOBs' sides. Reporting as neutral to allow contested check.",_FOBname)
		_bOFOBside = "neutral"
	end
	return _bOFOBside
end	

return M
