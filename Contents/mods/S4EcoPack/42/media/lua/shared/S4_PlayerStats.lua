S4_PlayerStats = {}

-- Inicializar datos de jugador
function S4_PlayerStats.init(player)
    local username = player:getUsername()
    local stats = ModData.getOrCreate("S4_PlayerStats")
    
    if not stats[username] then
        stats[username] = {
            Karma = 0, -- -100 (Malvado) a 100 (Héroe)
            Factions = {
                ["Banditos"] = 0,
                ["Survivors"] = 0,
                ["Military"] = 0,
                ["TraderUnion"] = 0
            },
            Decisions = {},
            Stocks = {}, -- {"SPIFF" = 10}
            Warehouses = {}, -- {"1" = {name="Unit P", capacity=500, used=0, location="Muldraugh"}}
            Title = "Scavenger",
            TotalEarnings = 0,
            KillsNPC = 0,
            KillsZombie = 0
        }
    else
        -- Backward compatibility check
        if not stats[username].Stocks then stats[username].Stocks = {} end
        if not stats[username].Warehouses then stats[username].Warehouses = {} end
    end
    return stats[username]
end

-- Funciones para modificar Karma
function S4_PlayerStats.addKarma(player, amount)
    local stats = S4_PlayerStats.init(player)
    stats.Karma = math.min(100, math.max(-100, stats.Karma + amount))
    if isClient() then ModData.transmit("S4_PlayerStats") end
end

-- Funciones para modificar Facciones
function S4_PlayerStats.addFactionRep(player, faction, amount)
    local stats = S4_PlayerStats.init(player)
    if stats.Factions[faction] then
        stats.Factions[faction] = math.min(100, math.max(-100, stats.Factions[faction] + amount))
    end
    if isClient() then ModData.transmit("S4_PlayerStats") end
end

-- Registrar una decisión
function S4_PlayerStats.addDecision(player, decisionID, value)
    local stats = S4_PlayerStats.init(player)
    stats.Decisions[decisionID] = value
    if isClient() then ModData.transmit("S4_PlayerStats") end
end

-- Funciones de Logistica
function S4_PlayerStats.addStock(player, symbol, amount)
    local stats = S4_PlayerStats.init(player)
    if not stats.Stocks[symbol] then stats.Stocks[symbol] = 0 end
    stats.Stocks[symbol] = stats.Stocks[symbol] + amount
    if stats.Stocks[symbol] < 0 then stats.Stocks[symbol] = 0 end
    if isClient() then ModData.transmit("S4_PlayerStats") end
end

function S4_PlayerStats.addWarehouse(player, id, name, capacity, location)
    local stats = S4_PlayerStats.init(player)
    stats.Warehouses[id] = {name=name, capacity=capacity, used=0, location=location}
    if isClient() then ModData.transmit("S4_PlayerStats") end
end

function S4_PlayerStats.updateWarehouseUsage(player, id, amount)
    local stats = S4_PlayerStats.init(player)
    if stats.Warehouses[id] then
        stats.Warehouses[id].used = stats.Warehouses[id].used + amount
        if stats.Warehouses[id].used < 0 then stats.Warehouses[id].used = 0 end
        if stats.Warehouses[id].used > stats.Warehouses[id].capacity then
            stats.Warehouses[id].used = stats.Warehouses[id].capacity
        end
        if isClient() then ModData.transmit("S4_PlayerStats") end
    end
end

-- Obtener stats de un jugador
function S4_PlayerStats.getStats(player)
    local username = player:getUsername()
    local stats = ModData.get("S4_PlayerStats")
    return stats and stats[username] or S4_PlayerStats.init(player)
end

-- Evento para inicializar al entrar
local function OnGameStart()
    local player = getPlayer()
    if player then
        S4_PlayerStats.init(player)
    end
end

Events.OnGameStart.Add(OnGameStart)
