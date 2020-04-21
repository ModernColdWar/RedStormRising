local utils = require("utils")
local logging = require("logging")
local log = logging.Logger:new("hitEventHandler")

local M = {}

M.eventHandler = nil -- constructed in onMissionStart

M.HIT_EVENTHANDLER = {
    ClassName = "HIT_EVENTHANDLER"
}

function M.HIT_EVENTHANDLER:New(hitMessageDelay)
    local _self = BASE:Inherit(self, EVENTHANDLER:New())
    _self.hitMessageDelay = hitMessageDelay
    _self.sentMessages = {}
    return _self
end

function M.HIT_EVENTHANDLER:shouldSendMessage(message)
    -- only print the same message again after 5 seconds
    local time = timer.getTime()
    local lastSentTime = self.sentMessages[message]
    local shouldSend = lastSentTime == nil or time - lastSentTime > 5
    self.sentMessages[message] = time
    return shouldSend
end
--[[
	from Moose.lua line #6232
	-- @field DCS#Unit initiator (UNIT/STATIC/SCENERY) The initiating @{DCS#Unit} or @{DCS#StaticObject}.
	-- @field DCS#Object.Category IniObjectCategory (UNIT/STATIC/SCENERY) The initiator object category ( Object.Category.UNIT or Object.Category.STATIC ).
	-- @field DCS#Unit IniDCSUnit (UNIT/STATIC) The initiating @{DCS#Unit} or @{DCS#StaticObject}.
	-- @field #string IniDCSUnitName (UNIT/STATIC) The initiating Unit name.
	-- @field Wrapper.Unit#UNIT IniUnit (UNIT/STATIC) The initiating MOOSE wrapper @{Wrapper.Unit#UNIT} of the initiator Unit object.
	-- @field #string IniUnitName (UNIT/STATIC) The initiating UNIT name (same as IniDCSUnitName).
	-- @field DCS#Group IniDCSGroup (UNIT) The initiating {DCSGroup#Group}.
	-- @field #string IniDCSGroupName (UNIT) The initiating Group name.
	-- @field Wrapper.Group#GROUP IniGroup (UNIT) The initiating MOOSE wrapper @{Wrapper.Group#GROUP} of the initiator Group object.
	-- @field #string IniGroupName UNIT) The initiating GROUP name (same as IniDCSGroupName).
	-- @field #string IniPlayerName (UNIT) The name of the initiating player in case the Unit is a client or player slot.
	-- @field DCS#coalition.side IniCoalition (UNIT) The coalition of the initiator.
	-- @field DCS#Unit.Category IniCategory (UNIT) The category of the initiator.
	-- @field #string IniTypeName (UNIT) The type name of the initiator.
	-- 
	-- @field DCS#Unit target (UNIT/STATIC) The target @{DCS#Unit} or @{DCS#StaticObject}.
	-- @field DCS#Object.Category TgtObjectCategory (UNIT/STATIC) The target object category ( Object.Category.UNIT or Object.Category.STATIC ).
	-- @field DCS#Unit TgtDCSUnit (UNIT/STATIC) The target @{DCS#Unit} or @{DCS#StaticObject}.
	-- @field #string TgtDCSUnitName (UNIT/STATIC) The target Unit name.
	-- @field Wrapper.Unit#UNIT TgtUnit (UNIT/STATIC) The target MOOSE wrapper @{Wrapper.Unit#UNIT} of the target Unit object.
	-- @field #string TgtUnitName (UNIT/STATIC) The target UNIT name (same as TgtDCSUnitName).
	-- @field DCS#Group TgtDCSGroup (UNIT) The target {DCSGroup#Group}.
	-- @field #string TgtDCSGroupName (UNIT) The target Group name.
	-- @field Wrapper.Group#GROUP TgtGroup (UNIT) The target MOOSE wrapper @{Wrapper.Group#GROUP} of the target Group object.
	-- @field #string TgtGroupName (UNIT) The target GROUP name (same as TgtDCSGroupName).
	-- @field #string TgtPlayerName (UNIT) The name of the target player in case the Unit is a client or player slot.
	-- @field DCS#coalition.side TgtCoalition (UNIT) The coalition of the target.
	-- @field DCS#Unit.Category TgtCategory (UNIT) The category of the target.
	-- @field #string TgtTypeName (UNIT) The type name of the target.
--]]


