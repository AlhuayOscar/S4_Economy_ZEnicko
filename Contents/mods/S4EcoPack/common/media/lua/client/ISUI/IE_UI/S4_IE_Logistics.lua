S4_IE_Logistics = ISPanel:derive("S4_IE_Logistics")

function S4_IE_Logistics:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.9, g=0.9, b=0.92, a=1} -- Corporate light blue/grey
    o.borderColor = {r=0.3, g=0.3, b=0.4, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.currentTab = "Warehouses"
    
    o.accentColor = {r=0.1, g=0.3, b=0.6, a=1} -- Corporate Blue
    
    return o
end

function S4_IE_Logistics:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Logistics:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- Banner
    self.Banner = ISPanel:new(0, 0, w, 50)
    self.Banner.backgroundColor = self.accentColor
    self.Banner.borderColor = self.accentColor
    self:addChild(self.Banner)
    
    local title = ISLabel:new(20, 15, S4_UI.FH_L, "S4 LOGISTICS & COMMERCE", 1, 1, 1, 1, UIFont.Large, true)
    self.Banner:addChild(title)

    -- Navigation Bar
    self.NavBar = ISPanel:new(0, 50, w, 40)
    self.NavBar.backgroundColor = {r=0.8, g=0.8, b=0.85, a=1}
    self:addChild(self.NavBar)
    
    local btnW = 160
    self.BtnWarehouses = ISButton:new(10, 5, btnW, 30, "[ My Warehouses ]", self, S4_IE_Logistics.switchTab)
    self.BtnWarehouses.internal = "Warehouses"
    self.BtnWarehouses.backgroundColor = {r=0.7, g=0.7, b=0.75, a=1}
    self.BtnWarehouses.textColor = {r=0.1, g=0.1, b=0.1, a=1}
    self.NavBar:addChild(self.BtnWarehouses)
    
    self.BtnStocks = ISButton:new(20 + btnW, 5, btnW, 30, "[ Corporate Stocks ]", self, S4_IE_Logistics.switchTab)
    self.BtnStocks.internal = "Stocks"
    self.BtnStocks.backgroundColor = {r=0.7, g=0.7, b=0.75, a=1}
    self.BtnStocks.textColor = {r=0.1, g=0.1, b=0.1, a=1}
    self.NavBar:addChild(self.BtnStocks)

    self.BtnContracts = ISButton:new(30 + btnW*2, 5, btnW, 30, "[ Cargo Contracts ]", self, S4_IE_Logistics.switchTab)
    self.BtnContracts.internal = "Contracts"
    self.BtnContracts.backgroundColor = {r=0.7, g=0.7, b=0.75, a=1}
    self.BtnContracts.textColor = {r=0.1, g=0.1, b=0.1, a=1}
    self.NavBar:addChild(self.BtnContracts)

    -- Main Content Area
    self.ContentArea = ISPanel:new(10, 100, w - 20, h - 110)
    self.ContentArea.backgroundColor = {r=1, g=1, b=1, a=0.9}
    self.ContentArea.borderColor = {r=0.3, g=0.3, b=0.3, a=0.5}
    self:addChild(self.ContentArea)
    
    self:renderWarehouses()
end

function S4_IE_Logistics:switchTab(btn)
    self.currentTab = btn.internal
    
    if self.ContentArea then
        self.ContentArea:clearChildren()
    end
    
    if self.currentTab == "Warehouses" then self:renderWarehouses()
    elseif self.currentTab == "Stocks" then self:renderStocks()
    elseif self.currentTab == "Contracts" then self:renderContracts()
    end
end

function S4_IE_Logistics:renderWarehouses()
    local cw = self.ContentArea:getWidth()
    self.ContentArea:addChild(ISLabel:new(15, 15, S4_UI.FH_L, "Off-Map Storage Facilities", 0.1, 0.2, 0.4, 1, UIFont.Large, true))
    self.ContentArea:addChild(ISLabel:new(15, 45, S4_UI.FH_S, "Manage your remote cargo containers.", 0.4, 0.4, 0.4, 1, UIFont.Small, true))
    
    local y = 80
    local stats = S4_PlayerStats.getStats(self.player)
    
    local storage = {}
    for k, v in pairs(stats.Warehouses) do
        table.insert(storage, v)
    end
    
    if #storage == 0 then
        self.ContentArea:addChild(ISLabel:new(15, y, S4_UI.FH_M, "You don't own any warehouses.", 0.6, 0.6, 0.6, 1, UIFont.Medium, true))
    end
    
    for _, wh in ipairs(storage) do
        local pnl = ISPanel:new(15, y, cw - 30, 70)
        pnl.backgroundColor = {r=0.95, g=0.95, b=0.95, a=1}
        pnl.borderColor = {r=0.6, g=0.6, b=0.6, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "Warehouse: " .. wh.name, 0.1, 0.1, 0.1, 1, UIFont.Medium, true))
        pnl:addChild(ISLabel:new(10, 35, S4_UI.FH_S, "Location: " .. wh.location, 0.4, 0.4, 0.4, 1, UIFont.Small, true))
        
        -- Progress bar for capacity
        local fillPct = wh.used / wh.capacity
        local barX = pnl:getWidth() - 320
        local barW = 200
        
        -- Draw custom bar in render
        local oldRender = pnl.render
        pnl.render = function(selfPnl)
            oldRender(selfPnl)
            selfPnl:drawRect(barX, 25, barW, 15, 1, 0.8, 0.8, 0.8)
            selfPnl:drawRectBorder(barX, 25, barW, 15, 1, 0.4, 0.4, 0.4)
            local r, g, b = 0.2, 0.8, 0.2
            if fillPct > 0.8 then r, g, b = 0.8, 0.2, 0.2 end
            selfPnl:drawRect(barX+1, 26, (barW-2) * fillPct, 13, 1, r, g, b)
        end
        
        pnl:addChild(ISLabel:new(barX, 45, S4_UI.FH_S, "Capacity: " .. wh.used .. " / " .. wh.capacity .. " kg", 0.3, 0.3, 0.3, 1, UIFont.Small, true))
        
        local btnOpen = ISButton:new(pnl:getWidth() - 100, 20, 80, 30, "Open", self, S4_IE_Logistics.onAction)
        btnOpen.backgroundColor = self.accentColor
        btnOpen.textColor = {r=1, g=1, b=1, a=1}
        pnl:addChild(btnOpen)
        
        y = y + 80
    end
    
    local btnBuy = ISButton:new(15, y + 20, 200, 30, "Purchase New Warehouse ($15,000)", self, S4_IE_Logistics.onAction)
    btnBuy.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    btnBuy.textColor = {r=1, g=1, b=1, a=1}
    self.ContentArea:addChild(btnBuy)
