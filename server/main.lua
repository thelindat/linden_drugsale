ESX = ExM

RegisterNetEvent('linden_drugsale:sellDrugs')
AddEventHandler('linden_drugsale:sellDrugs', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		local xItem = xPlayer.getInventoryItem(item)
		if xItem.count > 0 then
			local price = Config.Drugs[item] * xItem.count
			xPlayer.removeInventoryItem(item, xItem.count)
			xPlayer.addAccountMoney('money', price)
		end
	end
end)
