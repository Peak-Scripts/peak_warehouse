local utils = {}
local config = require 'config.client'
local sharedConfig = require 'config.shared'

if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('ND_Core') ~= 'started' then
    NDCore = exports['ND_Core']
end

--- @param message string
--- @param type string
function utils.notify(message, type)
    if config.notify == 'ox_lib' then
        lib.notify({ description = message, type = type })
    elseif config.notify == 'esx' then
        ESX.ShowNotification(message)
    elseif config.notify == 'qbox' then
        exports.qbx_core:Notify(message, type)
    elseif config.notify == 'nd' then
        NDCore:notify({ title = message, type = type })
    elseif config.notify == 'custom' then
        -- Add your custom notification system here
    end
end

function utils.minigame()
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
    return success
end

--- @param data table
function utils.policeDispatch(data)
    if config.dispatch == 'cd_dispatch' then
        local data = exports.cd_dispatch:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = 'police',
            coords = data.coords,
            title = '10-44 - Warehouse Robbery',
            message = 'Warehouse Robbery, respond code 2 high!',
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 51,
                scale = 1.0,
                colour = 1,
                flashes = false,
                text = '10-44 - Warehouse Robbery',
                time = 5,
                radius = 0,
            }
        })
    elseif config.dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:SuspiciousActivity()
    elseif config.dispatch == 'custom' then
        -- Add your custom dispatch system here
    else
        lib.print.error('No dispatch system was found - please update your config')
    end
end

return utils