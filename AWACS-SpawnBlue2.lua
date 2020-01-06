function spawnBlueAWACS2()
    blueAWACSSpawn2 = SPAWN:New("Blue AWACS 2")
                           :InitLimit(1, 99)
                           :SpawnScheduled(1800, 0.1)
end

spawnBlueAWACS2()