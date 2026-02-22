S4_IE_MyDoc = ISPanel:derive("S4_IE_MyDoc")

function S4_IE_MyDoc:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=10/255, g=15/255, b=25/255, a=1} -- Dark slate
    o.borderColor = {r=0, g=1, b=1, a=0.3} -- Cyan border (Hitech)
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
    
    -- Main Grid
    local margin = 15
    local panelW = (self:getWidth() - (margin * 3)) / 2
    local topH = 200
    
    -- Panel 1: Stats & Karma (Left Top)
    local p1 = ISPanel:new(margin, margin, panelW, topH)
    p1.backgroundColor = {r=0, g=0.1, b=0.2, a=0.5}
    p1.borderColor = {r=0, g=0.5, b=1, a=1}
    self:addChild(p1)
    
    p1:addChild(ISLabel:new(10, 10, S4_UI.FH_L, "SURVIVOR DOSSIER", 0, 1, 1, 1, UIFont.Large, true))
    p1:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "ID: " .. self.player:getUsername(), 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    p1:addChild(ISLabel:new(10, 60, S4_UI.FH_S, "Status: Alive", 0, 1, 0, 1, UIFont.Small, true))
    
    -- Karma
    local kmY = 90
    p1:addChild(ISLabel:new(10, kmY, S4_UI.FH_M, "MORAL ALIGNMENT", 0.5, 0.8, 1, 1, UIFont.Medium, true))
    
    local karmaText = "Neutral Worker"
    local karmaColor = {r=0.6, g=0.6, b=0.6}
    if stats.Karma > 80 then karmaText = "Guardian of Knox"; karmaColor = {r=0, g=1, b=1}
    elseif stats.Karma > 30 then karmaText = "Good Samaritan"; karmaColor = {r=0, g=0.8, b=0}
    elseif stats.Karma < -80 then karmaText = "Public Enemy #1"; karmaColor = {r=1, g=0, b=0}
    elseif stats.Karma < -30 then karmaText = "Outlaw Scavenger"; karmaColor = {r=0.8, g=0.4, b=0}
    end
    
    p1:addChild(ISLabel:new(10, kmY + 25, S4_UI.FH_L, karmaText, karmaColor.r, karmaColor.g, karmaColor.b, 1, UIFont.Large, true))
    p1:addChild(ISLabel:new(10, kmY + 50, S4_UI.FH_S, "Rating: " .. stats.Karma .. "/100", 0.5, 0.5, 0.5, 1, UIFont.Small, true))


    -- Panel 2: Factions (Right Top)
    local p2 = ISPanel:new(margin * 2 + panelW, margin, panelW, topH)
    p2.backgroundColor = {r=0, g=0.1, b=0.2, a=0.5}
    p2.borderColor = {r=0, g=0.5, b=1, a=1}
    self:addChild(p2)
    
    p2:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "FACTION INTEL", 0.5, 0.8, 1, 1, UIFont.Medium, true))
    
    local yF = 40
    for faction, rep in pairs(stats.Factions) do
        local fName = getText("IGUI_S4_Faction_" .. faction)
        local rCol = {r=0.6, g=0.6, b=0.6}
        local rTxt = "Neutral"
        if rep > 50 then rCol={r=0,g=1,b=0}; rTxt="Ally"
        elseif rep < -50 then rCol={r=1,g=0,b=0}; rTxt="Hostile" end
        
        p2:addChild(ISLabel:new(10, yF, S4_UI.FH_S, fName .. ":", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
        p2:addChild(ISLabel:new(150, yF, S4_UI.FH_S, rTxt .. " ["..rep.."]", rCol.r, rCol.g, rCol.b, 1, UIFont.Small, true))
        yF = yF + 25
    end


    -- Panel 3: Collected Files / Database (Bottom Full Width)
    local p3H = self:getHeight() - topH - (margin * 3)
    local p3 = ISPanel:new(margin, topH + (margin * 2), self:getWidth() - (margin * 2), p3H)
    p3.backgroundColor = {r=0, g=0.05, b=0.1, a=0.8}
    p3.borderColor = {r=0, g=0.5, b=1, a=0.5}
    self:addChild(p3)
    
    p3:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "DECRYPTED FILES & LOGS", 0, 1, 0.5, 1, UIFont.Medium, true))
    
    -- Mockup File List
    local fileY = 40
    local files = {
        "[AUDIO] Military Comms - Day 3",
        "[MEMO] Patient 0 - Spiffo's Kitchen",
        "[EMAIL] Evacuation Orders (Classified)",
        "[LOG] Subject 14 Escape."
    }
    
    for i, file in ipairs(files) do
        local fBtn = ISButton:new(10, fileY, 300, 20, file, self, S4_IE_MyDoc.onFileClick)
        fBtn.backgroundColor = {r=0, g=0, b=0, a=0}
        fBtn.borderColor = {r=0, g=0, b=0, a=0}
        fBtn.textColor = {r=0.5, g=0.8, b=1, a=1}
        fBtn:initialise()
        p3:addChild(fBtn)
        fileY = fileY + 25
    end
    
    -- Decisions timeline
    p3:addChild(ISLabel:new(350, 10, S4_UI.FH_M, "TIMELINE (EVENTS)", 0.8, 0.8, 0, 1, UIFont.Medium, true))
    local tY = 40
    local count = 0
    for k, v in pairs(stats.Decisions) do
        p3:addChild(ISLabel:new(350, tY, S4_UI.FH_S, "- " .. k .. ": " .. tostring(v), 0.7, 0.7, 0.7, 1, UIFont.Small, false))
        tY = tY + 20
        count = count + 1
    end
    if count == 0 then
        p3:addChild(ISLabel:new(350, tY, S4_UI.FH_S, "No major events recorded.", 0.4, 0.4, 0.4, 1, UIFont.Small, false))
    end
end

function S4_IE_MyDoc:onFileClick(btn)
    -- Aquí se podría abrir un S4_System:new con el texto de la nota
    self.ComUI:AddMsgBox("File Reader - Decrypted", false, "Content locked or corrupted.", false, false)
end

function S4_IE_MyDoc:render()
    ISPanel.render(self)
end
