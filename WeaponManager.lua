--[[
    Weapon Manager Script - Version: 1.8 - 21/12/2019 by Theodossis Papadopoulos
    -- Requires MIST
       ]]
local msgTimer = 15
local limitations = {} -- Do not touch

-- ---------------------------LIMITATIONS-----------------------------------
limitations[1] = {
  WP_NAME = "AIM_120C",
  QTY = 40,
  DISPLAY_NAME = "AIM 120C"
}
limitations[2] = {
  WP_NAME = "AIM_120",
  QTY = 10,
  DISPLAY_NAME = "AIM 120B"
}
limitations[3] = {
  WP_NAME = "SD-10",
  QTY = 40,
  DISPLAY_NAME = "SD-10"
}
limitations[4] = {
  WP_NAME = "P_77",
  QTY = 100,
  DISPLAY_NAME = "R-77"
}
limitations[5] = {
  WP_NAME = "AIM_54A_Mk47",
  QTY = 10,
  DISPLAY_NAME = "AIM 54A-Mk47"
}
limitations[6] = {
  WP_NAME = "AIM_54A_Mk60",
  QTY = 40,
  DISPLAY_NAME = "AIM 54A-Mk60"
}
limitations[7] = {
  WP_NAME = "AIM_54C_Mk47",
  QTY = 10,
  DISPLAY_NAME = "AIM 54C-Mk47"
}
limitations[8] = {
  WP_NAME = "PN_24",
  QTY = 0,
  DISPLAY_NAME = "RN-24"
}
limitations[9] = {
  WP_NAME = "PN_28",
  QTY = 0,
  DISPLAY_NAME = "RN-28"
}
limitations[10] = {
  WP_NAME = "AGM-154C",
  QTY = 0,
  DISPLAY_NAME = "AGM 154 JSOW-C"
}
--limitations[11] = {
--  WP_NAME = "P_27TE",
--  QTY = 6,
--  DISPLAY_NAME = "R-27ET"
--}
--limitations[12] = {
--  WP_NAME = "P_27EP",
--  QTY = 6,
--  DISPLAY_NAME = "R-27ER"
--}
-- ----------------------- DO NOT TOUCH UNDER HERE-------------------------------
local playersSettedUp = {}
local data = {}
local tobedestroyed = {}
-- ----------------------- MISC METHODS CODE ------------------------------------
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function tableConcat(t1, t2)
  for i=1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end
-- --------------------DATA MANAGER--------------------
function setup(playerName)
  data[tablelength(data) + 1] = { ["PlayerName"] = playerName, ["Limitations"] = mist.utils.deepCopy(limitations) }
  playersSettedUp[tablelength(playersSettedUp) + 1] = playerName
end

function destroyerContains(unitName)
  for i=1, tablelength(tobedestroyed) do
    if(tobedestroyed[i].Unitname == unitName) then
      return true
    end
  end
  return false
end

function makeMore(playerName, wpn, howMany)
  local earlyBreak = false
  for i=1, tablelength(data) do
    if(data[i].PlayerName == playerName) then -- FOUND HIM
      earlyBreak = true
      for j=1, tablelength(data[i].Limitations) do
        if(data[i].Limitations[j].WP_NAME == wpn) then -- FOUND WEAPON
          data[i].Limitations[j].QTY = data[i].Limitations[j].QTY + howMany
        end
      end
    end
    if earlyBreak == true then
      break
    end
  end
end

function destroyAfter5MINS(unitName)
  for i=1, tablelength(tobedestroyed) do
    if tobedestroyed[i].Unitname == unitName then -- FOUND HIM
      trigger.action.explosion(Unit.getByName(unitName):getPosition().p, 100)
      mist.removeFunction(tobedestroyed[i].Funcid)
      table.remove(tobedestroyed, i)
      break
    end
  end
end

function makeLess(playerName, wpn, howMany, unit)
  local earlyBreak = false
  for i=1, tablelength(data) do
    if(data[i].PlayerName == playerName) then -- FOUND HIM
      earlyBreak = true
      for j=1, tablelength(data[i].Limitations) do
        if(data[i].Limitations[j].WP_NAME == wpn) then -- FOUND WEAPON
          if(data[i].Limitations[j].QTY - howMany < 0) then
            if not destroyerContains(unit:getName()) then
              trigger.action.outTextForGroup(unit:getGroup():getID(), "LOADOUT NOT VALID, RETURN TO BASE FOR REARMING NOW OR YOU WILL BE DESTROYED IN 5 MINS", 300)
              local id = mist.scheduleFunction(destroyAfter5MINS, {unit:getName()}, timer.getTime() + 300)
              tobedestroyed[tablelength(tobedestroyed) + 1] = { ["Unitname"] = unit:getName(), ["Funcid"] = id}
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

