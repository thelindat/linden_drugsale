local ox_inventory = exports.ox_inventory

RegisterNetEvent('linden_drugsale:sellDrugs')
AddEventHandler('linden_drugsale:sellDrugs', function(drugToSell, sellCount, salePrice)
	local src = source
	ox_inventory:RemoteItem(src, drugToSell, sellCount)
	ox_inventory:AddItem(Config.PaymentType, salePrice)
end)

RegisterNetEvent('linden_drugsale:robPlayer')
AddEventHandler('linden_drugsale:robPlayer', function(item, count)
	local src = source
	ox_inventory:RemoveItem(src, item, count)
end)

ESX.RegisterServerCallback('linden_drugsale:checkCops', function(copsOnline, callback)
	local xPlayers = ESX.GetPlayers()
	local copsOnline = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police_bcso' or xPlayer.job.name == 'police_lspd' or xPlayer.job.name == 'police_fbi' then
			copsOnline = copsOnline +1
		end
	end
	callback(copsOnline)
end)