end

function S4_IE_Logistics:renderStocks()
    local cw = self.ContentArea:getWidth()
    self.ContentArea:addChild(ISLabel:new(15, 15, S4_UI.FH_L, "Corporate Stock Certificates", 0.1, 0.2, 0.4, 1, UIFont.Large, true))
    self.ContentArea:addChild(ISLabel:new(15, 45, S4_UI.FH_S, "Buy and sell public shares. High volatility.", 0.4, 0.4, 0.4, 1, UIFont.Small, true))
    
    local y = 80
    local stats = S4_PlayerStats.getStats(self.player)
    
    local spiffOwned = stats.Stocks["SPIFF"] or 0
    local knoxOwned = stats.Stocks["KNOX"] or 0
    local phmOwned = stats.Stocks["PHM"] or 0
    
    local stocks = {
        {symbol="SPIFF", name="Spiffo Corp Industries", price=124.50, trend="UP", held=spiffOwned},
        {symbol="KNOX", name="Knox Bank Group", price=34.20, trend="DOWN", held=knoxOwned},
        {symbol="PHM", name="PharmaHug Operations", price=289.00, trend="UP", held=phmOwned}
    }
    
    for _, st in ipairs(stocks) do
        local pnl = ISPanel:new(15, y, cw - 30, 80)
        pnl.backgroundColor = {r=0.98, g=0.98, b=0.98, a=1}
        pnl.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_L, "[" .. st.symbol .. "]", 0.3, 0.3, 0.3, 1, UIFont.Large, true))
        pnl:addChild(ISLabel:new(110, 15, S4_UI.FH_M, st.name, 0.1, 0.1, 0.1, 1, UIFont.Medium, true))
        
        local tCol = {r=0.2, g=0.7, b=0.2}
        if st.trend == "DOWN" then tCol = {r=0.8, g=0.2, b=0.2} end
        
        pnl:addChild(ISLabel:new(110, 35, S4_UI.FH_S, "Current Price: $" .. st.price .. " / share", 0.3, 0.3, 0.3, 1, UIFont.Small, true))
        pnl:addChild(ISLabel:new(110, 50, S4_UI.FH_S, "Market Trend: " .. st.trend, tCol.r, tCol.g, tCol.b, 1, UIFont.Small, true))
        
        pnl:addChild(ISLabel:new(cw - 300, 30, S4_UI.FH_M, "Shares Owned: " .. st.held, 0.1, 0.3, 0.6, 1, UIFont.Medium, true))
        
        local btnSell = ISButton:new(cw - 150, 15, 60, 30, "Sell 10", self, S4_IE_Logistics.onActionSell)
        btnSell.internal = st.symbol
        btnSell.backgroundColor = {r=0.9, g=0.9, b=0.9, a=1}
        if st.held < 10 then btnSell.enable = false end
        pnl:addChild(btnSell)
        
        local btnBuy = ISButton:new(cw - 80, 15, 60, 30, "Buy 10", self, S4_IE_Logistics.onActionBuy)
        btnBuy.internal = st.symbol
        btnBuy.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
        btnBuy.textColor = {r=1, g=1, b=1, a=1}
        pnl:addChild(btnBuy)
        
        y = y + 90
    end
