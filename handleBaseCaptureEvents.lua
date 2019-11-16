require("mist_4_3_74")
local utils = require("utils")

local log = mist.Logger:new("HandleBaseCaptureEvents", "info")

local baseCapturedEventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.BaseCaptured)

function baseCapturedEventHandler:OnEventBaseCaptured(event)
    self:I({ event = event })
    local sideName = utils.getSideName(event.IniCoalition)
    local message = event.PlaceName .. " has been captured by a " .. sideName .. " " .. event.IniTypeName
    log:info(message)
    trigger.action.outText(message, 10)
end
