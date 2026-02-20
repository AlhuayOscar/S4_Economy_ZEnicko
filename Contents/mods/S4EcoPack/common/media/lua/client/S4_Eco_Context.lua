S4_Eco_Context = {}
require "TimedActions/ISBaseTimedAction"

local S4_Action_ComputerInteract = ISBaseTimedAction:derive("S4_Action_ComputerInteract")

function S4_Action_ComputerInteract:isValid()
    return self.Obj ~= nil
end

function S4_Action_ComputerInteract:waitToStart()
    self.character:faceThisObject(self.Obj)
    return self.character:shouldBeTurning()
end

function S4_Action_ComputerInteract:update()
    self.character:faceThisObject(self.Obj)
end

function S4_Action_ComputerInteract:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
end

function S4_Action_ComputerInteract:stop()
    self.character:clearVariable("LootPosition")
    ISBaseTimedAction.stop(self)
end

function S4_Action_ComputerInteract:perform()
    self.character:clearVariable("LootPosition")
    if self.onDone then
        self.onDone(self.character, self.Obj)
    end
    ISBaseTimedAction.perform(self)
end

function S4_Action_ComputerInteract:new(character, Obj, onDone)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.Obj = Obj
    o.onDone = onDone
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = (PerformanceSettings.getLockFPS() * 0.125) or 8
    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end
    return o
end

local function playComputerToggleSound()
    if getSoundManager and getSoundManager().playUISound then
        getSoundManager():playUISound("S4_QoL_ButtonPush")
    end
end

local function playATMBeepSound()
    if getSoundManager and getSoundManager().playUISound then
        local ok = pcall(function()
            getSoundManager():playUISound("ATMBeep")
        end)
        if not ok then
            getSoundManager():playUISound("S4_QoL_ButtonPush")
        end
    end
end

function S4_Eco_Context.InventoryMenu(playerNum, context, items)
    items = ISInventoryPane.getActualItems(items)
    local item = items[1]
    if not item then
        return
    end
    local player = getSpecificPlayer(playerNum)
    local itemName = item:getFullType()
    if itemName == "S4Item.Signal" then
        context:addOption(getText("ContextMenu_S4_Signal_Install"), player, S4_Eco_Context.SetAddress)
    elseif itemName == "S4Item.BuyPackingBox" then
        context:addOption(getText("ContextMenu_S4_BuyBox_Open"), player, S4_Eco_Context.BoxOpen, item)
    elseif itemName == "Base.Money" or itemName == "Base.MoneyBundle" then
        context:addOption(getText("ContextMenu_S4_Cash_Check"), player, S4_Eco_Context.CashCheck, item)
        context:addOption(getText("ContextMenu_S4_Cash_Check_All"), player, S4_Eco_Context.CashCheckAll)
    elseif itemName == "S4Item.AirDropBox_Weapon" or itemName == "S4Item.AirDropBox_Ammo" or itemName ==
        "S4Item.AirDropBox_Food" or itemName == "S4Item.AirDropBox_Medical" or itemName == "S4Item.AirDropBox_Materials" or
        itemName == "S4Item.AirDropBox_Etc" then
        local IvnItemsTable = S4_Utils.getPlayerItems(player)
        local AirDropMenu = context:addOption(getText("ContextMenu_S4_AirDrop_Open"), player,
            S4_Eco_Context.AirDropOpen, item)
        local AirDropToolTip = ISToolTip:new()
        AirDropMenu.toolTip = AirDropToolTip
        AirDropToolTip.description = getText("Tooltip_S4_AirDrop")
        AirDropToolTip:setName(getText("Tooltip_S4_AirDrop_Open"))

        local ItemCashe = S4_Utils.setItemCashe("Base.Crowbar")
        local NeedItemName = ItemCashe:getDisplayName()
        if IvnItemsTable and IvnItemsTable["Base.Crowbar"] then
            AirDropToolTip.description = AirDropToolTip.description .. " <LINE> " ..
                                             string.format(getText("Tooltip_S4_NeedItems"), NeedItemName, 1, 1)
        else
            AirDropToolTip.description = AirDropToolTip.description .. " <LINE> " ..
                                             string.format(getText("Tooltip_S4_NeedItems"), NeedItemName, 0, 1)
            AirDropMenu.onSelect = nil
            AirDropMenu.notAvailable = true
        end
    end
    -- context:addOption(getText("Test Menu"), player, S4_Eco_Context.TestMenu, item)
end

