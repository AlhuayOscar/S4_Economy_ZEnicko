S4_Eco_Context = {}

function S4_Eco_Context.InventoryMenu(playerNum, context, items)
    items = ISInventoryPane.getActualItems(items)
    local item = items[1]
    if not item then return end
    local player = getSpecificPlayer(playerNum)
    local itemName = item:getFullType()
    if itemName == "S4Item.Signal" then
        context:addOption(getText("ContextMenu_S4_Signal_Install"), player, S4_Eco_Context.SetAddress)
    elseif itemName == "S4Item.BuyPackingBox" then
        context:addOption(getText("ContextMenu_S4_BuyBox_Open"), player, S4_Eco_Context.BoxOpen, item)
    elseif itemName == "Base.Money" or itemName == "Base.MoneyBundle" then
        context:addOption(getText("ContextMenu_S4_Cash_Check"), player, S4_Eco_Context.CashCheck, item)
        context:addOption(getText("ContextMenu_S4_Cash_Check_All"), player, S4_Eco_Context.CashCheckAll)
    elseif itemName == "S4Item.AirDropBox_Weapon" or itemName == "S4Item.AirDropBox_Ammo" or
    itemName == "S4Item.AirDropBox_Food" or itemName == "S4Item.AirDropBox_Medical" or
    itemName == "S4Item.AirDropBox_Materials" or itemName == "S4Item.AirDropBox_Etc" then
        local IvnItemsTable = S4_Utils.getPlayerItems(player)
        local AirDropMenu = context:addOption(getText("ContextMenu_S4_AirDrop_Open"), player, S4_Eco_Context.AirDropOpen, item)
        local AirDropToolTip = ISToolTip:new()
        AirDropMenu.toolTip = AirDropToolTip
        AirDropToolTip.description = getText("Tooltip_S4_AirDrop")
        AirDropToolTip:setName(getText("Tooltip_S4_AirDrop_Open"))

        local ItemCashe = S4_Utils.setItemCashe("Base.Crowbar")
        local NeedItemName = ItemCashe:getDisplayName()
        if IvnItemsTable and IvnItemsTable["Base.Crowbar"] then
            AirDropToolTip.description = AirDropToolTip.description .. " <LINE> " .. string.format(getText("Tooltip_S4_NeedItems"), NeedItemName, 1, 1)
        else
            AirDropToolTip.description = AirDropToolTip.description .. " <LINE> " .. string.format(getText("Tooltip_S4_NeedItems"), NeedItemName, 0, 1)
            AirDropMenu.onSelect = nil
            AirDropMenu.notAvailable = true
        end
    end
    -- context:addOption(getText("Test Menu"), player, S4_Eco_Context.TestMenu, item)
end

-- Test
function S4_Eco_Context.TestMenu(player, item)
    print("Now Hour Time: "..tostring(getGameTime():getWorldAgeHours()))
    print("Now Day Time: "..tostring(getWorld():getWorldAgeDays()))
    item:setAge(0)
    -- print("Age: "..tostring(item:getAge()))
end

-- AirDrop
function S4_Eco_Context.AirDropOpen(player, item)
    local Action = S4_Action_AirDrop:new(player, item)
    ISTimedActionQueue.add(Action)
end

-- Open UI to install a delivery address signal device.
function S4_Eco_Context.SetAddress(player)
    S4_Signal_Main:show(player)
    -- local SignalCursor = ISSignalCursor:new(player, worldobjects, IvnItems)
    -- getCell():setDrag(SignalCursor, SignalCursor.player)
end
-- Open delivery box
function S4_Eco_Context.BoxOpen(player, item)
    local itemModData = item:getModData()
    local sq = player:getSquare()
    if not sq then return end
    if itemModData.S4ItemList then
        for itemName, Amount in pairs(itemModData.S4ItemList) do
            for i = 1, Amount do
                if itemModData.BankCard then
                    local CreateCard = instanceItem("Base.CreditCard")
                    local CardItem = player:getInventory():AddItem(CreateCard)
                    local CardItemModData = CardItem:getModData()
                    local DisplayName = string.format(getText("IGUI_S4_Item_CreditCard"), player:getUsername())
                    local NewCardNumber = string.format(getText("IGUI_S4_Item_CardNumber"), itemModData.BankCard)
                    CardItemModData.S4CardNumber = itemModData.BankCard
                    S4_Utils.SnycObject(CardItem)
                    CardItem:setName(DisplayName .. NewCardNumber)
                else
                    local Sqitem = sq:AddWorldInventoryItem(itemName, 0.3, 0.3, 0)
                    if instanceof(Sqitem, "Food") then
                        Sqitem:setAge(0)
                        S4_Utils.SnycObject(Sqitem)
                    end
                end
            end
        end
        if item:getWorldItem() then
            item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
            ISInventoryPage.dirtyUI()
        else
            if item:getContainer() then
                item:getContainer():Remove(item)
            else
                player:getInventory():Remove(item)
            end
        end
    end
