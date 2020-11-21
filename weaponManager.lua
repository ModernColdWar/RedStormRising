--[[
    Weapon Manager Script - Version: 1.8 - 21/12/2019 by Theodossis Papadopoulos
    -- Requires MIST
       ]]
-- luacheck: no max line length
-- luacheck: globals EV_MANAGER

local M = {}

local msgTimer = 15

local rsrConfig = require("RSR_config")
local perLife = math.floor(rsrConfig.maxLives / rsrConfig.livesMultiplier + 0.5)
local JSON = require("json")

local socket = require("socket")

-- ---------------------------LIMITATIONS-----------------------------------
local limitations = {
    {
        WP_NAME = "AIM_54A_Mk47",
        QTY = 2 * perLife,
        DISPLAY_NAME = "AIM-54A Mk47"
    },
    {
        WP_NAME = "AIM_54A_Mk60",
        QTY = 4 * perLife,
        DISPLAY_NAME = "AIM-54A Mk60"
    },
    {
        WP_NAME = "AIM_54C_Mk47",
        QTY = 2 * perLife,
        DISPLAY_NAME = "AIM-54C Mk47"
    },
    {
        WP_NAME = "weapons.missiles.AIM_120",
        QTY = 4 * perLife,
        DISPLAY_NAME = "AIM-120B"
    },
    {
        WP_NAME = "weapons.missiles.AIM_120C",
        QTY = 4 * perLife,
        DISPLAY_NAME = "AIM-120C"
    },
    --{
    --    WP_NAME = "weapons.missiles.AGM_88",
    --    QTY = 0,
    --    DISPLAY_NAME = "AGM-88C"
    --},
    --{
    --    WP_NAME = "weapons.missiles.AGM_154A",
    --    QTY = 0,
    --    DISPLAY_NAME = "AGM-154A"
    --},
    {
        WP_NAME = "weapons.missiles.AGM_154",
        QTY = 1 * perLife,
        DISPLAY_NAME = "AGM-154C"
    },
    --{
    --    WP_NAME = "weapons.bombs.CBU_97",
    --    QTY = 0,
    --    DISPLAY_NAME = "CBU-97"
    --},
    --{
    --    WP_NAME = "weapons.missiles.CM-802AK",
    --    QTY = 0,
    --    DISPLAY_NAME = "CM-802AK"
    --},
    --{
    --    WP_NAME = "CM-802AKG",
    --    QTY = 0,
    --    DISPLAY_NAME = "CM-802AKG"
    --},
    {
        WP_NAME = "weapons.missiles.GB-6",
        QTY = 1 * perLife,
        DISPLAY_NAME = "GB-6"
    },
    {
        WP_NAME = "weapons.missiles.GB-6-HE",
        QTY = 1 * perLife,
        DISPLAY_NAME = "GB-6-HE"
    },
    {
        WP_NAME = "weapons.missiles.GB-6-SFW",
        QTY = 1 * perLife,
        DISPLAY_NAME = "GB-6-SFW"
    },
    {
        WP_NAME = "weapons.bombs.GBU_31",
        QTY = 1 * perLife,
        DISPLAY_NAME = "GBU-31"
    },
    {
        WP_NAME = "weapons.bombs.GBU_31_V_3B",
        QTY = 1 * perLife,
        DISPLAY_NAME = "GBU-31(V)3/B"
    },
    {
        WP_NAME = "weapons.bombs.GBU_38",
        QTY = 1 * perLife,
        DISPLAY_NAME = "GBU-38"
    },
    --{
    --    WP_NAME = "weapons.missiles.X_58",
    --    QTY = 0,
    --    DISPLAY_NAME = "Kh-58U"
    --},
    --{
    --    WP_NAME = "weapons.missiles.LD-10",
    --    QTY = 4,
    --    DISPLAY_NAME = "LD-10"
    --},
    --{
    --    WP_NAME = "weapons.missiles.LS-6-500",
    --    QTY = 0,
    --    DISPLAY_NAME = "LS-6-500"
    --},
    --{
    --    WP_NAME = "P_27TE",
    --    QTY = 0,
    --    DISPLAY_NAME = "R-27ET"
    --},
    --{
    --    WP_NAME = "P_27EP",
    --    QTY = 0,
    --    DISPLAY_NAME = "R-27ER"
    --},
    --{
    --    WP_NAME = "P_77",
    --    QTY = 8 * perLife,
    --    DISPLAY_NAME = "R-77"
    --},
    {
        WP_NAME = "weapons.bombs.RN-24",
        QTY = 0,
        DISPLAY_NAME = "RN-24"
    },
    {
        WP_NAME = "weapons.bombs.RN-28",
        QTY = 0,
        DISPLAY_NAME = "RN-28"
    },
    {
        WP_NAME = "SD-10",
        QTY = 4 * perLife,
        DISPLAY_NAME = "SD-10"
    },
}

