local bridge = {}

RegisterNetEvent('ND:characterUnloaded', function()
    LocalPlayer.state.isLoggedIn = false
    OnPlayerLoaded()
end)

RegisterNetEvent('ND:characterLoaded', function()
    LocalPlayer.state.isLoggedIn = true
    OnPlayerUnload()
end)

function bridge.hasPlayerLoaded()
    return LocalPlayer.state.isLoggedIn
end

return bridge