end

-- Convert default money items
function S4_Eco_Context.CashCheck(player, item)
    S4_Utils.CheckInvCash(player, item)
end
function S4_Eco_Context.CashCheckAll(player)
    local InvItems = S4_Utils.getPlayerItems(player)
    if InvItems then
        if InvItems["Base.Money"] then
            local MoneyAmount = InvItems["Base.Money"].Amount
            for i = 1, MoneyAmount do
                local item = InvItems["Base.Money"].items[i]
                S4_Utils.CheckInvCash(player, item)
            end
        end
        if InvItems["Base.MoneyBundle"] then
            local MoneyBundleAmount = InvItems["Base.MoneyBundle"].Amount
            for i = 1, MoneyBundleAmount do
                local item = InvItems["Base.MoneyBundle"].items[i]
                S4_Utils.CheckInvCash(player, item)
            end
        end
    end
end
Events.OnPreFillInventoryObjectContextMenu.Add(S4_Eco_Context.InventoryMenu)

local S4_Eco_Tiles_List = { -- ATM/Computer tile data
    -- Computer
    ["appliances_com_01_72"] = {Px = 0, Py = 1, Type = "Computer"},
    ["appliances_com_01_73"] = {Px = 1, Py = 0, Type = "Computer"},
    ["appliances_com_01_74"] = {Px = 0, Py = -1, Type = "Computer"},
    ["appliances_com_01_75"] = {Px = -1, Py = 0, Type = "Computer"},
    ["appliances_com_01_76"] = {Px = 0, Py = 1, Type = "Computer"},
    ["appliances_com_01_77"] = {Px = 1, Py = 0, Type = "Computer"},
    ["appliances_com_01_78"] = {Px = 0, Py = -1, Type = "Computer"},
    ["appliances_com_01_79"] = {Px = -1, Py = 0, Type = "Computer"},
    -- ATM
    ["location_business_bank_01_64"] = {Px = 1, Py = 0, Type = "ATM"},
    ["location_business_bank_01_65"] = {Px = 0, Py = 1, Type = "ATM"},
    ["location_business_bank_01_66"] = {Px = 0, Py = 0, Type = "ATM"},
    ["location_business_bank_01_67"] = {Px = 0, Py = 0, Type = "ATM"},
    -- TODO: add direction values to find/look at the target object.
    -- PostBox
    ["street_decoration_01_8"] = {Px = 0, Py = 1, Type = "PostBox"},
    ["street_decoration_01_9"] = {Px = 1, Py = 0, Type = "PostBox"},
    ["street_decoration_01_10"] = {Px = 0, Py = -1, Type = "PostBox"},
    ["street_decoration_01_11"] = {Px = -1, Py = 0, Type = "PostBox"},
}

