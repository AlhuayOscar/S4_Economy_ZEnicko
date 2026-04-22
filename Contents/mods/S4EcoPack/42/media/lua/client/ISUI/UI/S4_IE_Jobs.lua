require "ISUI/ISPanel"

S4_IE_Jobs = ISPanel:derive("S4_IE_Jobs")

local function jobText(key, fallback)
    local text = getText(key)
    if text == key or text == ("[" .. key .. "]") then
        return fallback or key
    end
    return text
end

local function safeGetPlayerFatigue(player)
    if not player or not player.getStats then
        return 0
    end

    local stats = player:getStats()
    if stats and stats.getFatigue then
        local fatigue = stats:getFatigue()
        if fatigue then
            return fatigue
        end
    end

    return 0
end

local function getJobPayForLevel(jobSalary2h, level)
    local salaryMultiplier = 1.0
    if (level or 1) >= 9 then
        salaryMultiplier = 3.5
    elseif (level or 1) >= 6 then
        salaryMultiplier = 2.5
    elseif (level or 1) >= 3 then
        salaryMultiplier = 2.0
    end
    return math.floor((jobSalary2h or 125) * salaryMultiplier), salaryMultiplier
end

local function getJobLevelDetailsForXp(xp, difficulty)
    local function t(val)
        return math.ceil(val * (difficulty or 1.0))
    end

    local thresholds = {t(150), t(400), t(900), t(1600), t(2500), t(4000), t(6000), t(9000), t(13000)}
    local ranks = {
        jobText("IGUI_S4_Jobs_Rank_1", "Intern"),
        jobText("IGUI_S4_Jobs_Rank_2", "Junior"),
        jobText("IGUI_S4_Jobs_Rank_3", "Senior"),
        jobText("IGUI_S4_Jobs_Rank_4", "Supervisor"),
        jobText("IGUI_S4_Jobs_Rank_5", "Manager"),
        jobText("IGUI_S4_Jobs_Rank_6", "Team Leader"),
        jobText("IGUI_S4_Jobs_Rank_7", "Dept. Head"),
        jobText("IGUI_S4_Jobs_Rank_8", "Director"),
        jobText("IGUI_S4_Jobs_Rank_9", "VP"),
        jobText("IGUI_S4_Jobs_Rank_10", "CEO")
    }

    xp = xp or 0
    if xp < thresholds[1] then
        return {
            level = 1,
            min = 0,
            max = thresholds[1],
            rank = ranks[1]
        }
    end
    for i = 1, 8 do
        if thresholds[i + 1] and xp < thresholds[i + 1] then
            return {
                level = i + 1,
                min = thresholds[i],
                max = thresholds[i + 1],
                rank = ranks[i + 1]
            }
        end
    end
    return {
        level = 10,
        min = thresholds[9] or 13000,
        max = nil,
        rank = ranks[10]
    }
end

local function getBrokerBonusRange(player)
    if not player or not player.getModData then
        return nil
    end

    local pData = player:getModData()
    local brokerXP = pData["S4_Job_Broker_Hours"] or 0
    if brokerXP <= 0 then
        return nil
    end

    local details = getJobLevelDetailsForXp(brokerXP, 1.6)
    if details.level >= 6 then
        return 60, 140, details.level
    end
    return 20, 60, details.level
end

local function normalizeRequirementText(value)
    if value == nil then
        return ""
    end

    local text = tostring(value)
    text = text:gsub("([a-z])([A-Z])", "%1 %2")
    text = text:lower()
    text = text:gsub("[^%w]+", " ")
    text = text:gsub("%s+", " ")
    return " " .. text .. " "
end

