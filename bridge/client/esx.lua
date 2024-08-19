if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function()
    ESX.PlayerLoaded = true
end)