-- ----------------------- DO NOT TOUCH UNDER HERE-------------------------------
local playersSettedUp = {}
local data = {}
local tobedestroyed = {}
-- ----------------------- MISC METHODS CODE ------------------------------------
local function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

local function contains(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function tableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end
-- --------------------DATA MANAGER--------------------
local function setup(playerName)
    data[tablelength(data) + 1] = { ["PlayerName"] = playerName, ["Limitations"] = mist.utils.deepCopy(limitations) }
    playersSettedUp[tablelength(playersSettedUp) + 1] = playerName
end

local function destroyerContains(unitName)
    for i = 1, tablelength(tobedestroyed) do
        if (tobedestroyed[i].Unitname == unitName) then
            return true
        end
    end
    return false
end

local function makeMore(playerName, wpn, howMany)
    local earlyBreak = false
    for i = 1, tablelength(data) do
        if (data[i].PlayerName == playerName) then
            -- FOUND HIM
            earlyBreak = true
            for j = 1, tablelength(data[i].Limitations) do
                if (data[i].Limitations[j].WP_NAME == wpn) then
                    -- FOUND WEAPON
                    data[i].Limitations[j].QTY = data[i].Limitations[j].QTY + howMany
                end
            end
        end
        if earlyBreak == true then
            break
        end
    end
end

local function destroyAfter5MINS(unitName)
    for i = 1, tablelength(tobedestroyed) do
        if tobedestroyed[i].Unitname == unitName then
            -- FOUND HIM
            trigger.action.explosion(Unit.getByName(unitName):getPosition().p, 100)
            tobedestroyed[i].scheduler:Stop()
            table.remove(tobedestroyed, i)
            break
        end
    end
end

local function makeLess(playerName, wpn, howMany, unit)
    local earlyBreak = false
    for i = 1, tablelength(data) do
        if (data[i].PlayerName == playerName) then
            -- FOUND HIM
            earlyBreak = true
            for j = 1, tablelength(data[i].Limitations) do
                if (data[i].Limitations[j].WP_NAME == wpn) then
                    -- FOUND WEAPON
                    if (data[i].Limitations[j].QTY - howMany < 0) then
                        if not destroyerContains(unit:getName()) then
                            trigger.action.outTextForGroup(unit:getGroup():getID(), "LOADOUT NOT VALID, RETURN TO BASE FOR REARMING NOW OR YOU WILL BE DESTROYED IN 5 MINS", 300)
                            local scheduler = SCHEDULER:New(nil, destroyAfter5MINS, { unit:getName() }, 300)
                            tobedestroyed[tablelength(tobedestroyed) + 1] = { ["Unitname"] = unit:getName(), ["scheduler"] = scheduler }
                        end
                    end
                    data[i].Limitations[j].QTY = data[i].Limitations[j].QTY - howMany
                end
            end
        end
        if earlyBreak == true then
            break
        end
    end
end

function M.validateLoadout(gpid)
    local earlyBreak = false
    local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
    local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
    local allUnits = tableConcat(blueUnits, redUnits)
    for j = 1, tablelength(allUnits) do
        local us = allUnits[j]
        if us:getGroup():getID() == gpid and us:getGroup():getCategory() == Group.Category.AIRPLANE then
            -- Found him/them for two seat
            earlyBreak = true
            local playerName = us:getPlayerName()
            local secondaryearlyBreak = false
            if us:inAir() == false then
                for d = 1, tablelength(data) do
                    if data[d].PlayerName == playerName then
                        secondaryearlyBreak = true
                        local text = "Loadout validation for " .. playerName .. " : \n----------------------------------------------------------------------"
                        local valid = true
                        if us:getAmmo() ~= nil then
                            for e = 1, tablelength(data[d].Limitations) do
                                for a = 1, tablelength(us:getAmmo()) do
                                    if (data[d].Limitations[e].WP_NAME == us:getAmmo()[a].desc.typeName) then
                                        if (data[d].Limitations[e].QTY - us:getAmmo()[a].count < 0) then
                                            valid = false
                                            text = text .. "\n" .. "You need to remove " .. -(data[d].Limitations[e].QTY - us:getAmmo()[a].count) .. "x" .. data[d].Limitations[e].DISPLAY_NAME
                                        end
                                    end
                                end
                            end
                        end
                        if valid == true then
                            text = text .. "\nYour loadout is valid"
                        end
                        trigger.action.outTextForGroup(us:getGroup():getID(), text, msgTimer * 2)
                    end
                    if secondaryearlyBreak == true then
                        break
                    end
                end
            else
                trigger.action.outTextForGroup(us:getGroup():getID(), "You cannot validate loadout while you are on air", msgTimer)
            end
        end
        if earlyBreak == true then
            break
        end
    end
end
-- --------------------DATA PRINTER--------------------
function M.printHowManyLeft(gpid)
    local earlyBreak = false
    local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
    local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
    local allUnits = tableConcat(blueUnits, redUnits)
    for j = 1, tablelength(allUnits) do
        local us = allUnits[j]
        if us:getGroup():getID() == gpid and us:getGroup():getCategory() == Group.Category.AIRPLANE then
            -- Found him/them for two seat
            earlyBreak = true
            local playerName = us:getPlayerName()
            local secondearlyBreak = false
            for d = 1, tablelength(data) do
                if data[d].PlayerName == playerName then
                    secondearlyBreak = true
                    local text = "Weapons left for " .. playerName .. " : \n----------------------------------------------------------------------"
                    for e = 1, tablelength(data[d].Limitations) do
                        text = text .. "\n" .. data[d].Limitations[e].DISPLAY_NAME .. " : " .. data[d].Limitations[e].QTY
                    end
                    trigger.action.outTextForGroup(us:getGroup():getID(), text, msgTimer)
                end
                if secondearlyBreak == true then
                    break
                end
            end
        end
        if earlyBreak == true then
            break
        end
    end
end

local function sendToRsrBot(event)
    if not rsrConfig.udpEventReporting then
        return
    end
    if (event.id > 1 and event.id < 10) or (event.id == 28) then
        local event2send = {
            ["id"] = event.id,
            ["time"] = event.time,
            ["initiator"] = "",
            ["initiatorCoalition"] = 0,
            ["target"] = "",
            ["targetCoalition"] = 0,
            ["weapon"] = "",
        }

        --log:info("event: $1",inspect(event, { newline = " ", indent = "" }))
        --log:info("event.target: $1, event.TgtPlayerName: $2, event.TgtCoalition: $3",event.target, event.TgtPlayerName, event.TgtCoalition)

        --some events dont have a target
        if event.target ~= nil then

            --check for AI or Player
            if event.TgtPlayerName then

                event2send.target = event.TgtPlayerName
            else
                event2send.target = "AI"
            end
            event2send.targetCoalition = event.TgtCoalition
        end
        if event.weapon_name ~= nil then
            --check the event has a weapon associated with it (some dont)
            event2send.weapon = event.weapon_name
        end

        if event.initiator ~= nil then
            --check the event has an initiator
            if event.initiator:getCategory() == Object.Category.UNIT then
                if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
                    if event.initiator:getPlayerName() then
                        --check for AI or Player
                        event2send.initiator = event.initiator:getPlayerName()
                    else
                        event2send.initiator = "AI"
                    end
                    event2send.initiatorCoalition = event.initiator:getCoalition()
                end
            end
        end
        --PrintTable(event)
        local udp = assert(socket.udp())
        udp:settimeout(0.01)
        assert(udp:setsockname("*", 0))
        assert(udp:setpeername(rsrConfig.udpEventHost, rsrConfig.udpEventPort))
        local jsonEventTableForBot = JSON:encode(event2send) --Encode the event table
        assert(udp:send(jsonEventTableForBot))
        --env.info(jsonEventTableForBot)
    end
end

EV_MANAGER = {}
-- luacheck: push no unused
function EV_MANAGER:onEvent(event)
    if event.id == world.event.S_EVENT_BIRTH then
        if event.initiator:getCategory() == Object.Category.UNIT then
            if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
                local playerName = event.initiator:getPlayerName()
                if not contains(playersSettedUp, playerName) then
                    setup(playerName)
                end
                -- RSR: menus added via birth event handling
                --local gpid = event.initiator:getGroup():getID()
                --missionCommands.addCommandForGroup(gpid, "Show weapons left", nil, M.printHowManyLeft, gpid)
                --missionCommands.addCommandForGroup(gpid, "Validate Loadout", nil, M.validateLoadout, gpid)
                --FOR WEAPON DEBUGGING
                --for i, ammo in pairs(event.initiator:getAmmo()) do
                --  trigger.action.outText(ammo.desc.typeName, msgTimer)
                --end
            end
        end
    elseif event.id == world.event.S_EVENT_TAKEOFF then
        if event.initiator ~= nil then
            if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
                if event.initiator:getAmmo() ~= nil then
                    for _, ammo in pairs(event.initiator:getAmmo()) do
                        for j = 1, tablelength(limitations) do
                            if (limitations[j].WP_NAME == ammo.desc.typeName) then
                                makeLess(event.initiator:getPlayerName(), ammo.desc.typeName, ammo.count, event.initiator)
                            end
                        end
                    end
                end
            end
        end
    elseif event.id == world.event.S_EVENT_LAND then
        if event.initiator ~= nil then
            if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
                if event.initiator:getAmmo() ~= nil then
                    for _, ammo in pairs(event.initiator:getAmmo()) do
                        for j = 1, tablelength(limitations) do
                            if (limitations[j].WP_NAME == ammo.desc.typeName) then
                                makeMore(event.initiator:getPlayerName(), ammo.desc.typeName, ammo.count)
                            end
                        end
                    end
                    for i = 1, tablelength(tobedestroyed) do
                        if (tobedestroyed[i].Unitname == event.initiator:getName()) then
                            -- FOUND HIM
                            tobedestroyed[i].scheduler:Stop()
                            table.remove(tobedestroyed, i)
                            trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "Successfully returned back to base. You will not be destroyed", 300)
                            break
                        end
                    end
                end
            end
        end
    elseif event.id == world.event.S_EVENT_SHOT then
        if event.initiator:getCategory() == Object.Category.UNIT then
            if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
                for i = 1, tablelength(tobedestroyed) do
                    if (tobedestroyed[i].Unitname == event.initiator:getName()) then
                        -- FOUND HIM
                        tobedestroyed[i].scheduler:Stop()
                        table.remove(tobedestroyed, i)
                        trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "You have been destroyed because you fired a limited weapon", msgTimer, true)
                        trigger.action.explosion(event.initiator:getPosition().p, 100)
                        trigger.action.explosion(event.weapon:getPosition().p, 100)
                        break
                    end
                end
            end
        end
    elseif event.id == world.event.S_EVENT_DEAD then
        if event.initiator:getCategory() == Object.Category.UNIT then
            if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
                missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), { [1] = "Show weapons left", [2] = "Validate Loadout" })
                for i = 1, tablelength(tobedestroyed) do
                    if (tobedestroyed[i].Unitname == event.initiator:getName()) then
                        -- FOUND HIM
                        tobedestroyed[i].scheduler:Stop()
                        table.remove(tobedestroyed, i)
                        break
                    end
                end
            end
        end
    elseif event.id == world.event.S_EVENT_EJECTION then
        if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
            missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), { [1] = "Show weapons left", [2] = "Validate Loadout" })
            for i = 1, tablelength(tobedestroyed) do
                if (tobedestroyed[i].Unitname == event.initiator:getName()) then
                    -- FOUND HIM
                    tobedestroyed[i].scheduler:Stop()
                    table.remove(tobedestroyed, i)
                    break
                end
            end
        end
    end
    -- wrap in pcall as we're doing I/O (even if UDP)
    local status, err = pcall(sendToRsrBot, event)
    if not status then
        env.error(string.format("Error inside sendToRsrBot: %s", err))
    end

end
-- luacheck: pop
world.addEventHandler(EV_MANAGER)
env.info("Weapon Manager loaded")

return M
