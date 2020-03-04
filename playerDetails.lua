-- determine players UCID
-- derived from SimpleSlotBlockGameGUI.lua

--[[
	'id'    : playerID
	'name'  : player name
	'side'  : 0 - spectators, 1 - red, 2 - blue
	'slot'  : slotID of the player or 
	'ping'  : ping of the player in ms
	'ipaddr': IP address of the player, SERVER ONLY
	'ucid'  : Unique Client Identifier, SERVER ONLY
--]]

require("mist_4_3_74")
local log = mist.Logger:new("playeDetails", "info")

-- net.get_my_player_id( ) -- Returns the playerID of the local player. Always returns 1 for server.

local M = {}
function M.getPlayerDetails(_passedPlayerName)
    local _matchedPlayerDetails = {}
    if DCS.isServer() and DCS.isMultiplayer() then
        -- must check this to prevent a possible CTD by using a_do_script before the game is ready to use a_do_script
        if DCS.getModelTime() > 1 then

            local _playersList = net.get_player_list()
            for _playerIDIndex, _playerID in pairs(_playersList) do

                -- is player still in a valid slot
                local _playerDetails = net.get_player_info(_playerID)
                if _playerDetails ~= nil and _playerDetails.side ~= 0 and _playerDetails.slot ~= "" and _playerDetails.slot ~= nil then

                    _playerName = net.get_player_info(_playerID, 'name')
                    if _passedPlayerName == _playerName then
                        _matchedPlayerDetails = _playerDetails
                    end
                end
            end
        end
    end
    return _matchedPlayerDetails
end
return M