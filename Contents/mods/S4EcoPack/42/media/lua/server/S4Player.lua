-- In multiplayer, prevent execution outside the server.
-- if not isServer() then return end

-- Module initialization
S4Player = {}
local OPPOSITE_TRAITS = {
    AllThumbs = "Dextrous",
    Brave = "Cowardly",
    Cowardly = "Brave",
    Dextrous = "AllThumbs",
    FastLearner = "SlowLearner",
    FastReader = "SlowReader",
    SlowLearner = "FastLearner",
    SlowReader = "FastReader",
    SpeedDemon = "SundayDriver",
    SundayDriver = "SpeedDemon"
}

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
        if ok and result then
            return result
        end
    end

    local descriptor = player.getDescriptor and player:getDescriptor() or nil
    local traitLists = {
        player.getTraits and player:getTraits() or nil,
        descriptor and descriptor.getTraits and descriptor:getTraits() or nil
    }
    local attempts = {traitId, resolveTraitEntry(traitId)}

    for _, traits in ipairs(traitLists) do
        if traits and traits.contains then
            for _, entry in ipairs(attempts) do
                if entry ~= nil then
                    local ok, result = pcall(function()
                        return traits:contains(entry)
                    end)
                    if ok and result then
                        return result
                    end
                end
            end
        end
    end

    return false
end

local function getTraitAttemptValues(traitId)
    local attempts = {}
    local seen = {}

    local function addAttempt(entry)
        if entry == nil then
            return
        end

        local key = tostring(entry)
        if seen[key] then
            return
        end

        seen[key] = true
        table.insert(attempts, entry)
    end

    addAttempt(traitId)

    local traitEntry = resolveTraitEntry(traitId)
    addAttempt(traitEntry)

    if traitEntry and traitEntry.getType then
        local ok, traitType = pcall(function()
            return traitEntry:getType()
        end)
        if ok and traitType then
            addAttempt(traitType)
        end
    end

    return attempts
end

local function getPlayerTraitLists(player)
    local traitLists = {}

    if player and player.getTraits then
        local traits = player:getTraits()
        if traits and traits.add then
            table.insert(traitLists, traits)
        end
    end

    local descriptor = player and player.getDescriptor and player:getDescriptor() or nil
    if descriptor and descriptor.getTraits then
        local descriptorTraits = descriptor:getTraits()
        if descriptorTraits and descriptorTraits.add then
            table.insert(traitLists, descriptorTraits)
        end
    end

    return traitLists
end

local function removeTraitFromPlayer(player, traitId)
    if not player or not traitId or not serverPlayerHasTrait(player, traitId) then
        return true
    end

    local attempts = getTraitAttemptValues(traitId)
    local traitLists = getPlayerTraitLists(player)

    for _, traits in ipairs(traitLists) do
        if traits.remove then
            for _, entry in ipairs(attempts) do
                pcall(function()
                    traits:remove(entry)
                end)
            end
        end
    end

    return not serverPlayerHasTrait(player, traitId)
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

    local oppositeTrait = OPPOSITE_TRAITS[traitId]
    if oppositeTrait then
        removeTraitFromPlayer(player, oppositeTrait)
    end

    local attempts = getTraitAttemptValues(traitId)
    local traitLists = getPlayerTraitLists(player)
    if #traitLists == 0 then
        return
    end

    for _, traits in ipairs(traitLists) do
        for _, entry in ipairs(attempts) do
            local ok = pcall(function()
                traits:add(entry)
            end)
            if ok and serverPlayerHasTrait(player, traitId) then
                if player.resetModel then
                    pcall(function()
                        player:resetModel()
                    end)
                end
                if player.transmitModData then
                    player:transmitModData()
                end
                return
            end
        end
    end
end