function S4_Eco_Context.ObjectsMenu(playerNum, context, worldobjects)
    local player = getSpecificPlayer(playerNum)
    local UserName = player:getUsername()
    local sq = worldobjects[1]:getSquare()
    local objects = sq:getObjects()
    local IvnItemsTable = S4_Utils.getPlayerItems(player)
    -- ATM/Computer/PostBox object context menu
    -- Computer modData: ComPower = power, ComPassword = computer password, ComLock = lock state, ComAdmin = main user
    -- Computer modData: ComSatellite = satellite dish installed (true/false), ComCardReder = card reader installed (true/false)
    for Name, Data in pairs(S4_Eco_Tiles_List) do
        for i = 0, objects:size() - 1 do
            local Obj = objects:get(i)
            if Obj:getSprite() == getSprite(Name) then
                if Data.Type == "Computer" then
                    local ObjModData = Obj:getModData()
                    if ObjModData.ComPowerBar then
                        local ComOption = false
                        if ObjModData.ComPower then -- Check power state
                            ComOption = context:addOption(getText("ContextMenu_S4_Com_Use"), Obj, S4_Eco_Context.ComputerAction, player, Data)
                        else
                            ComOption = context:addOption(getText("ContextMenu_S4_Com_On"), Obj, S4_Eco_Context.ComputerAction, player, Data)
                        end
                        local ElectricCheck = ((SandboxVars.AllowExteriorGenerator and Obj:getSquare():haveElectricity()) or (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier and not Obj:getSquare():isOutside()))
                        if ComOption and not ElectricCheck then -- Cannot turn on without electricity/generator
                            local ComToolTip = ISToolTip:new()
                            ComOption.toolTip = ComToolTip
                            ComToolTip.description = getText("Tooltip_S4_Computer_NotElectric")
                            ComToolTip:setName(getText("ContextMenu_S4_Com_Use"))
                            ComOption.onSelect = nil
                            ComOption.notAvailable = true
                        end
                    else -- Install power cable
                        local ItemCashe = S4_Utils.setItemCashe("Base.PowerBar")
                        local ItemName = ItemCashe:getDisplayName()

                        local PowerBarOption = context:addOption(getText("ContextMenu_S4_Com_PowerBar_Install"), Obj, S4_Eco_Context.PowerBarAction, player, Data, IvnItemsTable)
                        local PowerBarToolTip = ISToolTip:new()
                        PowerBarOption.toolTip = PowerBarToolTip
                        PowerBarToolTip.description = string.format(getText("Tooltip_S4_PowerBar_Install"), ItemName)
                        PowerBarToolTip:setName(getText("ContextMenu_S4_Com_PowerBar_Install"))
                        if IvnItemsTable["Base.PowerBar"] then
                            local Count = IvnItemsTable["Base.PowerBar"].Amount
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") .. " <LINE><RGB:0,1,0> " .. string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count, 1)
                            PowerBarToolTip.description = PowerBarToolTip.description .. FixTooltip
                        else
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") .. " <LINE><RGB:1,0,0> " .. string.format(getText("Tooltip_S4_NeedItems"), ItemName, 0, 1)
                            PowerBarToolTip.description = PowerBarToolTip.description .. FixTooltip
                            PowerBarOption.onSelect = nil
                            PowerBarOption.notAvailable = true
                        end
                    end
                    -- Install card reader
                    if not ObjModData.ComCardReader then
                        local ItemCashe = S4_Utils.setItemCashe("S4Item.CardReader")
                        local ItemName = ItemCashe:getDisplayName()

                        local CardReaderOption = context:addOption(getText("ContextMenu_S4_Com_CardReader_Install"), Obj, S4_Eco_Context.CardReaderAction, player, Data, IvnItemsTable)
                        local CardReaderToolTip = ISToolTip:new()
                        CardReaderOption.toolTip = CardReaderToolTip
                        CardReaderToolTip.description = string.format(getText("Tooltip_S4_CardReader_Install"), ItemName)
                        CardReaderToolTip:setName(getText("ContextMenu_S4_Com_CardReader_Install"))

                        if IvnItemsTable["S4Item.CardReader"] then
                            local Count = IvnItemsTable["S4Item.CardReader"].Amount
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") .. " <LINE><RGB:0,1,0> " .. string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count, 1)
                            CardReaderToolTip.description = CardReaderToolTip.description .. FixTooltip
                        
                        else
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") .. " <LINE><RGB:1,0,0> " .. string.format(getText("Tooltip_S4_NeedItems"), ItemName, 0, 1)
                            CardReaderToolTip.description = CardReaderToolTip.description .. FixTooltip
                            CardReaderOption.onSelect = nil
                            CardReaderOption.notAvailable = true
                        end
                    end
                    -- Install satellite dish
                    if not ObjModData.ComSatellite then 
                        local SatelliteCheck, Dishxyz = S4_Utils.DistanceSatelliteDish(Obj)
                        local ItemCashe = S4_Utils.setItemCashe("Base.ElectricWire")
                        local ItemName = ItemCashe:getDisplayName()

                        local SatelliteOption = context:addOption(getText("ContextMenu_S4_Com_Satellite_Install"), Obj, S4_Eco_Context.SatelliteAction, player, Data, IvnItemsTable, SatelliteCheck, Dishxyz)
                        local SatelliteToolTip = ISToolTip:new()
                        SatelliteOption.toolTip = SatelliteToolTip
                        SatelliteToolTip.description = string.format(getText("Tooltip_S4_Satellite_Install"), ItemName)
                        SatelliteToolTip:setName(getText("ContextMenu_S4_Com_Satellite_Install"))

                        if SatelliteCheck < 1 then
                            local NotFoundText = " <LINE><RGB:1,0,0><LINE>" .. getText("Tooltip_S4_Satellite_NotFound") .. " <LINE><RGB:1,1,1> " .. getText("Tooltip_S4_Satellite_FoundTip")
                            SatelliteToolTip.description = SatelliteToolTip.description  .. NotFoundText
                            SatelliteOption.onSelect = nil
                            SatelliteOption.notAvailable = true
                        else
                            local Count = 0
                            if IvnItemsTable["Base.ElectricWire"] then Count = IvnItemsTable["Base.ElectricWire"].Amount end
                            if Count >= SatelliteCheck then
                                local GoodText = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") .. " <LINE><RGB:0,1,0> " .. string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count, SatelliteCheck, Dishxyz)
                                SatelliteToolTip.description = SatelliteToolTip.description  .. GoodText
                            else
                                local BadText = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") .. " <LINE><RGB:1,0,0> " .. string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count, SatelliteCheck, Dishxyz)
                                SatelliteToolTip.description = SatelliteToolTip.description  .. BadText
                                SatelliteOption.onSelect = nil
                                SatelliteOption.notAvailable = true

                            end
                        end
                    end

                elseif Data.Type == "ATM" then
                    local ATM_Option = context:addOption(getText("ContextMenu_S4_ATM_Use"), Obj, S4_Eco_Context.ATM_Action, player, Data)
                elseif Data.Type == "PostBox" and IvnItemsTable["S4Item.SellPackingBox"] and Obj:getSquare():isOutside() then
                    local PostBox_Option = context:addOption(getText("ContextMenu_S4_PostBox_Sell"), Obj, S4_Eco_Context.PostBox_Action, player, Data, IvnItemsTable)
                end
            end
        end
    end
