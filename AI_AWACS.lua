AI_AWACS = {
    ClassName = "AI_AWACS",
}

function AI_AWACS:New(AIGroup, OrbitZone, OrbitAlt, OrbitSpeed)
    local self = BASE:Inherit(self, AI_AIR:New(AIGroup))
    self:AddTransition("*", "Orbit", "*")
    self:AddTransition("*", "Orbit", "Orbiting")
    self:AddTransition("*", "Route", "*")
    self:SetOrbitZone(OrbitZone)
    self:SetOrbitAlt(OrbitAlt)
    self:SetOrbitSpeed(OrbitSpeed)

    return self
end

function AI_AWACS:SetOrbitZone(OrbitZone)
    self:F2({ OrbitZone })
    self.OrbitZone = OrbitZone
end

function AI_AWACS:SetOrbitAlt(OrbitAlt)
    self:F2({ OrbitAlt })
    self.OrbitAlt = OrbitAlt
end

function AI_AWACS:SetOrbitSpeed(OrbitSpeed)
    self:F2({ OrbitSpeed })
    self.OrbitSpeed = OrbitSpeed
end

function AI_AWACS:SetFuelThreshold(FuelThreshold)
    self:F2({ FuelThreshold })
    self.FuelThresholdPercentage = FuelThreshold
end

function AI_AWACS:SetDamageThreshold(DamageThreshold)
    self:F2({ DamageThreshold })
    self.PatrolDamageThreshold = DamageThreshold
end

function AI_AWACS:onafterStart(Controllable, From, Event, To)
    BASE:E("Inside AI_AWACS:onafterStart")
    self:GetParent(self).onafterStart(self, Controllable, From, Event, To)
    self:__Route(3)
end

