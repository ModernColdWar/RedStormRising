local utils = require("utils")

local M = {}

local HIT_EVENT_HANDLER = {
    ClassName = "HIT_EVENTHANDLER"
}

function HIT_EVENT_HANDLER:New(hitMessageDelay)
    local _self = BASE:Inherit(self, EVENTHANDLER:New())
    _self.hitMessageDelay = hitMessageDelay
    _self.lastMessage = nil
    _self.lastMessageTime = 0
    return _self
end

M.eventHandler = nil -- constructed in onMissionStart

local function getUnitDesc(coalition, groupName, typeName)
    local ownerName = groupName ~= nil and utils.getPlayerNameFromGroupName(groupName) or nil
    local coalitionName = coalition ~= nil and utils.getSideName(coalition) .. " " or ""
    if ownerName == nil then
        return string.format("%s%s", coalitionName, typeName)
    else
        return string.format("%s's %s%s", ownerName, coalitionName, typeName)
    end
end

local function getPlayerDesc(coalition, groupName, typeName, playerName)
    return string.format("%s in %s", playerName, getUnitDesc(coalition, groupName, typeName))
end

function M.buildHitMessage(event)
    if event.IniPlayerName == nil and event.TgtPlayerName == nil then
        -- AI on AI; no interest
        return nil
    end
    local message = ''
    if event.IniPlayerName ~= nil then
        message = message .. getPlayerDesc(event.IniCoalition, event.IniGroupName, event.IniTypeName, event.IniPlayerName)
    else
        message = message .. getUnitDesc(event.IniCoalition, event.IniGroupName, event.IniTypeName)
    end
    message = message .. " hit "
    if event.TgtPlayerName ~= nil then
        message = message .. getPlayerDesc(event.TgtCoalition, event.TgtGroupName, event.TgtTypeName, event.TgtPlayerName)
    else
        message = message .. getUnitDesc(event.TgtCoalition, event.TgtGroupName, event.TgtTypeName)
    end

    if event.WeaponName ~= nil then
        message = message .. " with " .. event.WeaponName
    end

    if event.IniPlayerName ~= nil and event.TgtPlayerName ~= nil and event.IniCoalition == event.TgtCoalition then
        message = "FRIENDLY FIRE: " .. message
    end

    return message:gsub("^%l", string.upper)
end

function M.eventHandler:shouldSendMessage(message)
    -- only print the same message again after 5 seconds
    local time = timer.getTime()
    local shouldSend = message ~= self.lastMessage or time - self.lastMessageTime > 5
    self.lastMessage = message
    self.lastMessageTime = time
    return shouldSend
end

function M.eventHandler:onHit(event)
    local message = M.buildHitMessage(event)
    if message ~= nil then
        if self:shouldSendMessage(message) then
            self:I(message)
            if self.hitMessageDelay > 0 and not utils.startswith(message, "FRIENDLY FIRE: ") then
                timer.scheduleFunction(function(args)
                    trigger.action.outText(args[1], 10)
                end, { message }, timer.getTime() + self.hitMessageDelay)
            else
                trigger.action.outText(message, 10)
            end
        end
    end
end

function M.onMissionStart(hitMessageDelay)
    M.eventHandler = HIT_EVENT_HANDLER:New(hitMessageDelay)
    M.eventHandler:HandleEvent(EVENTS.Hit, M.eventHandler.onHit)
end

return M
