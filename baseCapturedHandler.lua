require("mist_4_3_74")
local bases = require("bases")
local utils = require("utils")
local state = require("state")

local M = {}

local log = mist.Logger:new("BaseCapturedHandler", "info")

function M.register()
    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.BaseCaptured)
    function M.eventHandler:OnEventBaseCaptured(event)
        self:I({ event = event })
        local baseName = event.PlaceName
        local sideName = utils.getSideName(event.IniCoalition)
        log:info("Base captured event for $1 captured by $2", baseName, sideName)
        local changedSide = state.setBaseOwner(baseName, sideName)
        if changedSide == false then
            log:info("Ignoring capture event for $1: no change of side ($2)", baseName, sideName)
            return
        end
        local message = baseName .. " has been captured by a " .. sideName .. " " .. event.IniTypeName
        self:I(message)
        trigger.action.outText(message, 10)
        bases.configureForSide(baseName, sideName)
    end
end

return M