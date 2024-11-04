fx_version 'cerulean'
game 'gta5'

author 'Peak Scripts'
description 'Advanced Warehouse Robbery for QBX, QB, OX, ESX, ND frameworks'
version '2.0.0'

lua54 'yes'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

server_scripts { 
    'server/*.lua' 
}

client_scripts { 
    'client/*.lua'
}

files {
    'config/*.lua',
    'locales/*.json',
    'modules/**/*.lua'
}

