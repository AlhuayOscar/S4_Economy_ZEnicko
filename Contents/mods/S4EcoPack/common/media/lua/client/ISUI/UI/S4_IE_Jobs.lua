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
        {
            name="Call Center", id="CallCenter", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.0, salary=125,
            requirements={
                {types={"Radio.Microphone", "Base.Phone", "Base.CordlessPhone"}, name="Microphone or Phone"},
                {types={"Base.Headphones", "Base.Headphones_Red"}, name="Headphones"}
            }
        },
        {
            name="Graphic Designer", id="Designer", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.1, salary=140,
            requirements={
                {types={"Base.Pen", "Base.Pencil", "Base.RedPen", "Base.BluePen"}, name="Pen/Pencil"},
                {types={"Base.SheetPaper", "Base.Notebook"}, name="Paper/Notebook"}
            }
        },
        {
            name="Insurance Seller", id="Insurance", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.2, salary=130,
            requirements={
                {types={"Base.Pen", "Base.BluePen"}, name="Pen"},
                {types={"Base.Notebook"}, name="Notebook"}
            }
        },
        {
            name="Programmer", id="Programmer", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.3, salary=160,
            requirements={
                {types={"Base.DigitalWatch", "Base.AlarmClock2"}, name="Digital Watch"}
            }
        },
        {
            name="Banker", id="Banker", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.4, salary=150,
            requirements={
                {types={"Base.Pen", "Base.RedPen"}, name="Pen"},
                {types={"Base.Notebook", "Base.SheetPaper"}, name="Paper/Notebook"}
            }
        },
        {
            name="Cleaner", id="Cleaner", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.5, salary=110,
            requirements={
                {types={"Base.Bleach"}, name="Bleach"},
                {types={"Base.DishCloth", "Base.BathTowel", "Base.KitchenTowel"}, name="Towel/Cloth"}
            }
        },
        {
            name="Journalist", id="Journalist", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.1, salary=135,
            requirements={
                {types={"Base.Camera", "Base.CameraDisposable"}, name="Camera"},
                {types={"Base.Notebook"}, name="Notebook"},
                {types={"Base.Pen", "Base.Pencil"}, name="Pen"}
            }
        },
        {
            name="Spy", id="Spy", icon="media/textures/S4_Icon/Icon_64_CallCenter.png", difficulty=1.4, salary=180,
            requirements={
                {types={"Base.Camera"}, name="Camera"},
                {types={"Radio.WalkieTalkie"}, name="Walkie Talkie"}
            }
        },
    }
end

-- ... render ... getJobLevelDetails ... isMouseOverBox ... 

function S4_IE_Jobs:onMouseDown(x, y)
    local startX, startY = 20, 20
    local col = math.floor((x - startX) / (self.gridSize + self.gridGap))
    local row = math.floor((y - startY) / (self.gridSize + self.gridGap))
    
    if col >= 0 and col < self.cols and row >= 0 and row < self.rows then
        local index = (row * self.cols) + col + 1
        local job = self.Jobs[index]
        
        if job then
            self:StartSelectedJob(job)
        end
    end
end

function S4_IE_Jobs:StartSelectedJob(job)
    local player = self.player
    local inv = player:getInventory()
    
    -- Check Requirements
    if job.requirements then
        local missing = {}
        for _, req in ipairs(job.requirements) do
            local hasItem = false
            for _, typeName in ipairs(req.types) do
                if inv:containsTypeRecurse(typeName) then
                    hasItem = true
                    break
                end
            end
            if not hasItem then
                table.insert(missing, req.name)
            end
        end
        
        if #missing > 0 then
            local msg = table.concat(missing, ", ")
            self.S4_IE.ComUI:AddMsgBox("Job Error", nil, "Missing Equipment:", msg, "Required for " .. job.name)
            return
        end
    end
    
    -- Check Fatigue
    local stats = player:getStats()
    if stats:getFatigue() > 0.5 then
         self.S4_IE.ComUI:AddMsgBox("Job Error", nil, "Too Tired to Work", "You need rest.", "")
         return
    end

    -- Close UI first as requested to access hours menu
    local player = self.player
    local computer = self.S4_IE.ComUI.ComObj
    self.S4_IE.ComUI:close()
    
    -- Open Context Menu
    local context = ISContextMenu.get(0, getMouseX() + 60, getMouseY())
    -- Pass job data to the context option
    local function makeData(h)
        return {player=player, computer=computer, hours=h, job=job}
    end
    
    context:addOption("Work 1 Hour ($" .. math.floor(job.salary/2) .. ")", makeData(1), S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption("Work 2 Hours ($" .. job.salary .. ")", makeData(2), S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption("Work 3 Hours ($" .. math.floor(job.salary*1.5) .. ")", makeData(3), S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption("Work 4 Hours ($" .. job.salary*2 .. ")", makeData(4), S4_IE_Jobs.OnSelectTimeStatic)
end

function S4_IE_Jobs.OnSelectTimeStatic(data)
    local player = data.player
    local computer = data.computer
    local hours = data.hours
    ISTimedActionQueue.add(S4_Action_Job_CallCenter:new(player, computer, hours))
end
