local ox_inventory = exports.ox_inventory

local canSell = false
local isSelling = false
local waitTime = 2000
local lastPed = nil
local numberOfCops = 0

local DrugNames = {}

for k, v in pairs(Config.Drugs) do
	table.insert(DrugNames, k)
end

----------------------------------------------------------------------------------
-- Show 3D Text -- 
----------------------------------------------------------------------------------

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

options = {
	{
        name = 'ox:option2',
        icon = 'fa-solid fa-comment-dots',
        label = 'Sell Drugs',
		distance = 3,
		items = DrugNames,
		anyItem = true,
		onSelect = function(data)
			local playerPed = PlayerPedId()
			canSell = false
			lastPed = data.entity
			TriggerEvent('linden_drugsale:attemptSale', CountDrugs(), playerPed, data.entity)
		end,
         canInteract = function(entity, distance)
             return not IsEntityDead(entity) and distance < 3 and canSell and not isSelling and entity ~= lastPed and GetPedType(entity) ~= 1 and GetPedType(entity) ~= 28 and GetPedType(entity) ~= 2
         end
    }
}

exports.ox_target:addGlobalPed(options)
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
CountDrugs = function()
	local drugCount = 0
	for k, v in pairs(Config.Drugs) do
		local search = exports.ox_inventory:Search('count', k)
		if search > 0 then
			drugCount = drugCount+1 
		end
	end
end

CanSellDrugs = function()
	local itemNames = {}

	for item, data in pairs(exports.ox_inventory:Items()) do
		itemNames[item] = data.label
	end

	isSelling = true
	drugs = {}
	local drugCount = 0
	for k, v in pairs(Config.Drugs) do
		local search = exports.ox_inventory:Search('count', k)
		if search > 0 then
			if drugs[k] then 
				drugs[k].count = drugs[k].count + search 
			else
				drugs[k] = {index=drugCount+1, name=k, count=search, label=itemNames[k]} 
				drugCount = drugCount+1 
			end
		end
	end
	Citizen.CreateThread(function()
		ESX.TriggerServerCallback('linden_drugsale:checkCops', function(copsOnline)
			numberOfCops = copsOnline
			canSell = true
		end)
		isSelling = false
	end)
end

PedInteraction = function(playerPed, ped, item, count)
	local interaction = 100
	interaction = math.random(100)
	local chanceToRob = Config.ChanceToRob

	if interaction <= chanceToRob then
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
	if lib.progressBar({
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
	}) then
		ClearPedTasks(playerPed)
		
		local interaction = math.random(1, 100)
		
		local saleChance = math.random(1, 100)
		-- local drugSelection = math.random(1, drugCount)
		local sellCount = math.random(Config.MaxSellAmount)
		local drugToSell = nil
		local salePrice = 0

		local playerCoords = GetEntityCoords(playerPed)
		local increaseSaleOf = nil
		local saleLocation = nil
		local distance

		local chancetoSell = Config.ChanceToSell

		for i, j in pairs(Config.SaleLocations) do
			distance = #(playerCoords - j.coords)
			if distance < j.radius then
				local increaseChance = math.random(1, 100)
				interaction = j.increaseChanceToNotify
				saleLocation = i
				if increaseChance <= j.increaseSaleChance then
					increaseSaleOf = j.increaseSaleOf
				else
					increaseSaleOf = nil
					saleLocation = nil
				end
			end
		end

		-- if interaction <= Config.ChanceToNotify then
		-- 	local data = {displayCode = '420', description = 'Drug sale in progress', recipientList = {'police'}, length = '7000'}
		-- 	local dispatchData = {dispatchData = data, caller = 'Local', coords = playerCoords}
		-- 	TriggerServerEvent('wf-alerts:svNotify', dispatchData)
		-- end
		local increaseSalePrice = 1

		for k, v in pairs(drugs) do
			if increaseSaleOf ~= nil then
				if v.name == increaseSaleOf then
					drugToSell = v
					increaseSalePrice = Config.SaleLocations(saleLocation).increaseEarnings
					chancetoSell = (100 - Config.SaleLocations(saleLocation).increaseSaleChance)
				else
					drugToSell = v
					increaseSalePrice = 1
				end
			else
				drugToSell = v
				increaseSalePrice = 1
			end
		end

		if sellCount > drugToSell.count then
			sellCount = math.random(drugToSell.count)
		end

		salePrice = ((math.random(Config.MinimumPayment, (Config.Drugs[drugToSell.name]+20)) * increaseSalePrice) * sellCount)

		if numberOfCops == 2 then
			salePrice = salePrice * 1.1
		elseif numberOfCops == 3 then
			salePrice = salePrice * 1.2
		elseif numberOfCops > 4 then
			salePrice = salePrice * 1.3
		end

		if saleChance <= chancetoSell then
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
	if lib.progressBar({
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
	}) then
			ClearPedTasks(playerPed)
			TriggerServerEvent('linden_drugsale:sellDrugs', drugToSell, sellCount, salePrice)
			Citizen.Wait(1000)
			SetPedAsNoLongerNeeded(ped)
			isSelling = false
		end
end)

if ESX.IsPlayerLoaded() then StartResource() end
