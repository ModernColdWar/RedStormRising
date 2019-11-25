local M = {}

local log = mist.Logger:new("HitEventHandler", "info")

function M.register()
    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.Hit)
    function M.eventHandler:OnEventHit(event)
        self:I({ event = event })
        if event.IniPlayerName == nil or event.TgtPlayerName == nil then
            return
        end
        if event.WeaponTypeName == nil then
            log:info("$1 hit $2", event.IniPlayerName, event.TgtPlayerName)
        else
            log:info("$1 hit $2 with $3", event.IniPlayerName, event.TgtPlayerName, event.WeaponTypeName)
        end
    end
end

return M
