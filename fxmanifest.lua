fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'atm-dui'
description 'Ultra-realistic DUI-based ATM System'
author 'OSMFX'
version '1.0.0'

dependencies {
    'ox_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/bridge.lua',
    'bridge/client/*.lua',
    'client/dui.lua',
    'client/camera.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'bridge/server/*.lua',
    'server/main.lua',
}

-- DUI loads HTML directly via nui:// URL, but we need ui_page for native receipt viewing
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/*.ogg',
}
