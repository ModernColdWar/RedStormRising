require("mist_4_3_74")

local M = {}

local log = mist.Logger:new("Utils", "info")

function M.runningInDcs()
    -- luacheck: globals dcsStub
    return dcsStub == nil
end

function M.getFilePath(filename)
    if M.runningInDcs() then
        return lfs.writedir() .. [[Scripts\RSR\]] .. filename
    else
        return filename
    end
end

local function getBackupFilename(filename)
    local beforeExtension = filename:match("^(.+)%..+$")
    local extension = filename:match("^.+(%..+)$")
    return beforeExtension .. "-backup" .. extension
end

function M.createBackup(filename)
    local backupFilename = getBackupFilename(filename)
    log:info("Backing up $1 to $2", filename, backupFilename)
    local backup = io.open(backupFilename, "w")
    local infile = io.open(filename, "r")
    backup:write(infile:read("*all"))
    infile:close()
    backup:close()
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

return M