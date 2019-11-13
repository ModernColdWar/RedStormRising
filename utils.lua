M = {}

function M.runningInDcs()
    return dcsStub == nil
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