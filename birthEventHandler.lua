local restartInfo = require("restartInfo")

local M = {}

M.eventHandler = nil  -- constructed in onMissionStart

M.BIRTH_EVENTHANDLER = {
    ClassName = "BIRTH_EVENTHANDLER"
}

function M.BIRTH_EVENTHANDLER:New(restartHours)
    local _self = BASE:Inherit(self, EVENTHANDLER:New())
    _self.restartHours = restartHours
    return _self
end

function M.BIRTH_EVENTHANDLER:createMissionInfoMenu(event)
    if event.IniPlayerName then
        self:I("Adding mission info menu for " .. event.IniPlayerName)
        local playerGroup = event.IniGroup
        MENU_GROUP_COMMAND:New(playerGroup, "Time until restart", nil, function()
            local secondsUntilRestart = restartInfo.getSecondsUntilRestart(os.date("*t"), self.restartHours)
            MESSAGE:New(string.format("The mission will restart in %s", restartInfo.getSecondsAsString(secondsUntilRestart)), 5):ToGroup(playerGroup)
        end)
    end
end

function M.onMissionStart(restartHours)
    M.eventHandler = M.BIRTH_EVENTHANDLER:New(restartHours)
    M.eventHandler:HandleEvent(EVENTS.Birth, M.eventHandler.createMissionInfoMenu)
end

return M
