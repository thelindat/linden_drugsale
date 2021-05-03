local canSell = false
local isSelling = false
local waitTime = 2000

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
			if ped ~= 0 and GetPedType(ped) ~= 1 and GetPedType(ped) ~= 28 then
				pedCoords = GetEntityCoords(ped)
				local dist = #(playerCoords - pedCoords)
				if dist < 1.0 then waitTime = 10
					if not isSelling then
						canSell = true
						CanSellDrugs(ped)
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
	isSelling = true
	Citizen.CreateThread(function()
		while canSell do
			drugs = {}
			local drugCount = 0
			local sleep = 10000
			ESX.PlayerData.inventory = ESX.GetPlayerData().inventory
			for k, v in pairs(ESX.PlayerData.inventory) do
				if Config.Drugs[v.name] then
					if drugs[v.name] then drugs[v.name].count = drugs[v.name].count + v.count else drugs[v.name] = {index=drugCount+1, name=v.name, count=v.count} drugCount = drugCount+1 end
				end
			end
			if drugCount > 0 then
				sleep = 5
				local text = 'Press ~g~[E]~w~ to sell drugs'
				if IsControlJustReleased(0, 153) then
					canSell = false
					local random = math.random(1~(drugCount+2))
					if random <= drugCount then	
						for k,v in pairs(drugs) do
							if v.index == random then sellDrug = v break end
						end
						TriggerServerEvent('linden_drugsale:sellDrugs', sellDrug.name)
					else	
						local random = math.random(1,10)
						if random > 8 then
							local data = {displayCode = '420', description = 'Drug sale in progress', recipientList = {'police'}, length = '7000'}
							local dispatchData = {dispatchData = data, caller = 'Local', coords = playerCoords}
							TriggerServerEvent('wf-alerts:svNotify', dispatchData)
						else print('not interested') end
					end
				end
				Draw3dText(pedCoords,text)
			end
			Citizen.Wait(sleep)
		end
		isSelling = false
	end)
end

if ESX.IsPlayerLoaded() then StartResource() end
