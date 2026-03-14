S4_IE_MyDoc = ISPanel:derive("S4_IE_MyDoc")

function S4_IE_MyDoc:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    -- Tech/CRT background color
    o.backgroundColor = {r=0.02, g=0.08, b=0.05, a=1}
    o.borderColor = {r=0, g=0.6, b=0.4, a=0.8}
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
    -- Instead of using static labels for everything, we'll draw some elements in render
    -- But we will use labels for text to simplify font handling
    
    local stats = S4_PlayerStats.getStats(self.player)
    local margin = 20
    
    local pWidth = self:getWidth()
    local pHeight = self:getHeight()
    
    local leftW = (pWidth / 2) - margin * 1.5
    local rightW = leftW
    
    -- LEFT PANEL: KARMA & FACTIONS
    self.LeftPanel = ISPanel:new(margin, margin, leftW, pHeight - margin*2)
    self.LeftPanel.backgroundColor = {r=0, g=0.05, b=0.02, a=0.8}
    self.LeftPanel.borderColor = {r=0.2, g=0.8, b=0.6, a=0.5}
    self:addChild(self.LeftPanel)
    
    -- Title
    self.LeftPanel:addChild(ISLabel:new(20, 15, S4_UI.FH_L, "KARMA METER", 0.5, 1, 0.8, 1, UIFont.Large, true))
    
    -- We will draw the Karma bar in leftpanel:render
    
    local factionY = 250
    self.LeftPanel:addChild(ISLabel:new(20, factionY, S4_UI.FH_M, "FACTION INTEL", 0.4, 0.8, 0.6, 1, UIFont.Medium, true))
    
    factionY = factionY + 40
    local i = 0
    for faction, rep in pairs(stats.Factions) do
        local fName = getText("IGUI_S4_Faction_" .. faction)
        self.LeftPanel:addChild(ISLabel:new(20, factionY + (i*50), S4_UI.FH_S, fName, 0.8, 0.9, 0.8, 1, UIFont.Small, true))
        -- Bar will be drawn in render
        i = i + 1
    end
    
    -- RIGHT PANEL: DECISIONS TIMELINE
    self.RightPanel = ISPanel:new(margin*2 + leftW, margin, rightW, pHeight - margin*2)
    self.RightPanel.backgroundColor = {r=0, g=0.05, b=0.02, a=0.8}
    self.RightPanel.borderColor = {r=0.2, g=0.8, b=0.6, a=0.5}
    self:addChild(self.RightPanel)
    
    self.RightPanel:addChild(ISLabel:new(20, 15, S4_UI.FH_L, "DECISIONS TIMELINE", 0.5, 1, 0.8, 1, UIFont.Large, true))
    
    local tY = 70
    local count = 0
    
    -- Helper local table
    local decList = {}
    for k, v in pairs(stats.Decisions) do
        table.insert(decList, {name=k, value=tostring(v)})
    end
    
    if #decList == 0 then
        self.RightPanel:addChild(ISLabel:new(50, tY, S4_UI.FH_S, "No major events recorded.", 0.5, 0.5, 0.5, 1, UIFont.Small, true))
    else
        for _, dec in ipairs(decList) do
            self.RightPanel:addChild(ISLabel:new(60, tY, S4_UI.FH_M, dec.name, 0.8, 1, 0.8, 1, UIFont.Medium, true))
            
            -- Result/Value
            local valColor = {r=0.6, g=0.6, b=0.6}
            local valText = dec.value
            if type(dec.value) == "boolean" then valText = "Completed" end
            
            self.RightPanel:addChild(ISLabel:new(60, tY + 25, S4_UI.FH_S, valText, 0.6, 0.8, 1, 1, UIFont.Small, true))
            
            tY = tY + 70
            count = count + 1
            if tY > self.RightPanel:getHeight() - 50 then break end
        end
    end
    
    -- Override renders to draw custom graphics
    local origLeftRender = self.LeftPanel.render
    self.LeftPanel.render = function(pnl)
        origLeftRender(pnl)
        
        -- Draw custom Karma progress bar (horizontal gradient simulation)
        local barX = 20
        local barY = 80
        local barW = pnl:getWidth() - 40
        local barH = 30
        
        -- Background for bar
        pnl:drawRect(barX, barY, barW, barH, 0.5, 0.1, 0.1, 0.1)
        pnl:drawRectBorder(barX, barY, barW, barH, 1, 0.2, 0.8, 0.6)
        
        -- Current Karma Value
        local plyStats = S4_PlayerStats.getStats(pnl.parent.player)
        local karmaNormalized = (plyStats.Karma + 100) / 200 -- 0.0 to 1.0 (since karma is -100 to 100)
        if karmaNormalized < 0 then karmaNormalized = 0 end
        if karmaNormalized > 1 then karmaNormalized = 1 end
        
        local fillW = barW * karmaNormalized
        local r, g, b = 1, 0.8, 0 -- Yellow default
        if plyStats.Karma > 20 then
            r, g, b = 0.2, 1, 0.2 -- Greenish
        elseif plyStats.Karma < -20 then
            r, g, b = 1, 0.2, 0.2 -- Redish
        end
        
        pnl:drawRect(barX + 2, barY + 2, fillW - 4, barH - 4, 0.8, r, g, b)
        
        -- Karma Text
        local kText = "NEUTRAL"
        if plyStats.Karma > 80 then kText = "SAVIOR"
        elseif plyStats.Karma > 30 then kText = "GOOD"
        elseif plyStats.Karma < -80 then kText = "PSYCHOPATH"
        elseif plyStats.Karma < -30 then kText = "BANDIT"
        end
        
        pnl:drawTextCentre("KARMA: " .. kText .. " (" .. plyStats.Karma .. ")", pnl:getWidth() / 2, barY + barH + 15, r, g, b, 1, UIFont.Large)
        
        -- Draw Faction bars
        local fYOffset = 315
        for faction, rep in pairs(plyStats.Factions) do
            local fbX = 20
            local fbY = fYOffset
            local fbW = pnl:getWidth() - 90
            local fbH = 15
            
            pnl:drawRect(fbX, fbY, fbW, fbH, 0.4, 0, 0, 0)
            pnl:drawRectBorder(fbX, fbY, fbW, fbH, 0.8, 0.4, 0.5, 0.5)
            
            local repNorm = (rep + 100) / 200
            if repNorm < 0 then repNorm = 0 end
            if repNorm > 1 then repNorm = 1 end
            
            local fR, fG, fB = 0.6, 0.6, 0.6
            if rep > 20 then fR, fG, fB = 0.2, 0.8, 1
            elseif rep < -20 then fR, fG, fB = 1, 0.3, 0.1 end
            
            pnl:drawRect(fbX + 1, fbY + 1, (fbW - 2) * repNorm, fbH - 2, 0.8, fR, fG, fB)
            pnl:drawTextRight(tostring(rep) .. "%", fbX + fbW + 40, fbY - 2, fR, fG, fB, 1, UIFont.Small)
            
            fYOffset = fYOffset + 50
        end
    end
    
    local origRightRender = self.RightPanel.render
    self.RightPanel.render = function(pnl)
        origRightRender(pnl)
        
        local plyStats = S4_PlayerStats.getStats(pnl.parent.player)
        
        -- Draw the vertical connecting line for timeline
        local tCount = 0
        for k, _ in pairs(plyStats.Decisions) do tCount = tCount + 1 end
        
        if tCount > 0 then
            local lineX = 35
            local startY = 80
            local endY = startY + ((tCount - 1) * 70)
            if endY > pnl:getHeight() - 50 then endY = pnl:getHeight() - 50 end
            
            pnl:drawRect(lineX, startY, 4, endY - startY, 0.8, 0.2, 0.8, 0.5)
            
            -- Draw nodes
            local nY = startY
            for i = 1, tCount do
                if nY > endY + 10 then break end
                -- Node outer rect
                pnl:drawRect(lineX - 4, nY - 4, 12, 12, 1, 0.1, 0.2, 0.1)
                -- Node inner dot
                pnl:drawRect(lineX - 2, nY - 2, 8, 8, 1, 0.4, 1, 0.6)
                
                nY = nY + 70
            end
        end
    end
end

function S4_IE_MyDoc:render()
    ISPanel.render(self)
    
    -- CRT scanlines effect (simple alternating rows or overlay block)
    -- This makes it look like Zomdows 88
    local w = self:getWidth()
    local h = self:getHeight()
    
    local numLines = math.floor(h / 4)
    for i=0, numLines do
        self:drawRect(0, i*4, w, 1, 0.05, 0, 0, 0)
    end
end
