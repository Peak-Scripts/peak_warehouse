local bridge = {}

--- @param source integer
function bridge.getPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

function bridge.checkCopCount()
    return exports.qbx_core:GetDutyCountType('leo')
end

--- @param source integer
function bridge.hasPoliceJob(source)
    local hasJob = exports.qbx_core:HasPrimaryGroup(source, 'police')
    if not hasJob then return false end

    return true
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    OnPlayerLoaded()
end)

return bridge