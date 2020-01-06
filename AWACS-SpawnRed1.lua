function spawnRedAWACS1()
    redAWACSSpawn1 = SPAWN:New("Red AWACS")
                          :InitLimit(1, 99)
                          :SpawnScheduled(1800, 0.1)
end

spawnRedAWACS1()