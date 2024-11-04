lib.versionCheck('Peak-Scripts/peak_warehouse')

local globalState = GlobalState
local spawnedEntities = {
    guards = {},
}
local config = require 'config.client'
local serverConfig = require 'config.server'
local utils = require 'modules.utils.server'
globalState.cooldown = false
globalState.robberyStarted = false

function OnPlayerLoaded()
    if not globalState.robberyStarted then return end

    TriggerClientEvent('peak_warehouse:client:setupInteractions', source)
end

local function resetAllStates()
    for key, location in pairs(serverConfig.interactLocations) do
        if location.isBusy ~= nil then
            location.isBusy = false
        end
        if location.isHacked ~= nil then
            location.isHacked = false
        end
        if location.isExploded ~= nil then
            location.isExploded = false
        end
        if location.isOpen ~= nil then
            location.isOpen = false
        end
    end

    for _, box in pairs(serverConfig.boxLocations) do
        if box.isBusy ~= nil then
            box.isBusy = false
        end
        if box.isRobbed ~= nil then
            box.isRobbed = false
        end
    end
end

local function cleanupEntities()
    for _, netId in ipairs(spawnedEntities.guards) do
        local ped = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end

    spawnedEntities.guards = {}
end

local function setCooldown()
    globalState.cooldown = true
    local cooldown = math.random(config.minCooldown, config.maxCooldown) * 60000

    SetTimeout(cooldown, function()
        globalState.cooldown = false
        globalState.robberyStarted = false
        resetAllStates()
        cleanupEntities()
    end)
end


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    cleanupEntities()
end)