end
Events.OnPreFillWorldObjectContextMenu.Add(S4_Eco_Context.ObjectsMenu)

-- Sell box handling
function S4_Eco_Context.PostBox_Action(Obj, player, Data, IvnItemsTable)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local Walkaction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(Walkaction)

        Walkaction:setOnComplete(function()
            local BoxCount = IvnItemsTable["S4Item.SellPackingBox"].Amount
            for i = 1, BoxCount do
                local item = IvnItemsTable["S4Item.SellPackingBox"].items[i]
                local SellBoxActcion = S4_Action_InsertPostBox:new(player, item)
                ISTimedActionQueue.add(SellBoxActcion)
            end
        end)
    end
end

-- Turn on/use computer
function S4_Eco_Context.ComputerAction(Obj, player, Data)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local Walkaction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(Walkaction)

        Walkaction:setOnComplete(function()
            S4_Booting_Sequence:show(player, Obj)
        end)
    end
end

function S4_Eco_Context.ATM_Action(Obj, player, Data)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local Walkaction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(Walkaction)

        Walkaction:setOnComplete(function()
            S4_ATM_MainUI:show(player, Obj)
        end)
    end
end

-- Install card reader
function S4_Eco_Context.CardReaderAction(Obj, player, Data, IvnItems)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local WalkAction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(WalkAction)

        WalkAction:setOnComplete(function()
            local MaxTime = PerformanceSettings.getLockFPS() * 2
            local InstallAction = S4_Action_Install:new(player, Obj, IvnItems, "CardReader", MaxTime)
            ISTimedActionQueue.add(InstallAction)
        end)
    end
end
-- Install power outlet
function S4_Eco_Context.PowerBarAction(Obj, player, Data, IvnItems)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local WalkAction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(WalkAction)

        WalkAction:setOnComplete(function()
            local MaxTime = PerformanceSettings.getLockFPS() * 2
            local InstallAction = S4_Action_Install:new(player, Obj, IvnItems, "PowerBar", MaxTime)
            ISTimedActionQueue.add(InstallAction)
        end)
    end
end
-- Connect satellite antenna
function S4_Eco_Context.SatelliteAction(Obj, player, Data, IvnItems, SatelliteAmount, Dishxyz)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local WalkAction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(WalkAction)

        WalkAction:setOnComplete(function()
            local MaxTime = PerformanceSettings.getLockFPS() * SatelliteAmount
            local InstallAction = S4_Action_Install:new(player, Obj, IvnItems, "Satellite", MaxTime, SatelliteAmount, Dishxyz)
            ISTimedActionQueue.add(InstallAction)
        end)
    end
end


