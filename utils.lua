M = {}

function M.runningInDcs()
    return dcsStub == nil
end

--- Returns true if the filename exists on disk, else false
function M.fileExists(filename)
    local f = io.open(filename, "r")
    if f == nil then
        return false
    else
        f:close()
        return true
    end
end

function M.getFilePath(filename)
    if M.runningInDcs() then
        return lfs.writedir() .. [[Scripts\RSR\]] .. filename
    else
        return filename
    end
end

function M.createBackup(filename)
    local backupFilename = filename .. ".bak"
    log:info("Backing up $1 to $2", filename, backupFilename)
    local backup = io.open(backupFilename, "w")
    local infile = io.open(filename, "r")
    backup:write(infile:read("*all"))
    infile:close()
    backup:close()
end

return M