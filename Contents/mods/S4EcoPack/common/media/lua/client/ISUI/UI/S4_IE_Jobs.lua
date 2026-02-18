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
    
    self.Jobs = {
        {name="Call Center", id="CallCenter", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.0},
        {name="Graphic Designer", id="Designer", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.1},
        {name="Insurance Seller", id="Insurance", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.2},
        {name="Programmer", id="Programmer", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.3},
        {name="Banker", id="Banker", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.4},
        {name="Cleaner", id="Cleaner", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.5},
        {name="Journalist", id="Journalist", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.1},
        {name="Spy", id="Spy", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.4},
    }
end

function S4_IE_Jobs:render()
    ISPanel.render(self)
    
    local x, y = 20, 20
    local index = 1
    
    -- Draw Job Grid
    for r = 1, self.rows do
        for c = 1, self.cols do
            local job = self.Jobs[index]
            
            if job then
                -- Box background
                self:drawRect(x, y, self.gridSize, self.gridSize, 1, 0.9, 0.9, 0.9)
                self:drawRectBorder(x, y, self.gridSize, self.gridSize, 1, 0.5, 0.5, 0.5)
                
                -- Icon
                local tex = getTexture(job.icon)
                if not tex then tex = getTexture("media/textures/S4_Icon/Icon_64_Network.png") end
                
                if tex then
                    self:drawTextureScaled(tex, x + 8, y + 8, 48, 48, 1)
                else
                    self:drawTextCentre(job.name, x + 32, y + 24, 0, 0, 0, 1, UIFont.Small)
                end
                
                -- Hover effect
                if self:isMouseOverBox(x, y, self.gridSize, self.gridSize) then
                     self:drawRect(x, y, self.gridSize, self.gridSize, 0.2, 0, 0, 1)
                     
                     -- Tooltip Data
                     local pData = self.player:getModData()
                     local xp = pData["S4_Job_" .. job.id .. "_Hours"] or 0
                     local details = self:GetJobLevelDetails(xp, job.difficulty)
                     
                     -- Tooltip Logic
                     local tooltipH = 70
                     local tooltipY = self.height - tooltipH - 10
                     
                     self:drawText("Job: " .. job.name, 20, tooltipY + 5, 0, 0, 0, 1, UIFont.Medium)
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
                     
                     self:drawRect(barX, barY, barW, barH, 1, 0.8, 0.8, 0.8)
                     self:drawRectBorder(barX, barY, barW, barH, 1, 0.3, 0.3, 0.3)
                     self:drawRect(barX, barY, barW * progress, barH, 1, 0.2, 0.8, 0.2)
                     
                     self:drawText("Lv " .. details.level, barX + barW + 10, barY - 2, 0, 0, 0, 1, UIFont.Small)
                     
                     if details.max then
                        local remaining = math.ceil(details.max - xp)
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

function S4_IE_Jobs:GetJobLevelDetails(xp, difficulty)
    -- Base thresholds extended by Difficulty
    local function t(val) return math.ceil(val * difficulty) end
    
    local thresholds = {
        t(150), t(400), t(900), t(1600), t(2500), 
        t(4000), t(6000), t(9000), t(13000)
    }
    
    local ranks = {
        "Intern", "Junior", "Senior", "Supervisor", "Manager",
        "Team Leader", "Dept. Head", "Director", "VP", "CEO"
    }

    if xp < thresholds[1] then return {level=1, min=0, max=thresholds[1], rank=ranks[1]} end
    for i=1, 8 do
        if xp < thresholds[i+1] then
            return {level=i+1, min=thresholds[i], max=thresholds[i+1], rank=ranks[i+1]}
        end
    end
    return {level=10, min=thresholds[9], max=nil, rank=ranks[10]} 
end

function S4_IE_Jobs:isMouseOverBox(x, y, w, h)
    local mx = self:getMouseX()
    local my = self:getMouseY()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function S4_IE_Jobs:onMouseDown(x, y)
    local startX, startY = 20, 20
    local col = math.floor((x - startX) / (self.gridSize + self.gridGap))
    local row = math.floor((y - startY) / (self.gridSize + self.gridGap))
    
    if col >= 0 and col < self.cols and row >= 0 and row < self.rows then
        local index = (row * self.cols) + col + 1
        local job = self.Jobs[index]
        
        if job then
            if job.id == "CallCenter" then
                self:StartCallCenterJob()
            else
                self.S4_IE.ComUI:AddMsgBox("Job Info", nil, "Coming Soon:", job.name .. " is under construction.", "")
            end
        end
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
    
    -- Open Context Menu - Offset by 60px to prevent accidental selection
    local context = ISContextMenu.get(0, getMouseX() + 60, getMouseY())
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
