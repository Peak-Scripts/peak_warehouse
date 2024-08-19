if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

--- @param source integer
function GetPlayer(source)
    if not source then return end

    return ESX.GetPlayerFromId(source)
end

function CheckCopCount()
    local amount = 0
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do 
        local xPlayer = players[i]
        if xPlayer.job.name == 'police' then
            amount += 1
        end
    end
    return amount
end