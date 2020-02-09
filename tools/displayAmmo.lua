-- for use with the displayAmmo.miz file to update restrictions in weaponManager

function displayAmmo(_arg, time)
    local unit = Unit.getByName("Player")
    local ammo = unit:getAmmo()
    local message = "Ammo:\n"
    for i = 1, #ammo do
        local typeName = ammo[i].desc.typeName
        local count = ammo[i].count
        message = string.format("%s%s x%d\n", message, typeName, count)
    end
    trigger.action.outText(message, 4)
    return time + 5
end

timer.scheduleFunction(displayAmmo, nil, timer.getTime() + 5)
