local restartInfo = require("restartInfo")

local M = {}

M.eventHandler = nil  -- constructed in onMissionStart

M.BIRTH_EVENTHANDLER = {
    ClassName = "BIRTH_EVENTHANDLER"
}

function M.BIRTH_EVENTHANDLER:New(restartHours)
    local _self = BASE:Inherit(self, EVENTHANDLER:New())
    _self.restartHours = restartHours
    _self:HandleEvent(EVENTS.Birth, _self._OnBirth)
    return _self
end

function M.BIRTH_EVENTHANDLER:_OnBirth(event)
    self:_AddMenus(event)
end

function M.BIRTH_EVENTHANDLER:_AddMenus(event)
    if event.IniPlayerName then
        local playerGroup = event.IniGroup
        if playerGroup then
            self:I("Adding menus for " .. event.IniPlayerName)
            self:_AddTimeUntilRestart(playerGroup)
        end
    end
end

function M.BIRTH_EVENTHANDLER:_AddTimeUntilRestart(playerGroup)
    MENU_GROUP_COMMAND:New(playerGroup, "Time until restart", nil, function()
        local secondsUntilRestart = restartInfo.getSecondsUntilRestart(os.date("*t"), self.restartHours)
        MESSAGE:New(string.format("The server will restart in %s", restartInfo.getSecondsAsString(secondsUntilRestart)), 5):ToGroup(playerGroup)
    end)
end

function M.onMissionStart(restartHours)
    M.eventHandler = M.BIRTH_EVENTHANDLER:New(restartHours)
end

return M
