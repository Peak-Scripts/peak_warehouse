if GetResourceState('ox_core') ~= 'started' then return end

AddEventHandler('ox:playerLoaded', function()
    playerLoaded = true
end)

function HasPlayerLoaded()
    return playerLoaded
end


