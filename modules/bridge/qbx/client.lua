local bridge = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    OnPlayerLoaded()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    OnPlayerUnload()
end)

function bridge.hasPlayerLoaded()
    return LocalPlayer.state.isLoggedIn
end

return bridge