end

function S4_IE_Logistics:onActionSell(btn)
    S4_PlayerStats.addStock(self.player, btn.internal, -10)
    self:switchTab({internal="Stocks"}) -- Re-render
    self.ComUI:AddMsgBox("Transaction Complete", false, "Sold 10 shares of " .. btn.internal .. " successfully.", false, false)
end

function S4_IE_Logistics:onActionBuy(btn)
    S4_PlayerStats.addStock(self.player, btn.internal, 10)
    self:switchTab({internal="Stocks"}) -- Re-render
    self.ComUI:AddMsgBox("Transaction Complete", false, "Bought 10 shares of " .. btn.internal .. " successfully.", false, false)
end

function S4_IE_Logistics:renderContracts()
    local cw = self.ContentArea:getWidth()
    self.ContentArea:addChild(ISLabel:new(15, 15, S4_UI.FH_L, "Cargo Procurement Contracts", 0.1, 0.2, 0.4, 1, UIFont.Large, true))
    self.ContentArea:addChild(ISLabel:new(15, 45, S4_UI.FH_S, "Buy raw materials in bulk for your warehouses.", 0.4, 0.4, 0.4, 1, UIFont.Small, true))
    
    local y = 80
    local pnl = ISPanel:new(15, y, cw - 30, 60)
    pnl.backgroundColor = {r=0.98, g=0.98, b=0.98, a=1}
    pnl.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
    self.ContentArea:addChild(pnl)
    
    pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "Wood Planks x500", 0.2, 0.2, 0.2, 1, UIFont.Medium, true))
    pnl:addChild(ISLabel:new(10, 30, S4_UI.FH_S, "Vendor: McCoy Logging Co.", 0.5, 0.5, 0.5, 1, UIFont.Small, true))
    
    local btnOrder = ISButton:new(cw - 220, 15, 180, 30, "Order to Muldraugh ($5,000)", self, S4_IE_Logistics.onAction)
    btnOrder.backgroundColor = self.accentColor
    btnOrder.textColor = {r=1, g=1, b=1, a=1}
    pnl:addChild(btnOrder)
end

function S4_IE_Logistics:onAction(btn)
    self.ComUI:AddMsgBox("Transaction Network", false, "Feature under development.", false, false)
end

function S4_IE_Logistics:render()
    ISPanel.render(self)
end
