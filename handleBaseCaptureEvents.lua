require("mist_4_3_74")
local utils = require("utils")
local slotBlocker = require("slotBlocker")
local pickupZoneManager = require("pickupZoneManager")

baseCapturedEventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.BaseCaptured)

function baseCapturedEventHandler:OnEventBaseCaptured(event)
    self:I({ event = event })
    local baseName = event.PlaceName
    local sideName = utils.getSideName(event.IniCoalition)
    local message = baseName .. " has been captured by a " .. sideName .. " " .. event.IniTypeName
    self:I(message)
    trigger.action.outText(message, 10)
    slotBlocker.configureSlotsForBase(baseName, sideName)
    pickupZoneManager.configurePickupZonesForBase(baseName, sideName)
end
