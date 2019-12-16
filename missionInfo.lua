local M = {}

function M.getNextRestartHour(currentHour, restartHours)
    for _, restartHour in ipairs(restartHours) do
        if restartHour > currentHour then
            return restartHour
        end
    end
    return restartHours[1]
end

function M.getSecondsUntilRestart(now, restartHours)
    local restartHour = M.getNextRestartHour(now.hour, restartHours)
    local restartDate = os.time({ year = now.year, month = now.month, day = now.day, hour = restartHour })
    local seconds = restartDate - os.time(now)
    if seconds <= 0 then
        seconds = seconds + 86400
    end
    return seconds
end

function M.getSecondsAsString(seconds)
    local remSeconds = seconds
    local hours = math.floor(seconds / 3600)
    remSeconds = remSeconds - (hours * 3600)
    local minutes = math.floor(remSeconds / 60)
    remSeconds = seconds - (minutes * 60) - (hours * 3600)
    return string.format("%02d:%02d:%02d", hours, minutes, remSeconds)
end

M.eventHandler = EVENTHANDLER:New()

function M.eventHandler:createMissionInfoMenu(event)
    if event.IniPlayerName then
        self:I("Adding mission info menu for " .. event.IniPlayerName)
        local playerGroup = event.IniGroup
        MENU_GROUP_COMMAND:New(playerGroup, "Time until restart", nil, function()
            local secondsUntilRestart = M.getSecondsUntilRestart(os.date("*t"), M._restartHours)
            MESSAGE:New(string.format("The mission will restart in %s", M.getSecondsAsString(secondsUntilRestart)), 5):ToGroup(playerGroup)
        end)
    end
end

function M.onMissionStart(rsrConfig)
    M._restartHours = rsrConfig.restartHours
    M.eventHandler:HandleEvent(EVENTS.Birth, M.eventHandler.createMissionInfoMenu)
end

return M