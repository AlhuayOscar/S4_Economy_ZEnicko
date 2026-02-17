-- In multiplayer, prevent execution outside the server.
-- if not isServer() then return end

-- Module initialization
S4Player = {}

-- Create player profile data
function S4Player.CreatePlayerData(player, args)
    local UserName = player:getUsername()
    local PlayerModData = ModData.get("S4_PlayerData")
    local Account = PlayerModData[UserName]
    if Account then return end
    ModData.get("S4_PlayerData")[UserName] = {
        MainCard = false,
        Guild = false,
        GunKill = 0,
        MeleeKill = 0,
    }
    ModData.transmit("S4_PlayerData")
end

function S4Player.setMainCard(player, args)
    local UserName = player:getUsername()
    local PlayerModData = ModData.get("S4_PlayerData")
    local Account = PlayerModData[UserName]
    if not Account then return end
    
    Account.MainCard = args[1]
    ModData.transmit("S4_PlayerData")
end

function S4Player.CreatePlayerShopData(player, args)
    local UserName = player:getUsername()
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    local Account = PlayerShopModData[UserName]
    if Account then return end
    ModData.get("S4_PlayerShopData")[UserName] = {
        DeliveryAdrres = false,
        DeliveryList = {},
        Delivery = {},
        FavoriteList = {},
        BuyAuthority = 0,
        BuyTotal = 0,
        SellAuthority = 0,
        SellTotal = 0,
        Cart = {},
    }
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.AddDeliveryList(player, args)
    local UserName = player:getUsername()
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    local Account = PlayerShopModData[UserName]
    if not Account then return end
    if Account.DeliveryList[args[1]] then return end
    Account.DeliveryList[args[1]] = args[2]
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.RemoveDelivery(player, args)
    local UserName = player:getUsername()
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    local Account = PlayerShopModData[UserName]
    if not Account then return end
    if not Account.Delivery[args[1]] then return end
    Account.Delivery[args[1]] = nil
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.AddBuyCart(player, args)
    local UserName = player:getUsername()
    local Account = ModData.get("S4_PlayerShopData")[UserName]
    if not Account and not Account.Cart then return end
    if Account.Cart[args[1]] then
        Account.Cart[args[1]] = Account.Cart[args[1]] + args[2]
    else
        Account.Cart[args[1]] = args[2]
    end
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.SetBuyCart(player, args)
    local UserName = player:getUsername()
    local Account = ModData.get("S4_PlayerShopData")[UserName]
    if not Account and not Account.Cart and Account.Cart[args[1]] then return end
    Account.Cart[args[1]] = args[2]
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.setFavorite(player, args)
    local UserName = player:getUsername()
    local Account = ModData.get("S4_PlayerShopData")[UserName]
    if not Account and not Account.FavoriteList then return end
    if Account.FavoriteList[args[1]] then
        Account.FavoriteList[args[1]] = nil
    else
        Account.FavoriteList[args[1]] = true
    end
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.AddSellTotal(player, args)
    local UserName = args[1]
    local Account = ModData.get("S4_PlayerShopData")[UserName]
    if not Account then return end
    Account.SellTotal = Account.SellTotal + args[2]
    ModData.transmit("S4_PlayerShopData")
end

function S4Player.SetAuthority(player, args)
    local UserName = player:getUsername()
    local Account = ModData.get("S4_PlayerShopData")[UserName]
    if not Account then return end
    if args[1] then
        Account.BuyAuthority = args[1]
    end
    if args[2] then
        Account.SellAuthority = args[2]
    end
    ModData.transmit("S4_PlayerShopData")
end