-- Test
function S4_Eco_Context.TestMenu(player, item)
    print("Now Hour Time: " .. tostring(getGameTime():getWorldAgeHours()))
    print("Now Day Time: " .. tostring(getWorld():getWorldAgeDays()))
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
    if not sq then
        return
    end
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
    ["appliances_com_01_72"] = {
        Px = 0,
        Py = 1,
        Type = "Computer"
    },
    ["appliances_com_01_73"] = {
        Px = 1,
        Py = 0,
        Type = "Computer"
    },
    ["appliances_com_01_74"] = {
        Px = 0,
        Py = -1,
        Type = "Computer"
    },
    ["appliances_com_01_75"] = {
        Px = -1,
        Py = 0,
        Type = "Computer"
    },
    ["appliances_com_01_76"] = {
        Px = 0,
        Py = 1,
        Type = "Computer"
    },
    ["appliances_com_01_77"] = {
        Px = 1,
        Py = 0,
        Type = "Computer"
    },
    ["appliances_com_01_78"] = {
        Px = 0,
        Py = -1,
        Type = "Computer"
    },
    ["appliances_com_01_79"] = {
        Px = -1,
        Py = 0,
        Type = "Computer"
    },
    -- ATM
    ["location_business_bank_01_64"] = {
        Px = 1,
        Py = 0,
        Type = "ATM"
    },
    ["location_business_bank_01_65"] = {
        Px = 0,
        Py = 1,
        Type = "ATM"
    },
    ["location_business_bank_01_66"] = {
        Px = 0,
        Py = 0,
        Type = "ATM"
    },
    ["location_business_bank_01_67"] = {
        Px = 0,
        Py = 0,
        Type = "ATM"
    },
    ["location_business_bank_01_68"] = {
        Px = 0,
        Py = 0,
        Type = "ATM"
    },
    ["location_business_bank_01_69"] = {
        Px = 0,
        Py = 0,
        Type = "ATM"
    },
    ["location_business_bank_01_70"] = {
        Px = 0,
        Py = 0,
        Type = "ATM"
    },
    ["location_business_bank_01_71"] = {
        Px = 0,
        Py = 0,
        Type = "ATM"
    },
    -- Phone
    ["location_business_office_generic_02_18"] = {
        Px = 0,
        Py = 0,
        Type = "Phone"
    },
    -- TODO: add direction values to find/look at the target object.
    -- PostBox
    ["street_decoration_01_8"] = {
        Px = 0,
        Py = 1,
        Type = "PostBox"
    },
    ["street_decoration_01_9"] = {
        Px = 1,
        Py = 0,
        Type = "PostBox"
    },
    ["street_decoration_01_10"] = {
        Px = 0,
        Py = -1,
        Type = "PostBox"
    },
    ["street_decoration_01_11"] = {
        Px = -1,
        Py = 0,
        Type = "PostBox"
    }
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
                            ComOption = context:addOption(getText("ContextMenu_S4_Com_Use"), Obj,
                                S4_Eco_Context.ComputerAction, player, Data)
                        else
                            ComOption = context:addOption(getText("ContextMenu_S4_Com_On"), Obj,
                                S4_Eco_Context.ComputerAction, player, Data)
                        end
                        local ElectricCheck =
                            ((SandboxVars.AllowExteriorGenerator and Obj:getSquare():haveElectricity()) or
                                (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() <
                                    SandboxVars.ElecShutModifier and not Obj:getSquare():isOutside()))
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

                        local PowerBarOption = context:addOption(getText("ContextMenu_S4_Com_PowerBar_Install"), Obj,
                            S4_Eco_Context.PowerBarAction, player, Data, IvnItemsTable)
                        local PowerBarToolTip = ISToolTip:new()
                        PowerBarOption.toolTip = PowerBarToolTip
                        PowerBarToolTip.description = string.format(getText("Tooltip_S4_PowerBar_Install"), ItemName)
                        PowerBarToolTip:setName(getText("ContextMenu_S4_Com_PowerBar_Install"))
                        if IvnItemsTable["Base.PowerBar"] then
                            local Count = IvnItemsTable["Base.PowerBar"].Amount
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") ..
                                                   " <LINE><RGB:0,1,0> " ..
                                                   string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count, 1)
                            PowerBarToolTip.description = PowerBarToolTip.description .. FixTooltip
                        else
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") ..
                                                   " <LINE><RGB:1,0,0> " ..
                                                   string.format(getText("Tooltip_S4_NeedItems"), ItemName, 0, 1)
                            PowerBarToolTip.description = PowerBarToolTip.description .. FixTooltip
                            PowerBarOption.onSelect = nil
                            PowerBarOption.notAvailable = true
                        end
                    end
                    -- Install card reader
                    if not ObjModData.ComCardReader then
                        local ItemCashe = S4_Utils.setItemCashe("S4Item.CardReader")
                        local ItemName = ItemCashe:getDisplayName()

                        local CardReaderOption = context:addOption(getText("ContextMenu_S4_Com_CardReader_Install"),
                            Obj, S4_Eco_Context.CardReaderAction, player, Data, IvnItemsTable)
                        local CardReaderToolTip = ISToolTip:new()
                        CardReaderOption.toolTip = CardReaderToolTip
                        CardReaderToolTip.description =
                            string.format(getText("Tooltip_S4_CardReader_Install"), ItemName)
                        CardReaderToolTip:setName(getText("ContextMenu_S4_Com_CardReader_Install"))

                        if IvnItemsTable["S4Item.CardReader"] then
                            local Count = IvnItemsTable["S4Item.CardReader"].Amount
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") ..
                                                   " <LINE><RGB:0,1,0> " ..
                                                   string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count, 1)
                            CardReaderToolTip.description = CardReaderToolTip.description .. FixTooltip

                        else
                            local FixTooltip = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") ..
                                                   " <LINE><RGB:1,0,0> " ..
                                                   string.format(getText("Tooltip_S4_NeedItems"), ItemName, 0, 1)
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

                        local SatelliteOption = context:addOption(getText("ContextMenu_S4_Com_Satellite_Install"), Obj,
                            S4_Eco_Context.SatelliteAction, player, Data, IvnItemsTable, SatelliteCheck, Dishxyz)
                        local SatelliteToolTip = ISToolTip:new()
                        SatelliteOption.toolTip = SatelliteToolTip
                        SatelliteToolTip.description = string.format(getText("Tooltip_S4_Satellite_Install"), ItemName)
                        SatelliteToolTip:setName(getText("ContextMenu_S4_Com_Satellite_Install"))

                        if SatelliteCheck < 1 then
                            local NotFoundText =
                                " <LINE><RGB:1,0,0><LINE>" .. getText("Tooltip_S4_Satellite_NotFound") ..
                                    " <LINE><RGB:1,1,1> " .. getText("Tooltip_S4_Satellite_FoundTip")
                            SatelliteToolTip.description = SatelliteToolTip.description .. NotFoundText
                            SatelliteOption.onSelect = nil
                            SatelliteOption.notAvailable = true
                        else
                            local Count = 0
                            if IvnItemsTable["Base.ElectricWire"] then
                                Count = IvnItemsTable["Base.ElectricWire"].Amount
                            end
                            if Count >= SatelliteCheck then
                                local GoodText = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") ..
                                                     " <LINE><RGB:0,1,0> " ..
                                                     string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count,
                                        SatelliteCheck, Dishxyz)
                                SatelliteToolTip.description = SatelliteToolTip.description .. GoodText
                            else
                                local BadText = " <LINE><LINE> " .. getText("Tooltip_S4_Needitem") ..
                                                    " <LINE><RGB:1,0,0> " ..
                                                    string.format(getText("Tooltip_S4_NeedItems"), ItemName, Count,
                                        SatelliteCheck, Dishxyz)
                                SatelliteToolTip.description = SatelliteToolTip.description .. BadText
                                SatelliteOption.onSelect = nil
                                SatelliteOption.notAvailable = true

                            end
                        end
                    end

                elseif Data.Type == "ATM" then
                    local ATM_Option = context:addOption(getText("ContextMenu_S4_ATM_Use"), Obj,
                        S4_Eco_Context.ATM_Action, player, Data)
                elseif Data.Type == "PostBox" and IvnItemsTable["S4Item.SellPackingBox"] and Obj:getSquare():isOutside() then
                    local PostBox_Option = context:addOption(getText("ContextMenu_S4_PostBox_Sell"), Obj,
                        S4_Eco_Context.PostBox_Action, player, Data, IvnItemsTable)
                elseif Data.Type == "Phone" then
                    context:addOption("Use Phone", Obj, S4_Eco_Context.Phone_Action, player, Data)
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
function S4_Eco_Context.ComputerAction(Obj, player, Data, playToggleSfx)
    local adjacent = S4_Utils.getAdjacent(player, Obj, Data.Px, Data.Py)
    if adjacent then
        local Walkaction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(Walkaction)

        Walkaction:setOnComplete(function()
            local InteractAction = S4_Action_ComputerInteract:new(player, Obj, function(character, targetObj)
                S4_Booting_Sequence:show(character, targetObj)
                if playToggleSfx then
                    playComputerToggleSound()
                end
            end)
            ISTimedActionQueue.add(InteractAction)
        end)
    end
