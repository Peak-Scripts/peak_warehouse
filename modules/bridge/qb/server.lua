
local bridge = {}
local QBCore = exports['qb-core']:GetCoreObject()

--- @param source integer
function bridge.getPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function bridge.checkCopCount()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()

    for _, player in pairs(players) do
        if player.PlayerData.job.type == 'leo' and player.PlayerData.job.onduty then
            amount += 1
        end
    end
    return amount
end

--- @param source integer
function bridge.hasPoliceJob(source)
    local player = QBCore.Functions.GetPlayer(source)

    if player.PlayerData.job.name == 'police' then
        return true
    end

    return nil
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    OnPlayerLoaded()
end)

return bridge