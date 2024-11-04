local config = require 'config.client'
local serverConfig = require 'config.server'
local utils = require 'modules.utils.client'
local spawnedEntities = {
    props = {}
}

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

AddStateBagChangeHandler('peak_warehouse:pedHandler', nil, function(bagName, _, value)
    if not value then return end

    local guard = GetEntityFromStateBagName(bagName)
    if not guard and not DoesEntityExist(guard) then return end

    local netId = NetworkGetNetworkIdFromEntity(guard)
    if not netId then return end

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

    Entity(guard).state:set('peak_warehouse:pedHandler', nil)
end)

lib.callback.register('peak_warehouse:client:startRobbery', function()

    local success = utils.thermiteMinigame()
    if not success then return end

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
        return true
    else 
        return false
    end
end)

lib.callback.register('peak_warehouse:client:createC4', function()
    local coords = serverConfig.interactLocations.electricalBox.coords

    local c4Prop = CreateObject(`prop_c4_final_green`, coords.x , coords.y, coords.z, false, false, true)
    SetEntityHeading(c4Prop, 0.0)
    FreezeEntityPosition(c4Prop, true)

    Wait(1000)

    if c4Prop and DoesEntityExist(c4Prop) then
        DeleteEntity(c4Prop)
    end

    AddExplosion(coords.x, coords.y - 0.5, coords.z, 5, 1.0, true, false, 1.0)

    return true
end)

