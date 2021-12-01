RegisterNetEvent('linden_drugsale:sellDrugs')
AddEventHandler('linden_drugsale:sellDrugs', function(drugToSell, sellCount, salePrice)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		xPlayer.removeInventoryItem(drugToSell, sellCount)
		xPlayer.addInventoryItem(Config.PaymentType, salePrice)
	end
end)

RegisterNetEvent('linden_drugsale:robPlayer')
AddEventHandler('linden_drugsale:robPlayer', function(item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, count)
end)

ESX.RegisterServerCallback('linden_drugsale:checkCops', function(copsOnline, callback)
	local xPlayers = ESX.GetPlayers()
	local copsOnline = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			copsOnline = copsOnline +1
		end
	end
	callback(copsOnline)
end)