local missionUtils = require("missinUtils")
local restartInfo = require("restartInfo")
local weaponManager = require("weaponManager")

local M = {}

M.eventHandler = nil  -- constructed in onMissionStart

M.BIRTH_EVENTHANDLER = {
    ClassName = "BIRTH_EVENTHANDLER"
}

function M.BIRTH_EVENTHANDLER:New(restartHours)
    local _self = BASE:Inherit(self, EVENTHANDLER:New())
    _self.restartHours = restartHours
    _self:HandleEvent(EVENTS.Birth, _self._OnBirth)
    return _self
end

function M.BIRTH_EVENTHANDLER:_OnBirth(event)
    self:_AddMenus(event)
end

function M.BIRTH_EVENTHANDLER:_AddMenus(event)
    if event.IniPlayerName then
        local playerName = event.IniPlayerName
        local playerGroup = event.IniGroup
        if playerGroup then
            self:I("Adding menus for " .. playerName)
            local groupId = playerGroup:GetDCSObject():getID()
            self:_AddTimeUntilRestart(playerGroup)
            self:_AddJTACStatusMenu(groupId, playerName)
            if playerGroup:GetCategory() == Group.Category.AIRPLANE then
                self:_AddWeaponsManagerMenus(groupId)
            end
            if missionUtils.isTransportType(playerGroup:GetTypeName()) then
                -- add CTLD menus
            else
                self:_AddRadioListMenu(groupId, playerName)
            end
        end
    end
end

function M.BIRTH_EVENTHANDLER:_AddTimeUntilRestart(playerGroup)
    MENU_GROUP_COMMAND:New(playerGroup, "Time until restart", nil, function()
        local secondsUntilRestart = restartInfo.getSecondsUntilRestart(os.date("*t"), self.restartHours)
        MESSAGE:New(string.format("The server will restart in %s", restartInfo.getSecondsAsString(secondsUntilRestart)), 5):ToGroup(playerGroup)
    end)
end

function M.BIRTH_EVENTHANDLER:_AddJTACStatusMenu(groupId, playerName)
    if ctld.JTAC_jtacStatusF10 then
        missionCommands.addCommandForGroup(groupId, "JTAC Status", nil, ctld.getJTACStatus, { playerName })
    end
end

function M.BIRTH_EVENTHANDLER:_AddWeaponsManagerMenus(groupId)
    missionCommands.addCommandForGroup(groupId, "Show weapons left", nil, weaponManager.printHowManyLeft, groupId)
    missionCommands.addCommandForGroup(groupId, "Validate Loadout", nil, weaponManager.validateLoadout, groupId)
end

function M.BIRTH_EVENTHANDLER:_AddRadioListMenu(groupId, playerName)
    if ctld.ctld.enabledRadioBeaconDrop then
        missionCommands.addCommandForGroup(groupId, "List Radio Beacons", nil, ctld.listRadioBeacons, { playerName })
    end
end

function M.onMissionStart(restartHours)
    M.eventHandler = M.BIRTH_EVENTHANDLER:New(restartHours)
end

return M
