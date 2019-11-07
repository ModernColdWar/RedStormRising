local function unpack(_args)
    log:info('Unpack: $1', _args)
    local groupName = _args.spawnedGroup:getName()
    table.insert(rsrState.ctldUnpackedGroupNames, groupName)
end

ctld.addCallback(function(_args)
    if _args.action and _args.action == "unpack" then
        unpack(_args)
    end
end)
