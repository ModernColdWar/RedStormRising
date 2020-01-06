function spawnBlueAWACS1()
    blueAWACSSpawn1 = SPAWN:New("Blue AWACS")
                           :InitLimit(1, 99)
                           :SpawnScheduled(1800, 0.1)
end

spawnBlueAWACS1()  
