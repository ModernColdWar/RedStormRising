require("mist_4_3_74")
require("Moose")

local utils = require("utils")
local inspect = require("inspect")
local baseOwnershipCheck = require("baseOwnershipCheck")

local log = mist.Logger:new("deadEventHandler", "info")

local M = {}

function M.register()

    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.Dead) --MOOSE
	
    function M.eventHandler:OnEventDead(Event)--MOOSE
		--log:info("eventHander DEAD: event: $1",inspect(Event, { newline = " ", indent = "" }))
		log:info("eventHander DEAD: TYPE: $1, DCS NAME: $2, UNIT: $3",Event.IniTypeName,Event.IniDCSUnitName,Event.IniDCSUnit)
		
		local _deadUnit = Event.IniDCSUnit
		local _deadUnitCategory = Event.IniObjectCategory
		local _deadUnitType = Event.IniTypeName
		local _deadUnitName = Event.IniDCSUnitName
		--log:info("eventHander DEAD: TEST1 DEAD LC = nil: $1",mist.utils.basicSerialize(_deadUnit == nil))
		
		
		if _deadUnitCategory == Object.Category.UNIT then

		end
		if _deadUnitCategory == Object.Category.STATIC then
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

			if _deadUnitType == ctld.logisticCentreL3 or _deadUnitType == ctld.logisticCentreL2 then
				
				local _baseName = "NoBase"
				local _storedLogisticsCentreBase = "NoLCbase"
				local _storedLogisticsCentre = "NoLC"
				local _storedLogisticsCentreName = "NoLCname"
				local _storedLogisticsCentreSideName = "NoLCside"
				local _storedLogisticsCentreCoalition = "NoLCcoalition"
				

				for _baseName, _storedLogisticsCentre in pairs(ctld.logisticCentreObjects) do
				
					if _storedLogisticsCentre ~= nil then
						_storedLogisticsCentreName = _storedLogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
						_storedLogisticsCentreBase = string.match(_storedLogisticsCentreName,("^(.+)%sLog")) --"Sochi Logistics Centre #001 red" = "Sochi"
						_storedLogisticsCentreSideName = string.match(_storedLogisticsCentreName,("%w+$")) --"Sochi Logistics Centre #001 red" = "red"
						_storedLogisticsCentreCoalition = utils.getSide(_storedLogisticsCentreSideName)
						
						log:info("eventHander DEAD: _storedLogisticsCentre: $1, _storedLogisticsCentreName: $2, _storedLogisticsCentreBase: $3, _storedLogisticsCentreSideName: $4",_storedLogisticsCentre,_storedLogisticsCentreName,_storedLogisticsCentreBase,_storedLogisticsCentreSideName)
						
						--log:info("eventHander DEAD: TEST2 LC = nil: $1",mist.utils.basicSerialize(_storedLogisticsCentre == nil))
						--log:info("eventHander DEAD: TEST3 LC getLife: $1",mist.utils.basicSerialize(StaticObject.getLife(_storedLogisticsCentre)))
						--log:info("eventHander DEAD: _storedLogisticsCentreBase: $1, _storedLogisticsCentreSideName: $2",_storedLogisticsCentreBase,_storedLogisticsCentreSideName)
					end
					
					log:info("eventHander DEAD: _logisticsCentreName: $1, _deadUnitName: $2",_storedLogisticsCentreName,_deadUnitName)
					log:info("eventHander DEAD: _storedLogisticsCentreBase: $1, _baseName: $2",_storedLogisticsCentreBase,_baseName)
					if _storedLogisticsCentreName == _deadUnitName and _storedLogisticsCentreBase == _baseName then 
						--log:info("eventHander DEAD: ctld.logisticCentreObjects[_baseName]: $1",inspect(ctld.logisticCentreObjects[_baseName], { newline = " ", indent = "" }))
						ctld.logisticCentreObjects[_baseName] = nil
						--log:info("eventHander DEAD: ctld.logisticCentreObjects[_baseName]: $1",inspect(ctld.logisticCentreObjects[_baseName], { newline = " ", indent = "" }))
						-- (_checkWhichBases,_playerName,_campaignStartSetup)
						baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership("ALL","none",false)
						return
					end
					
					
				end
			end
		end
		
	end	

end

return M