function AI_AWACS:onafterOrbit(AIGroup, From, Event, To)
    BASE:E("Inside AI_AWACS:onafterOrbit")

    if AIGroup:IsAlive() then
        local Tasks = {}
        --Tasks[#Tasks+1] = AIGroup:TaskOrbitCircle(self.OrbitAlt, self.OrbitSpeed)
        local OrbitCoord = self.OrbitZone:GetCoordinate()
        Tasks[#Tasks + 1] = AIGroup:TaskOrbit(OrbitCoord, self.OrbitAlt, self.OrbitSpeed)
        AIGroup:SetTask(
                AIGroup:TaskCombo(
                        Tasks
                ), 1
        )
    end
end

function AI_AWACS:onafterStatus()
    if self.Controllable and self.Controllable:IsAlive() then

        local RTB = false

        local DistanceFromHomeBase = self.HomeAirbase:GetCoordinate():Get2DDistance(self.Controllable:GetCoordinate())

        if not self:Is("Holding") and not self:Is("Returning") then
            local DistanceFromHomeBase = self.HomeAirbase:GetCoordinate():Get2DDistance(self.Controllable:GetCoordinate())

            if DistanceFromHomeBase > self.DisengageRadius then
                self:E(self.Controllable:GetName() .. " is too far from home base, RTB!")
                self:Hold(300)
                RTB = false
            end
        end

        if not self:Is("Fuel") and not self:Is("Home") then

            local Fuel = self.Controllable:GetFuelMin()

            -- If the fuel in the controllable is below the treshold percentage,
            -- then send for refuel in case of a tanker, otherwise RTB.
            if Fuel < self.FuelThresholdPercentage then
                BASE:E("Checking fuel")
                if self.TankerName then
                    self:E(self.Controllable:GetName() .. " is out of fuel: " .. Fuel .. " ... Refuelling at Tanker!")
                    --self:Refuel()
                else
                    self:E(self.Controllable:GetName() .. " is out of fuel: " .. Fuel .. " ... RTB!")
                    local OldAIControllable = self.Controllable

                    local OrbitTask = OldAIControllable:TaskOrbitCircle(math.random(self.PatrolFloorAltitude, self.PatrolCeilingAltitude), self.PatrolMinSpeed)
                    local TimedOrbitTask = OldAIControllable:TaskControlled(OrbitTask, OldAIControllable:TaskCondition(nil, nil, nil, nil, self.OutOfFuelOrbitTime, nil))
                    OldAIControllable:SetTask(TimedOrbitTask, 10)

                    --self:Fuel()
                    RTB = true
                end
            else
            end
        end

        -- TODO: Check GROUP damage function.
        local Damage = self.Controllable:GetLife()
        local InitialLife = self.Controllable:GetLife0()

        -- If the group is damaged, then RTB.
        -- Note that a group can consist of more units, so if one unit is damaged of a group, the mission may continue.
        -- The damaged unit will RTB due to DCS logic, and the others will continue to engage.
        if (Damage / InitialLife) < self.PatrolDamageThreshold then
            self:E(self.Controllable:GetName() .. " is damaged: " .. Damage .. " ... RTB!")
            self:Damaged()
            RTB = true
            self:SetStatusOff()
        end

        -- Check if planes went RTB and are out of control.
        -- We only check if planes are out of control, when they are in duty.
        if self.Controllable:HasTask() == false then
            if not self:Is("Started") and
                    not self:Is("Stopped") and
                    not self:Is("Fuel") and
                    not self:Is("Damaged") and
                    not self:Is("Home") then
                if self.IdleCount >= 10 then
                    if Damage ~= InitialLife then
                        self:Damaged()
                    else
                        self:E(self.Controllable:GetName() .. " control lost! ")

                        self:LostControl()
                    end
                else
                    self.IdleCount = self.IdleCount + 1
                end
            end
        else
            self.IdleCount = 0
        end

        if RTB == true then
            self:__RTB(self.TaskDelay)
        end

        if not self:Is("Home") then
            self:__Status(10)
        end

    end
end

function AI_AWACS:onafterRoute(AIGroup, From, Event, To)
    BASE:E("Inside AI_AWACS:onafterRoute")
    if self.Controllable:IsAlive() then
        local PatrolRoute = {}
        local EngageRoute = {}
        local tasks = {}

        local CurrentCoord = self.Controllable:GetCoordinate()
        local wp = {}
        wp[1] = CurrentCoord:WaypointAir("BARO", _type, _action, 400, true, self.HomeAirbase, nil, "Route")
        --[[
        local CurrentPointVec2 = POINT_VEC2:NewFromVec2(CurrentVec2)
        local CurrentRoutePoint = CurrentPointVec2:WaypointGround()
        
        EngageRoute[#EngageRoute+1] = CurrentRoutePoint
        --]]

        local ToTargetVec3 = self.OrbitZone:GetVec3()
        local ToTargetCoord = COORDINATE:NewFromVec3(ToTargetVec3)
        ToTargetCoord.y = self.OrbitAlt
        BASE:E("Coord Alt " .. ToTargetCoord.y)
        wp[2] = ToTargetCoord:WaypointAir("BARO", _type, _action, 400, true, self.HomeAirbase, nil, "Orbit Waypoint")

        tasks = self.Controllable:TaskFunction("AI_AWACS.Orbit", self)
        self.Controllable:SetTaskWaypoint(wp[2], tasks)

        local Waypoints = {}

        for i, p in ipairs(wp) do
            table.insert(Waypoints, i, wp[i])
        end

        self.Controllable:Route(Waypoints, 0.5)
    end

end

function AI_AWACS.Orbit(AIGroup, Fsm)
    BASE:E("Inside AI_AWACS.Orbit")
    if Fsm.Controllable:IsAlive() then
        Fsm:__Orbit(3)
    end
end

function AI_AWACS:onafterHome(AIGroup, From, Event, To)
    BASE:E("Inside AI_AWACS:onafterHome")
    self:F({ AIGroup, From, Event, To })

    self:E("Group " .. self.Controllable:GetName() .. " ... Home! ( " .. self:GetState() .. " )")

    if AIGroup and AIGroup:IsAlive() then
        AIGroup:Destroy(true)
    end
end