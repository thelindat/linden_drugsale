fx_version 'cerulean'
game 'gta5'

description 'https://github.com/thelindat/linden_drugsale'

dependency 'extendedmode'
shared_script '@extendedmode/imports.lua'
shared_script 'config.lua'

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}