end

function S4_Eco_Context.ATM_Action(Obj, player, Data)
    local function findAtmAdjacent()
        local defaults = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {0, 0}}
        if Data then
            local a = S4_Utils.getAdjacent(player, Obj, Data.Px or 0, Data.Py or 0)
            if a then
                return a
            end
        end
        for i = 1, #defaults do
            local d = defaults[i]
            local a = S4_Utils.getAdjacent(player, Obj, d[1], d[2])
            if a then
                return a
            end
        end
        return nil
    end

    local function openATMNow()
        S4_ATM_MainUI:show(player, Obj)
        playATMBeepSound()
    end

    local adjacent = findAtmAdjacent()
    if adjacent then
        local playerSq = player:getSquare()
        if playerSq and playerSq == adjacent then
            openATMNow()
            return
        end
        local Walkaction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(Walkaction)

        Walkaction:setOnComplete(function()
            openATMNow()
        end)
    end
end

function S4_Eco_Context.Phone_Action(Obj, player, Data)
    if not player then
        return
    end

    local px = Data and Data.Px or 0
    local py = Data and Data.Py or 0
    local adjacent = S4_Utils.getAdjacent(player, Obj, px, py)
    if adjacent then
        local playerSq = player:getSquare()
        if playerSq and playerSq == adjacent then
            if player.setHaloNote then
                player:setHaloNote("Parece que aun funciona esto...", 210, 210, 200, 230)
            end
            return
        end

        local walkAction = ISWalkToTimedAction:new(player, adjacent)
        ISTimedActionQueue.add(walkAction)
        walkAction:setOnComplete(function()
            if player.setHaloNote then
                player:setHaloNote("Parece que aun funciona esto...", 210, 210, 200, 230)
            end
        end)
    elseif player.setHaloNote then
        player:setHaloNote("Parece que aun funciona esto...", 210, 210, 200, 230)
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
            local InstallAction = S4_Action_Install:new(player, Obj, IvnItems, "Satellite", MaxTime, SatelliteAmount,
                Dishxyz)
            ISTimedActionQueue.add(InstallAction)
        end)
    end
