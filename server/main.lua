lib.versionCheck('Peak-Scripts/peak_warehouse')
if not lib.checkDependency('ox_inventory', '2.41.0', true) then return end
if not lib.checkDependency('ox_lib', '3.25.0', true) then return end

local busyStates = {}
local spawnedEntities = {
    guards = {},
    props = {}
}
local config = require 'config.client'
local sharedConfig = require 'config.shared'
local serverConfig = require 'config.server'
local utils = require 'modules.utils.server'
local ELECTRICAL_BOX_ID = 'electrical_box' -- Do not touch this
GlobalState.Cooldown = false

local function resetAllStates()
    for entityId, _ in pairs(busyStates) do
        busyStates[entityId] = false
    end
end

RegisterNetEvent('peak_warehouse:server:setBusyState')
AddEventHandler('peak_warehouse:server:setBusyState', function(entityId, isBusy)
    busyStates[entityId] = isBusy
end)

lib.callback.register('peak_warehouse:server:checkBusyState', function(_, entityId) 
    local state = busyStates[entityId] or false
    return state
end)

local function cleanupGuards()
    
    for _, netId in ipairs(spawnedEntities.guards) do
        local ped = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        else
            lib.print.error('Guard with netId', netId, 'does not exist')
        end
    end

    spawnedEntities.guards = {}
end

RegisterNetEvent('peak_warehouse:server:setCooldown', function()
    GlobalState.Cooldown = true
    local cooldown = math.random(config.minCooldown, config.maxCooldown) * 60000
    Wait(cooldown)
    GlobalState.Cooldown = false
    resetAllStates()
    cleanupGuards()
end)

--- @param source integer
lib.callback.register('peak_warehouse:server:removeItem', function(source)
    local player = GetPlayer(source)
    if not player then return end

    local distance = utils.checkDistance(source, config.interactLocations.electricalBox)
    if not distance then return end

    exports.ox_inventory:RemoveItem(source, serverConfig.requiredItem, 1)

    if serverConfig.discordLogs.enabled then
        local logData = {
            title = 'Item Removed',
            message = "**Item Removed**: " .. tostring(serverConfig.requiredItem) .. "\n**Distance:** " .. tostring(distance),
            color = 16711680, -- Red color
            link = serverConfig.discordLogs.webhookURL
        }
        utils.discordLogs(source, logData)
    end

    return true
end)

--- @param source integer
lib.callback.register('peak_warehouse:server:boxReward', function(source)
    local player = GetPlayer(source)
    if not player then return end

    local distance = utils.checkPlayerDistance(source)
    if not distance then return end

    local isBusy = busyStates[ELECTRICAL_BOX_ID]
    if not isBusy then return end
    
    local items = utils.generateLoot(serverConfig.items, serverConfig.lootMin, serverConfig.lootMax)

    for item, itemData in pairs(items) do
        exports.ox_inventory:AddItem(source, item, itemData.amount, itemData.metadata)

        if serverConfig.discordLogs.enabled then
            local logData = {
                title = 'Added Item',
                message = "**Item Added**: " .. tostring(item) .. "\n**Amount:** " .. tostring(itemData.amount) .. "\n**Distance:** " .. tostring(distance) ,
                color = 16711680, -- Red color
                link = serverConfig.discordLogs.webhookURL
            }
            utils.discordLogs(source, logData)
        end
    end

    return true
end)

lib.callback.register('peak_warehouse:server:createC4', function()
    if not GlobalState.RobberyStarted then return end
    
    local coords = config.interactLocations.electricalBox
    local c4Prop = CreateObjectNoOffset(`prop_c4_final_green`, coords.x , coords.y -0.1, coords.z, false, false, true)
    SetEntityHeading(c4Prop, 0.0)
    FreezeEntityPosition(c4Prop, true)

    Wait(10000)

    if c4Prop and DoesEntityExist(c4Prop) then
        DeleteEntity(c4Prop)
    end

    return true
end)

RegisterNetEvent('peak_warehouse:server:startRobbery', function()
    local player = GetPlayer(source)
    if not player then return end

    local distance = utils.checkDistance(source, config.interactLocations.electricalBox)
    if not distance then return end

    local isBusy = busyStates[ELECTRICAL_BOX_ID]
    if isBusy then
        utils.notify(source, locale('notify.already_blown'), 'error')
        return
    end

    if GlobalState.Cooldown then
        utils.notify(source, locale('notify.cooldown'), 'error')
        return
    end
  
    local copCount = CheckCopCount()
    if copCount < sharedConfig.requiredCops then
        utils.notify(source, locale('notify.not_enough_police'), 'error')
        return
    end

    GlobalState.RobberyStarted = true
    TriggerClientEvent('peak_warehouse:client:startRobbery', source)
end)

local function createObjects()
    for i = 1, #config.boxLocations do
        local coord = config.boxLocations[i].coords
        local model = joaat(config.warehouseObjects[math.random(1, #config.warehouseObjects)])

        local entity = CreateObjectNoOffset(model, coord.x, coord.y, coord.z, true, true, true)
        while not DoesEntityExist(entity) do Wait(25) end
        FreezeEntityPosition(entity, true)

        local netId = NetworkGetNetworkIdFromEntity(entity)
        if not netId then
            lib.print.error('Failed to get netId for prop')
            return
        end

        spawnedEntities.props[#spawnedEntities.props + 1] = netId
    end
end

RegisterNetEvent('peak_warehouse:server:spawnGuards', function()
    if not GlobalState.RobberyStarted then return end

    for _, guard in pairs(config.guardList) do
        
        local ped = CreatePed(4, joaat(guard.model), guard.coords.x, guard.coords.y, guard.coords.z, guard.heading, true, false)
        GiveWeaponToPed(ped, joaat(guard.weapon), 255, false, true)

        while not DoesEntityExist(ped) do
            Wait(25)
        end

        local netId = NetworkGetNetworkIdFromEntity(ped)
        if not netId then
            lib.print.error('Failed to get netId for guard')
            return
        end
        
        Entity(ped).state.ped = true
        spawnedEntities.guards[#spawnedEntities.guards + 1] = netId
    end
end)

local function cleanupEntities()
    
    for _, netId in ipairs(spawnedEntities.props) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        else
            lib.print.error('Prop with netId', netId, 'does not exist')
        end
    end

    for _, netId in ipairs(spawnedEntities.guards) do
        local ped = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        else
            lib.print.error('Guard with netId', netId, 'does not exist')
        end
    end

    spawnedEntities.props = {}
    spawnedEntities.guards = {}
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    createObjects()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    cleanupEntities()
end)
