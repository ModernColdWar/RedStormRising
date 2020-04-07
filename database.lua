local sqlite3 = require("lsqlite3")
local utils = require("utils")

local M = {}

M.DB_FILENAME = "rsr.sqlite"

function M.openOrCreate()
    if M.instance == nil then
        M.instance = sqlite3.open(utils.getFilePath(M.DB_FILENAME), sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE)
    end
    return M.instance
end

function M.open()
    if M.instance == nil then
        local f = utils.getFilePath(M.DB_FILENAME)
        M.instance = sqlite3.open(f, sqlite3.OPEN_READWRITE)
    end
    return M.instance
end

function M.close()
    if M.instance ~= nil then
        M.instance:close()
    end
end

-- parses SQLite datetime to seconds since 1970
function M.toEpochSeconds(s)
    local y, m, d, hh, mm, ss = s:match("^(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)$")
    return os.time({ year = y, month = m, day = d, hour = hh, min = mm, sec = ss })
end

return M
