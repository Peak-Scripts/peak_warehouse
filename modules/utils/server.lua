local utils = {}
local serverConfig = require 'config.server'

--- @param source integer
--- @param message string
--- @param type string
function utils.notify(source, message, type)
    lib.notify(source, { 
        description = message, 
        type = type 
    })
end

local function getAmount(item)
    return item.amount or (item.min and item.max and math.random(item.min, item.max)) or 1
end

--- @param items table
--- @param minLoot number
--- @param maxLoot number
function utils.generateLoot(items, minLoot, maxLoot)
    if not items or #items == 0 then
        lib.print.error('Invalid loot configuration: no items provided')
        return {}
    end

    local loot = {}
    local lootAmount = 0
    local attempts = 0
    local maxAttempts = 100

    while lootAmount < minLoot and attempts < maxAttempts do
        for i = 1, #items do
            if lootAmount >= maxLoot then
                break
            end

            local item = items[i]
            local chance = math.random(100)

            if chance <= item.chance then
                local amount = getAmount(item)

                if amount and amount > 0 then
                    if not loot[item.name] then
                        lootAmount = lootAmount + 1
                        loot[item.name] = {
                            amount = amount,
                            metadata = item.metadata or nil
                        }
                    else
                        loot[item.name].amount = math.min(loot[item.name].amount + amount, item.max)
                    end

                    if lootAmount >= maxLoot then
                        break
                    end
                end
            end
        end
        attempts = attempts + 1
    end

    if lootAmount < minLoot then
        return utils.generateLoot(items, minLoot, maxLoot)
    end

    return loot
end

--- @param source integer
--- @param location vector3
--- @param maxDistance number
function utils.checkDistance(source, location, maxDistance)
    if not (type(location) == 'vector3' or type(location) == 'vector4') then
        return false
    end

    local locationCoords = vec3(location.x, location.y, location.z)
    local ped = GetPlayerPed(source)
    local playerPos = GetEntityCoords(ped)

    local distance = #(playerPos - locationCoords)
    return distance < maxDistance
end

function utils.handleExploit(source)
    -- If this is triggered, 99% of the time the player is cheating or doing something weird. Take precautions and investigate the player.
    DropPlayer(source, locale('exploit.exploiting_server'))
    utils.logPlayer(source, { locale('exploit.exploiting_server') })
end

--- @param source integer
--- @param data table
function utils.logPlayer(source, data)
    if serverConfig.logging.system == 'ox_lib' then
        lib.logger(source, 'House Robbery', json.encode(data))
    elseif serverConfig.logging.system == 'discord' then
        local playerName = GetPlayerName(source)
        local identifiers = GetPlayerIdentifiers(source)
        local playerIdentifier = identifiers[1] or 'Unknown'
        local playerDiscordId, playerSteamId, playerLicense, playerLicense2 = 'Unknown', 'Unknown', 'Unknown', 'Unknown'
        
        for _, id in ipairs(identifiers) do
            if string.match(id, 'discord:') then
                playerDiscordId = string.gsub(id, 'discord:', '')
            elseif string.match(id, 'steam:') then
                playerSteamId = string.gsub(id, 'steam:', '')
            elseif string.match(id, 'license:') then
                playerLicense = string.gsub(id, 'license:', '')
            elseif string.match(id, 'license2:') then
                playerLicense2 = string.gsub(id, 'license2:', '')
            end
        end
        
        local logMessage = string.format(
            "%s\n\n**Player identifiers:**\n" ..
            "•**player:** %s\n" ..
            "•**identifier:** %s\n" ..
            "•**discord:** %s\n" ..
            "•**steam:** %s\n" ..
            "•**license:** %s\n" ..
            "•**license2:** %s",
            data.message or 'No message provided',
            playerName, playerIdentifier, playerDiscordId, playerSteamId, playerLicense, playerLicense2
        )
        
        local payload = {
            username = serverConfig.discordLogs.name,
            avatar_url = serverConfig.discordLogs.image,
            content = data.normalMessage or '',
            embeds = {}
        }
        
        if data.title then
            table.insert(payload.embeds, {
                color = data.color,
                title = "**" .. data.title .. "**",
                description = "**Message: **\n" .. logMessage,
                footer = {
                    text = os.date("%a %b %d, %I:%M%p"),
                    icon_url = serverConfig.discordLogs.footer
                }
            })
        end
        
        if #payload.embeds == 0 then
            payload.embeds = nil
        end
        
        PerformHttpRequest(data.link, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
    end
end

return utils