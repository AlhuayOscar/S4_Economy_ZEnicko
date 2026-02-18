require "ISUI/ISPanel"

S4_IE_Jobs = ISPanel:derive("S4_IE_Jobs")

function S4_IE_Jobs:new(S4_IE, x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.S4_IE = S4_IE
    o.player = S4_IE.player
    o.backgroundColor = {r=1, g=1, b=1, a=1}
    o.borderColor = {r=0, g=0, b=0, a=1}
    return o
end

function S4_IE_Jobs:initialise()
    ISPanel.initialise(self)
    self.gridSize = 64
    self.gridGap = 10
    self.cols = 4
    self.rows = 3
end

function S4_IE_Jobs:render()
    ISPanel.render(self)
    
    local x, y = 20, 20
    local index = 1
    
    -- Draw Job Grid
    for r = 1, self.rows do
        for c = 1, self.cols do
            -- Box background
            self:drawRect(x, y, self.gridSize, self.gridSize, 1, 0.9, 0.9, 0.9)
            self:drawRectBorder(x, y, self.gridSize, self.gridSize, 1, 0.5, 0.5, 0.5)
            
            -- First Item: Call Center
            if index == 1 then
                -- Draw Icon
                -- User requested Microphone Icon from S4_Icon
                local tex = getTexture("media/textures/S4_Icon/Icon_64_CallCenter.png") 
                if not tex then tex = getTexture("media/textures/S4_Icon/Icon_64_Network.png") end -- Fallback

                if tex then
                    self:drawTextureScaled(tex, x + 8, y + 8, 48, 48, 1)
                else
                     -- Manual centering to avoid nil error on drawTextCentre
                     local text1 = "Call"
                     local text2 = "Center"
                     local font = UIFont.Small
                     local w1 = getTextManager():MeasureStringX(font, text1)
                     local w2 = getTextManager():MeasureStringX(font, text2)
                     self:drawText(text1, x + (self.gridSize/2) - (w1/2), y + 16, 0, 0, 0, 1, font)
                     self:drawText(text2, x + (self.gridSize/2) - (w2/2), y + 32, 0, 0, 0, 1, font)
                end
                
                -- Hover effect
                if self:isMouseOverBox(x, y, self.gridSize, self.gridSize) then
                     self:drawRect(x, y, self.gridSize, self.gridSize, 0.2, 0, 0, 1)
                     self:drawText("Call Center Part Time", 20, self.height - 40, 0, 0, 0, 1, UIFont.Small)
                end
            end
            
            x = x + self.gridSize + self.gridGap
            index = index + 1
        end
        x = 20
        y = y + self.gridSize + self.gridGap
    end
end

function S4_IE_Jobs:isMouseOverBox(x, y, w, h)
    local mx = self:getMouseX()
    local my = self:getMouseY()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function S4_IE_Jobs:onMouseDown(x, y)
    -- Check if clicked first box
    local boxX, boxY = 20, 20
    if x >= boxX and x <= boxX + self.gridSize and y >= boxY and y <= boxY + self.gridSize then
        self:StartCallCenterJob()
    end
end

function S4_IE_Jobs:StartCallCenterJob()
    local player = self.player
    local inv = player:getInventory()
    
    -- Requirements
    -- 1. Microphone or Phone
    local hasMic = inv:containsTypeRecurse("Radio.Microphone") or inv:containsTypeRecurse("Base.Phone") or inv:containsTypeRecurse("Base.CordlessPhone")
    -- 2. Headphones (Big or Red)
    local hasHeadphones = inv:containsTypeRecurse("Base.Headphones") or inv:containsTypeRecurse("Base.Headphones_Red")
    
    if not hasMic or not hasHeadphones then
        self.S4_IE.ComUI:AddMsgBox("Job Error", nil, "Missing Equipment:", "Microphone/Phone + Headphones", "Required")
        return
    end
    
    -- Check Fatigue (Must be < 50 to start? "el grado minimo que debe ser -50")
    -- Interpretation: Must not be too tired.
    local stats = player:getStats()
    if stats:getFatigue() > 0.5 then
         self.S4_IE.ComUI:AddMsgBox("Job Error", nil, "Too Tired to Work", "You need rest.", "")
         return
    end

    -- Create Buttons for duration (In-UI to avoid Z-order issues)
    self:CreateDurationButtons()
end

function S4_IE_Jobs:CreateDurationButtons()
    if self.DurationBtns then return end -- Already open
    
    self.DurationBtns = {}
    local btnW, btnH = 100, 25
    local startY = (self.height / 2) - ((btnH * 5) / 2)
    local centerX = (self.width / 2) - (btnW / 2)
    
    -- Background blocker (optional, but good for UX)
    -- Just treating it as a state implicitly
    
    for i=1, 4 do
        local btn = ISButton:new(centerX, startY + (i-1)*(btnH+5), btnW, btnH, "Work " .. i .. " Hour(s)", self, S4_IE_Jobs.OnDurationClick)
        btn.internal = i
        btn:initialise()
        btn:instantiate()
        btn.borderColor = {r=1, g=1, b=1, a=1}
        self:addChild(btn)
        table.insert(self.DurationBtns, btn)
    end
    
    -- Cancel Button
    local cancelBtn = ISButton:new(centerX, startY + 4*(btnH+5), btnW, btnH, "Cancel", self, S4_IE_Jobs.CloseDurationMenu)
    cancelBtn:initialise()
    cancelBtn:instantiate()
    cancelBtn.borderColor = {r=1, g=0, b=0, a=1}
    self:addChild(cancelBtn)
    table.insert(self.DurationBtns, cancelBtn)
end

function S4_IE_Jobs:CloseDurationMenu()
    if self.DurationBtns then
        for _, btn in ipairs(self.DurationBtns) do
            self:removeChild(btn)
        end
        self.DurationBtns = nil
    end
end

function S4_IE_Jobs:OnDurationClick(button)
    self:CloseDurationMenu()
    self:OnSelectTime(button.internal)
end

function S4_IE_Jobs:OnSelectTime(hours)
    local player = self.player
    -- Calculate stats per hour
    -- Hunger: 12.5 per hour (Total 50 for 4 hours)
    -- Thirst: 6.25 per hour (Total 25 for 4 hours)
    -- Fatigue: 12.5 per hour (Total 50 for 4 hours)
    -- Stress: 11.25 per hour (Total 45 for 4 hours)
    
    local computer = self.S4_IE.ComUI.ComObj
    ISTimedActionQueue.add(S4_Action_Job_CallCenter:new(player, computer, hours))
    self.S4_IE:close() -- Close browser while working? Or keep open? Usually better to close or minimize.
end
