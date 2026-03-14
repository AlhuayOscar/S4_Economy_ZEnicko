S4_Eco_Client = {}

local function reloadOpenShopWindows(modKey)
    local ComUI = S4_Computer_Main and S4_Computer_Main.instance or nil
    if not ComUI then
        return
    end

    local function safeReload(app, modKey)
        if not app or not app.isVisible or not app:isVisible() then
            return
        end
        local mainPage = app.MainPage
        if mainPage and mainPage.OnShopDataUpdated then
            pcall(function()
                mainPage:OnShopDataUpdated(modKey)
            end)
            return
        end
        if mainPage and mainPage.ReloadData then
            pcall(function()
                mainPage:ReloadData()
            end)
            return
        end
        if app.ReloadUI then
            pcall(function()
                app:ReloadUI()
            end)
        end
    end

    safeReload(ComUI.GoodShop, modKey)
    safeReload(ComUI.VehicleShop, modKey)
    safeReload(ComUI.GoodShopAdmin, modKey)
end

-- Mode data reception
function S4_Eco_Client.OnReceiveGlobalModData(key, modData)
    if not modData then
        return
    end
    ModData.remove(key)
    ModData.add(key, modData)
    if key == "S4_ShopData" or key == "S4_PlayerShopData" then
        reloadOpenShopWindows(key)
    end
end
Events.OnReceiveGlobalModData.Add(S4_Eco_Client.OnReceiveGlobalModData)

function S4_Eco_Client.OnConnected()
    if SandboxVars and SandboxVars.S4SandBox and not SandboxVars.S4SandBox.SinglePlay and isServer() then
        return
    end
    -- Economey
    ModData.request("S4_CardData")
    ModData.request("S4_CardLog")
    -- PlayerData
    ModData.request("S4_PlayerData")
    -- Quest
    ModData.request("S4_QuestData")
    -- Shop
    ModData.request("S4_ShopData")
    ModData.request("S4_PlayerShopData")
    -- Xp Count
    ModData.request("S4_PlayerXpData")
    -- Server Data
    ModData.request("S4_ServerData")

    S4_Eco_Client.RegisterMoveableATMs()
end
Events.OnConnected.Add(S4_Eco_Client.OnConnected)

function S4_Eco_Client.CreatePlayerData()
    if SandboxVars and SandboxVars.S4SandBox and not SandboxVars.S4SandBox.SinglePlay and isServer() then
        return
    end

    local Player = getSpecificPlayer(0)
    if not Player then
        return
    end

    local PlayerModData = ModData.get("S4_PlayerData")
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    local PlayerXpModData = ModData.get("S4_PlayerXpData")
    if not PlayerModData and not PlayerShopModData and not PlayerXpModData then
        return
    end

    local PlayerName = Player:getUsername()
    -- if PlayerModData[PlayerName] and PlayerShopModData[PlayerName] and PlayerXpModData[PlayerName] then
    if PlayerModData[PlayerName] and PlayerShopModData[PlayerName] then
        Events.EveryOneMinute.Remove(S4_Eco_Client.CreatePlayerData)
    else
        if not PlayerModData[PlayerName] then
            sendClientCommand("S4PD", "CreatePlayerData", {false})
        end
        if not PlayerShopModData[PlayerName] then
            sendClientCommand("S4PD", "CreatePlayerShopData", {false})
        end
        -- if not PlayerXpModData[PlayerName] then
        --     sendClientCommand("S4PD", "CreatePlayerData", {false})
        -- end
    end
end
Events.EveryOneMinute.Add(S4_Eco_Client.CreatePlayerData)

local Object_Range = 10
-- local Computer_LightList = {}
local Computer_Sprite = {"appliances_com_01_72", "appliances_com_01_73", "appliances_com_01_74", "appliances_com_01_75",
                         "appliances_com_01_76", "appliances_com_01_77", "appliances_com_01_78", "appliances_com_01_79"}

