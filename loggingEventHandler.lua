local M = {}

M.eventHandler = EVENTHANDLER:New()

function M.eventHandler:logEvent(event)
    self:I({ event = event })
end

function M.eventHandler:onHit(event)
    self:logEvent(event)
    if event.IniPlayerName == nil or event.TgtPlayerName == nil then
        return
    end
    if event.WeaponTypeName == nil then
        log:info("$1 hit $2", event.IniPlayerName, event.TgtPlayerName)
    else
        log:info("$1 hit $2 with $3", event.IniPlayerName, event.TgtPlayerName, event.WeaponTypeName)
    end
end

function M.register()
    M.eventHandler:HandleEvent(EVENTS.Takeoff, M.eventHandler.logEvent)
    M.eventHandler:HandleEvent(EVENTS.Land, M.eventHandler.logEvent)
    M.eventHandler:HandleEvent(EVENTS.Hit, M.eventHandler.onHit)
end

return M
