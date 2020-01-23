require ("Moose")
local inspect = require("inspect")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("QueryDCS", "info")

local _firstTimeSetup = false

function M.getAllBaseOwnership(_firstTimeSetup)
    local baseOwnership = { airbases = { red = {}, blue = {}, neutral = {} },
                            FOBs = { red = {}, blue = {}, neutral = {} } }

--[[
{
	"baseOwnership": 
	{
		"airbases": 
		{
		  "blue": [ "Sukhumi-Babushara", "Vaziani", "Batumi", "Gudauta", "Soganlug", "Tbilisi-Lochini", "Senaki-Kolkhi", "Kobuleti",  "Kutaisi" ],
		  "neutral": [],
		  "red": [ "Novorossiysk", "Krasnodar-Pashkovsky", "Maykop-Khanskaya", "Sochi-Adler", "Anapa-Vityazevo", "Mozdok", "Gelendzhik", "Mineralnye Vody", "Nalchik", "Krasnodar-Center", "Krymsk", "Beslan" ]
		},
		"farps": 
		{
		  "blue": [ "BlueStagingPoint", "LN16", "MN61", "LM56", "LN90", "MM75", "KN70", "MM69", "LN21", "KN76", "GG19", "GH03", "LM95", "GH17", "KN53", "MM25", "RedBeachhead" ],
		  "neutral": [],
		  "red": [ "LP17", "EJ08", "FJ53", "GJ38", "BlueBeachhead", "FJ03", "EK51", "EK20", "FJ69", "MP24", "EK14", "DK65", "FJ95", "EJ98", "GJ22", "RedStagingPoint", "LP31", "DK61", "EJ34", "LP65", "MN12", "MN19", "KP74", "MN34" ]
		}
	}
 }
--]]
	--mr: intercept first time campaign setup here to read FOB ownership from Trigger Zone Name or Color
	if _firstTimeSetup then
		--[[
		--mr: assign side by Trigger Zone name
		local _FOBinitZones = {}
		
		for _k, _anyZone in ipairs(env.mission.triggers.zones) do
			local _zoneName = _anyZone.name
			if string.match(_zoneName, "FOBinit") then --mr: add FOB to zone name just in case "init" string found elsewhere in MIZ tables
				table.insert(_FOBinitZones,_zoneName)
			end
		end
		
		local _FOBside = ""
		for _k, _initZone in ipairs(_FOBinitZones) do
			local _initZoneName = string.match(_initZone,("^%w+")) --"MM75 FOBinit red" = "MM75"
			local _FOBside = string.match(_initZone,("%w+$")) --"MM75 FOBinit red" = "red"
			if _FOBside == nil then 
				_FOBside = "neutral"
				log:error("No side specified for FOB init trigger zones $1", inspect(_initZone))
			end
			table.insert(baseOwnership.FOBs[_FOBside], _initZoneName)
		end

		table.sort(_FOBinitZones)
		log:info("FOB init trigger zones in mission are $1", inspect(_FOBinitZones))
		]]--
		
		--mr: assign by Trigger Zone color, i.e.  RGB values 0 to 1: [1,0,0] = red, [0,1,0] = green (netural), [0,0,1] = blue
		for _k, _anyZone in ipairs(env.mission.triggers.zones) do
			local _zoneName = _anyZone.name
			if string.match(_zoneName, "FOBinit") then --mr: add "FOB" to "init" in zone name just in case "init" string elsewhere in MIZ file
			
				local _initZoneName = string.match(_zoneName,("^%w+")) --"MM75 FOBinit" = "MM75"
				local _zoneColor = _anyZone.color
				local _FOBside = "none"
				local _whiteInitZoneCheck = 0
				if _zoneColor[1] == 1 then 
					_FOBside = "red" 
					_whiteInitZoneCheck = _whiteInitZoneCheck + 1
				elseif _zoneColor[3] == 1 then 
					_FOBside = "blue"
					_whiteInitZoneCheck = _whiteInitZoneCheck + 1
				elseif _zoneColor[2] == 1 then --green
					_FOBside = "neutral"
					_whiteInitZoneCheck = _whiteInitZoneCheck + 1
				end
				
				if _FOBside == "none" then
					if _whiteInitZoneCheck == 3 then
						log:error("$1 FOBinit Trigger Zone color not changed from white. Setting as neutral",_initZoneName)
					else
					
						log:error("$1 FOBinit Trigger Zone color not set to red, blue or green. Setting as neutral",_initZoneName)
					end
					_FOBside = "neutral"
				end
				table.insert(baseOwnership.FOBs[_FOBside], _initZoneName)
			end
		end
	end
	
    for _, base in ipairs(AIRBASE.GetAllAirbases()) do
        local baseName = base:GetName()
        local sideName = utils.getSideName(base:GetCoalition())
        if sideName == nil then
            log:info("Got no coalition for $1; setting to neutral", baseName)
            sideName = "neutral"
        end
        if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
            table.insert(baseOwnership.airbases[sideName], baseName)

		--mr: intercept to respect previous FOB ownership = prevents slot blocker = allow spawning even when no friendly units in 2km of FARP helipad
        elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD and not _firstTimeSetup then
			
			--mr: TODO CHECK sidename as set by DCS against current baseOwnership.  If mismatch, then detect current CC owner.
			--[[
			local _currBaseOwner = {}
			for _k, _FOBzoneName in ipairs(baseOwnership.FOBs) do
				
					local _initZoneName = string.match(baseName)
					local _zoneColor = _anyZone.color
					_FOBside = "none"
					if _zoneColor[1] == 255 then 
						_FOBside = "red" 
					elseif _zoneColor[3] == 255 then 
						_FOBside = "blue"
					elseif _zoneColor[2] == 255 then --green
						_FOBside = "neutral"
					end
					
					if _FOBside == "none" then
						--log:error("No side specified by FOBinit trigger zone colour $1", inspect(_initZoneName))
					end
					
					table.insert(baseOwnership.FOBs[_FOBside], _initZoneName)
				end
			end
			--]]
			table.insert(baseOwnership.FOBs[sideName], baseName) 
			
        end
    end
    log:info("baseOwnership = $1", inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end

return M


--[[
	local FOBinitZones = missionUtils.getZoneNames(mission, " init$")
	log:info("FOB init trigger zones in mission are $1", inspect(FOBinitZones))
	for _FOB, FOBinitName in ipairs(FOBinitZones) do
		
		if utils.matchesBaseName(baseName, zoneBaseName) then
			

		end
	end


	function M.getPickupZones(mission)
		local zones = missionUtils.getZoneNames(mission, " pickup$")
		log:info("Pickup zones in mission are $1", inspect(zones))
		local pickupZones = {}
		for _, zone in ipairs(zones) do
			table.insert(pickupZones, { zone, "none", -1, "no", 0 })
		end
		return pickupZones
	end
--]]

--[[
	"FOBs":{
			  "blue": [ "BlueStagingPoint", "LN16", "MN61", "LM56", "LN90", "MM75", "KN70", "MM69", "LN21", "KN76", "GG19", "GH03", "LM95", "GH17", "KN53", "MM25", "RedBeachhead" ],
			  "neutral": [],
			  "red": [ "LP17", "EJ08", "FJ53", "GJ38", "BlueBeachhead", "FJ03", "EK51", "EK20", "FJ69", "MP24", "EK14", "DK65", "FJ95", "EJ98", "GJ22", "RedStagingPoint", "LP31", "DK61", "EJ34", "LP65", "MN12", "MN19", "KP74", "MN34" ]
			}
	--]]

--]]
