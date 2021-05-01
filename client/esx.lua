ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
  StartResource()
end)

RegisterNetEvent('esx:onPlayerLogout')	-- Trigger this event when a player logs out to character selection
AddEventHandler('esx:onPlayerLogout', function()
  PlayerLoaded = false
  ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)