local function spawnGuards()
    for _, guard in pairs(config.guardList) do
        
        local ped = CreatePed(4, guard.model, guard.coords.x, guard.coords.y, guard.coords.z, guard.heading, true, false)
        GiveWeaponToPed(ped, guard.weapon, 255, false, true)

        while not DoesEntityExist(ped) do Wait(25) end

        local netId = NetworkGetNetworkIdFromEntity(ped)
        if not netId then return end
        
        Entity(ped).state:set('peak_warehouse:pedHandler', true, true)
        spawnedEntities.guards[#spawnedEntities.guards + 1] = netId
    end
end

RegisterNetEvent('peak_warehouse:server:startRobbery', function()
    local player = bridge.getPlayer(source)
    if not player then return end

    local distance = utils.checkDistance(source, serverConfig.interactLocations.electricalBox.coords, 5)
    if not distance then
        utils.handleExploit(source) 
        return  
    end

    if serverConfig.interactLocations.electricalBox.isExploded then
        utils.notify(source, locale('notify.already_blown'), 'error')
        return
    end

    if globalState.cooldown then
        utils.notify(source, locale('notify.cooldown'), 'error')
        return
    end
  
    local copCount = bridge.checkCopCount()
    if copCount < serverConfig.requiredCops then
        utils.notify(source, locale('notify.not_enough_police'), 'error')
        return
    end

    local itemCount = exports.ox_inventory:Search(source, 'count', serverConfig.requiredItem.name)
    if itemCount < serverConfig.requiredItem.amount then
        utils.notify(source, locale('notify.dont_have_item'), 'error')
        return
    end

    globalState.robberyStarted = true

    serverConfig.interactLocations.electricalBox.isBusy = true

    local success = lib.callback.await('peak_warehouse:client:startRobbery', source)
    if not success then 
        serverConfig.interactLocations.electricalBox.isBusy = false

        utils.notify(source, locale('notify.failed'), 'error')

        if serverConfig.requiredItem.remove.onFail then
            exports.ox_inventory:RemoveItem(source, serverConfig.requiredItem.name, serverConfig.requiredItem.amount)
        end

        return 
    end

    serverConfig.interactLocations.electricalBox.isBusy = false
    serverConfig.interactLocations.electricalBox.isExploded = true

    exports.ox_inventory:RemoveItem(source, serverConfig.requiredItem.name, serverConfig.requiredItem.amount)

    local exploded = lib.callback.await('peak_warehouse:client:createC4', source)
    if not exploded then return end

    serverConfig.interactLocations.entrance.isOpen = true
    utils.notify(source, locale('notify.gate_unlocked'), 'success')

    if config.guardConfig.spawnGuards then 
        spawnGuards()
    end

    TriggerClientEvent('peak_warehouse:client:setupInteractions', -1)
end)

RegisterNetEvent('peak_warehouse:server:enterWarehouse', function()
    
    local distance = utils.checkDistance(source, serverConfig.interactLocations.entrance.coords, 5)
    if not distance then
        utils.handleExploit(source) 
        return  
    end

    if not globalState.robberyStarted then
        utils.notify(source, locale('notify.entrance_closed'), 'error')
        return
    end

    TriggerClientEvent('peak_warehouse:client:enterWarehouse', source)
end)

RegisterNetEvent('peak_warehouse:server:exitWarehouse', function(type)
    if not globalState.robberyStarted then
        utils.notify(source, locale('notify.entrance_closed'), 'error')
        return
    end

    local exitLocation = serverConfig.interactLocations[type == 'front' and 'exit' or 'backExit']
    local distance = utils.checkDistance(source, exitLocation.coords, 5)

    if not distance then
        utils.handleExploit(source) 
        return
    end

    if not exitLocation.isOpen then
        utils.notify(source, locale('notify.exit_locked'), 'error')
        return
    end

    TriggerClientEvent('peak_warehouse:client:exitWarehouse', source, type)
end)

RegisterNetEvent('peak_warehouse:server:hackLaptop', function()
    local source = source

    if serverConfig.interactLocations.laptop.isHacked then 
        utils.notify(source, locale('notify.already_hacked'), 'error')
        return 
    end

    local distance = utils.checkDistance(source, serverConfig.interactLocations.laptop.coords, 5)
    if not distance then
        utils.handleExploit(source) 
        return  
    end

    serverConfig.interactLocations.laptop.isBusy = true

    local success = lib.callback.await('peak_warehouse:client:hackLaptop', source)
    if not success then
        serverConfig.interactLocations.laptop.isBusy = false

        utils.notify(source, locale('notify.failed_hack'), 'error')
        return
    end

    serverConfig.interactLocations.laptop.isBusy = false

    utils.notify(source, locale('notify.successfully_hacked'), 'success')

    serverConfig.interactLocations.laptop.isHacked = true
    serverConfig.interactLocations.exit.isOpen = true
    serverConfig.interactLocations.backExit.isOpen = true
    setCooldown()
end)

RegisterNetEvent('peak_warehouse:server:policeReset', function()
    local distance = utils.checkDistance(source, serverConfig.interactLocations.policeReset.coords, 5)
    if not distance then
        utils.handleExploit(source) 
        return  
    end

    local playerJob = bridge.hasPoliceJob(source)
    if not playerJob then
        utils.notify(source, locale('notify.must_be_police'), 'error')
        return 
    end

    if not serverConfig.interactLocations.entrance.isOpen then 
        utils.notify(source, locale('notify.exit_locked'), 'error')
        return 
    end

    resetAllStates()
    utils.notify(source, locale('notify.successfully_locked'), 'success')
end)

RegisterNetEvent('peak_warehouse:server:searchBox', function(index)
    local boxConfig = serverConfig.boxLocations[index]

    local distance = utils.checkDistance(source, boxConfig.coords, 5)
    if not distance then 
        utils.handleExploit(source)
        return 
    end

    if boxConfig.isBusy then
        utils.notify(source, locale('notify.already_doing'), 'error')
        return
    end

    if boxConfig.isRobbed then
        utils.notify(source, locale('notify.already_searched'), 'error')
        return
    end

    if not globalState.robberyStarted then
        utils.handleExploit(source)
        return
    end

    boxConfig.isBusy = true

    local success = lib.callback.await('peak_warehouse:client:searchBox', source)
    if not success then 
        boxConfig.isBusy = false
        return 
    end

    boxConfig.isBusy = false
    boxConfig.isRobbed = true

    utils.notify(source, locale('notify.successfully_searched'), 'success')

    local items = utils.generateLoot(serverConfig.items, serverConfig.lootMin, serverConfig.lootMax)

    for item, itemData in pairs(items) do
        exports.ox_inventory:AddItem(source, item, itemData.amount, itemData.metadata)
    end
end)