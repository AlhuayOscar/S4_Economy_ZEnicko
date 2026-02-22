S4_IE_Recon = ISPanel:derive("S4_IE_Recon")

function S4_IE_Recon:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.1, g=0.12, b=0.1, a=1} -- Military terminal dark
    o.borderColor = {r=0.3, g=0.6, b=0.3, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Recon:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Recon:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.15, g=0.25, b=0.15, a=1}
    self.Banner.borderColor = {r=0.2, g=0.5, b=0.2, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "TACTICAL RECON & MAPPING", 0.4, 0.9, 0.4, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Encrypted connection... Intel acquired.", 0.2, 0.6, 0.2, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.05, g=0.08, b=0.05, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Available Heatmap Data Packages:", 0.3, 0.8, 0.3, 1, UIFont.Medium, true))
    y = y + 40
    
    local pkgs = {
        {name="Muldraugh Zombie Density", price=1200},
        {name="West Point Loot Hotspots", price=2500},
        {name="Louisville Military Caches", price=8000}
    }
    
    for _, p in ipairs(pkgs) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 45)
        pnl.backgroundColor = {r=0.1, g=0.15, b=0.1, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_S, "> " .. p.name, 0.4, 0.9, 0.4, 1, UIFont.Small, true))
        
        local buyBtn = ISButton:new(pnl:getWidth() - 150, 5, 140, 35, "Purchase [$" .. p.price .. "]", self, S4_IE_Recon.onDebug)
        buyBtn.backgroundColor = {r=0.2, g=0.4, b=0.2, a=1}
        buyBtn.textColor = {r=0.8, g=1, b=0.8, a=1}
        pnl:addChild(buyBtn)
        
        y = y + 55
    end
end

function S4_IE_Recon:onDebug(btn)
    self.ComUI:AddMsgBox("Recon Uplink", false, "[DEBUG] Initiating satellite scan download...", false, false)
end

function S4_IE_Recon:render()
    ISPanel.render(self)
end
