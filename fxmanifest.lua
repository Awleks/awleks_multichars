fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Awleks Multicharacter'
author 'Awleks'
description 'Multicharacter, identity, and spawn selector'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    -- '@qb-core/shared/locale.lua', -- qbcore
    '@qbx_core/modules/lib.lua', -- qbox
    -- '@es_extended/imports.lua', -- esx
    'shared/config.lua',
    'shared/integrations.lua',
    'shared/theme.lua',
    'shared/locations.lua',
    'shared/spawns.lua',
    'shared/nationalities.lua',
    'bridge/init.lua',
}

client_scripts {
    '@qbx_core/modules/lib.lua', -- qbox
    '@qbx_core/modules/playerdata.lua', -- qbox
    'bridge/client.lua',
    'bridge/qbcore/client.lua',
    'bridge/qbox/client.lua',
    'bridge/esx/client.lua',
    'bridge/custom/client.lua',
    'client/main.lua',
    'client/spawn.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua',
    'bridge/qbcore/server.lua',
    'bridge/qbox/server.lua',
    'bridge/esx/server.lua',
    'bridge/custom/server.lua',
    'server/main.lua',
    'server/version.lua',
}

ui_page 'build/index.html'

files {
    'build/**',
}
