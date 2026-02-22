S4_IE_MyDoc = ISPanel:derive("S4_IE_MyDoc")

function S4_IE_MyDoc:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=199/255, g=200/255, b=199/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_MyDoc:initialise()
    ISPanel.initialise(self)
end

function S4_IE_MyDoc:createChildren()
    ISPanel.createChildren(self)
    
    local stats = S4_PlayerStats.getStats(self.player)
    local x = 20
    local y = 20
    
    -- Título Header
    self.LabelTitle = ISLabel:new(x, y, S4_UI.FH_L, getText("IGUI_S4_Dossier_Title") .. ": " .. self.player:getUsername(), 0, 0, 0, 1, UIFont.Large, true)
    self:addChild(self.LabelTitle)
    y = y + S4_UI.FH_L + 15

    -- Sección Karma
    self.LabelKarmaTag = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Dossier_Karma"), 0.2, 0.2, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.LabelKarmaTag)
    y = y + S4_UI.FH_M + 5
    
    local karmaText = getText("IGUI_S4_Dossier_Karma_Neutral")
    local karmaColor = {r=0.5, g=0.5, b=0.5}
    if stats.Karma > 80 then karmaText = getText("IGUI_S4_Dossier_Karma_Hero"); karmaColor = {r=0, g=1, b=1}
    elseif stats.Karma > 30 then karmaText = getText("IGUI_S4_Dossier_Karma_Good"); karmaColor = {r=0, g=0.8, b=0}
    elseif stats.Karma < -80 then karmaText = getText("IGUI_S4_Dossier_Karma_Evil"); karmaColor = {r=1, g=0, b=0}
    elseif stats.Karma < -30 then karmaText = getText("IGUI_S4_Dossier_Karma_Bad"); karmaColor = {r=0.8, g=0.4, b=0}
    end
    
    self.LabelKarmaVal = ISLabel:new(x + 20, y, S4_UI.FH_M, karmaText .. " (" .. stats.Karma .. ")", karmaColor.r, karmaColor.g, karmaColor.b, 1, UIFont.Medium, true)
    self:addChild(self.LabelKarmaVal)
    y = y + S4_UI.FH_M + 20

    -- Sección Facciones
    self.LabelFactionsTag = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Dossier_Factions"), 0.2, 0.2, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.LabelFactionsTag)
    y = y + S4_UI.FH_M + 10
    
    for faction, rep in pairs(stats.Factions) do
        local factionName = getText("IGUI_S4_Faction_" .. faction)
        local repText = getText("IGUI_S4_Relationship_Neutral")
        local repColor = {r=0.6, g=0.6, b=0.6}
        
        if rep > 80 then repText = getText("IGUI_S4_Relationship_Ally"); repColor = {r=0, g=1, b=0}
        elseif rep > 30 then repText = getText("IGUI_S4_Relationship_Friendly"); repColor = {r=0, g=0.7, b=0.3}
        elseif rep < -80 then repText = getText("IGUI_S4_Relationship_Enemy"); repColor = {r=1, g=0, b=0}
        elseif rep < -30 then repText = getText("IGUI_S4_Relationship_Hostile"); repColor = {r=0.7, g=0.2, b=0}
        end
        
        local fLabel = ISLabel:new(x + 20, y, S4_UI.FH_S, factionName .. ":", 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(fLabel)
        
        local rLabel = ISLabel:new(x + 180, y, S4_UI.FH_S, repText .. " [" .. rep .. "]", repColor.r, repColor.g, repColor.b, 1, UIFont.Small, true)
        self:addChild(rLabel)
        
        y = y + S4_UI.FH_S + 5
    end
    
    y = y + 15
    -- Timeline / Decisiones
    self.LabelTimeline = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Dossier_Decisions"), 0.2, 0.2, 0.5, 1, UIFont.Medium, true)
    self:addChild(self.LabelTimeline)
    y = y + S4_UI.FH_M + 5
    
    local hasDecisions = false
    for decID, val in pairs(stats.Decisions) do
        local decLabel = ISLabel:new(x + 20, y, S4_UI.FH_S, "- " .. decID .. ": " .. (val and "YES" or "NO"), 0, 0, 0, 0.8, UIFont.Small, true)
        self:addChild(decLabel)
        y = y + S4_UI.FH_S + 2
        hasDecisions = true
    end
    
    if not hasDecisions then
        local noneLabel = ISLabel:new(x + 20, y, S4_UI.FH_S, "(No major decisions recorded yet)", 0.4, 0.4, 0.4, 1, UIFont.Small, false)
        self:addChild(noneLabel)
    end
end

function S4_IE_MyDoc:render()
    ISPanel.render(self)
end
