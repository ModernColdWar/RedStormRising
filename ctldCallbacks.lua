local function unpack(state, _args)
    log:info('Unpacked: $1', _args)
    local groupName = _args.spawnedGroup:getName()
    table.insert(state.ctldUnpackedGroupNames, groupName)
end

ctld.addCallback(function(_args)
    if _args.action and _args.action == "unpack" then
        unpack(rsr.state, _args)
    end
end)
