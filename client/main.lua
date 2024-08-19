local config = require 'config.client'
local serverConfig = require 'config.server'
local utils = require 'modules.Utils.client'
local ELECTRICAL_BOX_ID = 'electrical_box' -- Do not touch this
local ENTRANCE_ID = 'entrance' -- Do not touch this
local FRONT_EXIT_ID = 'front_exit' -- Do not touch this
local BACK_EXIT_ID = 'back_exit' -- Do not touch this
local LAPTOP_ID = 'laptop' -- Do not touch this
local FRONT_EXIT = 'front_exit' -- Do not touch this
local BACK_EXIT = 'back_exit' -- Do not touch this

CreateThread(function()
    if config.blip.enabled then
        local blip = AddBlipForCoord(config.blip.location.x, config.blip.location.y, config.blip.location.z)

        SetBlipSprite(blip, config.blip.sprite)
        SetBlipDisplay(blip, config.blip.display)
        SetBlipScale(blip, config.blip.scale)
        SetBlipColour(blip, config.blip.colour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(config.blip.label)
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, true)
    end
end)

AddStateBagChangeHandler('ped', nil, function(bagName, _, value)
    if value then
        local guard = GetEntityFromStateBagName(bagName)
        if guard and DoesEntityExist(guard) then
            local netId = NetworkGetNetworkIdFromEntity(guard)
            if netId then
                SetPedCombatAttributes(guard, 46, true)
                SetPedCombatMovement(guard, config.guardConfig.aggresiveness)
                SetEntityHealth(guard, config.guardConfig.health)
                SetEntityMaxHealth(guard, config.guardConfig.health)
                SetPedFleeAttributes(guard, 0, false)
                SetPedCombatAbility(guard, 2)
                SetPedCanRagdollFromPlayerImpact(guard, false)
                SetPedAsEnemy(guard, true)
                SetPedDropsWeaponsWhenDead(guard, false)
                SetPedAlertness(guard, config.guardConfig.alertness)
                SetPedSeeingRange(guard, 150.0)
                SetPedHearingRange(guard, 150.0)
                SetPedAsCop(guard, true)
                SetPedCombatAbility(guard, 2)
                SetPedAccuracy(guard, config.guardConfig.accuracy)
                SetPedArmour(guard, config.guardConfig.armor)
                SetPedSuffersCriticalHits(guard, config.guardConfig.sufferHeadshots)
                TaskCombatPed(guard, cache.ped, 0, 16)
            end
        end
    end
end)

local function createC4()
    local success = lib.callback.await('peak_warehouse:server:createC4')
    if not success then return end

    local coords = config.interactLocations.electricalBox
    AddExplosion(coords.x, coords.y - 0.5, coords.z, 'STICKYBOMB', 1500000.0, true, false, 50000.0)
    utils.notify(locale('notify.gate_unlocked'), 'success')
end

RegisterNetEvent('peak_warehouse:client:startRobbery', function()
    local hasItem = exports.ox_inventory:Search('count', serverConfig.requiredItem) > 0
    if not hasItem then
        utils.notify(locale('notify.dont_have_item'), 'error')
        return
    end

    TriggerServerEvent('peak_warehouse:server:setBusyState', ELECTRICAL_BOX_ID, true)

    local success = exports['SN-Hacking']:Thermite(7, 5, 10000, 2, 1, 3000)
    if success then
        if lib.progressCircle({
            duration = 5000,
            label = locale('progress.placing_c4'),
            useWhileDead = false,
            position = 'bottom',
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'anim@heists@ornate_bank@thermal_charge_heels',
                clip = 'thermal_charge',
                flag = 16,
            },
            prop = {
                model = `prop_c4_final_green`,
                pos = vec3(0.06, 0.0, 0.06),
                rot = vec3(90.0, 0.0, 0.0),
            }
        }) then
            utils.notify(locale('notify.c4_placed'), 'success')
            TriggerServerEvent('peak_warehouse:server:setBusyState', ELECTRICAL_BOX_ID, true)
            TriggerServerEvent('peak_warehouse:server:setCooldown')

            if serverConfig.removeOnUse then
                lib.callback.await('peak_warehouse:server:removeItem', false)
            end

            createC4()
            TriggerServerEvent('peak_warehouse:server:setBusyState', ENTRANCE_ID, true)
            if config.guardConfig.spawnGuards then 
                TriggerServerEvent('peak_warehouse:server:spawnGuards')
             end
        else
            TriggerServerEvent('peak_warehouse:server:setBusyState', ELECTRICAL_BOX_ID, false)
        end
    else
        utils.notify(locale('notify.failed'), 'error')
        if serverConfig.removeOnFail then
            lib.callback.await('peak_warehouse:server:removeItem', false)
        end
        TriggerServerEvent('peak_warehouse:server:setBusyState', ELECTRICAL_BOX_ID, false)
    end
    utils.policeDispatch()
