-- Function initialization
S4Shop = {}
local S4_SHOP_DATA_PATHS = {"media/lua/shared/S4_Shop_Data.lua", "../Lua/S4Economy/S4_Shop_Data.lua"}

local S4_LAST_SHOP_DATA_SOURCE = nil

local function addSteamWorkshopShopDataCandidates(addPath, workshopIds)
    local roots = {}
    local seenRoots = {}
    local suffixes = {}
    local seenSuffixes = {}

    local function addRoot(path)
        if type(path) ~= "string" or path == "" then
            return
        end
        if seenRoots[path] then
            return
        end
        seenRoots[path] = true
        table.insert(roots, path)
    end

    local function addSuffix(path)
        if type(path) ~= "string" or path == "" then
            return
        end
        if seenSuffixes[path] then
            return
        end
        seenSuffixes[path] = true
        table.insert(suffixes, path)
    end

    addRoot("C:/Program Files (x86)/Steam")
    addRoot("C:/Program Files/Steam")
    for i = 65, 90 do
        local drive = string.char(i) .. ":"
        addRoot(drive .. "/SteamLibrary")
        addRoot(drive .. "/Program Files (x86)/Steam")
        addRoot(drive .. "/Program Files/Steam")
    end

    for _, workshopId in ipairs(workshopIds) do
        addSuffix("steamapps/workshop/content/108600/" .. workshopId ..
                      "/mods/S4EcoPack/common/media/lua/shared/S4_Shop_Data.lua")
    end

    for _, root in ipairs(roots) do
        for _, suffix in ipairs(suffixes) do
            addPath(root .. "/" .. suffix)
        end
    end
end

local function getCardCreditLimit()
    local maxNegative = 1000
    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.MaxNegativeBalance then
        maxNegative = SandboxVars.S4SandBox.MaxNegativeBalance
    end
    if maxNegative < 0 then
        maxNegative = 0
    end
    return -maxNegative
end

local function collectShopDataCandidates()
    local candidates = {}
    local seen = {}
    local discoveredWorkshopIds = {}
    local seenWorkshopIds = {}

    local function addPath(path)
        if type(path) ~= "string" or path == "" then
            return
        end
        if seen[path] then
            return
        end
        seen[path] = true
        table.insert(candidates, path)
    end

    local function addWorkshopId(workshopId)
        if type(workshopId) ~= "string" or workshopId == "" then
            return
        end
        if seenWorkshopIds[workshopId] then
            return
        end
        seenWorkshopIds[workshopId] = true
        table.insert(discoveredWorkshopIds, workshopId)
    end

    addWorkshopId("3667850050")

    if getLoadedLuaCount and getLoadedLua then
        local okCount, loadedCount = pcall(getLoadedLuaCount)
        if okCount and type(loadedCount) == "number" then
            for i = 0, loadedCount - 1 do
                local okPath, loadedPath = pcall(getLoadedLua, i)
                if okPath and type(loadedPath) == "string" then
                    local pathLower = string.lower(loadedPath)
                    local workshopId = string.match(pathLower, "workshop/content/108600/(%d+)/mods/s4ecopack/")
                    if workshopId then
                        addWorkshopId(workshopId)
                    end
                    if string.find(pathLower, "s4_shop_data.lua", 1, true) then
                        addPath(loadedPath)
                    end
                end
            end
        end
    end

    for _, path in ipairs(S4_SHOP_DATA_PATHS) do
        addPath(path)
    end

    addSteamWorkshopShopDataCandidates(addPath, discoveredWorkshopIds)

    return candidates
end

local function refreshShopDataSource()
    S4_Shop_Data = nil

    local candidates = collectShopDataCandidates()

    for _, filePath in ipairs(candidates) do
        local exists = true
        if fileExists then
            local okExists, result = pcall(fileExists, filePath)
            exists = okExists and result == true
        end

        if exists then
            pcall(reloadLuaFile, filePath)
            if type(S4_Shop_Data) == "table" then
                if S4_LAST_SHOP_DATA_SOURCE ~= filePath then
                    print("[S4_Economy] Shop data source: " .. tostring(filePath))
                    S4_LAST_SHOP_DATA_SOURCE = filePath
                end
                break
            end
        end
    end

    return type(S4_Shop_Data) == "table"
end

local function buildShopEntry(Data, CurrentCategory)
    local category = Data and Data.Category
    if not category or category == "" then
        category = CurrentCategory or "Etc"
    end
    return {
        BuyPrice = tonumber(Data and Data.BuyPrice) or 0,
        SellPrice = tonumber(Data and Data.SellPrice) or 0,
        Stock = tonumber(Data and Data.Stock) or 0,
        Restock = tonumber(Data and Data.Restock) or 0,
        Category = category,
        BuyAuthority = tonumber(Data and Data.BuyAuthority) or 0,
        SellAuthority = tonumber(Data and Data.SellAuthority) or 0,
        Discount = tonumber(Data and Data.Discount) or 0,
        HotItem = tonumber(Data and Data.HotItem) or 0
    }
