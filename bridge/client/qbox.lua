if GetResourceState('qbx_core') ~= 'started' then return end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBX.PlayerData
    PlayerLoaded = true
end)