function M.HIT_EVENTHANDLER:onHit(event)

    log:info("event.IniObjectCategory : $1, event.IniCategory: $2, event.TgtCategory: $3,  event.TgtObjectCategory: $4", event.IniObjectCategory, event.IniCategory, event.TgtCategory, event.TgtObjectCategory)
	
    log:info("event.IniUnitName : $1, event.IniTypeName: $2, event.TgtDCSUnitName: $3, event.TgtTypeName: $4, event.WeaponName: $5", event.IniUnitName, event.IniTypeName, event.TgtDCSUnitName, event.TgtTypeName, event.WeaponName)
    --[[
        Object.Category
        UNIT    1
        WEAPON  2
        STATIC  3
        BASE    4
        SCENERY 5
        CARGO   6
    --]]
	
	--exclude hit notifications that do not have an initiating unit and/or target unit
    if event.IniUnitName == nil or event.TgtDCSUnitName == nil then
        log:info("Aborting hit notification for nil initiating and/or target unit: event.IniUnitName: $1, event.TgtDCSUnitName: $2", event.IniUnitName, event.TgtDCSUnitName)
        return
    end

    --exclude hit notifications of scenery objects e.g. missed bomb hitting tree/house 
    if event.TgtObjectCategory == Object.Category.SCENERY then
        log:info("Aborting hit notification for scenery object: event.TgtObjectCategory: $1, event.TgtTypeName: $2", event.TgtObjectCategory, event.TgtTypeName)
        return
    end

	--exclude hit notifications of aircraft (helos) bumping into cargo container
    if event.IniObjectCategory == Object.Category.CARGO then
        log:info("Aborting hit notification for cargo object: event.TgtObjectCategory: $1, event.TgtTypeName: $2", event.TgtObjectCategory, event.TgtTypeName)
        return
    end
	
	--exclude hit notifications for aircraft (Harrier) take-off from friendly Tarawa
	-- Tarawa starting life points = 7301. 
	-- Tarawa:getLife0 = 0 so cannot obtain this value and even then, does not account for subsequent take-offs and assoc damage.
	-- Su-27 S-25OFM rocket damage to Tarawa = 5% to 8% (S-25OFM can kill CommandCenter object with livfe points = 10000!)
	-- Harrier take-off damage to Tarawa = 2%
    if event.IniTypeName == "AV8BNA" and event.TgtTypeName == "LHA_Tarawa" and event.IniCoalition == event.TgtCoalition and event.WeaponName == "AV8BNA" then
        log:info("Aborting hit notification for Harrier take-off from friendly Tarawa: event.IniPlayerName: $1, event.IniCoalition: $2", event.IniPlayerName, event.IniCoalition)
        return
    end
	
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
		log:info("Hit notification sent: $1", message)
    end
end

local function getUnitDesc(coalition, groupName, typeName, unitName)
    local ownerName = groupName ~= nil and utils.getPlayerNameFromGroupName(groupName) or nil
    local coalitionName = coalition ~= nil and utils.getSideName(coalition) .. " " or ""

    local typeDesc = typeName
    local _isLogisticsCentre = false
    local _LCsideName
    if (typeName == ".Command Center" or typeName == "outpost") and unitName ~= nil then

        typeDesc = "Logistics Centre"

        --buildings will always be neutral coaltion associated, therefore derive side from name
        local _logisticsCentreName = unitName
        _LCsideName = string.match(_logisticsCentreName, ("%w+$")) --"Sochi Logistics Centre #001 red" = "red"

        _isLogisticsCentre = true
    end
    log:info("typeDesc: $1 typeName: $2, unitName: $3, ownerName: $4", typeDesc, typeName, unitName, ownerName)

    if ownerName == nil then
        --buildings will not have a groupName
        if _isLogisticsCentre then

            if _LCsideName ~= nil then
                return string.format("%s %s", _LCsideName, typeDesc)
            else
                return string.format("%s", typeDesc)
            end
        else
            return string.format("%s%s", coalitionName, typeDesc)
        end
    else
        return string.format("%s's %s%s", ownerName, coalitionName, typeDesc)
    end
end

local function getPlayerDesc(coalition, groupName, typeName, playerName, unitName)
    return string.format("%s in %s", playerName, getUnitDesc(coalition, groupName, typeName, unitName))
end

function M.buildHitMessage(event)
    if event.IniPlayerName == nil and event.TgtPlayerName == nil then
        -- AI on AI; no interest
        return nil
    end

    local message = ""
    if event.IniPlayerName ~= nil then
        message = message .. getPlayerDesc(event.IniCoalition, event.IniGroupName, event.IniTypeName, event.IniPlayerName, event.IniUnitName)
    else
        message = message .. getUnitDesc(event.IniCoalition, event.IniGroupName, event.IniTypeName)
    end

    message = message .. " hit "
    if event.TgtPlayerName ~= nil then
        message = message .. getPlayerDesc(event.TgtCoalition, event.TgtGroupName, event.TgtTypeName, event.TgtPlayerName, event.IniUnitName)
    else
        message = message .. getUnitDesc(event.TgtCoalition, event.TgtGroupName, event.TgtTypeName, event.TgtUnitName)
    end

    log:info("event.WeaponName: $1", event.WeaponName)
    log:info("event.Weapon: getDesc(): $1", event.Weapon)

    if event.Weapon ~= nil then
        local _weaponDesc = event.Weapon:getDesc()
        local _weaponDisplayName = _weaponDesc.displayName
        message = message .. " with " .. _weaponDisplayName
    end

    if event.IniPlayerName ~= nil and (event.TgtPlayerName ~= nil or event.TgtTypeName ~= nil) and event.IniCoalition == event.TgtCoalition then
        message = "FRIENDLY FIRE: " .. message
    end

    message = "[ALL] " .. message -- let player know that hit notifications are seen by both teams

    return message:gsub("^%l", string.upper)
end

function M.onMissionStart(hitMessageDelay)
    M.eventHandler = M.HIT_EVENTHANDLER:New(hitMessageDelay)
    M.eventHandler:HandleEvent(EVENTS.Hit, M.eventHandler.onHit)
end

return M
