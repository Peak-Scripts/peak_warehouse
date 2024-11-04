local bridge = {}

local ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function()
    ESX.PlayerLoaded = true
    OnPlayerLoaded()
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    OnPlayerUnload()
end)

function bridge.hasPlayerLoaded()
    return ESX.PlayerLoaded
end

return bridge