S4_IE_Recover = ISPanel:derive("S4_IE_Recover")

function S4_IE_Recover:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.1, g=0.1, b=0.1, a=1} -- Dark gray theme
    o.borderColor = {r=0.6, g=0.2, b=0.2, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Recover:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Recover:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.4, g=0.1, b=0.1, a=1}
    self.Banner.borderColor = {r=0.8, g=0.2, b=0.2, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "BODY RECOVERY SERVICES", 1, 1, 1, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "We go where you died. So you don't have to.", 0.8, 0.8, 0.8, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.15, g=0.15, b=0.15, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Locating recent casualty tokens...", 0.6, 0.6, 0.6, 1, UIFont.Medium, true))
    y = y + 40
    
    local corpses = {
        {name="Previous Survivor (You)", items=25, price=10000},
        {name="Unknown Thug", items=4, price=500}
    }
    
    for _, c in ipairs(corpses) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 50)
        pnl.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_S, c.name, 0.8, 0.3, 0.3, 1, UIFont.Small, true))
        pnl:addChild(ISLabel:new(10, 25, S4_UI.FH_S, "Est. Items: " .. c.items, 0.5, 0.5, 0.5, 1, UIFont.Small, true))
        
        local btnRec = ISButton:new(pnl:getWidth() - 180, 10, 170, 30, "Dispatch Team ($" .. c.price .. ")", self, S4_IE_Recover.onDebug)
        btnRec.backgroundColor = {r=0.5, g=0.1, b=0.1, a=1}
        btnRec.textColor = {r=1, g=1, b=1, a=1}
        pnl:addChild(btnRec)
        
        y = y + 60
    end
end

function S4_IE_Recover:onDebug(btn)
    self.ComUI:AddMsgBox("Recovery Service", false, "[DEBUG] Team dispatched. Gear will be delivered to stash.", false, false)
end

function S4_IE_Recover:render()
    ISPanel.render(self)
end
