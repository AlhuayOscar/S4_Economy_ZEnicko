S4_IE_Crimeboid = ISPanel:derive("S4_IE_Crimeboid")

function S4_IE_Crimeboid:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=10/255, g=0, b=0, a=1} -- Blood Red / Black 
    o.borderColor = {r=0.6, g=0, b=0, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.currentTab = "Market"
    return o
end

function S4_IE_Crimeboid:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Crimeboid:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- Banner (Skull or Dark Theme text)
    self.Banner = ISPanel:new(0, 0, w, 50)
    self.Banner.backgroundColor = {r=0.1, g=0, b=0, a=1}
    self.Banner.borderColor = {r=0.5, g=0, b=0, a=1}
    self:addChild(self.Banner)
    
    local title = ISLabel:new(20, 15, S4_UI.FH_L, "CRIMEBOID.NET - Welcome to the Shadows", 1, 0, 0, 1, UIFont.Large, true)
    self.Banner:addChild(title)

    -- Navigation Bar
    self.NavBar = ISPanel:new(0, 50, w, 40)
    self.NavBar.backgroundColor = {r=20/255, g=0, b=0, a=1}
    self:addChild(self.NavBar)
    
    local btnW = 150
    self.BtnMarket = ISButton:new(10, 5, btnW, 30, "[ Black Market ]", self, S4_IE_Crimeboid.switchTab)
    self.BtnMarket.internal = "Market"
    self.BtnMarket.backgroundColor = {r=0.2, g=0, b=0, a=1}
    self.BtnMarket.textColor = {r=1, g=0.2, b=0.2, a=1}
    self.BtnMarket:initialise()
    self.NavBar:addChild(self.BtnMarket)
    
    self.BtnBounty = ISButton:new(20 + btnW, 5, btnW, 30, "[ Hit Contracts ]", self, S4_IE_Crimeboid.switchTab)
    self.BtnBounty.internal = "Bounty"
    self.BtnBounty.backgroundColor = {r=0.2, g=0, b=0, a=1}
    self.BtnBounty.textColor = {r=1, g=0.2, b=0.2, a=1}
    self.BtnBounty:initialise()
    self.NavBar:addChild(self.BtnBounty)

    self.BtnIdentity = ISButton:new(30 + btnW*2, 5, btnW, 30, "[ Forged Identity ]", self, S4_IE_Crimeboid.switchTab)
    self.BtnIdentity.internal = "Identity"
    self.BtnIdentity.backgroundColor = {r=0.2, g=0, b=0, a=1}
    self.BtnIdentity.textColor = {r=1, g=0.2, b=0.2, a=1}
    self.BtnIdentity:initialise()
    self.NavBar:addChild(self.BtnIdentity)

    self.BtnRecords = ISButton:new(40 + btnW*3, 5, btnW, 30, "[ Criminal Records ]", self, S4_IE_Crimeboid.switchTab)
    self.BtnRecords.internal = "Records"
    self.BtnRecords.backgroundColor = {r=0.2, g=0, b=0, a=1}
    self.BtnRecords.textColor = {r=1, g=0.2, b=0.2, a=1}
    self.BtnRecords:initialise()
    self.NavBar:addChild(self.BtnRecords)

    -- Main Content Area
    self.ContentArea = ISPanel:new(10, 100, w - 20, h - 110)
    self.ContentArea.backgroundColor = {r=0, g=0, b=0, a=0.8}
    self.ContentArea.borderColor = {r=1, g=0, b=0, a=0.5}
    self:addChild(self.ContentArea)
    
    self:renderMarket()
end

function S4_IE_Crimeboid:switchTab(btn)
    self.currentTab = btn.internal
    
    -- Clear content area completely
    if self.ContentArea then
        self.ContentArea:clearChildren()
    end
    
    if self.currentTab == "Market" then self:renderMarket()
    elseif self.currentTab == "Bounty" then self:renderBounty()
    elseif self.currentTab == "Identity" then self:renderIdentity()
    elseif self.currentTab == "Records" then self:renderRecords()
    end
end

function S4_IE_Crimeboid:renderMarket()
    local cw = self.ContentArea:getWidth()
    self.ContentArea:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "Untraceable Goods - 0% Tax. High Base Price.", 0.8, 0.8, 0.8, 1, UIFont.Medium, true))
    
    local y = 40
    local items = {
        {name="Military Supply Crate", price=50000, desc="Stolen from the checkpoint."},
        {name="Classified Syringe (Cura?)", price=150000, desc="Experimental. Results vary."},
        {name="C4 Explosive x3", price=25000, desc="Handle with care."}
    }
    
    for i, item in ipairs(items) do
        local pnl = ISPanel:new(10, y, cw - 20, 60)
        pnl.backgroundColor = {r=0.1, g=0.1, b=0.1, a=1}
        pnl.borderColor = {r=0.5, g=0, b=0, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 5, S4_UI.FH_S, item.name, 1, 0.5, 0.2, 1, UIFont.Small, true))
        pnl:addChild(ISLabel:new(10, 25, S4_UI.FH_S, item.desc, 0.6, 0.6, 0.6, 1, UIFont.Small, true))
        
        local btnBuy = ISButton:new(cw - 120, 15, 90, 30, "Buy $" .. S4_UI.getNumCommas(item.price), self, S4_IE_Crimeboid.onBuy)
        btnBuy.internal = "buy_" .. i
        btnBuy.backgroundColor = {r=0.4, g=0, b=0, a=1}
        btnBuy:initialise()
        pnl:addChild(btnBuy)
        
        y = y + 70
    end
