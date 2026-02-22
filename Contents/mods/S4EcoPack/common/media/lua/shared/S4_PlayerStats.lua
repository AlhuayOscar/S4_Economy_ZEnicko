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
            Decisions = {}, -- ["SavedBanker"] = true
            Title = "Scavenger",
            TotalEarnings = 0,
            KillsNPC = 0,
            KillsZombie = 0
        }
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
function S4_PlayerStats.makeDecision(player, decisionID, value)
    local stats = S4_PlayerStats.init(player)
    stats.Decisions[decisionID] = value
    if isClient() then ModData.transmit("S4_PlayerStats") end
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
