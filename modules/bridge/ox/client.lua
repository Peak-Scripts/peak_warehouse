local bridge = {}

AddEventHandler('ox:playerLoaded', function()
    PlayerLoaded = true
    OnPlayerLoaded()
end)

AddEventHandler('ox:playerLogout', function()
    PlayerLoaded = false
    OnPlayerUnload()
end)

function bridge.hasPlayerLoaded()
    return PlayerLoaded
end

return bridge