end)

local function enterWarehouse()
    if GlobalState.RobberyStarted then
        DoScreenFadeOut(500)
        Wait(1000)
        SetEntityCoords(cache.ped, config.interactLocations.warehouseInterior)
        SetEntityHeading(cache.ped, 266.59)
        DoScreenFadeIn(500)
    else
        utils.notify(locale('notify.entrance_closed'), 'error')
    end
end

--- @param exit string
local function exitWarehouse(exit)
    if exit == FRONT_EXIT then
        local isBusy = lib.callback.await('peak_warehouse:server:checkBusyState', false, FRONT_EXIT_ID) 
        if isBusy then
            DoScreenFadeOut(500)
            Wait(1000)
            SetEntityCoords(cache.ped, config.interactLocations.warehouseEntrance)
            SetEntityHeading(cache.ped, 267.58)
            DoScreenFadeIn(500)
        else
            utils.notify(locale('notify.exit_locked'), 'error')
        end
    elseif exit == BACK_EXIT then
        local isBusy = lib.callback.await('peak_warehouse:server:checkBusyState', false, BACK_EXIT_ID) 
        if isBusy then
            DoScreenFadeOut(500)
            Wait(1000)
            SetEntityCoords(cache.ped, config.interactLocations.warehouseBackEntrance)
            SetEntityHeading(cache.ped, 267.58)
            DoScreenFadeIn(500)
        else
            utils.notify(locale('notify.exit_locked'), 'error')
        end
    end
end

--- @param boxId string
local function searchBox(boxId)
    local isBusy = lib.callback.await('peak_warehouse:server:checkBusyState', false, ELECTRICAL_BOX_ID) 
    if not isBusy then
        utils.notify(locale('notify.not_hacked'), 'error') -- Possible exploiter
        TriggerServerEvent('peak_warehouse:server:setBusyState', boxId, false)
        return
    end

    if lib.progressCircle({
        duration = 5000,
        label = locale('progress.searching_box'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            sprint = true,
            car = true,
        },
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer'
        },
    }) then 
        local success = lib.callback.await('peak_warehouse:server:boxReward', false) 
        if success then utils.notify(locale('notify.successfully_searched'), 'success') end

        if config.interact == 'ox_target' then
            exports.ox_target:removeZone(boxId)
        elseif config.interact == 'interact' then
            exports.interact:RemoveInteraction(boxId)
        elseif config.interact == 'sleepless_interact' then
            exports.sleepless_interact:removeById(boxId)
        end

    else 
        TriggerServerEvent('peak_warehouse:server:setBusyState', boxId, false)
    end
end

local function policeReset()
    local isLocked = lib.callback.await('peak_warehouse:server:checkBusyState', false, ENTRANCE_ID) 
    if not isLocked then
        utils.notify(locale('notify.exit_locked'), 'error')
    else
        TriggerServerEvent('peak_warehouse:server:setBusyState', ENTRANCE_ID, false)
        TriggerServerEvent('peak_warehouse:server:setBusyState', BACK_EXIT_ID, false)
        utils.notify(locale('notify.successfully_locked'), 'success')
    end
end

local function hackLaptop()
    local isHacked = lib.callback.await('peak_warehouse:server:checkBusyState', false, LAPTOP_ID)
    if not isHacked then
        local success = exports['SN-Hacking']:SkillCheck(50, 0, {'w','a','s','w'}, 2, 20, 5) --SkillCheck(speed(milliseconds), time(milliseconds), keys(string or table), rounds(number), bars(number), safebars(number))
        if success then
            TriggerServerEvent('peak_warehouse:server:setBusyState', LAPTOP_ID, true)
            TriggerServerEvent('peak_warehouse:server:setBusyState', FRONT_EXIT_ID, true)
            TriggerServerEvent('peak_warehouse:server:setBusyState', BACK_EXIT_ID, true)

            if config.interact == 'ox_target' then
                exports.ox_target:removeZone('laptop')
            elseif config.interact == 'interact' then
                exports.interact:RemoveInteraction('laptop')
            elseif config.interact == 'sleepless_interact' then
                exports.sleepless_interact:removeById('laptop')
            end

            utils.notify(locale('notify.successfully_hacked'), 'success')
        else
            utils.notify(locale('notify.failed_hack'), 'error')
        end
    else
        utils.notify(locale('notify.already_hacked'), 'error')
    end
end


local function shuffleTable(t)
    assert(t, 'shuffleTable() expected a table, got nil')
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

shuffleTable(config.boxLocations)

