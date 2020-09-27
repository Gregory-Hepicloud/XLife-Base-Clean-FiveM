
------------------ removeAIcops ------------------------------------------------------------

Citizen.CreateThread(function()
while true do
Citizen.Wait(0)
local playerPed = GetPlayerPed(-1)
local playerLocalisation = GetEntityCoords(playerPed)
ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)
end
end)

----------------------------------------------------------------------------------------------



------------------ PVP ------------------------------------

AddEventHandler("playerSpawned", function(spawn)
	SetCanAttackFriendly(GetPlayerPed(-1), true, false)
	NetworkSetFriendlyFireOption(true)
end)

----------------------------------------------------------



------------------ ANTI PVP PNJ ------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetEveryoneIgnorePlayer(PlayerId(), true)
    end
end)

----------------------------------------------------------

------------------ Pas de drop d'armes voitures flics.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        DisablePlayerVehicleRewards(PlayerId())
    end
end)

----------------------------------------------------------