end

local function getShopDataState(shopData)
    if not shopData then return "0:0" end
    local count = 0
    local sum = 0
    for _, v in pairs(shopData) do
        count = count + 1
        sum = sum + (tonumber(v.BuyPrice) or 0) + (tonumber(v.SellPrice) or 0) + (tonumber(v.Stock) or 0)
    end
    return tostring(count) .. ":" .. tostring(sum)
end

local function applyShopDataFromLua(overwriteExisting, removeMissing)
    local ShopModData = ModData.get("S4_ShopData")
    if not ShopModData or type(S4_Shop_Data) ~= "table" then
        return false
    end

    local oldState = getShopDataState(ShopModData)

    if removeMissing then
        for ItemName, _ in pairs(ShopModData) do
            if not S4_Shop_Data[ItemName] then
                ShopModData[ItemName] = nil
            end
        end
    end

    for ItemName, Data in pairs(S4_Shop_Data) do
        if not ShopModData[ItemName] then
            ShopModData[ItemName] = buildShopEntry(Data)
        elseif overwriteExisting then
            local merged = buildShopEntry(Data, ShopModData[ItemName].Category)
            ShopModData[ItemName].BuyPrice = merged.BuyPrice
            ShopModData[ItemName].SellPrice = merged.SellPrice
            ShopModData[ItemName].Stock = merged.Stock
            ShopModData[ItemName].Restock = merged.Restock
            ShopModData[ItemName].Category = merged.Category
            ShopModData[ItemName].BuyAuthority = merged.BuyAuthority
            ShopModData[ItemName].SellAuthority = merged.SellAuthority
            ShopModData[ItemName].Discount = merged.Discount
            ShopModData[ItemName].HotItem = merged.HotItem
        end
    end

    local newState = getShopDataState(ShopModData)
    if oldState ~= newState then
        ModData.transmit("S4_ShopData")
        return true, true -- success, hadChanges
    end

    return true, false -- success, noChanges
end

-- Generate kill data
function S4Shop.UpdateShopData(player, args)
    local ItemName = args["ItemName"]
    local Account = ModData.get("S4_ShopData")[ItemName]
    if Account then
        if args["BuyPrice"] then
            Account.BuyPrice = args["BuyPrice"]
        end
        if args["SellPrice"] then
            Account.SellPrice = args["SellPrice"]
        end
        if args["Stock"] then
            Account.Stock = args["Stock"]
        end
        if args["Restock"] then
            Account.Restock = args["Restock"]
        end
        if args["Category"] then
            Account.Category = args["Category"]
        end
        if args["BuyAuthority"] then
            Account.BuyAuthority = args["BuyAuthority"]
        end
        if args["SellAuthority"] then
            Account.SellAuthority = args["SellAuthority"]
        end
        if args["Discount"] then
            Account.Discount = args["Discount"]
        end
        if args["HotItem"] then
            Account.HotItem = args["HotItem"]
        end
        print("TestOK")
    elseif not Account then
        local FixBuyPrice = args["BuyPrice"] or 0
        local FixSellPrice = args["SellPrice"] or 0
        local FixStock = args["Stock"] or 0
        local FixRestock = args["Restock"] or 0
        local FixCategory = args["Category"] or "Etc"
        local FixBuyAuthority = args["BuyAuthority"] or 0
        local FixSellAuthority = args["SellAuthority"] or 0
        local FixDiscount = args["Discount"] or 0
        local FixHotItem = args["HotItem"] or 0
        ModData.get("S4_ShopData")[ItemName] = {
            BuyPrice = FixBuyPrice,
            SellPrice = FixSellPrice,
            Stock = FixStock,
            Restock = FixRestock,
            Category = FixCategory,
            BuyAuthority = FixBuyAuthority,
            SellAuthority = FixSellAuthority,
            Discount = FixDiscount,
            HotItem = FixHotItem
        }

    end
    ModData.transmit("S4_ShopData")
end

function S4Shop.ResetShopData(player, args)
    local Account = ModData.get("S4_ShopData")
    if not Account then
        return
    end
    for ItemName, _ in pairs(Account) do
        ModData.get("S4_ShopData")[ItemName] = nil
    end
    ModData.transmit("S4_ShopData")
end

function S4Shop.RemoveShopData(player, args)
    local ItemName = args[1]
    local Account = ModData.get("S4_ShopData")[ItemName]
    if not Account then
        return
    end
    ModData.get("S4_ShopData")[ItemName] = nil
    ModData.transmit("S4_ShopData")
