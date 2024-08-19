if GetResourceState('ox_core') ~= 'started' then return end

Ox = require '@ox_core.lib.init'

--- @param source integer
function GetPlayer(source)
    if not source then return end

    return Ox.GetPlayer(source)
end

function CheckCopCount()
    local amount = 0
    local players = Ox.GetPlayers({ groups = { ["police"] = 1 } })
    for _, player in pairs(players) do
        amount += 1
    end

    return amount
end