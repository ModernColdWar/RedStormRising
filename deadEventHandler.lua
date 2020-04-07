local logging = require("logging")
require("Moose")
local baseOwnershipCheck = require("baseOwnershipCheck")

local log = logging.Logger:new("deadEventHandler")

local M = {}

function M.register()

    M.eventHandler = EVENTHANDLER:New():HandleEvent(EVENTS.Dead) --MOOSE

    function M.eventHandler:OnEventDead(Event)
        --MOOSE
        --log:info("eventHander DEAD: event: $1",Event)
        log:info("eventHander DEAD: TYPE: $1, DCS NAME: $2, UNIT: $3", Event.IniTypeName, Event.IniDCSUnitName, Event.IniDCSUnit)

        local _deadUnitCategory = Event.IniObjectCategory
        local _deadUnitType = Event.IniTypeName
        local _deadUnitName = Event.IniDCSUnitName
        --log:info("eventHander DEAD: TEST1 DEAD LC = nil: $1",_deadUnit == nil)


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

                local _storedLogisticsCentreBase = "NoLCbase"
                local _storedLogisticsCentreName = "NoLCname"
                local _storedLogisticsCentreSideName
                local _storedLogisticsCentreMarkerID

                for _LCsideName, _baseTable in pairs(ctld.logisticCentreObjects) do

                    for _LCbaseName, _storedLogisticsCentre in pairs(_baseTable) do

                        if _storedLogisticsCentre ~= nil then
                            _storedLogisticsCentreName = _storedLogisticsCentre:getName() --getName = DCS function, GetName = MOOSE function
                            _storedLogisticsCentreBase = string.match(_storedLogisticsCentreName, ("^(.+)%sLog")) --"Sochi Logistics Centre #001 red" = "Sochi"
                            _storedLogisticsCentreSideName = string.match(_storedLogisticsCentreName, ("%w+$")) --"Sochi Logistics Centre #001 red" = "red"

                            --log:info("eventHander DEAD: _storedLogisticsCentre: $1, _storedLogisticsCentreName: $2, _storedLogisticsCentreBase: $3, _storedLogisticsCentreSideName: $4", _storedLogisticsCentre, _storedLogisticsCentreName, _storedLogisticsCentreBase, _storedLogisticsCentreSideName)

                        end

                        --log:info("eventHander DEAD: _logisticsCentreName: $1, _deadUnitName: $2", _storedLogisticsCentreName, _deadUnitName)
                        --log:info("eventHander DEAD: _storedLogisticsCentreBase: $1, _LCbaseName: $2", _storedLogisticsCentreBase, _LCbaseName)
                        if _storedLogisticsCentreName == _deadUnitName and _storedLogisticsCentreSideName == _LCsideName and _storedLogisticsCentreBase == _LCbaseName then

                            --log:info("eventHander DEAD (PRE): ctld.logisticCentreObjects[_LCsideName][_LCbaseName]: $1",ctld.logisticCentreObjects[_LCsideName][_LCbaseName])
                            ctld.logisticCentreObjects[_LCsideName][_LCbaseName] = nil
                            --log:info("eventHander DEAD (POST): ctld.logisticCentreObjects[_LCsideName][_LCbaseName]: $1",ctld.logisticCentreObjects[_LCsideName][_LCbaseName])

                            -- remove map marker
                            _storedLogisticsCentreMarkerID = ctld.logisticCentreMarkerID[_LCsideName][_LCbaseName]
                            trigger.action.removeMark(_storedLogisticsCentreMarkerID)
                            ctld.logisticCentreMarkerID[_LCsideName][_LCbaseName] = nil

                            -- (_checkWhichBases,_playerName,_campaignStartSetup)
                            baseOwnershipCheck.baseOwnership = baseOwnershipCheck.getAllBaseOwnership("ALL", "LCdead", false)
                            return
                        end

                    end
                end
            end
        end

    end

end

return M