local function setSpriteMoveableWeight(spriteName, weight)
    if not spriteName or not weight then
        return
    end
    local sprite = getSprite(spriteName)
    if not sprite or not sprite.getProperties then
        return
    end
    local props = sprite:getProperties()
    if not props or not props.Set then
        return
    end

    props:Set("IsMoveAble", "true")
    props:Set("PickUpWeight", tostring(weight))
end

function S4_Eco_Client.RegisterMoveableATMs()
    -- Standing ATM (heavier)
    local normalATM = {"location_business_bank_01_64", "location_business_bank_01_65", "location_business_bank_01_66",
                       "location_business_bank_01_67"}
    -- Wall ATM (lighter)
    local wallATM = {"location_business_bank_01_68", "location_business_bank_01_69", "location_business_bank_01_70",
                     "location_business_bank_01_71"}

    for i = 1, #normalATM do
        setSpriteMoveableWeight(normalATM[i], 40)
    end
    for i = 1, #wallATM do
        setSpriteMoveableWeight(wallATM[i], 25)
    end
end
Events.OnGameStart.Add(S4_Eco_Client.RegisterMoveableATMs)

function S4_Eco_Client.ObjectEffect()
    local Multi = false
    if SandboxVars and SandboxVars.S4SandBox and not SandboxVars.S4SandBox.SinglePlay then
        Multi = true
        if isServer() then
            return
        end
    end
    local player = getSpecificPlayer(0)
    if not player then
        return
    end

    local Px, Py, Pz = player:getX(), player:getY(), player:getZ()
    for x = Px - Object_Range, Px + Object_Range do
        for y = Py - Object_Range, Py + Object_Range do
            local Square = getCell():getGridSquare(x, y, Pz)
            if Square then
                for i = 0, Square:getObjects():size() - 1 do
                    local Obj = Square:getObjects():get(i)
                    for _, SpriteName in ipairs(Computer_Sprite) do
                        if Obj:getSprite() == getSprite(SpriteName) then
                            local ObjModData = Obj:getModData()
                            if ObjModData.ComPower then
                                S4_Eco_Client.ComSpriteOn(Obj, Multi)
                                local ElectricCheck = ((SandboxVars.AllowExteriorGenerator and
                                                          Obj:getSquare():haveElectricity()) or
                                                          (SandboxVars.ElecShutModifier > -1 and
                                                              GameTime:getInstance():getNightsSurvived() <
                                                              SandboxVars.ElecShutModifier and
                                                              not Obj:getSquare():isOutside()))
                                if not ElectricCheck then
                                    ObjModData.ComPower = false
                                    S4_Utils.SnycObject(Obj)
                                    S4_Eco_Client.ComSpriteOff(Obj, Multi)
                                end
                            else
                                S4_Eco_Client.ComSpriteOff(Obj, Multi)
                            end
                        end
                    end
                end
            end
        end
    end
end
Events.EveryOneMinute.Add(S4_Eco_Client.ObjectEffect)

