local restartInfo = require("restartInfo")

local M = {}

function M.addMenu(playerGroup, restartHours)
    local infoMenu = MENU_GROUP:New(playerGroup, "Mission info")
    MENU_GROUP_COMMAND:New(playerGroup, "Time until restart", infoMenu, function()
        local secondsUntilRestart = restartInfo.getSecondsUntilRestart(os.date("*t"), restartHours)
        MESSAGE:New(string.format("The server will restart in %s", restartInfo.getSecondsAsString(secondsUntilRestart)), 5):ToGroup(playerGroup)
    end)
end

return M
