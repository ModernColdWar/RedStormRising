require("mist_4_3_74")
require("Moose")
require("CTLD_config")
local utils = require("utils")
local inspect = require("inspect")
local baseOwnershipCheck = require("baseOwnershipCheck")

local log = mist.Logger:new("deadEventHandler", "info")

local M = {}



function M.register()

    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.Dead) --MOOSE
	
    function M.eventHandler:OnEventDead(Event)--MOOSE
		--log:info("eventHander DEAD: event: $1",inspect(Event, { newline = " ", indent = "" }))
		-- TYPE: .Command Center, DCS NAME: LCtest, UNIT: { ["id_"] = 8000168, }
		log:info("eventHander DEAD: TYPE: $1, DCS NAME: $2, UNIT: $3",Event.IniTypeName,Event.IniDCSUnitName,Event.IniDCSUnit)
		
		if Event.IniObjectCategory == Object.Category.UNIT then

		end
		log:info("eventHander DEAD: Event.IniObjectCategory: $1",Event.IniObjectCategory)
		if Event.IniObjectCategory == Object.Category.STATIC then
			--[[
			-- MOOSE
			  if Event.IniObjectCategory == Object.Category.STATIC then
				Event.IniDCSUnit = Event.initiator
				Event.IniDCSUnitName = Event.IniDCSUnit:getName()
				Event.IniUnitName = Event.IniDCSUnitName
				Event.IniUnit = STATIC:FindByName( Event.IniDCSUnitName, false )
				Event.IniCoalition = Event.IniDCSUnit:getCoalition()
				Event.IniCategory = Event.IniDCSUnit:getDesc().category
				Event.IniTypeName = Event.IniDCSUnit:getTypeName()
			  end
			--]]
			log:info("eventHander DEAD: Event.IniTypeName: $1",Event.IniTypeName)
			if Event.IniTypeName == ctld.logisticCentreL3 or Event.IniTypeName == ctld.logisticCentreL2 then
				
				local _logisticsCentre = "NoLC"
				local _logisticsCentreName = "NoLCname"
				local _logisticsCentreSide = "NoLCside"
				local _logisticsCentreCoalition = "NoLCcoalition"
				
				for _k, baseName in ipairs(ctld.logisticCentreObjects) do
				
					_logisticsCentre = ctld.logisticCentreObjects[baseName]
					
					log:info("eventHander DEAD: baseName: $1, _logisticsCentre: $2",baseName,_logisticsCentre)
					
					if _logisticsCentre ~= nil then
						_logisticsCentreName = _logisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
						_logisticsCentreSide = string.match(_logisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
						_logisticsCentreCoalition = utils.getSide(_logisticsCentreSide)
						
						log:info("eventHander DEAD: baseName: $1, _logisticsCentreName: $2",baseName,_logisticsCentreName)
						
						if _logisticsCentreName == Event.IniDCSUnitName then
							table.remove(ctld.logisticCentreObjects[baseName],1) --assumption that logisitics centre for base is always in position 1
							-- (_checkWhichBases,_playerName,_campaignStartSetup)
							baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership("ALL","none",false)
						end
					end
				end
			end
		end
	end	

end

return M