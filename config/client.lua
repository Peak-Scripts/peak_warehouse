return {
    notify = 'qbox', -- 'ox_lib', 'esx', 'qbox', nd, 'custom'
    dispatch = 'ps-dispatch', -- 'cd_dispatch', 'ps-dispatch', 'custom'

    interact = 'sleepless_interact', -- ox_target, interact, sleepless_interact

    minCooldown = 30, -- In minutes
    maxCooldown = 60, -- In minutes

    debugPoly = false,

    blip = {
        enabled = true,
        location = vec3(839.0181, -1923.1303, 30.8329), 
        sprite = 473,
        display = 4,
        scale = 0.6,
        colour = 18,
        label = 'Warehouse',
    },

    minLootableBoxes = 1, 
    maxLootableBoxes = 7, -- Max amount is 21 unless you add more to locations to boxLocations.

    interactLocations = {
        electricalBox = vec3(835.8817, -1923.2244, 30.7248),
        warehouseEntrance = vec3(839.0181, -1923.5303, 30.8329),
        warehouseBackEntrance = vec3(853.9672, -1852.6887, 29.7877),
        warehouseInterior = vec3(1027.5515, -3101.7664, -38.9999),
        warehouseExit = vec3(1028.0412, -3101.4567, -38.1793),
        warehouseBackExit = vec3(992.0262, -3097.8188, -38.8184),
        laptop = vec3(995.2347, -3100.0031, -39.1758),
        policeReset = vec3(1027.9757, -3098.5480, -38.7297),
    },
    
    boxLocations = { 
        [1] = { id = 1, coords = vec3(1018.1041, -3108.5, -40) },
        [2] = { id = 2, coords = vec3(1015.5176, -3108.5, -40) },
        [3] = { id = 3, coords = vec3(1013.2429, -3108.5, -40) },
        [4] = { id = 4, coords = vec3(1010.8519, -3108.5, -40) },
        [5] = { id = 5, coords = vec3(1008.5016, -3108.5, -40) },
        [6] = { id = 6, coords = vec3(1006.1173, -3108.5, -40) },
        [7] = { id = 7, coords = vec3(1003.4443, -3108.5, -40) },
    
        [8] = { id = 8, coords = vec3(1018.1041, -3102.7, -40) },
        [9] = { id = 9, coords = vec3(1015.5176, -3102.7, -40) },
        [10] = { id = 10, coords = vec3(1013.2429, -3102.7, -40) },
        [11] = { id = 11, coords = vec3(1010.8519, -3102.7, -40) },
        [12] = { id = 12, coords = vec3(1008.5016, -3102.7, -40) },
        [13] = { id = 13, coords = vec3(1006.1173, -3102.7, -40) },
        [14] = { id = 14, coords = vec3(1003.4443, -3102.7, -40) },
        
        [15] = { id = 15, coords = vec3(1018.1041, -3097, -40) },
        [16] = { id = 16, coords = vec3(1015.5176, -3097, -40) },
        [17] = { id = 17, coords = vec3(1013.2429, -3097, -40) },
        [18] = { id = 18, coords = vec3(1010.8519, -3097, -40) },
        [19] = { id = 19, coords = vec3(1008.5016, -3097, -40) },
        [20] = { id = 20, coords = vec3(1006.1173, -3097, -40) },
        [21] = { id = 21, coords = vec3(1003.4443, -3097, -40) },
    },
    
    warehouseObjects = { 
        'prop_boxpile_05a',
        'prop_boxpile_04a',
        'prop_boxpile_06b',
        'prop_boxpile_02c',
        'prop_boxpile_02b',
        'prop_boxpile_01a',
        'prop_boxpile_08a',
    },
    
    guardConfig = {
        spawnGuards = true,
        accuracy = 100,
        armor = 200,
        health = 200,
        sufferHeadshots = false,
        alertness = 2,
        aggresiveness = 2,

    },

    guardList = {
        {
            model = 's_m_m_security_01', 
            coords = vec4(998.8849, -3111.4160, -38.9999, 90), 
            weapon = 'WEAPON_CARBINERIFLE', 
        },
        {
            model = 's_m_m_security_01', 
            coords = vec4(999.9012, -3099.2932, -38.9999, 270), 
            weapon = 'WEAPON_CARBINERIFLE', 
        },
        {
            model = 's_m_m_security_01', 
            coords = vec4(1001.6360, -3092.2385, -38.999, 90), 
            weapon = 'WEAPON_CARBINERIFLE', 
        }, 
        {
            model = 's_m_m_security_01', 
            coords = vec4(993.8922, -3099.9907, -38.9958, 90), 
            weapon = 'WEAPON_CARBINERIFLE', 
        }
    }
    
}
