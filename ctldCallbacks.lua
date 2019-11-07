local function unpack(_args)
    log:info('Unpack: $1', _args)
    local groupName = _args.spawnedGroup:getName()
    local group = Group.getByName(groupName)
    if group == nil then
        log:warn("Group $1 is nil", groupName)
        return
    end
    local firstUnit = group:getUnit(1)
    if firstUnit == nil then
        log:warn("First unit in group $1 is nil", groupName)
    end
    table.insert(rsrState.CTLD, {
        name = groupName,
        pos = firstUnit:getPosition().p
    })
    writeState(rsrState)
end

ctld.addCallback(function(_args)
    if _args.action and _args.action == "unpack" then
        unpack(_args)
    end
end)