function validateLoadout(gpid) 
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid and us:getGroup():getCategory() == Group.Category.AIRPLANE then -- Found him/them for two seat
      earlyBreak = true
      local playerName = us:getPlayerName()
      local secondaryearlyBreak = false
      if us:inAir() == false then
        for d=1, tablelength(data) do
          if data[d].PlayerName == playerName then
            secondaryearlyBreak = true
            local text = "Loadout validation for " .. playerName .. " : \n----------------------------------------------------------------------"
            local valid = true
            if us:getAmmo() ~= nil then
              for e=1, tablelength(data[d].Limitations) do
                for a=1, tablelength(us:getAmmo()) do
                  if(data[d].Limitations[e].WP_NAME == us:getAmmo()[a].desc.typeName) then
                    if(data[d].Limitations[e].QTY - us:getAmmo()[a].count < 0) then
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
            trigger.action.outTextForGroup(us:getGroup():getID(), text, msgTimer*2)
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
function printHowManyLeft(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid and us:getGroup():getCategory() == Group.Category.AIRPLANE then -- Found him/them for two seat
      earlyBreak = true
      local playerName = us:getPlayerName()
      local secondearlyBreak = false
      for d=1, tablelength(data) do
        if data[d].PlayerName == playerName then
          secondearlyBreak = true
          local text = "Weapons left for " .. playerName .. " : \n----------------------------------------------------------------------"
          for e=1, tablelength(data[d].Limitations) do
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

EV_MANAGER = {}
function EV_MANAGER:onEvent(event)
  if event.id == world.event.S_EVENT_BIRTH then
    if event.initiator:getCategory() == Object.Category.UNIT then
      if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
        local playerName = event.initiator:getPlayerName()
        if not contains(playersSettedUp, playerName) then
          setup(playerName)
        end
        local gpid = event.initiator:getGroup():getID()
        missionCommands.addCommandForGroup(gpid, "Show weapons left", nil, printHowManyLeft, gpid)
        missionCommands.addCommandForGroup(gpid, "Validate Loadout", nil, validateLoadout, gpid)
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
          for i, ammo in pairs(event.initiator:getAmmo()) do
            for j=1, tablelength(limitations) do
              if(limitations[j].WP_NAME == ammo.desc.typeName) then
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
          for i, ammo in pairs(event.initiator:getAmmo()) do
            for j=1, tablelength(limitations) do
              if(limitations[j].WP_NAME == ammo.desc.typeName) then
                makeMore(event.initiator:getPlayerName(), ammo.desc.typeName, ammo.count)
              end
            end
          end
          for i=1, tablelength(tobedestroyed) do
            if(tobedestroyed[i].Unitname == event.initiator:getName()) then -- FOUND HIM
              mist.removeFunction(tobedestroyed[i].Funcid)
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
        for i=1, tablelength(tobedestroyed) do
          if(tobedestroyed[i].Unitname == event.initiator:getName()) then -- FOUND HIM
            mist.removeFunction(tobedestroyed[i].Funcid)
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
        missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show weapons left", [2] = "Validate Loadout"})
        for i=1, tablelength(tobedestroyed) do
          if(tobedestroyed[i].Unitname == event.initiator:getName()) then -- FOUND HIM
            mist.removeFunction(tobedestroyed[i].Funcid)
            table.remove(tobedestroyed, i)
            break
          end
        end
      end
    end
  elseif event.id == world.event.S_EVENT_EJECTION then
    if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
      missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show weapons left", [2] = "Validate Loadout"})
      for i=1, tablelength(tobedestroyed) do
        if(tobedestroyed[i].Unitname == event.initiator:getName()) then -- FOUND HIM
          mist.removeFunction(tobedestroyed[i].Funcid)
          table.remove(tobedestroyed, i)
          break
        end
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)
env.info("Weapon Manager loaded")
