S4_IE_Repair = ISPanel:derive("S4_IE_Repair")

function S4_IE_Repair:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.8, g=0.8, b=0.8, a=1} -- Grey steel theme
    o.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Repair:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Repair:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.85, g=0.6, b=0.1, a=1} -- Warning yellow/orange
    self.Banner.borderColor = {r=0.5, g=0.3, b=0.05, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "HANDYMAN ONLINE", 0.1, 0.1, 0.1, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Mail us your broken gear. We'll fix it.", 0.2, 0.2, 0.2, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.95, g=0.95, b=0.95, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Current Inventory Condition:", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
    y = y + 40
    
    local eq = {
        {name="Machete", cond="10%", cost=120},
        {name="Double Barrel Shotgun", cond="45%", cost=350},
        {name="Axe", cond="0%", cost=500}
    }
    
    for _, item in ipairs(eq) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 45)
        pnl.backgroundColor = {r=0.9, g=0.9, b=0.9, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, item.name .. " (Cond: " .. item.cond .. ")", 0.2, 0.2, 0.2, 1, UIFont.Medium, true))
        
        local rBtn = ISButton:new(pnl:getWidth() - 160, 5, 150, 35, "Full Repair ($" .. item.cost .. ")", self, S4_IE_Repair.onDebug)
        rBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
        rBtn.textColor = {r=1, g=1, b=1, a=1}
        rBtn:initialise()
        pnl:addChild(rBtn)
        
        y = y + 55
    end
end

function S4_IE_Repair:onDebug(btn)
    self.ComUI:AddMsgBox("Repair Service", false, "[DEBUG] Item fully restored.", false, false)
end

function S4_IE_Repair:render()
    ISPanel.render(self)
end
