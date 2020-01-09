local utils = require("utils")

local M = {}

M.eventHandler = EVENTHANDLER:New()

M.lastMessage = nil
M.lastMessageTime = 0

function M.eventHandler:logEvent(event)
    self:I({ event = event })
end

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

function M.eventHandler:onHit(event)
    -- self:logEvent(event)
    local message = M.buildHitMessage(event)
    if message ~= nil then
        local time = timer.getTime()
        -- only print the same message again after 5 seconds
        if message ~= M.lastMessage or time - M.lastMessageTime > 5 then
            self:I(message)
            if M.hitMessageDelay > 0 and not utils.startswith(message, "FRIENDLY FIRE: ") then
                timer.scheduleFunction(function(args)
                    trigger.action.outText(args[1], 10)
                end, { message }, timer.getTime() + M.hitMessageDelay)
            else
                trigger.action.outText(message, 10)
            end
            M.lastMessage = message
            M.lastMessageTime = time
        end
    end
end

function M.register(hitMessageDelay)
    M.hitMessageDelay = hitMessageDelay
    M.eventHandler:HandleEvent(EVENTS.Hit, M.eventHandler.onHit)
end

return M
