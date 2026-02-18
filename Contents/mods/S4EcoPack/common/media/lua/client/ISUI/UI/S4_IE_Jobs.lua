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
                     
                     local pData = self.player:getModData()
                     local xp = pData.S4_Job_CallCenter_Hours or 0
                     local details = self:GetCallCenterLevelDetails(xp)
                     
                     -- Tooltip Background
                     local tooltipH = 70
                     local tooltipY = self.height - tooltipH - 10
                     -- self:drawRect(15, tooltipY, 200, tooltipH, 0.8, 0, 0, 0) -- Optional bg
                     
                     self:drawText("Job: Call Center", 20, tooltipY + 5, 0, 0, 0, 1, UIFont.Medium)
                     self:drawText("Rank: " .. details.rank, 20, tooltipY + 25, 0, 0, 0.6, 1, UIFont.Small)
                     
                     -- Progress Bar
                     local barW = 150
                     local barH = 10
                     local barX = 20
                     local barY = tooltipY + 45
                     
                     local progress = 0
                     if details.max then
                        progress = (xp - details.min) / (details.max - details.min)
                        if progress > 1 then progress = 1 end
                        if progress < 0 then progress = 0 end
                     else
                        progress = 1
                     end
                     
                     -- Draw Bar Background
                     self:drawRect(barX, barY, barW, barH, 1, 0.8, 0.8, 0.8)
                     self:drawRectBorder(barX, barY, barW, barH, 1, 0.3, 0.3, 0.3)
                     -- Draw Progress
                     self:drawRect(barX, barY, barW * progress, barH, 1, 0.2, 0.8, 0.2)
                     
                     -- Draw Level Number
                     self:drawText("Lv " .. details.level, barX + barW + 10, barY - 2, 0, 0, 0, 1, UIFont.Small)
                     
                     -- Draw XP Remaining
                     if details.max then
                        local remaining = details.max - xp
                        self:drawText("Next Level: " .. remaining .. " XP", 20, barY + 12, 0, 0, 0.6, 1, UIFont.Small)
                     else
                        self:drawText("Max Level Reached", 20, barY + 12, 0, 0, 0.6, 1, UIFont.Small)
                     end
                end
            end
            
            x = x + self.gridSize + self.gridGap
            index = index + 1
        end
        x = 20
        y = y + self.gridSize + self.gridGap
    end
end

function S4_IE_Jobs:GetCallCenterLevelDetails(xp)
    if xp < 150 then return {level=1, min=0, max=150, rank="Intern"}
    elseif xp < 400 then return {level=2, min=150, max=400, rank="Junior"}
    elseif xp < 900 then return {level=3, min=400, max=900, rank="Senior"}
    elseif xp < 1600 then return {level=4, min=900, max=1600, rank="Supervisor"}
    elseif xp < 2500 then return {level=5, min=1600, max=2500, rank="Manager"}
    elseif xp < 4000 then return {level=6, min=2500, max=4000, rank="Team Leader"}
    elseif xp < 6000 then return {level=7, min=4000, max=6000, rank="Dept. Head"}
    elseif xp < 9000 then return {level=8, min=6000, max=9000, rank="Director"}
    elseif xp < 13000 then return {level=9, min=9000, max=13000, rank="VP"}
    else return {level=10, min=13000, max=nil, rank="CEO"} end
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

    -- Close UI first as requested to access hours menu
    local player = self.player
    local computer = self.S4_IE.ComUI.ComObj
    self.S4_IE.ComUI:close()
    
    -- Open Context Menu - Offset by 20px to prevent accidental selection
    local context = ISContextMenu.get(0, getMouseX() + 20, getMouseY() + 20)
    local data1 = {player=player, computer=computer, hours=1}
    local data2 = {player=player, computer=computer, hours=2}
    local data3 = {player=player, computer=computer, hours=3}
    local data4 = {player=player, computer=computer, hours=4}
    
    context:addOption("Work 1 Hour", data1, S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption("Work 2 Hours", data2, S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption("Work 3 Hours", data3, S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption("Work 4 Hours", data4, S4_IE_Jobs.OnSelectTimeStatic)
end

function S4_IE_Jobs.OnSelectTimeStatic(data)
    local player = data.player
    local computer = data.computer
    local hours = data.hours
    ISTimedActionQueue.add(S4_Action_Job_CallCenter:new(player, computer, hours))
end