end

local function isComputerUiOpen()
    if S4_Computer_Main and S4_Computer_Main.instance and S4_Computer_Main.instance.isVisible and
        S4_Computer_Main.instance:isVisible() then
        return true
    end
    if S4_Booting_Sequence and S4_Booting_Sequence.instance and S4_Booting_Sequence.instance.isVisible and
        S4_Booting_Sequence.instance:isVisible() then
        return true
    end
    return false
end

local function isAtmUiOpen()
    if S4_ATM_MainUI and S4_ATM_MainUI.instance and S4_ATM_MainUI.instance.isVisible and
        S4_ATM_MainUI.instance:isVisible() then
        return true
    end
    return false
end

local function closeComputerUiIfOpen()
    if S4_Booting_Sequence and S4_Booting_Sequence.instance and S4_Booting_Sequence.instance.isVisible and
        S4_Booting_Sequence.instance:isVisible() and S4_Booting_Sequence.instance.close then
        S4_Booting_Sequence.instance:close()
        return true
    end
    if S4_Computer_Main and S4_Computer_Main.instance and S4_Computer_Main.instance.isVisible and
        S4_Computer_Main.instance:isVisible() and S4_Computer_Main.instance.close then
        S4_Computer_Main.instance:close()
        return true
    end
    return false
end

local function closeAtmUiIfOpen()
    if S4_ATM_MainUI and S4_ATM_MainUI.instance and S4_ATM_MainUI.instance.isVisible and
        S4_ATM_MainUI.instance:isVisible() and S4_ATM_MainUI.instance.close then
        S4_ATM_MainUI.instance:close()
        return true
    end
    return false
end

local function hasPowerForComputer(obj)
    if not obj then
        return false
    end
    local square = obj:getSquare()
    if not square then
        return false
    end
    return ((SandboxVars.AllowExteriorGenerator and square:haveElectricity()) or
               (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() <
                   SandboxVars.ElecShutModifier and not square:isOutside()))
end

