local missionUtils = require("missionUtils")
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
    _self.groupsMenusAdded = {}
    return _self
end

function M.BIRTH_EVENTHANDLER:_OnBirth(event)
    self:_AddMenus(event)
end

function M.BIRTH_EVENTHANDLER:_AddMenus(event)
    if event.IniPlayerName then
        local playerGroup = event.IniGroup
        if playerGroup then
            local groupId = playerGroup:GetDCSObject():getID()
            local groupName = playerGroup:GetName()
            if self.groupsMenusAdded[groupName] then
                self:I("Not adding menus again for " .. groupName)
                return
            end
            self:I("Adding menus for " .. playerGroup:GetName())
            self.groupsMenusAdded[groupName] = true
            local unitName = event.IniUnitName
            self:_AddTimeUntilRestart(playerGroup)
            self:_AddJTACStatusMenu(groupId, unitName)
            if playerGroup:GetCategory() == Group.Category.AIRPLANE then
                self:_AddWeaponsManagerMenus(groupId)
            end
            if missionUtils.isTransportType(playerGroup:GetTypeName()) then
                self:_AddCTLDMenus(groupId, unitName)
                self:_AddCSARMenu(unitName)
            else
                self:_AddRadioListMenu(groupId, unitName)
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

function M.BIRTH_EVENTHANDLER:_AddJTACStatusMenu(groupId, unitName)
    if ctld.JTAC_jtacStatusF10 then
        missionCommands.addCommandForGroup(groupId, "JTAC Status", nil, ctld.getJTACStatus, { unitName })
    end
end

function M.BIRTH_EVENTHANDLER:_AddWeaponsManagerMenus(groupId)
    missionCommands.addCommandForGroup(groupId, "Show weapons left", nil, weaponManager.printHowManyLeft, groupId)
    missionCommands.addCommandForGroup(groupId, "Validate Loadout", nil, weaponManager.validateLoadout, groupId)
end

function M.BIRTH_EVENTHANDLER:_AddCTLDMenus(groupId, unitName)
    local _unit = ctld.getTransportUnit(unitName)
    local _unitActions = ctld.getUnitActions(_unit:getTypeName())
    if ctld.enableCrates and _unitActions.crates then
        if ctld.unitCanCarryVehicles(_unit) == false then
            ctld.addCrateMenu(nil, "Light crates", _unit, groupId, ctld.spawnableCrates, 1)
            ctld.addCrateMenu(nil, "Heavy crates", _unit, groupId, ctld.spawnableCrates, ctld.heavyCrateWeightMultiplier)
        end
    end
    if (ctld.enabledFOBBuilding or ctld.enableCrates) and _unitActions.crates then
        missionCommands.addCommandForGroup(groupId, "Unpack Nearby Crate", nil, ctld.unpackCrates, { unitName })
    end
    ctld.addF10MenuOptions(unitName)
    if (ctld.enabledFOBBuilding or ctld.enableCrates) and _unitActions.crates then
        if (ctld.slingLoad == false) or (ctld.internalCargo == true) then
            missionCommands.addCommandForGroup(groupId, "Load Nearby Crate", nil, ctld.loadNearbyCrate, { unitName })
            missionCommands.addCommandForGroup(groupId, "Drop Crate", nil, ctld.dropSlingCrate, { unitName })
        end
    end
    if _unitActions.troops then
        missionCommands.addCommandForGroup(groupId, "Unload / Extract Troops", nil, ctld.unloadExtractTroops, { unitName })
    end
end

function M.BIRTH_EVENTHANDLER:_AddCSARMenu(unitName)
    csar.addMedevacMenuItem(unitName)
end

function M.BIRTH_EVENTHANDLER:_AddRadioListMenu(groupId, unitName)
    if ctld.enabledRadioBeaconDrop then
        missionCommands.addCommandForGroup(groupId, "List Radio Beacons", nil, ctld.listRadioBeacons, { unitName })
    end
end

function M.onMissionStart(restartHours)
    M.eventHandler = M.BIRTH_EVENTHANDLER:New(restartHours)
end

return M