local function itemTextForRequirement(item)
    if not item then
        return ""
    end

    local parts = {}
    if item.getFullType then
        parts[#parts + 1] = item:getFullType() or ""
    end
    if item.getType then
        parts[#parts + 1] = item:getType() or ""
    end
    if item.getDisplayName then
        parts[#parts + 1] = item:getDisplayName() or ""
    end
    if item.getName then
        parts[#parts + 1] = item:getName() or ""
    end

    return normalizeRequirementText(table.concat(parts, " "))
end

local function textHasKeywordGroup(text, group)
    for _, keyword in ipairs(group) do
        local normalized = normalizeRequirementText(keyword):gsub("^%s+", ""):gsub("%s+$", "")
        if normalized ~= "" then
            local exactMatch = string.find(text, " " .. normalized .. " ", 1, true)
            local prefixMatch = string.find(text, " " .. normalized, 1, true)
            if not exactMatch and not prefixMatch then
                return false
            end
        end
    end
    return true
end

local function itemMatchesRequirement(item, req)
    if not item or not req then
        return false
    end

    local fullType = item.getFullType and item:getFullType() or nil
    if fullType and req.types then
        for _, typeName in ipairs(req.types) do
            if fullType == typeName then
                return true
            end
        end
    end

    if req.keywords then
        local itemText = itemTextForRequirement(item)
        for _, group in ipairs(req.keywords) do
            if textHasKeywordGroup(itemText, group) then
                return true
            end
        end
    end

    return false
end

local function inventoryHasRequirement(container, req)
    if not container or not req then
        return false
    end

    if req.types and container.containsTypeRecurse then
        for _, typeName in ipairs(req.types) do
            if container:containsTypeRecurse(typeName) then
                return true
            end
        end
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return false
    end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if itemMatchesRequirement(item, req) then
            return true
        end
        if item and item.getInventory then
            local nested = item:getInventory()
            if nested and inventoryHasRequirement(nested, req) then
                return true
            end
        end
    end

    return false
end

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
    o.backgroundColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
    }
    o.borderColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    }
    return o
end

function S4_IE_Jobs:initialise()
    ISPanel.initialise(self)
    print("S4_Jobs: Initialising...")
end

function S4_IE_Jobs:createChildren()
    ISPanel.createChildren(self)
    print("S4_Jobs: Creating Children...")

    self.gridSize = 64
    self.gridGap = 10
    self.cols = 4
    self.rows = 3

    self.Jobs = {{
        name = jobText("IGUI_S4_Jobs_Name_CallCenter", "Call Center"),
        id = "CallCenter",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.0,
        salary = 125,
        requirements = {{
            types = {"Radio.Microphone", "Base.Phone", "Base.CordlessPhone"},
            name = jobText("IGUI_S4_Jobs_Req_MicrophonePhone", "Microphone or Phone"),
            keywords = {{"microphone"}, {"phone"}}
        }, {
            types = {"Base.Headphones", "Base.Headphones_Red"},
            name = jobText("IGUI_S4_Jobs_Req_Headphones", "Headphones"),
            keywords = {{"headphones"}, {"headset"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Designer", "Graphic Designer"),
        id = "Designer",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.1,
        salary = 140,
        requirements = {{
            types = {"Base.Pen", "Base.Pencil", "Base.RedPen", "Base.BluePen", "Base.PenMultiColor"},
            name = jobText("IGUI_S4_Jobs_Req_PenPencil", "Pen/Pencil"),
            keywords = {{"pen"}, {"pencil"}}
        }, {
            types = {"Base.SheetPaper", "Base.SheetPaper2", "Base.Notebook"},
            name = jobText("IGUI_S4_Jobs_Req_PaperNotebook", "Paper/Notebook"),
            keywords = {{"paper"}, {"notebook"}, {"notepad"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Insurance", "Insurance Seller"),
        id = "Insurance",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.2,
        salary = 130,
        requirements = {{
            types = {"Base.SuitJacket", "Base.SuitJacket_Tiny", "Base.Blazer", "Base.Suit_Jacket", "Base.Suit_JacketTINT"},
            name = jobText("IGUI_S4_Jobs_Req_SuitJacket", "Suit Jacket"),
            keywords = {{"suit", "jacket"}, {"suit", "jack"}, {"blazer"}}
        }, {
            types = {"Base.Trousers_Suit", "Base.Trousers_SuitWhite"},
            name = jobText("IGUI_S4_Jobs_Req_SuitTrousers", "Suit Trousers"),
            keywords = {{"suit", "trousers"}, {"suit", "pants"}, {"dress", "pants"}}
        }, {
            types = {"Base.Shirt_FormalWhite", "Base.Shirt_FormalWhite_Short", "Base.Shirt_FormalTINT"},
            name = jobText("IGUI_S4_Jobs_Req_FormalShirt", "Formal Shirt"),
            keywords = {{"formal", "shirt"}, {"dress", "shirt"}}
        }, {
            types = {"Base.Tie_Full", "Base.Tie_Worn"},
            name = jobText("IGUI_S4_Jobs_Req_Tie", "Tie"),
            keywords = {{"tie"}}
        }, {
            types = {"Base.Pen", "Base.BluePen", "Base.RedPen", "Base.PenMultiColor"},
            name = jobText("IGUI_S4_Jobs_Req_Pen", "Pen"),
            keywords = {{"pen"}}
        }, {
            types = {"Base.Notebook"},
            name = jobText("IGUI_S4_Jobs_Req_Notebook", "Notebook"),
            keywords = {{"notebook"}, {"notepad"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Programmer", "Programmer"),
        id = "Programmer",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.3,
        salary = 160,
        requirements = {{
            types = {"Base.BusinessCard", "Base.BusinessCard_Personal", "Base.BusinessCard_Nolans"},
            name = jobText("IGUI_S4_Jobs_Req_BusinessCard", "Business Card"),
            keywords = {{"business", "card"}}
        }, {
            types = {"Base.DigitalWatch", "Base.AlarmClock2"},
            name = jobText("IGUI_S4_Jobs_Req_DigitalWatch", "Digital Watch"),
            keywords = {{"digital", "watch"}, {"alarm", "clock"}}
        }, {
            types = {"Base.CDplayer"},
            name = jobText("IGUI_S4_Jobs_Req_CDPlayer", "CD Player"),
            keywords = {{"cd", "player"}}
        }, {
            types = {"Base.Hat_VisorBlack", "Base.Hat_VisorRed", "Base.Hat_VisorWhite"},
            name = jobText("IGUI_S4_Jobs_Req_Visor", "Visor"),
            keywords = {{"visor"}}
        }, {
            types = {"Base.CordlessPhone"},
            name = jobText("IGUI_S4_Jobs_Req_CordlessPhone", "Cordless Phone"),
            keywords = {{"cordless", "phone"}, {"phone"}}
        }, {
            types = {"Base.Pager", "Base.Remote"},
            name = jobText("IGUI_S4_Jobs_Req_Pager", "Pager"),
            keywords = {{"pager"}, {"remote"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Banker", "Banker"),
        id = "Banker",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.4,
        salary = 150,
        requirements = {{
            types = {"Base.SuitJacket", "Base.SuitJacket_Tiny", "Base.Blazer", "Base.Suit_Jacket", "Base.Suit_JacketTINT"},
            name = jobText("IGUI_S4_Jobs_Req_SuitJacket", "Suit Jacket"),
            keywords = {{"suit", "jacket"}, {"suit", "jack"}, {"blazer"}}
        }, {
            types = {"Base.Tie_Full"},
            name = jobText("IGUI_S4_Jobs_Req_Tie", "Tie"),
            keywords = {{"tie"}}
        }, {
            types = {"Base.Shirt_FormalWhite", "Base.Shirt_FormalWhite_Short", "Base.Shirt_FormalTINT"},
            name = jobText("IGUI_S4_Jobs_Req_FormalShirt", "Formal Shirt"),
            keywords = {{"formal", "shirt"}, {"dress", "shirt"}}
        }, {
            types = {"Base.Pager", "Base.Remote"},
            name = jobText("IGUI_S4_Jobs_Req_Pager", "Pager"),
            keywords = {{"pager"}, {"remote"}}
        }, {
            types = {"Base.Calculator"},
            name = jobText("IGUI_S4_Jobs_Req_Calculator", "Calculator"),
            keywords = {{"calculator"}}
        }, {
            types = {"Base.IndexCard"},
            name = jobText("IGUI_S4_Jobs_Req_IndexCard", "Index Card"),
            keywords = {{"index", "card"}}
        }, {
            types = {"Base.Paperwork"},
            name = jobText("IGUI_S4_Jobs_Req_Paperwork", "Paperwork"),
            keywords = {{"paperwork"}, {"paper"}}
        }, {
            types = {"Base.StockCertificate"},
            name = jobText("IGUI_S4_Jobs_Req_StockCertificate", "Stock Certificate"),
            keywords = {{"stock", "certificate"}, {"certificate"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Broker", "Broker"),
        id = "Broker",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.6,
        salary = 220,
        requirements = {{
            types = {"Base.SuitJacket", "Base.SuitJacket_Tiny", "Base.Blazer", "Base.Suit_Jacket", "Base.Suit_JacketTINT"},
            name = jobText("IGUI_S4_Jobs_Req_SuitJacket", "Suit Jacket"),
            keywords = {{"suit", "jacket"}, {"suit", "jack"}, {"blazer"}}
        }, {
            types = {"Base.Tie_Full", "Base.Tie_Worn"},
            name = jobText("IGUI_S4_Jobs_Req_Tie", "Tie"),
            keywords = {{"tie"}}
        }, {
            types = {"Base.Calculator"},
            name = jobText("IGUI_S4_Jobs_Req_Calculator", "Calculator"),
            keywords = {{"calculator"}}
        }, {
            types = {"Base.Paperwork", "Base.StockCertificate", "Base.IndexCard", "Base.Clipboard"},
            name = jobText("IGUI_S4_Jobs_Req_BrokerDocs", "Paperwork / Certificates"),
            keywords = {{"paperwork"}, {"stock", "certificate"}, {"index", "card"}, {"clipboard"}, {"contract"}}
        }, {
            types = {"Base.BusinessCard", "Base.BusinessCard_Personal", "Base.BusinessCard_Nolans", "Base.CreditCard"},
            name = jobText("IGUI_S4_Jobs_Req_BrokerCard", "Business or Credit Card"),
            keywords = {{"business", "card"}, {"credit", "card"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Cleaner", "Cleaner"),
        id = "Cleaner",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.5,
        salary = 171,
        requirements = {{
            types = {"Base.Bleach"},
            name = jobText("IGUI_S4_Jobs_Req_Bleach", "Bleach"),
            keywords = {{"bleach"}}
        }, {
            types = {"Base.BathTowel", "Base.DishCloth"},
            name = jobText("IGUI_S4_Jobs_Req_Towel", "Towel"),
            keywords = {{"towel"}, {"dish", "cloth"}}
        }, {
            types = {"Base.Garbagebag"},
            name = jobText("IGUI_S4_Jobs_Req_GarbageBag", "Garbage Bag"),
            keywords = {{"garbage", "bag"}, {"trash", "bag"}}
        }, {
            types = {"Base.Pager", "Base.Remote"},
            name = jobText("IGUI_S4_Jobs_Req_Pager", "Pager"),
            keywords = {{"pager"}, {"remote"}}
        }, {
            types = {"Base.CameraDisposable"},
            name = jobText("IGUI_S4_Jobs_Req_DisposableCamera", "Disposable Camera"),
            keywords = {{"disposable", "camera"}, {"camera"}}
        }, {
            types = {"Base.Cigarettes"},
            name = jobText("IGUI_S4_Jobs_Req_Cigarettes", "Cigarettes"),
            keywords = {{"cigarette"}, {"cigarettes"}}
        }, {
            types = {"Base.Passport"},
            name = jobText("IGUI_S4_Jobs_Req_Passport", "Passport"),
            keywords = {{"passport"}}
        }, {
            customCheck = "Firearm",
            name = jobText("IGUI_S4_Jobs_Req_FirearmAmmo", "Firearm & Ammo (7+)")
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Journalist", "Journalist"),
        id = "Journalist",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.1,
        salary = 196,
        requirements = {{
            types = {"Base.Camcorder"},
            name = jobText("IGUI_S4_Jobs_Req_VideoCamera", "Video Camera"),
            keywords = {{"camcorder"}, {"video", "camera"}}
        }, {
            types = {"Base.Shirt_FormalWhite", "Base.Shirt_FormalTINT"},
            name = jobText("IGUI_S4_Jobs_Req_FormalShirt", "Formal Shirt"),
            keywords = {{"formal", "shirt"}, {"dress", "shirt"}}
        }, {
            types = {"Base.Tie_Full"},
            name = jobText("IGUI_S4_Jobs_Req_Tie", "Tie"),
            keywords = {{"tie"}}
        }, {
            types = {"Radio.Microphone"},
            name = jobText("IGUI_S4_Jobs_Req_Microphone", "Microphone"),
            keywords = {{"microphone"}}
        }, {
            types = {"Base.PressID", "Base.Card_Press", "Base.CreditCard"},
            name = jobText("IGUI_S4_Jobs_Req_PressBadge", "Press Badge"),
            keywords = {{"press", "badge"}, {"press", "id"}, {"credit", "card"}}
        }}
    }, {
        name = jobText("IGUI_S4_Jobs_Name_Spy", "Spy"),
        id = "Spy",
        icon = "media/textures/S4_Icon/Icon_64_CallCenter.png",
        difficulty = 1.4,
        salary = 405,
        requirements = {{
            types = {"Base.Bleach"},
            name = jobText("IGUI_S4_Jobs_Req_Bleach", "Bleach"),
            keywords = {{"bleach"}}
        }, {
            types = {"Base.BathTowel", "Base.DishCloth"},
            name = jobText("IGUI_S4_Jobs_Req_Towel", "Towel"),
            keywords = {{"towel"}, {"dish", "cloth"}}
        }, {
            types = {"Base.Garbagebag"},
            name = jobText("IGUI_S4_Jobs_Req_GarbageBag", "Garbage Bag"),
            keywords = {{"garbage", "bag"}, {"trash", "bag"}}
        }, {
            types = {"Base.Pager", "Base.Remote"},
            name = jobText("IGUI_S4_Jobs_Req_Pager", "Pager"),
            keywords = {{"pager"}, {"remote"}}
        }, {
            types = {"Base.CameraDisposable"},
            name = jobText("IGUI_S4_Jobs_Req_DisposableCamera", "Disposable Camera"),
            keywords = {{"disposable", "camera"}, {"camera"}}
        }, {
            types = {"Base.Cigarettes"},
            name = jobText("IGUI_S4_Jobs_Req_Cigarettes", "Cigarettes"),
            keywords = {{"cigarette"}, {"cigarettes"}}
        }, {
            types = {"Base.Passport"},
            name = jobText("IGUI_S4_Jobs_Req_Passport", "Passport"),
            keywords = {{"passport"}}
        }, {
            customCheck = "Firearm",
            name = jobText("IGUI_S4_Jobs_Req_FirearmAmmo", "Firearm & Ammo (7+)")
        }, {
            types = {"Base.Letter"},
            name = jobText("IGUI_S4_Jobs_Req_HandwrittenLetter", "Handwritten Letter"),
            keywords = {{"letter"}, {"handwritten"}}
        }, {
            types = {"Base.Photograph"},
            name = jobText("IGUI_S4_Jobs_Req_Photograph", "Photograph"),
            keywords = {{"photograph"}, {"photo"}}
        }}
    }}

end

function S4_IE_Jobs:render()
    if not self.JobRenderLogged then
        print("S4_Jobs: Rendering Grid...")
        self.JobRenderLogged = true
    end
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
                if not tex then
                    tex = getTexture("media/textures/S4_Icon/Icon_64_Network.png")
                end

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

                    self:drawText(jobText("IGUI_S4_Jobs_Job", "Job") .. ": " .. job.name, 20, tooltipY + 5, 0, 0, 0, 1, UIFont.Medium)
                    self:drawText(jobText("IGUI_S4_Jobs_Rank", "Rank") .. ": " .. details.rank, 20, tooltipY + 25, 0, 0, 0.6, 1, UIFont.Small)

                    -- Progress Bar
                    local barW = 150
                    local barH = 10
                    local barX = 20
                    local barY = tooltipY + 45

                    local progress = 0
                    if details.max then
                        progress = (xp - details.min) / (details.max - details.min)
                        if progress > 1 then
                            progress = 1
                        end
                        if progress < 0 then
                            progress = 0
                        end
                    else
                        progress = 1
                    end

                    self:drawRect(barX, barY, barW, barH, 1, 0.8, 0.8, 0.8)
                    self:drawRectBorder(barX, barY, barW, barH, 1, 0.3, 0.3, 0.3)
                    self:drawRect(barX, barY, barW * progress, barH, 1, 0.2, 0.8, 0.2)

                    self:drawText("Lv " .. details.level, barX + barW + 10, barY - 2, 0, 0, 0, 1, UIFont.Small)

                    if details.max then
                        local remaining = math.ceil(details.max - xp)
                        self:drawText(jobText("IGUI_S4_Jobs_NextLevel", "Next Level") .. ": " .. remaining .. " XP", 20, barY + 12, 0, 0, 0.6, 1, UIFont.Small)
                    else
                        self:drawText(jobText("IGUI_S4_Jobs_MaxLevelReached", "Max Level Reached"), 20, barY + 12, 0, 0, 0.6, 1, UIFont.Small)
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
    return getJobLevelDetailsForXp(xp, difficulty)
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
            self:StartSelectedJob(job)
        end
    end
end

function S4_IE_Jobs:CheckFirearm(inv)
    -- Find any firearm and check ammo
    local items = inv:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:IsWeapon() and item:isAimedFirearm() then
            -- Found gun, check ammo
            local ammoType = item:getAmmoType()
            if ammoType then
                local ammoCount = inv:getItemCountRecurse(ammoType)
                if ammoCount >= 7 then
                    return true
                end
                -- Also check loaded ammo?
                if item:getCurrentAmmoCount() >= 7 then
                    return true
                end
            elseif item:getAmmo() or item:getCurrentAmmoCount() >= 7 then
                -- For guns without separate ammo items (unlikely in PZ)
                return true
            end
        end
    end
    return false
end

function S4_IE_Jobs:StartSelectedJob(job)
    local player = self.player
    local inv = player:getInventory()

    -- Check Requirements
    if job.requirements then
        local missing = {}
        for _, req in ipairs(job.requirements) do
            local hasItem = false

            if req.customCheck == "Firearm" then
                hasItem = self:CheckFirearm(inv)
            else
                hasItem = inventoryHasRequirement(inv, req)
            end

            if not hasItem then
                table.insert(missing, req.name)
            end
        end

        if #missing > 0 then
            local msg = table.concat(missing, ", ")
            self.S4_IE.ComUI:AddMsgBox(jobText("IGUI_S4_Jobs_ErrorTitle", "Job Error"), nil,
                jobText("IGUI_S4_Jobs_MissingEquipment", "Missing Equipment:"), msg,
                jobText("IGUI_S4_Jobs_RequiredFor", "Required for") .. " " .. job.name)
            return
        end
    end

    -- Check Fatigue
    if safeGetPlayerFatigue(player) > 0.5 then
        self.S4_IE.ComUI:AddMsgBox(jobText("IGUI_S4_Jobs_ErrorTitle", "Job Error"), nil,
            jobText("IGUI_S4_Jobs_TooTired", "Too Tired to Work"), jobText("IGUI_S4_Jobs_NeedRest", "You need rest."), "")
        return
    end

    -- Close UI first as requested to access hours menu
    local player = self.player
    local computer = self.S4_IE.ComUI.ComObj
    self.S4_IE.ComUI:close()

    -- Open Context Menu
    local context = ISContextMenu.get(0, getMouseX() + 60, getMouseY())
    local pData = player:getModData()
    local shiftKey = "S4_JobShift_" .. tostring(job.id)
    local savedShift = pData[shiftKey]

    if savedShift and savedShift.totalHours then
        local remainingHours = savedShift.remainingGameHours or 0
        if remainingHours <= 0 and savedShift.remainingTime and savedShift.totalTime and savedShift.totalTime > 0 then
            remainingHours = (savedShift.totalHours * (savedShift.remainingTime / savedShift.totalTime))
        end
        if remainingHours < 0 then
            remainingHours = 0
        end
        context:addOption(jobText("IGUI_S4_Jobs_ResumeShift", "Resume Shift") .. " (" .. string.format("%.1fh", remainingHours) .. " " .. jobText("IGUI_S4_Jobs_Left", "left") .. ")", {
            player = player,
            computer = computer,
            job = job,
            savedShift = savedShift
        }, S4_IE_Jobs.OnResumeShiftStatic)
        context:addOption(jobText("IGUI_S4_Jobs_DiscardSavedProgress", "Discard Saved Progress"), {
            player = player,
            shiftKey = shiftKey
        }, S4_IE_Jobs.OnDiscardSavedShiftStatic)
    end

    -- Pass job data to the context option
    local function makeData(h)
        return {
            player = player,
            computer = computer,
            hours = h,
            job = job
        }
    end

    local pData = player:getModData()
    local xp = pData["S4_Job_" .. job.id .. "_Hours"] or 0
    local details = self:GetJobLevelDetails(xp, job.difficulty)
    local effectiveJobSalary2h = getJobPayForLevel(job.salary, details.level)
    local brokerMin, brokerMax, brokerLevel = getBrokerBonusRange(player)
    local brokerText = ""
    if brokerMin and brokerMax and brokerLevel then
        brokerText = " + Broker Lv " .. brokerLevel .. " (" .. brokerMin .. "-" .. brokerMax .. "%)"
    end

    context:addOption(jobText("IGUI_S4_Jobs_Work", "Work") .. " 1 " .. jobText("IGUI_S4_Jobs_Hour", "Hour") .. " ($" .. math.floor(effectiveJobSalary2h / 2) .. brokerText .. ")", makeData(1), S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption(jobText("IGUI_S4_Jobs_Work", "Work") .. " 2 " .. jobText("IGUI_S4_Jobs_Hours", "Hours") .. " ($" .. effectiveJobSalary2h .. brokerText .. ")", makeData(2), S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption(jobText("IGUI_S4_Jobs_Work", "Work") .. " 3 " .. jobText("IGUI_S4_Jobs_Hours", "Hours") .. " ($" .. math.floor(effectiveJobSalary2h * 1.5) .. brokerText .. ")", makeData(3),
        S4_IE_Jobs.OnSelectTimeStatic)
    context:addOption(jobText("IGUI_S4_Jobs_Work", "Work") .. " 4 " .. jobText("IGUI_S4_Jobs_Hours", "Hours") .. " ($" .. effectiveJobSalary2h * 2 .. brokerText .. ")", makeData(4), S4_IE_Jobs.OnSelectTimeStatic)

end

function S4_IE_Jobs.OnSelectTimeStatic(data)
    local player = data.player
    local computer = data.computer
    local hours = data.hours
    local job = data.job
    local pData = player:getModData()
    local shiftKey = "S4_JobShift_" .. tostring(job.id)
    local savedShift = pData[shiftKey]
    local maxShiftHours = 4

    if savedShift and savedShift.totalHours then
        local prevTotal = savedShift.totalHours or 0
        local prevRemaining = savedShift.remainingGameHours or 0

        if prevRemaining <= 0 and savedShift.remainingTime and savedShift.totalTime and savedShift.totalTime > 0 then
            prevRemaining = prevTotal * (savedShift.remainingTime / savedShift.totalTime)
        end

        local newTotal = prevTotal + hours
        if newTotal > maxShiftHours then
            newTotal = maxShiftHours
        end

        local addHours = newTotal - prevTotal
        if addHours < 0 then
            addHours = 0
        end

        local mergedShift = {
            totalHours = newTotal,
            remainingGameHours = prevRemaining + addHours,
            jobId = job.id
        }

        pData[shiftKey] = nil
        ISTimedActionQueue.add(S4_Action_Job_CallCenter:new(player, computer, mergedShift.totalHours, job, mergedShift))
        if player.setHaloNote then
            if addHours > 0 then
                local msg = string.format("%s: +%.1fh added (%.1fh total)", job.name, addHours, newTotal)
                if newTotal >= maxShiftHours then
                    msg = msg .. " [" .. jobText("IGUI_S4_Jobs_Max4h", "MAX 4h") .. "]"
                end
                player:setHaloNote(msg)
            else
                player:setHaloNote(job.name .. ": " .. jobText("IGUI_S4_Jobs_AlreadyMax4h", "already at max 4h."))
            end
        end
        return
    end

    pData[shiftKey] = nil
    ISTimedActionQueue.add(S4_Action_Job_CallCenter:new(player, computer, hours, job, nil))
    if player.setHaloNote then
        player:setHaloNote(string.format("%s: new shift %.1fh.", job.name, hours))
    end
end

function S4_IE_Jobs.OnResumeShiftStatic(data)
    local player = data.player
    local computer = data.computer
    local job = data.job
    local savedShift = data.savedShift
    ISTimedActionQueue.add(S4_Action_Job_CallCenter:new(player, computer, savedShift.totalHours, job, savedShift))
end

function S4_IE_Jobs.OnDiscardSavedShiftStatic(data)
    local player = data.player
    local shiftKey = data.shiftKey
    local pData = player:getModData()
    pData[shiftKey] = nil
    if player.setHaloNote then
        player:setHaloNote(jobText("IGUI_S4_Jobs_SavedShiftDiscarded", "Saved shift discarded."))
    end
end
