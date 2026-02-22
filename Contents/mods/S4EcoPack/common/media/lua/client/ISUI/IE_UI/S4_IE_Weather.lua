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
    o.isSubscribed = false
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
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Meteorological forecasting and 7-day climatic predictions.", 0.8, 0.9, 1, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.95, g=0.98, b=1, a=1}
    self.ContentArea.borderColor = {r=0.6, g=0.7, b=0.8, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    
    if not self.isSubscribed then
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_L, "Premium Weather Access ($250/mo)", 0.2, 0.3, 0.5, 1, UIFont.Large, true))
        y = y + 40
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Unlock 7-day hourly precision forecasts.", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
        y = y + 25
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Predict storms, snow, and military helicopter movements with 85% accuracy.", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
        
        y = y + 40
        local btnSub = ISButton:new(20, y, 200, 40, "Subscribe Now", self, S4_IE_Weather.onSub)
        btnSub.backgroundColor = {r=0.2, g=0.4, b=0.8, a=1}
        btnSub.textColor = {r=1, g=1, b=1, a=1}
        btnSub:initialise()
        self.ContentArea:addChild(btnSub)
    else
        self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_L, "7-Day Advanced Forecast (85% Precision)", 0.2, 0.3, 0.5, 1, UIFont.Large, true))
        y = y + 40
        
        local forecast = {
            {day="MON", temp="12°C", cond="Cloudy", desc="Overcast. Low wind speeds."},
            {day="TUE", temp="9°C", cond="Rain", desc="Heavy precipitation beginning 14:00."},
            {day="WED", temp="8°C", cond="Storm", desc="Severe thunderstorms. Power grid risk."},
            {day="THU", temp="15°C", cond="Clear", desc="Sunny. High visibility."},
            {day="FRI", temp="14°C", cond="Fog", desc="Thick morning fog. Visibility < 50m."},
            {day="SAT", temp="2°C", cond="Snow", desc="First snowfall expected at midnight."},
            {day="SUN", temp="-5°C", cond="Blizzard", desc="Dangerous cold. Seek shelter immediately."}
        }
        
        for _, day in ipairs(forecast) do
            local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 50)
            pnl.backgroundColor = {r=1, g=1, b=1, a=1}
            pnl.borderColor = {r=0.8, g=0.85, b=0.9, a=1}
            self.ContentArea:addChild(pnl)
            
            pnl:addChild(ISLabel:new(10, 15, S4_UI.FH_M, day.day, 0.1, 0.1, 0.4, 1, UIFont.Medium, true))
            pnl:addChild(ISLabel:new(80, 15, S4_UI.FH_M, day.temp, 0.6, 0.2, 0.2, 1, UIFont.Medium, true))
            pnl:addChild(ISLabel:new(160, 15, S4_UI.FH_M, day.cond, 0.3, 0.4, 0.6, 1, UIFont.Medium, true))
            
            pnl:addChild(ISLabel:new(300, 18, S4_UI.FH_S, day.desc, 0.4, 0.4, 0.4, 1, UIFont.Small, true))
            
            local viewBtn = ISButton:new(pnl:getWidth() - 120, 10, 110, 30, "Hourly Breakdown", self, S4_IE_Weather.onHourly)
            viewBtn:initialise()
            pnl:addChild(viewBtn)
            
            y = y + 60
        end
    end
end

function S4_IE_Weather:onHourly(btn)
    self.ComUI:AddMsgBox("Weather Uplink", false, "[DEBUG] Detailed hourly forecast generated.", false, false)
end

function S4_IE_Weather:onSub(btn)
    self.isSubscribed = true
    self.ContentArea:clearChildren()
    self:createChildren()
    self.ComUI:AddMsgBox("Subscription Active", false, "Advanced meteorological models unlocked.", false, false)
end

function S4_IE_Weather:render()
    ISPanel.render(self)
end
