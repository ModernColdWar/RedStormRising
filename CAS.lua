local state = require("state") --custom file that helps determine who owns bases

local M = {}
--root function to call moose CAS initialization from our server main driver file. (calls CTLD, MIST, etc in order)
function M.CASstart() 
	
	--patrol zones for the patrol functions
	PatrolZoneBeslan = ZONE:New( "BeslanCASzone" )
	PatrolZoneVaz = ZONE:New( "VazCASzone" )
	PatrolZoneSochi = ZONE:New( "SochiCASzone" )
	PatrolZoneMaykop = ZONE:New( "MaykopCASzone" )
	PatrolZoneMozdok = ZONE:New( "MozdokCASzone" )

	BeslanOwner = state.getOwner("Beslan")
	VazOwner = state.getOwner("Vaziani")
	SochiOwner = state.getOwner("Sochi-Adler")
	MaykopOwner = state.getOwner("Maykop-Khanskaya")
	MozdokOwner = state.getOwner("Mozdok")
		
	if BeslanOwner == "red" then
		--Red team detection scheme
		RedCasDetSetZone = SET_ZONE:New()
		RedCasDetSetZone:FilterPrefixes( { "BeslanCASzone" } )
		RedCasDetSetZone:FilterStart()
		RedCasDetection = DETECTION_ZONES:New( RedCasDetSetZone, coalition.side.BLUE )
		RedCasDispatcher = AI_A2G_DISPATCHER:New( RedCasDetection )
		RedCasDispatcher:SetSquadron( "BeslanRedCASai", AIRBASE.Caucasus.Beslan, { "BeslanRedCASai" }, 3 )
		RedCasDispatcher:SetSquadronBaiPatrol2( "BeslanRedCASai", PatrolZoneBeslan, 30, 150, 30, 500, "RADIO", 100, 230, 30, 200, "RADIO" )
		RedCasDispatcher:SetSquadronBaiPatrolInterval( "BeslanRedCASai", 2, 30, 180, 1 )
		--RedCasDispatcher:SetSquadronOverhead( "BeslanRedCASai", 0.5 )
		RedCasDispatcher:SetSquadronTakeoffInAir("BeslanRedCASai")
		RedCasDispatcher:SetSquadronLandingAtRunway("BeslanRedCASai")
		--RedCasDispatcher:SetTacticalDisplay( true )
		--RedCasDispatcher:SetDefenseReactivityHigh()
	end
	
	if MozdokOwner == "red" then
		RedCasDetSetZone = SET_ZONE:New()
		RedCasDetSetZone:FilterPrefixes( { "MozdokCASzone" } )
		RedCasDetSetZone:FilterStart()
		RedCasDetection = DETECTION_ZONES:New( RedCasDetSetZone, coalition.side.BLUE )
		RedCasDispatcher = AI_A2G_DISPATCHER:New( RedCasDetection )
		RedCasDispatcher:SetSquadron( "MozdokRedCASai", AIRBASE.Caucasus.Mozdok, { "MozdokRedCASai" }, 3 )
		RedCasDispatcher:SetSquadronBaiPatrol2( "MozdokRedCASai", PatrolZoneMozdok, 30, 150, 30, 500, "RADIO", 100, 230, 30, 200, "RADIO" )
		RedCasDispatcher:SetSquadronBaiPatrolInterval( "MozdokRedCASai", 2, 30, 180, 1 )
		--RedCasDispatcher:SetSquadronOverhead( "MozdokRedCASai", 0.5 )
		RedCasDispatcher:SetSquadronTakeoffInAir("MozdokRedCASai")
		RedCasDispatcher:SetSquadronLandingAtRunway("MozdokRedCASai")
		--RedCasDispatcher:SetTacticalDisplay( true )
		--RedCasDispatcher:SetDefenseReactivityHigh()	
	end
	
	if MaykopOwner == "red" then
		--Red team detection scheme
		RedCasDetSetZone = SET_ZONE:New()
		RedCasDetSetZone:FilterPrefixes( { "MaykopCASzone" } )
		RedCasDetSetZone:FilterStart()
		RedCasDetection = DETECTION_ZONES:New( RedCasDetSetZone, coalition.side.BLUE )
		RedCasDispatcher = AI_A2G_DISPATCHER:New( RedCasDetection )
		RedCasDispatcher:SetSquadron( "MaykopRedCASai", AIRBASE.Caucasus.Maykop_Khanskaya, { "MaykopRedCASai" }, 3 )
		RedCasDispatcher:SetSquadronBaiPatrol2( "MaykopRedCASai", PatrolZoneMaykop, 30, 150, 30, 500, "RADIO", 100, 230, 30, 200, "RADIO" )
		RedCasDispatcher:SetSquadronBaiPatrolInterval( "MaykopRedCASai", 2, 30, 180, 1 )
		--RedCasDispatcher:SetSquadronOverhead( "MaykopRedCASai", 0.5 )
		RedCasDispatcher:SetSquadronTakeoffInAir("MaykopRedCASai")
		RedCasDispatcher:SetSquadronLandingAtRunway("MaykopRedCASai")
		--RedCasDispatcher:SetTacticalDisplay( true )
		--RedCasDispatcher:SetDefenseReactivityHigh()
	end
	
	if SochiOwner == "blue" then
		BlueCasDetSetZone = SET_ZONE:New()
		BlueCasDetSetZone:FilterPrefixes( { "SochiCASzone" } )
		BlueCasDetSetZone:FilterStart()
		BlueCasDetection = DETECTION_ZONES:New( BlueCasDetSetZone, coalition.side.RED )
		BlueCasDispatcher = AI_A2G_DISPATCHER:New( BlueCasDetection )
		BlueCasDispatcher:SetSquadron( "SochiBlueCASai", AIRBASE.Caucasus.Sochi_Adler, { "SochiBlueCASai" }, 3 )
		BlueCasDispatcher:SetSquadronBaiPatrol2( "SochiBlueCASai", PatrolZoneSochi, 30, 150, 30, 500, "RADIO", 100, 230, 30, 200, "RADIO" )
		BlueCasDispatcher:SetSquadronBaiPatrolInterval( "SochiBlueCASai", 2, 30, 180, 1 )
		--BlueCasDispatcher:SetSquadronOverhead( "VazBlueCASai", 0.5 )
		BlueCasDispatcher:SetSquadronTakeoffInAir("SochiBlueCASai")
		BlueCasDispatcher:SetSquadronLandingAtRunway("SochiBlueCASai")
	end

	if VazOwner == "blue" then
		--Blue team detection scheme
		BlueCasDetSetZone = SET_ZONE:New()
		BlueCasDetSetZone:FilterPrefixes( { "VazCASzone" } )
		BlueCasDetSetZone:FilterStart()
		BlueCasDetection = DETECTION_ZONES:New( BlueCasDetSetZone, coalition.side.RED )
		BlueCasDispatcher = AI_A2G_DISPATCHER:New( BlueCasDetection )
		BlueCasDispatcher:SetSquadron( "VazBlueCASai", AIRBASE.Caucasus.Vaziani, { "VazBlueCASai" }, 3 )
		BlueCasDispatcher:SetSquadronBaiPatrol2( "VazBlueCASai", PatrolZoneVaz, 30, 150, 30, 500, "RADIO", 100, 230, 30, 200, "RADIO" )
		BlueCasDispatcher:SetSquadronBaiPatrolInterval( "VazBlueCASai", 2, 30, 180, 1 )
		--BlueCasDispatcher:SetSquadronOverhead( "VazBlueCASai", 0.5 )
		BlueCasDispatcher:SetSquadronTakeoffInAir("VazBlueCASai")
		BlueCasDispatcher:SetSquadronLandingAtRunway("VazBlueCASai")
		--BlueCasDispatcher:SetTacticalDisplay( true )
		--BlueCasDispatcher:SetDefenseReactivityHigh()
	end
	
end
return M