for i = config.minLootableBoxes, config.maxLootableBoxes do
    local location = config.boxLocations[i]
    local coords = location.coords
    local boxId = 'box_' .. i

    if config.interact == 'ox_target' then
        exports.ox_target:addBoxZone({
            name = boxId,
            debug = config.debugPoly,
            coords = vec3(coords.x, coords.y, coords.z),
            size = vec3(2, 2, 4),
            distance = 1,
            options = {
                {
                    name = 'search',
                    icon = 'fas fa-search',
                    label = locale('interaction.search_box'),
                    onSelect = function()
                        local isBusy = lib.callback.await('peak_warehouse:server:checkBusyState', false, boxId) 
                        if not isBusy then
                            TriggerServerEvent('peak_warehouse:server:setBusyState', boxId, true)
                            searchBox(boxId)
                        else
                            utils.notify(locale('notify.already_searched'), 'error')
                        end
                    end
                }
            }
        })
    elseif config.interact == 'interact' then
        exports.interact:AddInteraction({
            coords = vec3(coords.x, coords.y, coords.z),
            distance = 10,
            interactDst = 3.0,
            id = boxId,
            options = {
                 {
                    label = locale('interaction.search_box'),
                    action = function()
                        local isBusy = lib.callback.await('peak_warehouse:server:checkBusyState', false, boxId) 
                        if not isBusy then
                            TriggerServerEvent('peak_warehouse:server:setBusyState', boxId, true)
                            searchBox(boxId)
                        else
                            utils.notify(locale('notify.already_searched'), 'error')
                        end
                    end,
                },
            }
        })
    elseif config.interact == 'sleepless_interact' then
        interact.addCoords({
            id = boxId,
            coords = vec3(coords.x, coords.y, coords.z),
            options = {
                {
                    label = locale('interaction.search_box'),
                    icon = 'fas fa-search',
                    onSelect = function()
                        local isBusy = lib.callback.await('peak_warehouse:server:checkBusyState', false, boxId) 
                        if not isBusy then
                            TriggerServerEvent('peak_warehouse:server:setBusyState', boxId, true)
                            searchBox(boxId)
                        else
                            utils.notify(locale('notify.already_searched'), 'error')
                        end
                    end
                }
            },
            renderDistance = 10.0,
            activeDistance = 3.0,
        })
    end

end

if config.interact == 'ox_target' then

    exports.ox_target:addBoxZone({
        coords = config.interactLocations.warehouseEntrance,
        distance = 1,
        size = vec3(0.5, 1.2, 1.2),
        rotation = 85,
        debug = config.debugPoly,
        options = {
            {
                name = 'enter_warehouse',
                icon = 'fas fa-door-open',
                label = locale('interaction.enter_warehouse'),
                onSelect = function()
                    enterWarehouse()
                end
            }
        }
    })

    exports.ox_target:addBoxZone({
        coords = config.interactLocations.warehouseExit,
        size = vec3(1, 1.2, 1.2),
        rotation = 0,
        debug = config.debugPoly,
        distance = 1,
        options = {
            {
                name = 'exit_warehouse',
                icon = 'fas fa-door-open',
                label = locale('interaction.exit_warehouse'),
                onSelect = function()
                    exitWarehouse(FRONT_EXIT)
                end
            }
        }
    })

    exports.ox_target:addBoxZone({
        coords = config.interactLocations.warehouseBackExit,
        size = vec3(1, 0.8, 0.8),
        rotation = 0,
        debug = config.debugPoly,
        distance = 1,
        options = {
            {
                name = 'exit_warehouse_back',
                icon = 'fas fa-door-open',
                label = locale('interaction.exit_warehouse'),
                onSelect = function()
                    exitWarehouse('back_exit')
                end
            }
        }
    })

    exports.ox_target:addBoxZone({
        coords = config.interactLocations.electricalBox,
        size = vec3(0.4, 1, 1),
        rotation = 85,
        debug = config.debugPoly,
        options = {
            {
                name = 'place_c4',
                icon = 'fa-solid fa-bomb',
                label = locale('interaction.place_c4'),
                onSelect = function()
                    TriggerServerEvent('peak_warehouse:server:startRobbery')
                end
            }
        }
    })
    
    exports.ox_target:addBoxZone({
        name = 'laptop',
        coords = config.interactLocations.laptop,
        size = vec3(0.4, 0.4, 0.4),
        rotation = 85,
        debug = config.debugPoly,
        options = {
            {
                name = 'hack_laptop',
                icon = 'fa-solid fa-laptop',
                label = locale('interaction.hack_laptop'),
                onSelect = function()
                    hackLaptop()
                end
            }
        }
    })

    exports.ox_target:addBoxZone({
        coords = config.interactLocations.policeReset,
        size = vec3(0.4, 0.1, 0.4),
        rotation = 90,
        debug = config.debugPoly,
        options = {
            {
                groups = 'police',
                name = 'police_reset',
                icon = 'fa-solid fa-lock',
                label = locale('interaction.lock_gates'),
                onSelect = function()
                    policeReset()
                end
            }
        }
    })