local function findNearbyComputer(player)
    if not player then
        return nil, nil
    end
    local sq = player:getSquare()
    if not sq then
        return nil, nil
    end
    local cell = getCell()
    if not cell then
        return nil, nil
    end

    local bestObj = nil
    local bestData = nil
    local bestDist = 9999
    local z = sq:getZ()
    local px = sq:getX()
    local py = sq:getY()

    for dx = -1, 1 do
        for dy = -1, 1 do
            local testSq = cell:getGridSquare(px + dx, py + dy, z)
            if testSq then
                local objs = testSq:getObjects()
                for i = 0, objs:size() - 1 do
                    local obj = objs:get(i)
                    local sprite = obj and obj:getSprite()
                    local spriteName = sprite and sprite:getName()
                    local data = spriteName and S4_Eco_Tiles_List[spriteName] or nil
                    if data and data.Type == "Computer" then
                        local md = obj:getModData()
                        if md and md.ComPowerBar and hasPowerForComputer(obj) then
                            local dist = math.abs(testSq:getX() - px) + math.abs(testSq:getY() - py)
                            if dist < bestDist then
                                bestDist = dist
                                bestObj = obj
                                bestData = data
                            end
                        end
                    end
                end
            end
        end
    end

    return bestObj, bestData
end

local function isAtmSpriteName(spriteName)
    if not spriteName then
        return false
    end
    if S4_Eco_Tiles_List[spriteName] and S4_Eco_Tiles_List[spriteName].Type == "ATM" then
        return true
    end
    local prefix, idx = spriteName:match("^(location_business_bank_01)_(%d+)$")
    if prefix == "location_business_bank_01" then
        local n = tonumber(idx)
        if n and n >= 64 and n <= 79 then
            return true
        end
    end
    return false
end

local function findNearbyATM(player)
    if not player then
        return nil, nil
    end
    local sq = player:getSquare()
    if not sq then
        return nil, nil
    end
    local cell = getCell()
    if not cell then
        return nil, nil
    end

    local bestObj = nil
    local bestData = nil
    local bestDist = 9999
    local z = sq:getZ()
    local px = sq:getX()
    local py = sq:getY()

    for dx = -1, 1 do
        for dy = -1, 1 do
            local testSq = cell:getGridSquare(px + dx, py + dy, z)
            if testSq then
                local objs = testSq:getObjects()
                for i = 0, objs:size() - 1 do
                    local obj = objs:get(i)
                    local sprite = obj and obj:getSprite()
                    local spriteName = sprite and sprite:getName()
                    if isAtmSpriteName(spriteName) then
                        local data = S4_Eco_Tiles_List[spriteName] or {
                            Px = 0,
                            Py = 0,
                            Type = "ATM"
                        }
                        local dist = math.abs(testSq:getX() - px) + math.abs(testSq:getY() - py)
                        if dist < bestDist then
                            bestDist = dist
                            bestObj = obj
                            bestData = data
                        end
                    end
                end
            end
        end
    end

    return bestObj, bestData
end

function S4_Eco_Context.KeyOpenComputer(key)
    local isToggleKey = (key == Keyboard.KEY_E)
    if not isToggleKey and getCore then
        local core = getCore()
        if core and core.getKey then
            local ok, interactKey = pcall(function()
                return core:getKey("Interact")
            end)
            if ok and interactKey and key == interactKey then
                isToggleKey = true
            end
        end
    end
    if not isToggleKey then
        return
    end
    local player = getSpecificPlayer(0)
    if not player or player:isDead() then
        return
    end

    local md = player:getModData()
    local nowMs = getTimestampMs and getTimestampMs() or 0
    local lastMs = md.S4_LastEComputerOpenAtMs or 0
    if nowMs > 0 and (nowMs - lastMs) < 700 then
        return
    end

    if isComputerUiOpen() then
        if closeComputerUiIfOpen() then
            if nowMs > 0 then
                md.S4_LastEComputerOpenAtMs = nowMs
            end
            playComputerToggleSound()
        end
        return
    end
    if isAtmUiOpen() then
        if closeAtmUiIfOpen() then
            if nowMs > 0 then
                md.S4_LastEComputerOpenAtMs = nowMs
            end
        end
        return
    end

    local obj, data = findNearbyComputer(player)
    if obj and data then
        if nowMs > 0 then
            md.S4_LastEComputerOpenAtMs = nowMs
        end
        S4_Eco_Context.ComputerAction(obj, player, data, true)
        return
    end

    local atmObj, atmData = findNearbyATM(player)
    if atmObj and atmData then
        if nowMs > 0 then
            md.S4_LastEComputerOpenAtMs = nowMs
        end
        S4_Eco_Context.ATM_Action(atmObj, player, atmData)
    end
end
Events.OnKeyPressed.Add(S4_Eco_Context.KeyOpenComputer)