end

function S4_IE_Crimeboid:renderBounty()
    local cw = self.ContentArea:getWidth()
    self.ContentArea:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "WANTED ALIVE OR DEAD (Preferably Dead)", 1, 0, 0, 1, UIFont.Medium, true))
    
    self.ContentArea:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "Current Top Bounties:", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    
    -- Mock Bounties
    self.ContentArea:addChild(ISLabel:new(20, 70, S4_UI.FH_M, "1. The Gov ($250,000)", 1, 1, 1, 1, UIFont.Medium, true))
    self.ContentArea:addChild(ISLabel:new(20, 100, S4_UI.FH_M, "2. Unknown Survivor ($50,000)", 1, 1, 1, 1, UIFont.Medium, true))
    
    self.ContentArea:addChild(ISLabel:new(10, 150, S4_UI.FH_M, "Place a Bounty:", 0.5, 0, 0, 1, UIFont.Medium, true))
    self.InputTarget = ISTextEntryBox:new("Target Name", 10, 180, 200, 30)
    self.InputTarget.font = UIFont.Medium
    self.InputTarget:initialise()
    self.InputTarget:instantiate()
    self.ContentArea:addChild(self.InputTarget)
    
    self.InputMoney = ISTextEntryBox:new("10000", 220, 180, 100, 30)
    self.InputMoney.font = UIFont.Medium
    self.InputMoney:initialise()
    self.InputMoney:instantiate()
    self.ContentArea:addChild(self.InputMoney)
    
    local btnPut = ISButton:new(330, 180, 100, 30, "Place Hit", self, S4_IE_Crimeboid.onBounty)
    btnPut.backgroundColor = {r=0.6, g=0, b=0, a=1}
    btnPut:initialise()
    self.ContentArea:addChild(btnPut)
end

function S4_IE_Crimeboid:renderIdentity()
    local cw = self.ContentArea:getWidth()
    self.ContentArea:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "Identity Cleansing Services", 0.5, 0.5, 1, 1, UIFont.Medium, true))
    self.ContentArea:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "Wipe your server history, clean your Karma, disappear.", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    
    local btnWipe = ISButton:new(10, 80, 200, 40, "Reset Karma to 0 ($50,000)", self, S4_IE_Crimeboid.onWipe)
    btnWipe.backgroundColor = {r=0, g=0.3, b=0.6, a=1}
    btnWipe:initialise()
    self.ContentArea:addChild(btnWipe)
end

