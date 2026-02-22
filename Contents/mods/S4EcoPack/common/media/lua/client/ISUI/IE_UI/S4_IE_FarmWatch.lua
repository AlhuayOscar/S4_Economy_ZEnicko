S4_IE_FarmWatch = ISPanel:derive("S4_IE_FarmWatch")

function S4_IE_FarmWatch:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.9, g=0.95, b=0.9, a=1} -- Greenish tint
    o.borderColor = {r=0.2, g=0.4, b=0.2, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_FarmWatch:initialise()
    ISPanel.initialise(self)
end

function S4_IE_FarmWatch:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self.Banner.borderColor = {r=0.1, g=0.3, b=0.1, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "FARMWATCH AGROSYSTEMS", 1, 1, 1, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Market prices, supplies, and crop logistics.", 0.8, 1, 0.8, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.98, g=1, b=0.98, a=1}
    self.ContentArea.borderColor = {r=0.5, g=0.7, b=0.5, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Current Commodity Prices (per crate):", 0.1, 0.3, 0.1, 1, UIFont.Medium, true))
    y = y + 30
    
    local crops = {
        {name="Cabbage", price=450},
        {name="Potatoes", price=620},
        {name="Tomatoes", price=380}
    }
    
    for _, c in ipairs(crops) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 40)
        pnl.backgroundColor = {r=0.95, g=0.95, b=0.95, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_S, c.name, 0.2, 0.2, 0.2, 1, UIFont.Small, true))
        pnl:addChild(ISLabel:new(150, 10, S4_UI.FH_M, "$" .. c.price, 0.1, 0.5, 0.1, 1, UIFont.Medium, true))
        
        local sellBtn = ISButton:new(pnl:getWidth() - 100, 5, 90, 30, "Sell Crate", self, S4_IE_FarmWatch.onDebug)
        pnl:addChild(sellBtn)
        
        y = y + 50
    end
    
    y = y + 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Agricultural Supplies:", 0.1, 0.3, 0.1, 1, UIFont.Medium, true))
    y = y + 30
    
    local buyBtn = ISButton:new(20, y, 200, 30, "Buy NPK Fertilizer ($200)", self, S4_IE_FarmWatch.onDebug)
    self.ContentArea:addChild(buyBtn)
end

function S4_IE_FarmWatch:onDebug(btn)
    self.ComUI:AddMsgBox("FarmWatch System", false, "[DEBUG] Agricultural transaction triggered.", false, false)
end

function S4_IE_FarmWatch:render()
    ISPanel.render(self)
end
