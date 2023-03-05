fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'https://github.com/thelindat/linden_drugsale'

dependency 'es_extended'
shared_scripts {
	'@es_extended/imports.lua',
	'config.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}
