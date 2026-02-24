S4_FactionZones = {}

-- Definition of major territory zones
-- Each zone has a name, rect boundaries, and a default owner
S4_FactionZones.Zones = {
    {
        name = "Muldraugh Central",
        id = "muldraugh",
        x1 = 10500, y1 = 9000, x2 = 11000, y2 = 10500,
        defaultOwner = "Survivors",
        description = "A vital transit hub. The pulse of the Kentucky resistance."
    },
    {
        name = "West Point Urban",
        id = "westpoint",
        x1 = 11500, y1 = 6500, x2 = 12200, y2 = 7200,
        defaultOwner = "Military",
        description = "Densely populated and heavily fortified by remnants of the local guard."
    },
    {
        name = "Riverside Suburbs",
        id = "riverside",
        x1 = 6000, y1 = 5000, x2 = 6800, y2 = 5600,
        defaultOwner = "TraderUnion",
        description = "A relatively quiet area where trade still flows along the river."
    },
    {
        name = "Louisville Checkpoint",
        id = "louisville_entrance",
        x1 = 12400, y1 = 4000, x2 = 13000, y2 = 4500,
        defaultOwner = "Military",
        description = "The gateway to the city. Highly restricted and extremely dangerous."
    },
    {
        name = "Rosewood Area",
        id = "rosewood",
        x1 = 8000, y1 = 11300, x2 = 8400, y2 = 11800,
        defaultOwner = "Survivors",
        description = "Home to the prison and the fire station. A bastion of structure."
    },
    {
        name = "The Great Woods",
        id = "wilderness",
        x1 = 0, y1 = 0, x2 = 15000, y2 = 15000, -- Catch-all
        defaultOwner = "Banditos",
        description = "Lawless territory where only the strong survive."
    }
}

-- Initialize Global ModData for Territory Control
function S4_FactionZones.init()
    local territory = ModData.getOrCreate("S4_TerritoryControl")
    if not territory.Zones then
        territory.Zones = {}
        for _, z in ipairs(S4_FactionZones.Zones) do
            territory.Zones[z.id] = {
                owner = z.defaultOwner,
                influence = 100, -- 0 to 100
                contested = false
            }
        end
    end
    return territory
end

-- Get current zone at coordinates
function S4_FactionZones.getZoneAt(x, y)
    -- Iterate through specifically defined zones first (more specific rects first)
    for i = 1, #S4_FactionZones.Zones - 1 do
        local z = S4_FactionZones.Zones[i]
        if x >= z.x1 and x <= z.x2 and y >= z.y1 and y <= z.y2 then
            return z
        end
    end
    -- Default to wilderness if nothing else matches
    return S4_FactionZones.Zones[#S4_FactionZones.Zones]
end

-- Get owner of a zone
function S4_FactionZones.getZoneOwner(zoneId)
    local territory = S4_FactionZones.init()
    if territory.Zones[zoneId] then
        return territory.Zones[zoneId].owner
    end
    return "Unknown"
end

-- Update zone influence/owner
function S4_FactionZones.addInfluence(zoneId, faction, amount)
    local territory = S4_FactionZones.init()
    if not territory.Zones[zoneId] then return end
    
    local zData = territory.Zones[zoneId]
    if zData.owner == faction then
        zData.influence = math.min(100, zData.influence + amount)
    else
        zData.influence = zData.influence - amount
        if zData.influence <= 0 then
            zData.owner = faction
            zData.influence = math.abs(zData.influence)
        end
    end
    
    if isClient() then ModData.transmit("S4_TerritoryControl") end
end
