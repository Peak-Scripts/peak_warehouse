local utils = {}

--- @param message string
--- @param type string
function utils.notify(message, type)
    lib.notify({ 
        description = message, 
        type = type 
    })
end

function utils.thermiteMinigame()
    local success = exports.bl_ui:MineSweeper(3, {
        grid = 4,
        duration = 10000,
        target = 3,
        previewDuration = 1000
    })

    return success
end

function utils.laptopMinigame()
    local success = exports.bl_ui:PathFind(1, {
        numberOfNodes = 10,
        duration = 10000,
    })

    return success
end


return utils