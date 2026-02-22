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
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "TACTICAL RECON & SURVIVAL LOGISTICS", 0.4, 0.9, 0.4, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Encrypted link. Deploying satellite drone sweeps...", 0.2, 0.6, 0.2, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.05, g=0.08, b=0.05, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Available Sweeps / Targeting Packages:", 0.3, 0.8, 0.3, 1, UIFont.Medium, true))
    y = y + 40
    
    local pkgs = {
        {name="Thermal Map: Zombie Population Density", price=1200, desc="Highlights massive hordes and migration paths.", type="ZED"},
        {name="Struct Sweep: Random Safehouses Gen", price=2500, desc="Locates barricaded homes with potential high-tier loot.", type="HOUSE"},
        {name="Bio-Scan: Animal & Livestock Hotspots", price=8000, desc="Tracks local fauna for hunting and trapping efficiency.", type="ANIMAL"}
    }
    
    for _, p in ipairs(pkgs) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 80)
        pnl.backgroundColor = {r=0.1, g=0.15, b=0.1, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "> [ " .. p.name .. " ]", 0.4, 0.9, 0.4, 1, UIFont.Medium, true))
        pnl:addChild(ISLabel:new(10, 35, S4_UI.FH_S, p.desc, 0.3, 0.6, 0.3, 1, UIFont.Small, true))
        
        pnl:addChild(ISLabel:new(pnl:getWidth() - 250, 15, S4_UI.FH_M, "CREDITS: $" .. p.price, 0.8, 0.3, 0.3, 1, UIFont.Medium, true))
        
        local buyBtn = ISButton:new(pnl:getWidth() - 260, 40, 240, 30, "INITIATE SCAN PROTOCOL", self, S4_IE_Recon.onScan)
        buyBtn.internal = p.type
        buyBtn.backgroundColor = {r=0.2, g=0.4, b=0.2, a=1}
        buyBtn.textColor = {r=0.8, g=1, b=0.8, a=1}
        buyBtn:initialise()
        pnl:addChild(buyBtn)
        
        y = y + 90
    end
    
    self.StatusText = ISLabel:new(20, y + 20, S4_UI.FH_M, "SYSTEM STATUS: STANDBY", 0.6, 0.6, 0.6, 1, UIFont.Medium, true)
    self.ContentArea:addChild(self.StatusText)
end

function S4_IE_Recon:onScan(btn)
    local t = btn.internal
    if t == "ZED" then
        self.ComUI:AddMsgBox("Recon Uplink - Thermal Scan", false, "WARNING: Extreme density detected. Grid 45x12 (Louisville Checkpoint) overloaded. Estimated 5000+ hostile entities.", false, false)
    elseif t == "HOUSE" then
        self.ComUI:AddMsgBox("Recon Uplink - Structural Scan", false, "Locating anomalous fortifications... Found 3 barricaded properties in Rosewood residential vector.", false, false)
    elseif t == "ANIMAL" then
        self.ComUI:AddMsgBox("Recon Uplink - Bio Scan", false, "Tracking heat signatures... Large deer packs identified near McCoy Logging Co. forests.", false, false)
    end
end

function S4_IE_Recon:render()
    ISPanel.render(self)
end