function S4_IE_Crimeboid:renderRecords()
    local cw = self.ContentArea:getWidth()
    local stats = S4_PlayerStats.getStats(self.player)

    self.ContentArea:addChild(ISLabel:new(10, 10, S4_UI.FH_L, getText("IGUI_S4_Crime_Records_Title"), 0.5, 0.5, 1, 1, UIFont.Large, true))
    self.ContentArea:addChild(ISLabel:new(10, 45, S4_UI.FH_S, getText("IGUI_S4_Crime_Records_Desc"), 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    
    local y = 80
    
    -- Karma Bribe
    local kmPnl = ISPanel:new(10, y, cw - 20, 60)
    kmPnl.backgroundColor = {r=0.1, g=0.1, b=0.1, a=1}
    kmPnl.borderColor = {r=0.5, g=0, b=0, a=1}
    self.ContentArea:addChild(kmPnl)
    
    kmPnl:addChild(ISLabel:new(10, 5, S4_UI.FH_S, "Moral Alignment (Current: " .. stats.Karma .. ")", 1, 1, 1, 1, UIFont.Small, true))
    kmPnl:addChild(ISLabel:new(10, 25, S4_UI.FH_S, "Limit: Cannot exceed +20 via bribes.", 0.6, 0.6, 0.6, 1, UIFont.Small, true))
    
    local btnK = ISButton:new(cw - 220, 15, 200, 30, getText("IGUI_S4_Crime_ImproveKarma") .. " - $10,000", self, S4_IE_Crimeboid.onBribeKarma)
    btnK.backgroundColor = {r=0.4, g=0, b=0, a=1}
    if stats.Karma > 20 then btnK.enable = false; btnK.title = "Max Reached" end
    btnK:initialise()
    kmPnl:addChild(btnK)
    
    y = y + 70
    
    -- Faction Bribes
    for faction, rep in pairs(stats.Factions) do
        local fPnl = ISPanel:new(10, y, cw - 20, 60)
        fPnl.backgroundColor = {r=0.1, g=0.1, b=0.1, a=1}
        fPnl.borderColor = {r=0.5, g=0, b=0, a=1}
        self.ContentArea:addChild(fPnl)
        
        local factionName = getText("IGUI_S4_Faction_" .. faction)
        fPnl:addChild(ISLabel:new(10, 5, S4_UI.FH_S, factionName .. " (Current: " .. rep .. ")", 1, 1, 1, 1, UIFont.Small, true))
        fPnl:addChild(ISLabel:new(10, 25, S4_UI.FH_S, "Limit: Cannot exceed +20 via bribes.", 0.6, 0.6, 0.6, 1, UIFont.Small, true))
        
        local btnF = ISButton:new(cw - 220, 15, 200, 30, getText("IGUI_S4_Crime_ImproveRep") .. " - $15,000", self, S4_IE_Crimeboid.onBribeFaction)
        btnF.internal = faction
        btnF.backgroundColor = {r=0.4, g=0, b=0, a=1}
        
        if rep > 20 then btnF.enable = false; btnF.title = "Max Reached" end
        btnF:initialise()
        fPnl:addChild(btnF)
        
        y = y + 70
    end
end

function S4_IE_Crimeboid:onBuy(btn)
    self.ComUI:AddMsgBox("Transaction Failed", false, "Insufficient Funds / Network Monitored.", false, false)
end

function S4_IE_Crimeboid:onBounty(btn)
    self.ComUI:AddMsgBox("Bounty Board", false, "Contract posted successfully. They won't see it coming.", false, false)
end

function S4_IE_Crimeboid:onWipe(btn)
    self.ComUI:AddMsgBox("Identity Forge", false, "Network Error. FBI monitoring detected.", false, false)
end

function S4_IE_Crimeboid:onBribeKarma(btn)
    self.ComUI:AddMsgBox("Transaction Pending", false, "Simulated: Bribe sent. Karma will change shortly.", false, false)
end

function S4_IE_Crimeboid:onBribeFaction(btn)
    local faction = btn.internal
    self.ComUI:AddMsgBox("Transaction Pending", false, "Simulated: Paid off " .. faction .. " contacts.", false, false)
end

function S4_IE_Crimeboid:render()
    ISPanel.render(self)
end
