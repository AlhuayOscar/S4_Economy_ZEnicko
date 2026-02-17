-- Function initialization
S4Shop = {}
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
            Account.Discount = args["SellAuthority"]
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
            HotItem = FixHotItem,
        }
  
    end
    ModData.transmit("S4_ShopData")
end

function S4Shop.ResetShopData(player, args)
    local Account = ModData.get("S4_ShopData")
    if not Account then return end
    for ItemName, _ in pairs(Account) do
        ModData.get("S4_ShopData")[ItemName] = nil
    end
    ModData.transmit("S4_ShopData")
end

function S4Shop.RemoveShopData(player, args)
    local ItemName = args[1]
    local Account = ModData.get("S4_ShopData")[ItemName]
    if not Account then return end
    ModData.get("S4_ShopData")[ItemName] = nil
    ModData.transmit("S4_ShopData")
end

function S4Shop.ShopBuy(player, args)
    local UserName = player:getUsername()
    local LogTime = args[1]
    local DisplayTime = S4_Utils.getLogTimeMin(LogTime)
    local DeliveryTime = S4_Utils.setAddTime(DisplayTime, SandboxVars.S4SandBox.DeliveryTime)
    if args[2] == "Quick" then
        DeliveryTime = S4_Utils.setAddTime(DisplayTime, SandboxVars.S4SandBox.QuickDeliveryTime)
    end
    local CardNum = args[3]
    local TotalPrice = args[4]
    local CardModData = ModData.get("S4_CardData")[CardNum]
    if not CardModData then return end
    if (CardModData.Money - TotalPrice) < getCardCreditLimit() then return end
    local CardLogModData = ModData.get("S4_CardLog")[CardNum]
    if not CardLogModData then return end
    local PlayerShopModData = ModData.get("S4_PlayerShopData")[UserName]
    if not PlayerShopModData then return end
    local ShopModData = ModData.get("S4_ShopData")
    if not ShopModData then return end
    -- Card data update
    CardModData.Money = CardModData.Money - TotalPrice
    ModData.transmit("S4_CardData")
    -- Add card log
    CardLogModData[LogTime] = {
        Type = "Withdraw",
        Money = TotalPrice,
        Sender = UserName,
        Receiver = "GoodShop",
        DisplayTime = DisplayTime,
    }
    ModData.transmit("S4_CardLog")
    -- Delivery information update
    local ItemList = args[5]
    local DeliveryAddress = args[6]
    PlayerShopModData.Delivery[DeliveryTime] = {}
    PlayerShopModData.Delivery[DeliveryTime].XYZCode = DeliveryAddress
    PlayerShopModData.Delivery[DeliveryTime].List = {}
    for ItemName, Amount in pairs(ItemList) do
        PlayerShopModData.Delivery[DeliveryTime].List[ItemName] = Amount
        ShopModData[ItemName].Stock = ShopModData[ItemName].Stock - Amount
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
        if not PlayerModData then return end
        CardNum = PlayerModData.MainCard
        CardModData = ModData.get("S4_CardData")[CardNum]
    end
    if not CardModData then return end
    local CardLogModData = ModData.get("S4_CardLog")[CardNum]
    if not CardLogModData then return end
    CardModData.Money = CardModData.Money + Price
    local LogTime = args[3]
    local DisplayTime = S4_Utils.getLogTimeMin(LogTime)
    CardLogModData[LogTime] = {
        Type = "Deposit",
        Money = Price,
        Sender = "GoodShop",
        Receiver = UserName,
        DisplayTime = DisplayTime,
    }
    ModData.transmit("S4_CardData")
    ModData.transmit("S4_CardLog")
end

function S4Shop.ShopDataAddon(player, args)
    local ShopModData = ModData.get("S4_ShopData")
    if ShopModData and S4_Shop_Data then
        for ItemName, Data in pairs(S4_Shop_Data) do
            if not ShopModData[ItemName] then
                ShopModData[ItemName] = {
                    BuyPrice = Data.BuyPrice,
                    SellPrice = Data.SellPrice,
                    Stock = Data.Stock,
                    Restock = Data.Restock,
                    Category = Data.Category,
                    BuyAuthority = Data.BuyAuthority,
                    SellAuthority = Data.SellAuthority,
                    Discount = Data.Discount,
                    HotItem = Data.HotItem,
                }
            end
        end
        ModData.transmit("S4_ShopData")
    end
end

function S4Shop.OverWriteShopDataAddon(player, args)
    local ShopModData = ModData.get("S4_ShopData")
    if ShopModData and S4_Shop_Data then
        for ItemName, Data in pairs(S4_Shop_Data) do
            if not ShopModData[ItemName] then
                ShopModData[ItemName] = {
                    BuyPrice = Data.BuyPrice,
                    SellPrice = Data.SellPrice,
                    Stock = Data.Stock,
                    Restock = Data.Restock,
                    Category = Data.Category,
                    BuyAuthority = Data.BuyAuthority,
                    SellAuthority = Data.SellAuthority,
                    Discount = Data.Discount,
                    HotItem = Data.HotItem,
                }
            else
                ShopModData[ItemName].BuyPrice = Data.BuyPrice
                ShopModData[ItemName].SellPrice = Data.SellPrice
                ShopModData[ItemName].Stock = Data.Stock
                ShopModData[ItemName].Restock = Data.Restock
                ShopModData[ItemName].Category = Data.Category
                ShopModData[ItemName].BuyAuthority = Data.BuyAuthority
                ShopModData[ItemName].SellAuthority = Data.SellAuthority
                ShopModData[ItemName].Discount = Data.Discount
                ShopModData[ItemName].HotItem = Data.HotItem
            end
        end
        ModData.transmit("S4_ShopData")
    end
end
