local bridge = {}

local ESX = exports['es_extended']:getSharedObject()

--- @param source integer
function bridge.getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function bridge.checkCopCount()
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

--- @param source integer
function bridge.hasPoliceJob(source)
    local playerData = ESX.GetPlayerData(source)
    local playerJob = playerData.job.name

    if playerJob == 'police' then
        return true
    end

    return nil
end

RegisterNetEvent('esx:playerLoaded', function()
    OnPlayerLoaded()
end)

return bridge