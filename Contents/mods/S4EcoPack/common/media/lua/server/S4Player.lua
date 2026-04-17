-- In multiplayer, prevent execution outside the server.
-- if not isServer() then return end

-- Module initialization
S4Player = {}

local function resolveTraitEntry(traitId)
    if not traitId then
        return nil
    end

    if TraitFactory and TraitFactory.getTrait then
        local ok, trait = pcall(function()
            return TraitFactory.getTrait(traitId)
        end)
        if ok and trait then
            return trait
        end
    end

    return traitId
end

local function serverPlayerHasTrait(player, traitId)
    if not player or not traitId then
        return false
    end

    if player.HasTrait then
        local ok, result = pcall(function()
            return player:HasTrait(traitId)
        end)
        if ok and result ~= nil then
            return result
        end
    end

    local traits = player.getTraits and player:getTraits() or nil
    local traitEntry = resolveTraitEntry(traitId)
    if traits and traits.contains and traitEntry ~= nil then
        local ok, result = pcall(function()
            return traits:contains(traitEntry)
        end)
        if ok and result ~= nil then
            return result
        end
    end

    return false
end

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

function S4Player.AddTeachingTrait(player, args)
    local traitId = args and args[1]
    if not player or not traitId or serverPlayerHasTrait(player, traitId) then
        return
    end

    local traits = player.getTraits and player:getTraits() or nil
    if not traits or not traits.add then
        return
    end

    local traitEntry = resolveTraitEntry(traitId)
    local attempts = {traitEntry, traitId}
    for _, entry in ipairs(attempts) do
        if entry ~= nil then
            local ok = pcall(function()
                traits:add(entry)
            end)
            if ok and serverPlayerHasTrait(player, traitId) then
                if player.transmitModData then
                    player:transmitModData()
                end
                return
            end
        end
    end
end
