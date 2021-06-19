local canSell = false
local isSelling = false
local waitTime = 2000
local lastPed = nil
local numberOfCops = 0

StartResource = function()
	PlayerLoaded = true
	playerPed = PlayerPedId()
	playerCoords = GetEntityCoords(playerPed)
	playerID = GetPlayerServerId(PlayerId())
	StartLoop()
end

function GetPedInFront()
	local plyOffset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(playerCoords.x, playerCoords.y, playerCoords.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, playerPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
	return ped
end

function Draw3dText(coords, text)
	local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropShadow(0, 0, 0, 55)
		SetTextEdge(0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

StartLoop = function()
	Citizen.CreateThread(function()
		while PlayerLoaded do
			playerCoords = GetEntityCoords(playerPed)
			local ped = GetPedInFront()
			if ped ~= 0 and ped ~= lastPed and GetPedType(ped) ~= 1 and GetPedType(ped) ~= 28 and GetPedType(ped) ~= 2 and not IsEntityDead(ped) then
				pedCoords = GetEntityCoords(ped)
				local dist = #(playerCoords - pedCoords)
				if dist < 3.0 then waitTime = 10
					if not isSelling then
						CanSellDrugs()
					end
				elseif dist < 4.0 then waitTime = 500 canSell = false end
			else
				waitTime = 2000
				if canSell then canSell = false end
			end
			Citizen.Wait(waitTime)
		end
	end)
end

CanSellDrugs = function()
	local ped = GetPedInFront()
	local playerPed = PlayerPedId()
	isSelling = true
	drugs = {}
	local drugCount = 0
	ESX.PlayerData.inventory = ESX.GetPlayerData().inventory
	for k, v in pairs(ESX.PlayerData.inventory) do
		if Config.Drugs[v.name] then
			if drugs[v.name] then drugs[v.name].count = drugs[v.name].count + v.count else drugs[v.name] = {index=drugCount+1, name=v.name, count=v.count, label=v.label} drugCount = drugCount+1 end
		end
	end
	Citizen.CreateThread(function()
		ESX.TriggerServerCallback('linden_drugsale:checkCops', function(copsOnline)
			numberOfCops = copsOnline
			canSell = true
		end)
		while canSell do
			local sleep = 10000
			if drugCount > 0 then
				sleep = 5
				Draw3dText(pedCoords,'Press ~g~[E]~w~ to sell drugs')
				if IsControlJustReleased(0, 153) then
					canSell = false
					lastPed = ped
					TriggerEvent('linden_drugsale:attemptSale', drugCount, playerPed, ped)
					sleep = 0
				end
			end
			Citizen.Wait(sleep)
		end
		isSelling = false
	end)
end

PedInteraction = function(playerPed, ped, item, count)
	local interaction = math.random(1, 100)

	if interaction <= Config.ChanceToRob then
		TriggerServerEvent('linden_drugsale:robPlayer', item, count)
		exports['ms-notify']:SendAlert({ type = 'normal', text = 'You were robbed', icon = 'fas fa-info-circle'})
		SetPedAsNoLongerNeeded(ped)
		TaskSmartFleePed(ped, playerPed, 1000.0, -1, false, true)
	end

	if interaction <= Config.ChanceToFight then
		TaskCombatPed(ped, playerPed, 0, 16)
	end
	isSelling = false
	SetPedAsNoLongerNeeded(ped)
end

AddEventHandler('linden_drugsale:attemptSale', function(drugCount, playerPed, ped)
	SetEntityAsMissionEntity(ped)
	TaskStandStill(ped, 5000)
	TaskChatToPed(ped, playerPed)

	TriggerEvent('mythic_progbar:client:progress', {
		name = 'attempt_drug_sale',
		duration = Config.AttemptSaleTime,
		label = 'Showing your product...',
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = 'missheistdockssetup1clipboard@idle_a',
			anim = 'idle_b',
		},
		prop = {
			model = 'prop_poly_bag_01',
			coords = { x = 0.15, y = -0.15, z = 0.02 },
			rotation = { x = 0.0, y = -40.0, z = -80.0 },
			bone = 18905
		}
	}, function(status)
		if not status then
			ClearPedTasks(playerPed)
			
			local interaction = math.random(1, 100)

			if interaction <= Config.ChanceToNotify then
				local data = {displayCode = '420', description = 'Drug sale in progress', recipientList = {'police'}, length = '7000'}
				local dispatchData = {dispatchData = data, caller = 'Local', coords = playerCoords}
				TriggerServerEvent('wf-alerts:svNotify', dispatchData)
			end
			
			local saleChance = math.random(1, 100)
			local drugSelection = math.random(1, drugCount)
			local sellCount = math.random(1, Config.MaxSellAmount)
			local drugToSell = nil
			local salePrice = 0

			local playerCoords = GetEntityCoords(playerPed)
			local increaseSaleOf = nil
			local distance

			for i, j in pairs(Config.SaleLocations) do
				distance = #(playerCoords - j.coords)
				if distance < j.radius then
					local increaseChance = math.random(1, 100)
					if increaseChance <= j.increaseSaleChance then
						increaseSaleOf = j.increaseSaleOf
					else
						increaseSaleOf = nil
					end
				end
			end

			for k, v in pairs(drugs) do
				if increaseSaleOf ~= nil then
					if v.name == increaseSaleOf then
						drugToSell = v
					else
						drugToSell = v
					end
				else
					drugToSell = v
				end
			end

			if sellCount > drugToSell.count then
				sellCount = math.random(1, drugToSell.count)
			end

			salePrice = math.random(Config.MinimumPayment, Config.Drugs[drugToSell.name] * sellCount)

			if numberOfCops == 1 then
				salePrice = salePrice * 1.1
			elseif numberOfCops == 2 then
				salePrice = salePrice * 1.2
			elseif numberOfCops > 2 then
				salePrice = salePrice * 1.3
			end

			if saleChance <= Config.ChanceToSell then
				TriggerEvent('linden_drugsale:requestConfirm', drugToSell.name, drugToSell.label, sellCount, math.floor(salePrice), playerPed, ped)
			else
				exports['ms-notify']:SendAlert({ type = 'normal', text = 'This shit is weak', icon = 'fas fa-info-circle' })
				PedInteraction(playerPed, ped, drugToSell.name, sellCount)
			end
		end
	end)
end)

AddEventHandler('linden_drugsale:requestConfirm', function(drugToSell, label, sellCount, salePrice, playerPed, ped)
	Citizen.CreateThread(function()
		local timer = 0
		
		while timer < Config.SaleConfirmTime do
			Citizen.Wait(0)
			timer = timer + 1
			if IsControlJustReleased(0, 38) then
				exports['ms-notify']:RemoveAlert('request_sale_confirmation')
				exports['ms-notify']:SendAlert({ type = 'success', text='Confirmed', icon = 'fas fa-check', time = 1000 })
				TriggerEvent('linden_drugsale:confirmSale', drugToSell, sellCount, salePrice, playerPed, ped)
				break
			end
		end

		if timer == Config.SaleConfirmTime then
			exports['ms-notify']:SendAlert({ type = 'error', text='You took too long', icon = 'fas fa-ban' })
			PedInteraction(playerPed, ped, drugToSell.name, sellCount)
		end
		
		exports['ms-notify']:RemoveAlert('request_sale_confirmation')
		timer = 0
	end)
	exports['ms-notify']:SendAlert({ id = 'request_sale_confirmation', type = 'normal', text = '[E] Sell '..sellCount..' '..label.. ' for $'..salePrice, icon = 'fas fa-info-circle', time = -1 })
end)

AddEventHandler('linden_drugsale:confirmSale', function(drugToSell, sellCount, salePrice, playerPed, ped)
	TriggerEvent('mythic_progbar:client:progress', {
		name = 'selling_drugs',
		duration = Config.SaleTime,
		label = 'Making the deal...',
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = 'missheistdockssetup1clipboard@idle_a',
			anim = 'idle_a'
		},
		prop = {
			model = 'prop_drug_package_02',
			
		}
	}, function(status)
		if not status then
			ClearPedTasks(playerPed)
			TriggerServerEvent('linden_drugsale:sellDrugs', drugToSell, sellCount, salePrice)
			Citizen.Wait(1000)
			SetPedAsNoLongerNeeded(ped)
			isSelling = false
		end
	end)
end)

if ESX.IsPlayerLoaded() then StartResource() end
