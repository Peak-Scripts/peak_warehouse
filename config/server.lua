return {
    requiredItem = 'thermite',
    removeOnFail = true,
    removeOnUse = true,

    lootMin = 1, -- Minimum amount of different items player can get
    lootMax = 6, -- Maximum amount of different items player can get

    items = {
        { name = 'metalscrap', chance = 20, min = 2, max = 6 },
        { name = 'plastic', chance = 50, min = 5, max = 10 },
        { name = 'copper', chance = 100, min = 5, max = 20 },
        { name = 'ammo-9', chance = 30, min = 20, max = 50 },
        { name = 'ammo-rifle', chance = 10, min = 10, max = 30 },
        { name = 'WEAPON_APPISTOL', chance = 15, min = 1, max = 1 },
        { name = 'WEAPON_SMG', chance = 10, min = 1, max = 1 },
        { name = 'WEAPON_ASSAULTRIFLE', chance = 3, min = 1, max = 1 },
    },

    discordLogs = {
        enabled = true,
        name = 'Peak Scripts', -- Name for the webhook
        image = 'https://media.discordapp.net/attachments/711827512274976819/1263938025910566963/peakscripts.png?ex=669c0d84&is=669abc04&hm=ed7b80006e73722684176f2501389b508a834c97edc0cfe9b10644bdf52050b8&=&format=webp&quality=lossless', -- Image for the webhook
        footer = 'https://media.discordapp.net/attachments/711827512274976819/1263938025910566963/peakscripts.png?ex=669c0d84&is=669abc04&hm=ed7b80006e73722684176f2501389b508a834c97edc0cfe9b10644bdf52050b8&=&format=webp&quality=lossless', -- Footer image for the webhook
        webhookURL = ''
    }
}
