S4_AirDrop_Client = {}
S4_AirDrop_Client.Today = false
S4_AirDrop_Client.TodayX = false
S4_AirDrop_Client.TodayY = false


function S4_AirDrop_Client.OnRadioDevice(guid, codes, x, y, z, text, device)
    -- print("guid:"..tostring(guid))
    -- print("codes:"..tostring(codes))
    -- print("x:"..tostring(x))
    -- print("y:"..tostring(y))
    -- print("z:"..tostring(z))
    -- print("text:"..tostring(text))
    -- print("device:"..tostring(device))
    if text == getRadioText("HIND_AirDrop_TodayDrop") or text == getRadioText("HIND_Area_ReXYZ")
    or text == getRadioText("HIND_Area_Muldraugh") or text == getRadioText("HIND_Area_WestPoint")
    or text == getRadioText("HIND_Area_Rosewood") or text == getRadioText("HIND_Area_Riverside")
    or text == getRadioText("HIND_Area_Brandenburg") or text == getRadioText("HIND_Area_Ekron")
    or text == getRadioText("HIND_Area_Irvington") or text == getRadioText("HIND_Area_MarchRidge")
    or text == getRadioText("HIND_Area_FallasLake") or text == getRadioText("HIND_Area_EchoCreek")
    or text == getRadioText("HIND_Area_Louisville") then
        if S4_AirDrop_Client.Today then return end
        local AirDropModData = ModData.get("S4_ServerData")
        if not AirDropModData and not AirDropModData.TodayAirDrop then 
            return 
        end
        local x, y = AirDropModData.TodayAirDrop.X, AirDropModData.TodayAirDrop.Y
        S4_AirDrop_Client.TodayX = x
        S4_AirDrop_Client.TodayY = y
        S4_AirDrop_Client.CheckAirDrop()
        if not ISWorldMap_instance then 
            ISWorldMap.ShowWorldMap(0)
            ISWorldMap_instance:close()
        end

        local MapAPI = ISWorldMap_instance.javaObject:getAPIv1()
        local SymAPI = MapAPI:getSymbolsAPI()
        local NewSymbol = SymAPI:addTexture("AirDrop", x, y)
        NewSymbol:setAnchor(0.5, 0.5)
        NewSymbol:setRGBA(1, 0, 0, 1)
    else
        -- print(tostring(text))
    end

end
Events.OnDeviceText.Add(S4_AirDrop_Client.OnRadioDevice)

function S4_AirDrop_Client.CheckAirDrop()
    if S4_AirDrop_Client.Today then return end
    local XYCode = "X"..S4_AirDrop_Client.TodayX.."Y"..S4_AirDrop_Client.TodayY
    sendClientCommand("S4SMD", "CheckAirDrop", {XYCode})
    S4_AirDrop_Client.Today = true
end

function S4_AirDrop_Client.DayAirDrop()
    S4_AirDrop_Client.Today = false
    S4_AirDrop_Client.TodayX = false
    S4_AirDrop_Client.TodayY = false
    local ServerModData = ModData.get("S4_ServerData")
    if ServerModData and ServerModData.AirDropList then
        S4_AirDrop_Client.AirDropList = {}
        S4_AirDrop_Client.AirDropList = copyTable(ServerModData.AirDropList)
    end
end
Events.EveryDays.Add(S4_AirDrop_Client.DayAirDrop)


local OnGameStartAddSymbol = function ()
    MapSymbolDefinitions.getInstance():addTexture("AirDrop", "media/ui/LootableMaps/map_airdrop.png", "Loot")

    local ServerModData = ModData.get("S4_ServerData")
    if ServerModData and ServerModData.AirDropList then
        S4_AirDrop_Client.AirDropList = {}
        S4_AirDrop_Client.AirDropList = copyTable(ServerModData.AirDropList)
    end
end

Events.OnGameStart.Add(OnGameStartAddSymbol)