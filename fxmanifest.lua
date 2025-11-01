fx_version 'cerulean'
game 'gta5'

author 'Tilci'
description 'Vineyard farming and delivery script for QBox'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

lua54 'yes'