S4_IE_Weather = ISPanel:derive("S4_IE_Weather")

function S4_IE_Weather:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.8, g=0.9, b=0.95, a=1} -- Light sky blue
    o.borderColor = {r=0.3, g=0.4, b=0.6, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Weather:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Weather:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.2, g=0.4, b=0.7, a=1}
    self.Banner.borderColor = {r=0.1, g=0.3, b=0.5, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "KNOX WEATHER SERVICE", 1, 1, 1, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Because knowing is half the battle.", 0.8, 0.9, 1, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.95, g=0.98, b=1, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Current Local Conditions:", 0.2, 0.3, 0.5, 1, UIFont.Medium, true))
    y = y + 40
    
    local wtPnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 100)
    wtPnl.backgroundColor = {r=1, g=1, b=1, a=1}
    wtPnl.borderColor = {r=0.7, g=0.8, b=0.9, a=1}
    self.ContentArea:addChild(wtPnl)
    
    wtPnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "Temperature: 24°C / 75°F", 0.1, 0.1, 0.1, 1, UIFont.Medium, true))
    wtPnl:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "Precipitation: 0% (Clear)", 0.3, 0.3, 0.3, 1, UIFont.Small, true))
    wtPnl:addChild(ISLabel:new(10, 65, S4_UI.FH_S, "Wind: 10mph NNE", 0.3, 0.3, 0.3, 1, UIFont.Small, true))

    local refBtn = ISButton:new(wtPnl:getWidth() - 110, 60, 90, 30, "Refresh Data", self, S4_IE_Weather.onDebug)
    wtPnl:addChild(refBtn)
    
    y = y + 120
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "48-Hour Forecast:", 0.2, 0.3, 0.5, 1, UIFont.Medium, true))
    y = y + 30
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_S, "Tomorrow: Heavy Thunderstorms. Helicopter activity expected.", 0.2, 0.2, 0.2, 1, UIFont.Small, true))
end

function S4_IE_Weather:onDebug(btn)
    self.ComUI:AddMsgBox("Weather Uplink", false, "[DEBUG] Connecting to remote sensor...", false, false)
end

function S4_IE_Weather:render()
    ISPanel.render(self)
end
