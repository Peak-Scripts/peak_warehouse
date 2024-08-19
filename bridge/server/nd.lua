if GetResourceState('ND_Core') ~= 'started' then return end

if GetResourceState('ox_inventory') ~= 'started' then
    return lib.print.error('ox inventory is required for ND(who) Core')
end

local NDCore = exports["ND_Core"]

--- @param source integer
function GetPlayer(source)
    if not source then return end

    return NDCore:getPlayer(source)
end

function CheckCopCount()
    local amount = 0
    local players = NDCore:getPlayers()
    local policeDepartments = {'sahp', 'lspd', 'bcso'}

    for _, player in pairs(players) do
        for i=1, #policeDepartments do
            if player.groups[policeDepartments[i]] then
                amount += 1
            end
        end
    end
    
    return amount
end