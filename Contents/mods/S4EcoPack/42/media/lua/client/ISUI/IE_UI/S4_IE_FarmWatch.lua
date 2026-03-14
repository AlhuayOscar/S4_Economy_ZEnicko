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
    o.isSubscribed = false -- Can be hooked up to S4_PlayerStats later
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
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Satellite crop analysis and zone monitoring.", 0.8, 1, 0.8, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.98, g=1, b=0.98, a=1}
    self.ContentArea.borderColor = {r=0.5, g=0.7, b=0.5, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    
    if not self.isSubscribed then
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_L, "Subscription Required", 0.6, 0.1, 0.1, 1, UIFont.Large, true))
        y = y + 40
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "FarmWatch Premium allows you to track crop yields, hydration,", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
        y = y + 25
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "and diseases globally in real time using satellite scans.", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
        y = y + 40
        
        local btnSub = ISButton:new(20, y, 250, 40, "Subscribe ($500/mo)", self, S4_IE_FarmWatch.onSub)
        btnSub.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
        btnSub.textColor = {r=1, g=1, b=1, a=1}
        btnSub:initialise()
        self.ContentArea:addChild(btnSub)
    else
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Active Scans: Knox County Agricultural Blocks", 0.1, 0.4, 0.1, 1, UIFont.Medium, true))
        y = y + 30
        
        local zones = {
            {name="Rosewood Southern Farms", crop="Cabbage", hyd="45%", risk="High (Aphids)", yield="Low"},
            {name="Muldraugh Hidden Cabin", crop="Potatoes", hyd="80%", risk="None", yield="Excellent"},
            {name="Valley Station Central", crop="Carrots", hyd="12%", risk="Severe (Drought)", yield="Failing"}
        }
        
        for _, z in ipairs(zones) do
            local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 90)
            pnl.backgroundColor = {r=0.95, g=0.98, b=0.95, a=1}
            pnl.borderColor = {r=0.7, g=0.8, b=0.7, a=1}
            self.ContentArea:addChild(pnl)
            
            pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "Zone: " .. z.name, 0.2, 0.5, 0.2, 1, UIFont.Medium, true))
            pnl:addChild(ISLabel:new(10, 35, S4_UI.FH_S, "Primary Crop: " .. z.crop, 0.3, 0.3, 0.3, 1, UIFont.Small, true))
            
            local cHyd = {r=0.2, g=0.5, b=0.8}
            if z.hyd == "12%" then cHyd = {r=0.8, g=0.2, b=0.2} end
            pnl:addChild(ISLabel:new(250, 35, S4_UI.FH_S, "Hydration Level: " .. z.hyd, cHyd.r, cHyd.g, cHyd.b, 1, UIFont.Small, true))
            
            pnl:addChild(ISLabel:new(10, 55, S4_UI.FH_S, "Disease Risk: " .. z.risk, 0.6, 0.3, 0.1, 1, UIFont.Small, true))
            pnl:addChild(ISLabel:new(250, 55, S4_UI.FH_S, "Estimated Yield: " .. z.yield, 0.3, 0.5, 0.2, 1, UIFont.Small, true))
            
            y = y + 100
        end
    end
end

function S4_IE_FarmWatch:onSub(btn)
    self.isSubscribed = true
    self.ContentArea:clearChildren()
    self:createChildren()
    self.ComUI:AddMsgBox("FarmWatch Premium", false, "Subscription activated! Launching satellite interface.", false, false)
end

function S4_IE_FarmWatch:render()
    ISPanel.render(self)
end
