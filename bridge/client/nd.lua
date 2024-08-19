if GetResourceState('ND_Core') ~= 'started' then return end

local NDCore = exports['ND_Core']
local playerLoaded = false

RegisterNetEvent('ND:characterLoaded', function()
    playerLoaded = true
end)

RegisterNetEvent('ND:characterUnloaded', function()
    playerLoaded = false
end)