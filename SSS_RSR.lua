 --SIMPLE STATICS SAVING by Pikey, May 2019
  
 -- Usage of this script should credit the following contributors:
 --Pikey 
 --Speed & Grimes for their work on Serialising tables, included below,
 --FlightControl for MOOSE (Required)
 
 --INTENDED USAGE
 --DCS Server Admins looking to do long term multi session play that will need a server reboot in between and they wish to keep the Ground 
 --Unit positions true from one reload to the next.
 
 --USAGE
 --Ensure LFS and IO are not santitised in missionScripting.lua. This enables writing of files. If you don't know what this does, don't attempt to use this script.
 --Requires versions of MOOSE.lua supporting "SET:ForEachGroupAlive()". Should be good for 6 months or more from date of writing. 
 --MIST not required, but should work OK with it regardless.
 --Edit 'SaveScheduleUnits' below, (line 34) to the number of seconds between saves. Low impact. 10 seconds is a fast schedule.
 --Place Ground Groups wherever you want on the map as normal.
 --Run this script at Mission start
 --The script will create a small file with the list of Groups and Units.
 --At Mission Start it will check for a save file, if not there, create it fresh
 --If the table is there, it loads it and Spawns everything that was saved.
 --The table is updated throughout mission play
 --The next time the mission is loaded it goes through all the Groups again and loads them from the save file.
 
 --LIMITATIONS
--I experienced issues Spawning Statics and Destroying statics in some configurations, so I'm exploding them and not deleting them like SGS. 

----The only thing I did to configure this for RSR was change the save name of the files to SSS_RSR. Need to change the directory it saves to as well, as currently it saves to the \Eagle Dynamics\DCS World OpenBeta main drive. Going to leave the static saves off for now I think it may mess with the resupply crates, and I don't know how it works with Airbase Runways etc. 

  --Configurable for user:
 SaveScheduleStatics=10 --how many seconds between each check of all the statics.
 -----------------------------------
 --Do not edit below here
 -----------------------------------
 local version = "1.0"
 
 function IntegratedbasicSerialize(s)
    if s == nil then
      return "\"\""
    else
      if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
        return tostring(s)
      elseif type(s) == 'string' then
        return string.format('%q', s)
      end
    end
  end
-- imported slmod.serializeWithCycles (Speed)
  function IntegratedserializeWithCycles(name, value, saved)
    local basicSerialize = function (o)
      if type(o) == "number" then
        return tostring(o)
      elseif type(o) == "boolean" then
        return tostring(o)
      else -- assume it is a string
        return IntegratedbasicSerialize(o)
      end
    end

    local t_str = {}
    saved = saved or {}       -- initial value
    if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
      table.insert(t_str, name .. " = ")
      if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
        table.insert(t_str, basicSerialize(value) ..  "\n")
      else

        if saved[value] then    -- value already saved?
          table.insert(t_str, saved[value] .. "\n")
        else
          saved[value] = name   -- save name for next time
          table.insert(t_str, "{}\n")
          for k,v in pairs(value) do      -- save its fields
            local fieldname = string.format("%s[%s]", name, basicSerialize(k))
            table.insert(t_str, IntegratedserializeWithCycles(fieldname, v, saved))
          end
        end
      end
      return table.concat(t_str)
    else
      return ""
    end
  end

function file_exists(name) --check if the file already exists for writing
    if lfs.attributes(name) then
    return true
    else
    return false end 
end

function writemission(data, file)--Function for saving to file (commonly found)
  File = io.open(file, "w")
  File:write(data)
  File:close()
end

function Alive(grp)
if grp:IsAlive() then return false else return true end
end

--SCRIPT START
env.info("Loaded Simple Statics Saving, by Pikey, 2018, version " .. version)

if file_exists("SaveStatics_RSR.lua") then
  env.info("Script loading existing database")
  dofile("SaveStatics_RSR.lua")

  AllStatics = SET_STATIC:New():FilterStart()

  --Destroy() causes script error, so exploding them for now. benefit is you get wreckage. Issues with large amounts I expect.

  AllStatics:ForEach(function (stat)
  if SaveStatics_RSR[stat:GetName()]["dead"]==true then
    local coord = stat:GetCoordinate()
    coord:Explosion(1500) --works for Workshop size statics, may hit other things, not exact science :/
    coord:BigSmokeMedium(0.25) --may not appear in MP if joining after. Wait for ED to fix that.
   end

  end)

else --Save File does not exist we start a fresh table
  SaveStatics_RSR={}
  AllStatics = SET_STATIC:New():FilterStart()
end

--THE SAVING SCHEDULE
SCHEDULER:New( nil, function()
AllStatics:ForEach(function (grp)

SaveStatics_RSR[grp:GetName()] =

-- In case destroying silently and spawning is fixed I'm leaving it to be used to spawn statics in the
-- format required for coalition.addStaticObject(SaveStatics[k]["Country"], staticData) .

{
 -- ["heading"] = grp:GetHeading(),
  --["groupId"] =grp:GetID(),
 -- ["shape_name"] = "stolovaya",
 -- ["type"] = grp:GetTypeName(),
  --["unitId"] = grp:GetID(),
 -- ["rate"] = 100,
  ["name"] = grp:GetName(),
  --["category"] = "Fortifications",
--  ["y"] = grp:GetVec2().y, 
--  ["x"] = grp:GetVec2().x, 
  ["dead"] = Alive(grp),
 -- ["Country"] = grp:GetCountry()
}

end)--end of the for each groupAlive iteration

local newMissionStr = IntegratedserializeWithCycles("SaveStatics_RSR",SaveStatics_RSR)
writemission(newMissionStr, "SaveStatics_RSR.lua")
SaveStatics_RSR={} --flatten this between iterations to prevent accumulations
--env.info("Data saved.")
end, {}, 1, SaveScheduleStatics)