RegisterNetEvent('peak_warehouse:client:enterWarehouse', function()
    if GetInvokingResource() then return end

    local coords = serverConfig.interactLocations.interior.coords

    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(cache.ped, 266.59)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('peak_warehouse:client:exitWarehouse', function(type)
    if GetInvokingResource() then return end

    local exitLocation = serverConfig.interactLocations[type == 'front' and 'entrance' or 'backEntrance']

    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(cache.ped, exitLocation.coords.x, exitLocation.coords.y, exitLocation.coords.z, false, false, false, false)
    SetEntityHeading(cache.ped, 266.59)
    DoScreenFadeIn(500)
end)

lib.callback.register('peak_warehouse:client:hackLaptop', function()

    local success = utils.laptopMinigame()
    if not success then return false end

    return true
end)

lib.callback.register('peak_warehouse:client:searchBox', function()
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
        return true
    else 
        return false
    end
end)

local function createObjects()
    for index = 1, #serverConfig.boxLocations do
        local coord = serverConfig.boxLocations[index].coords
        local model = config.warehouseObjects[math.random(1, #config.warehouseObjects)]

        lib.requestModel(model, 50000)

        local entity = CreateObject(model, coord.x, coord.y, coord.z, false, false, false)
        FreezeEntityPosition(entity, true)

        if config.interact == 'ox_target' then
            exports.ox_target:addLocalEntity(entity, {
                name = index,
                icon = 'fas fa-search',
                label = locale('interaction.search_box'),
                distance = 1,
                onSelect = function()
                    TriggerServerEvent('peak_warehouse:server:searchBox', index)
                end
            })
        elseif config.interact == 'interact' then
            exports.interact:AddLocalEntityInteraction({
                entity = entity,
                id = index,
                distance = 3.0,
                interactDst = 1.5,
                options = {
                    {
                        label = locale('interaction.search_box'),
                        action = function()
                            TriggerServerEvent('peak_warehouse:server:searchBox', index)
                        end,
                    },
                }
            })
        elseif config.interact == 'sleepless_interact' then
            exports.sleepless_interact:addLocalEntity({
                id = index,
                entity = entity,
                options = {
                    {
                        label = locale('interaction.search_box'),
                        icon = 'fas fa-search',
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:searchBox', index)
                        end
                    }
                },
                renderDistance = 3.0,
                activeDistance = 1.5,
            })

            spawnedEntities.props[#spawnedEntities.props + 1] = entity
        end
    end
end


local function removeObjects()
    for _, entity in ipairs(spawnedEntities.props) do
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    spawnedEntities.props = {}
end

local function createZone()
    lib.points.new({
        coords = serverConfig.interactLocations.interior.coords,
        distance = 100,
        onEnter = createObjects,
        onExit = removeObjects
    })
end

RegisterNetEvent('peak_warehouse:client:setupInteractions', function()
    if GetInvokingResource() then return end

    createZone()
end)

CreateThread(function()
        if config.interact == 'ox_target' then

        local interactions = {
            {
                coords = serverConfig.interactLocations.entrance.coords,
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
                            TriggerServerEvent('peak_warehouse:server:enterWarehouse')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.exit.coords,
                distance = 1,
                size = vec3(1, 1.2, 1.2),
                rotation = 0,
                debug = config.debugPoly,
                options = {
                    {
                        name = 'exit_warehouse',
                        icon = 'fas fa-door-open',
                        label = locale('interaction.exit_warehouse'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:exitWarehouse', 'front')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.backExit.coords,
                distance = 1,
                size = vec3(1, 0.8, 0.8),
                rotation = 0,
                debug = config.debugPoly,
                options = {
                    {
                        name = 'exit_warehouse_back',
                        icon = 'fas fa-door-open',
                        label = locale('interaction.exit_warehouse'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:exitWarehouse', 'back')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.electricalBox.coords,
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
            },
            {
                name = 'laptop',
                coords = serverConfig.interactLocations.laptop.coords,
                size = vec3(0.4, 0.4, 0.4),
                rotation = 85,
                debug = config.debugPoly,
                options = {
                    {
                        name = 'hack_laptop',
                        icon = 'fa-solid fa-laptop',
                        label = locale('interaction.hack_laptop'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:hackLaptop')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.policeReset.coords,
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
                            TriggerServerEvent('peak_warehouse:server:policeReset')
                        end
                    }
                }
            }
        }
        
        for _, interaction in ipairs(interactions) do
            exports.ox_target:addBoxZone(interaction)
        end
            
        elseif config.interact == 'interact' then

        local interactions = {
            {
                coords = serverConfig.interactLocations.entrance.coords,
                distance = 10,
                interactDst = 1.0,
                options = {
                    {
                        icon = 'fas fa-door-open',
                        label = locale('interaction.enter_warehouse'),
                        action = function()
                            TriggerServerEvent('peak_warehouse:server:enterWarehouse')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.exit.coords,
                distance = 10,
                interactDst = 1.0,
                options = {
                    {
                        name = 'exit_warehouse',
                        label = locale('interaction.exit_warehouse'),
                        action = function()
                            TriggerServerEvent('peak_warehouse:server:exitWarehouse', 'front')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.backExit.coords,
                distance = 10,
                interactDst = 1.0,
                options = {
                    {
                        name = 'exit_warehouse_back',
                        label = locale('interaction.exit_warehouse'),
                        action = function()
                            TriggerServerEvent('peak_warehouse:server:exitWarehouse', 'back')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.electricalBox.coords,
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
            },
            {
                coords = serverConfig.interactLocations.laptop.coords,
                id = 'laptop',
                distance = 10,
                interactDst = 1.0,
                options = {
                    {
                        name = 'hack_laptop',
                        label = locale('interaction.hack_laptop'),
                        action = function()
                            TriggerServerEvent('peak_warehouse:server:hackLaptop')
                        end
                    }
                }
            },
            {
                coords = serverConfig.interactLocations.policeReset.coords,
                distance = 10,
                interactDst = 1.0,
                groups = {
                    ['police'] = 0
                },
                options = {
                    {
                        label = locale('interaction.lock_gates'),
                        action = function()
                            TriggerServerEvent('peak_warehouse:server:policeReset')
                        end
                    }
                }
            }
        }
        
        for _, interaction in ipairs(interactions) do
            exports.interact:AddInteraction(interaction)
        end
            
        elseif config.interact == 'sleepless_interact' then

        exports.sleepless_interact:addCoords({
            id = 'warehouse_enter',
            coords = serverConfig.interactLocations.entrance.coords,
            options = {
                {
                    icon = 'fas fa-door-open',
                    label = locale('interaction.enter_warehouse'),
                    onSelect = function()
                        TriggerServerEvent('peak_warehouse:server:enterWarehouse')
                    end,
                }
            },
            renderDistance = 10.0,
            activeDistance = 2.0,
            cooldown = 0
        })

        local interactions = {
            {
                id = 'warehouse_enter',
                coords = serverConfig.interactLocations.entrance.coords,
                options = {
                    {
                        icon = 'fas fa-door-open',
                        label = locale('interaction.enter_warehouse'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:enterWarehouse')
                        end
                    }
                },
                renderDistance = 10.0,
                activeDistance = 2.0,
                cooldown = 0
            },
            {
                id = 'warehouse_exit',
                coords = serverConfig.interactLocations.exit.coords,
                options = {
                    {
                        name = 'exit_warehouse',
                        label = locale('interaction.exit_warehouse'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:exitWarehouse', 'front')
                        end
                    }
                },
                renderDistance = 10.0,
                activeDistance = 2.0,
                cooldown = 0
            },
            {
                id = 'warehouse_back_exit',
                coords = serverConfig.interactLocations.backExit.coords,
                options = {
                    {
                        name = 'exit_warehouse_back',
                        label = locale('interaction.exit_warehouse'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:exitWarehouse', 'back')
                        end
                    }
                },
                renderDistance = 10.0,
                activeDistance = 2.0,
                cooldown = 0
            },
            {
                id = 'electrical_box',
                coords = serverConfig.interactLocations.electricalBox.coords,
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
            },
            {
                id = 'laptop',
                coords = serverConfig.interactLocations.laptop.coords,
                options = {
                    {
                        name = 'hack_laptop',
                        label = locale('interaction.hack_laptop'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:hackLaptop')
                        end
                    }
                },
                renderDistance = 10.0,
                activeDistance = 2.0,
                cooldown = 0
            },
            {
                coords = serverConfig.interactLocations.policeReset.coords,
                options = {
                    {
                        groups = { ['police'] = 0 },
                        label = locale('interaction.lock_gates'),
                        onSelect = function()
                            TriggerServerEvent('peak_warehouse:server:policeReset')
                        end
                    }
                },
                renderDistance = 10.0,
                activeDistance = 2.0,
                cooldown = 0
            }
        }
        
        for _, interaction in ipairs(interactions) do
            exports.sleepless_interact:addCoords(interaction)
        end
        
    end
end)





