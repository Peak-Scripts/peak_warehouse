if GetResourceState('qbx_core') ~= 'started' then return end

--- @param source integer
function GetPlayer(source)
    if not source then return end

    return exports.qbx_core:GetPlayer(source)
end

function CheckCopCount()
    local amount = 0
    amount = exports.qbx_core:GetDutyCountType('leo')
    
    return amount
end