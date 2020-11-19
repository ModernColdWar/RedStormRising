---
-- Name: SCUD Hunting
-- Author: Wildcat (Chandawg)
-- Date Created: 10 June 2020

SCUD_Units = SET_GROUP:New()
  :FilterPrefixes( "CTLD_SCUD_B " )
  :FilterStart()

SCUD_Units:HandleEvent(EVENTS.Shot)

env.info("SCUD Hunt Test loaded")

function SCUD_Units:OnEventShot(EventData)
  if EventData.IniTypeName == "Scud_B" then
  MESSAGE:New( "U.S. Missile Warning sensors have detected a Scud-B launch event. TAKE immediate shelter!"):ToAll("ALERT:")
  testUnitGrab = EventData.IniUnit
  local TargetCoord = testUnitGrab:GetCoordinate()
  local MarkID = TargetCoord:MarkToCoalition( "Analyst at the JIOC have pinpointed the launch position of the SCUD-B to this location. Task a strike mission to target this high value asset.", coalition.side.BLUE, true)
  else
  --nothing
  end
end
