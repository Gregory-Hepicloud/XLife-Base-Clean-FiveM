ESX = nil
local hasAlreadyEnteredMarker, lastZone
local currentAction, currentActionMsg, currentActionData = nil, nil, {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	if NetworkIsSessionStarted() then
		Citizen.Wait(15000)
		ESX.TriggerServerCallback('esx_shops:requestDBItems', function(ShopItems)
			for k,v in pairs(ShopItems) do
				Config.Zones[k].Items = v
			end
		end)
	end
end)

function OpenShopMenu(zone)
	local elements = {}
	
	SetNuiFocus(true, true)

	SendNUIMessage({
		display = true,
	})

	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]

		SendNUIMessage({
			itemLabel = item.label,
			item = item.item,
			price = item.price,
			imglink = item.imglink,
			zone = zone
		})
	end
end

AddEventHandler('esx_shops:hasEnteredMarker', function(zone)
	currentAction     = 'shop_menu'
	currentActionMsg  = _U('press_menu')
	currentActionData = {zone = zone}
end)

AddEventHandler('esx_shops:hasExitedMarker', function(zone)
	SendNUIMessage({
		display = false,
		clear = true
	})

	currentAction = false

	SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustReleased(1, 177) then
			SendNUIMessage({
				display = false,
				clear = true
			})

			SetNuiFocus(false, false)
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.Zones) do
		for i = 1, #v.Pos, 1 do
			local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)

			SetBlipSprite (blip, 59)
			SetBlipScale  (blip, 0.7)
			SetBlipColour (blip, 2)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(_U('shops'))
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, false

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				local distance = GetDistanceBetweenCoords(playerCoords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true)

				if distance < Config.DrawDistance then
					letSleep = false

					if distance < Config.Size.x then
						isInMarker  = true
						currentZone = k
						lastZone    = k
					end
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('esx_shops:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_shops:hasExitedMarker', lastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if currentAction then
			ESX.ShowHelpNotification(currentActionMsg)

			if IsControlJustReleased(0, 38) then
				if currentAction == 'shop_menu' then
					OpenShopMenu(currentActionData.zone)
				end
				currentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent("SendAdvanceNotify")
AddEventHandler("SendAdvanceNotify",function(type, item, amount)
	if type == 'enough' then

		exports['b1g_notify']:Notify('false', '	Vous devez avoir '..amount..'$ argent pour acheter cet article')
	elseif type == 'bought' then

		exports['b1g_notify']:Notify('true', 'Vous avez acheté '..item..' pour '..amount..'$ ')
	else 

		exports['b1g_notify']:Notify('false', 'Votre sac à dos est trop lourd pour transporter autant de choses.')
	end	
end)

RegisterNUICallback('buyItem', function(data, cb)
	TriggerServerEvent('esx_shops:buyItem', data.item, 1, data.zone)
end)

RegisterNUICallback('focusOff', function(data, cb)
	SetNuiFocus(false, false)
end)

----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", 1134.26, -982.79, 45.42, 270.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(1134.26, -982.79, 47.36)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)
----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", -47.42, -1758.67, 28.42, 55.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(-47.42, -1758.67, 30.35)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)
----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", -1221.74, -908.12, 11.33, 35.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(-1221.74, -908.12, 13.25)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)
----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", -706.06, -914.54, 18.22, 90.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(-706.06, -914.54, 20.15)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)

----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", 2557.25, 380.82, 107.62, 355.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(2557.25, 380.82, 109.53)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)

----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", 24.42, -1347.21, 28.5, 277.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(24.42, -1347.21, 30.5)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)

----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", 1164.89, -323.52, 68.21, 98.00, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(1164.89, -323.52, 70.21)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)

----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", -1486.33, -377.9, 39.16, 131.53, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(-1486.33, -377.9, 41.16)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)

----------------------------------------------------------------[PEDS MAGASINS]----------------------------------------------------------------

Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_epsilon_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVFEMALE", "a_m_y_epsilon_01", -1819.54, 793.55, 137.09, 141.28 , true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
end)

local v1 = vector3(-1819.54, 793.55, 139.09)

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local distance = 20

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < distance then
            Draw3DText(v1.x,v1.y,v1.z, "Vous souhaitez quelque chose ?")
        end
    end
end)