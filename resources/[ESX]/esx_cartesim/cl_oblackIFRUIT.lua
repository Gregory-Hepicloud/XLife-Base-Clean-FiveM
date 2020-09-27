
ESX = nil






                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
Citizen.CreateThread(function()

    while ESX == nil do

	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	Citizen.Wait(0)

    end

end)



local blips = {

    {title="Téléphone", colour=0, id=459, x = -632.9, y = -280.02, z = 36.52},



}



Citizen.CreateThread(function()

    for _, info in pairs(blips) do

        info.blip = AddBlipForCoord(info.x, info.y, info.z)

        SetBlipSprite(info.blip, info.id)

        SetBlipDisplay(info.blip, 4)

        SetBlipScale(info.blip, 0.7)

        SetBlipColour(info.blip, info.colour)

        SetBlipAsShortRange(info.blip, true)

        BeginTextCommandSetBlipName("STRING")

        AddTextComponentString(info.title)

        EndTextCommandSetBlipName(info.blip)

    

    end

end)



local iFruit = {



    Base = { Title = "Ifruit" },

    Data = { currentMenu = "iFruit" },

    Events = {



        onSelected = function(self, _, btn, CMenu, menuData, currentButton, currentSlt, result)

              if btn.name == "Téléphone" then

                    TriggerServerEvent('OblackTéléphone:buy', 500, "phone", "Téléphone")

             -- elseif btn.name == "Carte Sim" then

                  --  TriggerServerEvent('OblackTéléphone:buy', 100, "sim", "Carte Sim")









              end

        end,

    },



    Menu = {

        ["iFruit"] = {

            b = {

                {name = "Téléphone", ask = "→", askX = true},

                --{name = "Carte Sim", ask = "→", askX = true},

            }

        },



    }

}



local Shops = {

    { x = -627.7711, y = -274.9321, z = 35.577},

}



Citizen.CreateThread(function()

    while true do

        Citizen.Wait(0)



        for k in pairs(Shops) do



            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)

            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Shops[k].x, Shops[k].y, Shops[k].z)



            if dist <= 2.0 then

                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_TALK~ pour intéragir avec le ~g~Vendeur")

				if IsControlJustPressed(1,51) then 

                    CreateMenu(iFruit)

				end

            end

        end

    end

end)



Citizen.CreateThread(function()

    local hash = GetHashKey("cs_barry")



    while not HasModelLoaded(hash) do

        RequestModel(hash)

        Wait(20)

    end



    ped = CreatePed("PED_TYPE_CIVMALE", "cs_barry", -627.7711, -274.9321, 34.577, 116.982, false, true)

    SetBlockingOfNonTemporaryEvents(ped, true)

    SetEntityInvincible(ped, true)

    FreezeEntityPosition(ped, true)

end)



Citizen.CreateThread(function()

    local hash = GetHashKey("s_m_m_fiboffice_02")

    while not HasModelLoaded(hash) do

        RequestModel(hash)

        Wait(20)

    end

    

    ped = CreatePed("PED_TYPE_CIVMALE", "s_m_m_fiboffice_02", -641.4376, -287.5239, 34.440, 116.351, false, true)

    SetBlockingOfNonTemporaryEvents(ped, false)

    SetEntityInvincible(ped, false)

    FreezeEntityPosition(ped, false)

end)



Citizen.CreateThread(function()

    local hash = GetHashKey("s_m_m_fiboffice_01")



    while not HasModelLoaded(hash) do

        RequestModel(hash)

        Wait(20)

    end



    ped = CreatePed("PED_TYPE_CIVMALE", "s_m_m_fiboffice_01", -630.6692, -283.2282, 34.57, 37.507, false, true)

    SetBlockingOfNonTemporaryEvents(ped, false)

    SetEntityInvincible(ped, false)

    FreezeEntityPosition(ped, false)

end)