elseif config.interact == 'interact' then

     exports.interact:AddInteraction({
        coords = config.interactLocations.warehouseEntrance,
        distance = 10,
        interactDst = 1.0, 
        options = {
            {
                icon = 'fas fa-door-open',
                label = locale('interaction.enter_warehouse'),
                action = function()
                    enterWarehouse()
                end,
            }
        }
    })

     exports.interact:AddInteraction({
        coords = config.interactLocations.warehouseExit,
        distance = 10,
        interactDst = 1.0, 
        options = {
            {
                name = 'exit_warehouse',
                label = locale('interaction.exit_warehouse'),
                action = function()
                    exitWarehouse(FRONT_EXIT)
                end
            }
        }
    })

     exports.interact:AddInteraction({
        coords = config.interactLocations.warehouseBackExit,
        distance = 10,
        interactDst = 1.0, 
        options = {
            {
                name = 'exit_warehouse_back',
                label = locale('interaction.exit_warehouse'),
                action = function()
                    exitWarehouse('back_exit')
                end
            }
        }
    })

     exports.interact:AddInteraction({
        coords = config.interactLocations.electricalBox,
        distance = 10,
        interactDst = 1.0, 
        options = {
            {
                name = 'place_c4',
                label = locale('interaction.place_c4'),
                action = function()
                    TriggerServerEvent('peak_warehouse:server:startRobbery')
                end
            }
        }
    })

     exports.interact:AddInteraction({
        coords = config.interactLocations.laptop,
        id = 'laptop',
        distance = 10,
        interactDst = 1.0, 
        options = {
            {
                name = 'hack_laptop',
                label = locale('interaction.hack_laptop'),
                action = function()
                    hackLaptop()
                end
            }
        }
    })

     exports.interact:AddInteraction({
        coords = config.interactLocations.policeReset,
        distance = 10,
        interactDst = 1.0, 
        groups = {
            ['police'] = 0,
        },
        options = {
            {
                label = locale('interaction.lock_gates'),
                action = function()
                    policeReset()
                end
            }
        }
    })
elseif config.interact == 'sleepless_interact' then

    interact.addCoords({
        id = 'warehouse_enter',
        coords = config.interactLocations.warehouseEntrance,
        options = {
            {
                icon = 'fas fa-door-open',
                label = locale('interaction.enter_warehouse'),
                onSelect = function()
                    enterWarehouse()
                end,
            }
        },
        renderDistance = 10.0,
        activeDistance = 2.0,
        cooldown = 0
    })

    interact.addCoords({
        id = 'warehouse_exit',
        coords = config.interactLocations.warehouseExit,
        options = {
            {
                name = 'exit_warehouse',
                label = locale('interaction.exit_warehouse'),
                onSelect = function()
                    exitWarehouse(FRONT_EXIT)
                end
            }
        },
        renderDistance = 10.0,
        activeDistance = 2.0,
        cooldown = 0
    })

    interact.addCoords({
        id = 'warehouse_back_exit',
        coords = config.interactLocations.warehouseBackExit,
        options = {
            {
                name = 'exit_warehouse_back',
                label = locale('interaction.exit_warehouse'),
                onSelect = function()
                    exitWarehouse('back_exit')
                end
            }
        },
        renderDistance = 10.0,
        activeDistance = 2.0,
        cooldown = 0
    })

    interact.addCoords({
        id = 'electrical_box',
        coords = config.interactLocations.electricalBox,
        options = {
            {
                name = 'place_c4',
                label = locale('interaction.place_c4'),
                onSelect = function()
                    TriggerServerEvent('peak_warehouse:server:startRobbery')
                end
            }
        },
        renderDistance = 10.0,
        activeDistance = 2.0,
        cooldown = 0
    })

    interact.addCoords({
        id = 'laptop',
        coords = config.interactLocations.laptop,
        options = {
            {
                name = 'hack_laptop',
                label = locale('interaction.hack_laptop'),
                onSelect = function()
                    hackLaptop()
                end
            }
        },
        renderDistance = 10.0,
        activeDistance = 2.0,
        cooldown = 0
    })

    interact.addCoords({
        coords = config.interactLocations.policeReset,
        options = {
            {
                groups = {['police'] = 0},
                label = locale('interaction.lock_gates'),
                onSelect = function()
                    policeReset()
                end
            }
        },
        renderDistance = 10.0,
        activeDistance = 2.0,
        cooldown = 0
    })
end

