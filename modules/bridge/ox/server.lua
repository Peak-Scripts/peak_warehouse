local Ox = require '@ox_core.lib.init'
local bridge = {}

--- @param source integer
function bridge.getPlayer(source)
    return Ox.GetPlayer(source)
end

function bridge.checkCopCount()
    local amount = 0
    local players = Ox.GetPlayers({ groups = { ['police'] = 1 } })
    for _, player in pairs(players) do
        amount += 1
    end

    return amount
end

--- @param source integer
function bridge.hasPoliceJob(source)
    local player = Ox.GetPlayer(source)
    local groups = player.getGroups()

    for _, group in pairs(groups) do
        if group == 'police' then
            return true
        end
    end

    return nil
end

AddEventHandler('ox:playerLoaded', function()
    OnPlayerLoaded()
end)

return bridge