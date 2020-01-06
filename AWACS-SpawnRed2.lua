function spawnRedAWACS2()
    redAWACSSpawn2 = SPAWN:New("Red AWACS 2")
                          :InitLimit(1, 99)
                          :SpawnScheduled(1800, 0.1)
end

spawnRedAWACS2()