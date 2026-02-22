S4_IE_Taxes = ISPanel:derive("S4_IE_Taxes")

function S4_IE_Taxes:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.95, g=0.92, b=0.88, a=1} -- Paper-like official IRS style
    o.borderColor = {r=0.4, g=0.3, b=0.2, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Taxes:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Taxes:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- Banner (Knox regional Gov)
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.2, g=0.2, b=0.3, a=1} -- Gov Blue/Grey
    self.Banner.borderColor = {r=0.1, g=0.1, b=0.2, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "KNOX REGIONAL TAX AUTHORITY", 0.9, 0.9, 0.9, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Department of Revenue & Civil Contributions", 0.6, 0.6, 0.7, 1, UIFont.Small, true))

    -- Main Content Area
    self.ContentArea = ISScrollingListBox:new(20, 80, w - 40, h - 100)
    self.ContentArea.backgroundColor = {r=1, g=1, b=0.98, a=1}
    self.ContentArea.borderColor = {r=0.7, g=0.7, b=0.6, a=1}
    self.ContentArea:initialise()
    self.ContentArea:instantiate()
    self:addChild(self.ContentArea)
    
    local cW = self.ContentArea:getWidth()
    
    self.ContentArea:addChild(ISLabel:new(20, 20, S4_UI.FH_L, "Taxpayer Identity", 0.2, 0.2, 0.2, 1, UIFont.Large, true))
    
    local playerID = self.player:getUsername()
    self.ContentArea:addChild(ISLabel:new(20, 60, S4_UI.FH_M, "Name / SSN: " .. playerID, 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
    self.ContentArea:addChild(ISLabel:new(20, 85, S4_UI.FH_M, "Filing Status: UNPAID (DELINQUENT)", 0.8, 0, 0, 1, UIFont.Medium, true))
    self.ContentArea:addChild(ISLabel:new(20, 110, S4_UI.FH_M, "Current Address: Exclusion Zone", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
    
    -- Decorative line
    self.ContentArea.render = function(pnl)
        ISPanel.render(pnl)
        pnl:drawRect(20, 140, pnl:getWidth() - 40, 2, 1, 0.8, 0.8, 0.8)
    end
    
    self.ContentArea:addChild(ISLabel:new(20, 160, S4_UI.FH_L, "Assessments & Penalties", 0.2, 0.2, 0.2, 1, UIFont.Large, true))
    
    local y = 200
    
    -- Mock Penalties list
    local taxes = {
        {name="Property Tax (Safehouse)", amount=1500, due="01/01/1994"},
        {name="Vehicle Registration Penalties", amount=850, due="Immediate"},
        {name="Capital Gains (Trader Union)", amount=3400, due="Immediate"}
    }
    
    local total = 0
    for _, t in ipairs(taxes) do
        local pnl = ISPanel:new(20, y, cW - 40, 40)
        pnl.backgroundColor = {r=0.98, g=0.95, b=0.9, a=1}
        pnl.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, t.name, 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
        pnl:addChild(ISLabel:new(cW - 250, 10, S4_UI.FH_M, "$" .. t.amount, 0.8, 0.2, 0.2, 1, UIFont.Medium, true))
        pnl:addChild(ISLabel:new(cW - 150, 10, S4_UI.FH_S, "Due: " .. t.due, 0.5, 0.5, 0.5, 1, UIFont.Small, true))
        
        total = total + t.amount
        y = y + 50
    end
    
    -- Summary Bottom
    local sumPnl = ISPanel:new(20, y + 20, cW - 40, 80)
    sumPnl.backgroundColor = {r=0.9, g=0.9, b=0.85, a=1}
    sumPnl.borderColor = {r=0.6, g=0.5, b=0.4, a=1}
    self.ContentArea:addChild(sumPnl)
    
    sumPnl:addChild(ISLabel:new(20, 15, S4_UI.FH_L, "TOTAL DUE:", 0.1, 0.1, 0.1, 1, UIFont.Large, true))
    sumPnl:addChild(ISLabel:new(200, 15, S4_UI.FH_L, "$" .. S4_UI.getNumCommas(total), 0.8, 0, 0, 1, UIFont.Large, true))
    sumPnl:addChild(ISLabel:new(20, 50, S4_UI.FH_S, "Note: Failure to pay will result in Karma decimation and Military deployment.", 0.6, 0.2, 0.2, 1, UIFont.Small, true))
    
    local btnPay = ISButton:new(cW - 220, y + 35, 180, 40, "Submit Payment ($5750)", self, S4_IE_Taxes.onPay)
    btnPay.backgroundColor = {r=0.2, g=0.5, b=0.8, a=1}
    btnPay.textColor = {r=1, g=1, b=1, a=1}
    btnPay:initialise()
    self.ContentArea:addChild(btnPay)
    
    self.ContentArea:setScrollHeight(y + 140)
end

function S4_IE_Taxes:onPay(btn)
    self.ComUI:AddMsgBox("Payment Processing Error", false, "Your bank account has been frozen by Knox authorities.", false, false)
end

function S4_IE_Taxes:render()
    ISPanel.render(self)
end
