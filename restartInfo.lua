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

function M.getSecondsUntilTimeBeforeRestart(now, restartHours, secondsBeforeRestart)
    local secondsUnitRestart = M.getSecondsUntilRestart(now, restartHours)
    local schedulerTime = secondsUnitRestart - secondsBeforeRestart
    if schedulerTime <= 0 then
        -- don't print out any message that's been missed
        return nil
    end
    return schedulerTime
end

local function sendRestartWarning(args)
    local minutesUntilRestart = args[1]
    local plural = "s"
    if minutesUntilRestart == 1 then
        plural = ""
    end
    trigger.action.outText("[ALL] The server will restart in " .. minutesUntilRestart .. " minute" .. plural, 15)
end

function M.onMissionStart(restartHours, restartWarningMinutes)
    for _, minutesUntilRestart in pairs(restartWarningMinutes) do
        local schedulerTime = M.getSecondsUntilTimeBeforeRestart(os.date("*t"), restartHours, minutesUntilRestart * 60)
        if schedulerTime ~= nil then
            timer.scheduleFunction(sendRestartWarning, { minutesUntilRestart }, timer.getTime() + schedulerTime)
        end
    end
end

return M
