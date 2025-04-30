fx_version 'cerulean'
game 'gta5'
description 'MH Police Training'
version '1.0'
url 'https://github.com/MaDHouSe79'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'shared/peds.lua',
    'shared/vehicles.lua',
}

client_scripts { 
    'core/cl_framework.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/sv_framework.lua',
    'server/sv_config.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {'oxmysql', 'ox_lib'}

lua54 'yes'
