-- In multiplayer, prevent execution outside the server.
-- if not isServer() then return end

-- Module initialization
S4ServerCommand = {}

function S4ServerCommand.OnInitGlobalModData()
    if not SandboxVars.S4SandBox.SinglePlay and isClient() then return end
    -- Eco
    ModData.getOrCreate("S4_CardData")
    ModData.getOrCreate("S4_CardLog")
    -- PlayerData
    ModData.getOrCreate("S4_PlayerData")
    -- Quest
    ModData.getOrCreate("S4_QuestData")
    -- Shop
    ModData.getOrCreate("S4_ShopData")
    ModData.getOrCreate("S4_PlayerShopData")
    -- Xp Count
    ModData.getOrCreate("S4_PlayerXpData")
    -- Server Data
    ModData.getOrCreate("S4_ServerData")
    if SandboxVars.S4SandBox.AddonAuto and S4_Shop_Data then
        S4Shop.ShopDataAddon()
    end
end
Events.OnInitGlobalModData.Add(S4ServerCommand.OnInitGlobalModData)

-- Receive client commands
local function S4ServerCommand_OnClientCommand(module, command, player, args)
    if not SandboxVars.S4SandBox.SinglePlay and isClient() then return end
    
    if module == "S4ED" and S4Economy[command] then
        S4Economy[command](player, args)
    elseif module == "S4PD" and S4Player[command] then
        S4Player[command](player, args)
    elseif module == "S4QD" and S4Quest[command] then
        S4Quest[command](player, args)
    elseif module == "S4SD" and S4Shop[command] then
        S4Shop[command](player, args)
    elseif module == "S4SMD" and S4Server[command] then
    S4Server[command](player, args)
    end
end
Events.OnClientCommand.Add(S4ServerCommand_OnClientCommand)
