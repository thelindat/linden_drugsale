local ox_inventory = exports.ox_inventory

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
		for k, v in pairs(Config.Drugs) do
		drugCount = drugCount + ox_inventory:Search(source, 'count', Config.Drugs[v.name])
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
		lib.notify({
			title = 'You Were Robbed!',
			description = 'Thank\'s Asshole!',
			type = 'error'
		})		
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
	lib.progressBar({
		duration = Config.AttemptSaleTime,
		label = 'Showing your product...',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = true,
		},
		anim = {
			dict = 'missheistdockssetup1clipboard@idle_a',
			clip = 'idle_b',
		},
		prop = {
			model = 'prop_poly_bag_01',
			pos = vec3(0.15, -0.15, 0.02),
			rot = vec3(0.0, -40.0, -80.0),
			bone = 18905
		},
	},
	function(status)
		if not status then
			ClearPedTasks(playerPed)
			
			local interaction = math.random(1, 100)

			if interaction <= Config.ChanceToNotify then
				local data = {displayCode = '420', description = 'Drug sale in progress', recipientList = {'police'}, length = '7000'}
				local dispatchData = {dispatchData = data, caller = 'Local', coords = playerCoords}
				TriggerServerEvent('wf-alerts:svNotify', dispatchData)
			end
			
			local saleChance = math.random(1, 100)
			-- local drugSelection = math.random(1, drugCount)
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

			salePrice = (math.random(Config.MinimumPayment, Config.Drugs[drugToSell.name]) * sellCount)

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
				lib.notify({
					title = 'Feedback',
					description = 'This shit is weak..',
					type = 'inform'
				})
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
				lib.notify({
					title = 'Sold',
					description = 'Thanks man.',
					type = 'success'
				})				
				TriggerEvent('linden_drugsale:confirmSale', drugToSell, sellCount, salePrice, playerPed, ped)
				break
			end
		end

		if timer == Config.SaleConfirmTime then
			lib.notify({
				title = 'Timeout',
				description = 'You\'re taking too long, I\'m out of here.',
				type = 'error'
			})			
			PedInteraction(playerPed, ped, drugToSell.name, sellCount)
		end
		timer = 0
	end)
	lib.notify({
		title = 'Confirm Sale',
		description = 'Press [E] Sell '..sellCount..' '..label.. ' for $'..salePrice,
		type = 'inform'
	})
end)

AddEventHandler('linden_drugsale:confirmSale', function(drugToSell, sellCount, salePrice, playerPed, ped)
	lib.progressBar({
		duration = Config.SaleTime,
		label = 'Making the deal...',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = true,
		},
		anim = {
			dict = 'missheistdockssetup1clipboard@idle_a',
			clip = 'idle_a'
		},
		prop = {
			model = 'prop_drug_package_02',
			pos = vec3(0.03, 0.03, 0.02),
			rot = vec3(0.0, 0.0, -1.5)
		},
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
