fx_version 'cerulean'
game 'gta5'

author 'Peak Scripts'
description 'Advanced Warehouse Robbery for Qbox, Ox Core, ND Core and ESX'
version '1.0.0'

lua54 'yes'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts { 
    'bridge/server/*.lua',
    'server/*.lua' 
}

client_scripts { 
    '@qbx_core/modules/playerdata.lua',
    '@sleepless_interact/init.lua',
    'bridge/client/*.lua',
    'client/main.lua'
}

files {
    'config/*.lua',
    'locales/*.json',
    'modules/**/*.lua'
}