function S4_Eco_Client.ComSpriteOn(Obj, Multi)
    if Obj:getSprite() == getSprite("appliances_com_01_72") then
        Obj:setSprite(getSprite("appliances_com_01_76"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    elseif Obj:getSprite() == getSprite("appliances_com_01_73") then
        Obj:setSprite(getSprite("appliances_com_01_77"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    elseif Obj:getSprite() == getSprite("appliances_com_01_74") then
        Obj:setSprite(getSprite("appliances_com_01_78"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    elseif Obj:getSprite() == getSprite("appliances_com_01_75") then
        Obj:setSprite(getSprite("appliances_com_01_79"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    end
end

function S4_Eco_Client.ComSpriteOff(Obj, Multi)
    if Obj:getSprite() == getSprite("appliances_com_01_76") then
        Obj:setSprite(getSprite("appliances_com_01_72"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    elseif Obj:getSprite() == getSprite("appliances_com_01_77") then
        Obj:setSprite(getSprite("appliances_com_01_73"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    elseif Obj:getSprite() == getSprite("appliances_com_01_78") then
        Obj:setSprite(getSprite("appliances_com_01_74"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    elseif Obj:getSprite() == getSprite("appliances_com_01_79") then
        Obj:setSprite(getSprite("appliances_com_01_75"))
        if Multi then
            Obj:transmitUpdatedSpriteToServer()
        end
    end
end

-- Later, the weight of each item was measured.
function S4_Eco_Client.DeliveryCheck()
    local player = getSpecificPlayer(0)
    if not player then
        return
    end
    local playerName = player:getUsername()
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    -- Shop Buy Delivery Check
    if PlayerShopModData and PlayerShopModData[playerName] then
        local PlayerShopData = PlayerShopModData[playerName]
        for DeilveryTime, Data in pairs(PlayerShopData.Delivery) do
            if not S4_Utils.getTimeOver(DeilveryTime) then
                if Data.XYZCode then
                    local CodeX, CodeY, CodeZ = string.match(Data.XYZCode, "X(%d+)Y(%d+)Z(%d+)")
                    local x, y, z = tonumber(CodeX), tonumber(CodeY), tonumber(CodeZ)
                    local square = getCell():getGridSquare(x, y, z)
                    if square then
                        local BoxCount = 1
                        local BoxData = {}
                        for ItemName, Amount in pairs(Data.List) do
                            local ItemData = S4_Utils.setItemCashe(ItemName)
                            local ItemWeight = ItemData:getWeight() / 10
                            for i = 1, Amount do
                                if BoxData[BoxCount] and BoxData[BoxCount].Weight then
                                    if BoxData[BoxCount].Weight + ItemWeight > 45 then
                                        BoxCount = BoxCount + 1
                                    end
                                end
                                if not BoxData[BoxCount] then
                                    BoxData[BoxCount] = {}
                                    BoxData[BoxCount].ItemList = {}
                                    BoxData[BoxCount].ItemList[ItemName] = 1
                                    BoxData[BoxCount].Weight = ItemWeight
                                else
                                    if BoxData[BoxCount].ItemList[ItemName] then
                                        BoxData[BoxCount].ItemList[ItemName] = BoxData[BoxCount].ItemList[ItemName] + 1
                                    else
                                        BoxData[BoxCount].ItemList[ItemName] = 1
                                    end
                                    BoxData[BoxCount].Weight = BoxData[BoxCount].Weight + ItemWeight
                                end
                            end
                        end
                        for BoxNumeber, BData in pairs(BoxData) do
                            local BoxItem = square:AddWorldInventoryItem("S4Item.BuyPackingBox", 0.5, 0.5, 0)
                            local BoxItemModData = BoxItem:getModData()
                            if BData.Weight > 45 then
                                BData.Weight = 45
                            end
                            BoxItem:setWeight(BData.Weight)
                            BoxItem:setActualWeight(BData.Weight)
                            BoxItem:setCustomWeight(true)
                            ISInventoryPage.dirtyUI()
                            BoxItemModData.S4ItemList = BData.ItemList
                            if Data.BankCard then
                                BoxItemModData.BankCard = Data.BankCard
                            end
                            S4_Utils.SnycObject(BoxItem)
                        end
                        sendClientCommand("S4PD", "RemoveDelivery", {DeilveryTime})
                    end
                end
            end
        end
    end
    -- AirDrop Check
    -- if S4_AirDrop_Client.AirDropList then
    --     for XYCode, A_Data in pairs(S4_AirDrop_Client.AirDropList) do
    --         if A_Data.Check then
    --             local Ax, Ay, Az = A_Data.PointX, A_Data.PointY, 0
    --             local square = getCell():getGridSquare(Ax, Ay, Az)
    --             if square then
    --                 local ServerModData = ModData.get("S4_ServerData")
    --                 if ServerModData and ServerModData.AirDropList and ServerModData.AirDropList[XYCode] then
    --                     sendClientCommand("S4SMD", "CreateAirDropBox", {XYCode})
    --                     -- sendClientCommand(player, 'object', 'addSmokeOnSquare', { x = Ax, y = Ay, z = Az })
    --                     local AirDropItem = square:AddWorldInventoryItem("S4Item.AirDropBox", 0.5, 0.5, 0)
    --                     AirDropItem:setWeight(500)
    --                     AirDropItem:setActualWeight(500)
    --                     AirDropItem:setCustomWeight(true)
    --                     local AirDropItemModData = AirDropItem:getModData()
    --                     AirDropItemModData.S4AirDropType = A_Data.DropType
    --                     S4_Utils.SnycObject(AirDropItem)
    --                 end
    --             end
    --         end
    --     end
    -- end
end
Events.EveryTenMinutes.Add(S4_Eco_Client.DeliveryCheck)

function S4_Eco_Client.ShopAuthority()
    local player = getSpecificPlayer(0)
    if not player then
        return
    end

    local playerName = player:getUsername()
    local PlayerShopData = ModData.get("S4_PlayerShopData")[playerName]
    if not PlayerShopData then
        return
    end

    -- Function for calculating total sum
    local function getAuthorityTotal(NextAuthority, TotalType)
        local AuthorityList = {"Bronze", "Silver", "Gold", "Platinum", "Diamond", "VIP"}
        local Total = 0
        -- In case of level 0, it is excluded from Total as it is the basic level i = 2
        for i = 2, NextAuthority + 1 do
            Total = Total + SandboxVars.S4Authority[TotalType .. AuthorityList[i]]
        end
        return Total
    end

    -- Calculate purchase authority
    local BuyTotal = PlayerShopData.BuyTotal
    local BuyAuthority = PlayerShopData.BuyAuthority
    local NextBuyAuthority = BuyAuthority + 1
    if NextBuyAuthority > 5 then
        NextBuyAuthority = 5
    end
    local BuyAuthorityTotal = getAuthorityTotal(NextBuyAuthority, "BuyAuthority")

    -- Sales Authorization Calculation
    local SellTotal = PlayerShopData.SellTotal
    local SellAuthority = PlayerShopData.SellAuthority
    local NextSellAuthority = SellAuthority + 1
    if NextSellAuthority > 5 then
        NextSellAuthority = 5
    end
    local SellAuthorityTotal = getAuthorityTotal(NextSellAuthority, "SellAuthority")
    -- If you are at the same level, you will not level up.
    -- Update permissions when the total meets the conditions
    if BuyTotal >= BuyAuthorityTotal and SellTotal >= SellAuthorityTotal and BuyAuthority ~= NextBuyAuthority and
        SellAuthority ~= NextSellAuthority then
        sendClientCommand("S4PD", "SetAuthority", {NextBuyAuthority, NextSellAuthority})
    elseif BuyTotal >= BuyAuthorityTotal and BuyAuthority ~= NextBuyAuthority then
        sendClientCommand("S4PD", "SetAuthority", {NextBuyAuthority, false})
    elseif SellTotal >= SellAuthorityTotal and SellAuthority ~= NextSellAuthority then
        sendClientCommand("S4PD", "SetAuthority", {false, NextSellAuthority})
    end
end
Events.EveryDays.Add(S4_Eco_Client.ShopAuthority)

function S4_Eco_Client.XpTest(character, perk, amount)
    print("[Xp Test]")
    print("Player: " .. tostring(character))
    print("PlayerName: " .. tostring(character:getUsername()))
    print("Perk: " .. tostring(perk))
    print("Amount: " .. tostring(amount))
end
-- Events.AddXP.Add(S4_Eco_Client.XpTest)