end

function S4Shop.ShopBuy(player, args)
    local UserName = player:getUsername()
    local LogTime = args[1]
    local DisplayTime = S4_Utils.getLogTimeMin(LogTime)
    local deliveryHours = 72
    local quickDeliveryHours = 12
    if SandboxVars and SandboxVars.S4SandBox then
        deliveryHours = SandboxVars.S4SandBox.DeliveryTime or 72
        quickDeliveryHours = SandboxVars.S4SandBox.QuickDeliveryTime or 12
    end

    local DeliveryTime = S4_Utils.setAddTime(DisplayTime, deliveryHours)
    if args[2] == "Quick" then
        DeliveryTime = S4_Utils.setAddTime(DisplayTime, quickDeliveryHours)
    end
    local CardNum = args[3]
    local TotalPrice = args[4]
    local CardModData = ModData.get("S4_CardData")[CardNum]
    if not CardModData then
        return
    end
    if (CardModData.Money - TotalPrice) < getCardCreditLimit() then
        return
    end
    local CardLogModData = ModData.get("S4_CardLog")[CardNum]
    if not CardLogModData then
        return
    end
    local PlayerShopModData = ModData.get("S4_PlayerShopData")[UserName]
    if not PlayerShopModData then
        return
    end
    local ShopModData = ModData.get("S4_ShopData")
    if not ShopModData then
        return
    end
    -- Card data update
    CardModData.Money = CardModData.Money - TotalPrice
    ModData.transmit("S4_CardData")
    -- Add card log
    CardLogModData[LogTime] = {
        Type = "Withdraw",
        Money = TotalPrice,
        Sender = UserName,
        Receiver = "GoodShop",
        DisplayTime = DisplayTime
    }
    ModData.transmit("S4_CardLog")
    -- Delivery information update
    local ItemList = args[5]
    local DeliveryAddress = args[6]
    PlayerShopModData.Delivery[DeliveryTime] = {}
    PlayerShopModData.Delivery[DeliveryTime].XYZCode = DeliveryAddress
    PlayerShopModData.Delivery[DeliveryTime].List = {}
    for ItemName, Amount in pairs(ItemList) do
        if ShopModData[ItemName] then
            PlayerShopModData.Delivery[DeliveryTime].List[ItemName] = Amount
            ShopModData[ItemName].Stock = ShopModData[ItemName].Stock - Amount
        else
            print("[S4Shop] Warning: Item not found in ShopModData during purchase: " .. tostring(ItemName))
        end
    end
    PlayerShopModData.BuyTotal = PlayerShopModData.BuyTotal + TotalPrice
    PlayerShopModData.Cart = {}
    ModData.transmit("S4_PlayerShopData")
    ModData.transmit("S4_ShopData")
end

function S4Shop.ShopSell(player, args)
    local UserName = player:getUsername()
    local CardNum = args[1]
    local Price = args[2]
    local CardModData = ModData.get("S4_CardData")[CardNum]
    if not CardModData then
        local PlayerModData = ModData.get("S4_PlayerData")[UserName]
        if not PlayerModData then
            return
        end
        CardNum = PlayerModData.MainCard
        CardModData = ModData.get("S4_CardData")[CardNum]
    end
    if not CardModData then
        return
    end
    local CardLogModData = ModData.get("S4_CardLog")[CardNum]
    if not CardLogModData then
        return
    end
    CardModData.Money = CardModData.Money + Price
    local LogTime = args[3]
    local DisplayTime = S4_Utils.getLogTimeMin(LogTime)
    CardLogModData[LogTime] = {
        Type = "Deposit",
        Money = Price,
        Sender = "GoodShop",
        Receiver = UserName,
        DisplayTime = DisplayTime
    }
    ModData.transmit("S4_CardData")
    ModData.transmit("S4_CardLog")
end

function S4Shop.ShopDataAddon(player, args)
    if not refreshShopDataSource() then
        return
    end
    applyShopDataFromLua(false, false)
end

function S4Shop.OverWriteShopDataAddon(player, args)
    if not refreshShopDataSource() then
        return
    end
    applyShopDataFromLua(true, false)
end

-- Reload S4_Shop_Data.lua from disk and apply it immediately to runtime shop data.
function S4Shop.RefreshShopDataFromLua(player, args)
    if not refreshShopDataSource() then
        return
    end
    applyShopDataFromLua(true, true)
end

function S4Shop.SyncShop(player, args)
    if not refreshShopDataSource() then
        sendServerCommand(player, "S4SD", "SyncResult", {success = false, hadChanges = false})
        return
    end
    local success, hadChanges = applyShopDataFromLua(true, true)
    sendServerCommand(player, "S4SD", "SyncResult", {success = success, hadChanges = hadChanges})
end
