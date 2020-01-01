require("mist_4_3_74")

local M = {}

local log = mist.Logger:new("Utils", "info")

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

function M.getBackupFilename(filename)
    local beforeExtension = filename:match("^(.+)%..+$")
    local extension = filename:match("^.+(%..+)$")
    return beforeExtension .. "-backup" .. extension
end

function M.createBackup(filename)
    if UTILS.FileExists(filename) then
        local backupFilename = M.getBackupFilename(filename)
        log:info("Backing up $1 to $2", filename, backupFilename)
        local backup = io.open(backupFilename, "w")
        local infile = io.open(filename, "r")
        backup:write(infile:read("*all"))
        infile:close()
        backup:close()
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

return M