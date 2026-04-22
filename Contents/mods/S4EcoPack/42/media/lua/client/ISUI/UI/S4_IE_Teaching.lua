require "ISUI/ISPanel"
require "TimedActions/S4_Action_Teaching"

S4_IE_Teaching = ISPanel:derive("S4_IE_Teaching")

local TEACHING_COST_PER_HOUR = 500
local TEACHING_XP_PER_HOUR = 100
local TEACHING_TRAIT_PRICE_MIN = 3500
local TEACHING_TRAIT_LOW_PRICE_MAX = 10000
local TEACHING_TRAIT_HIGH_PRICE_MIN = 28000
local TEACHING_TRAIT_PRICE_MAX = 54000
local TEACHING_TRAIT_HIGH_PRICE_CHANCE = 80
local OPPOSITE_TRAITS = {
    AllThumbs = "Dextrous",
    Brave = "Cowardly",
    Cowardly = "Brave",
    Dextrous = "AllThumbs",
    FastLearner = "SlowLearner",
    FastReader = "SlowReader",
    SlowLearner = "FastLearner",
    SlowReader = "FastReader",
    SpeedDemon = "SundayDriver",
    SundayDriver = "SpeedDemon"
}

local function teachingText(key, fallback)
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

local function getCardCreditLimit()
    local maxNegative = 1000
    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.MaxNegativeBalance then
        maxNegative = SandboxVars.S4SandBox.MaxNegativeBalance
    end
    if maxNegative < 0 then
        maxNegative = 0
    end
    return -maxNegative
end

local function getRequirementDisplayName(typeName)
    if not typeName or typeName == "" then
        return "Unknown"
    end

    if S4_Utils and S4_Utils.setItemCashe then
        local item = S4_Utils.setItemCashe(typeName)
        if item and item.getDisplayName then
            local displayName = item:getDisplayName()
            if displayName and displayName ~= "" then
                return displayName
            end
        end
    end

    local tail = tostring(typeName):match("([^%.]+)$")
    return tail or tostring(typeName)
end

local function getRequirementDescription(req)
    if not req then
        return teachingText("IGUI_S4_Teaching_Req_Generic", "Required material")
    end

    if req.types and #req.types > 0 then
        local names = {}
        for _, typeName in ipairs(req.types) do
            table.insert(names, getRequirementDisplayName(typeName))
        end
        return table.concat(names, " / ")
    end

    return req.name or teachingText("IGUI_S4_Teaching_Req_Generic", "Required material")
end

local function getTeachingDayBucket()
    local gameTime = GameTime:getInstance()
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor(gameTime:getWorldAgeHours() / 24)
    end
    return 0
end

local function playerHasTrait(player, traitId)
    if not player or not traitId then
        return false
    end

    if player.HasTrait then
        local ok, result = pcall(function()
            return player:HasTrait(traitId)
        end)
        if ok and result then
            return result
        end
    end

    local descriptor = player.getDescriptor and player:getDescriptor() or nil
    local traitLists = {
        player.getTraits and player:getTraits() or nil,
        descriptor and descriptor.getTraits and descriptor:getTraits() or nil
    }

    for _, traits in ipairs(traitLists) do
        if traits and traits.contains then
            local ok, result = pcall(function()
                return traits:contains(traitId)
            end)
            if ok and result then
                return result
            end
        end
    end

    return false
end

local function resolveTraitEntry(traitId)
    if not traitId then
        return nil
    end

    if TraitFactory and TraitFactory.getTrait then
        local ok, trait = pcall(function()
            return TraitFactory.getTrait(traitId)
        end)
        if ok and trait then
            return trait
        end
    end

    return traitId
end

local function getTraitAttemptValues(traitId)
    local attempts = {}
    local seen = {}

    local function addAttempt(entry)
        if entry == nil then
            return
        end

        local key = tostring(entry)
        if seen[key] then
            return
        end

        seen[key] = true
        table.insert(attempts, entry)
    end

    addAttempt(traitId)

    local traitEntry = resolveTraitEntry(traitId)
    addAttempt(traitEntry)

    if traitEntry and traitEntry.getType then
        local ok, traitType = pcall(function()
            return traitEntry:getType()
        end)
        if ok and traitType then
            addAttempt(traitType)
        end
    end

    return attempts
end

local function getPlayerTraitLists(player)
    local traitLists = {}

    if player and player.getTraits then
        local traits = player:getTraits()
        if traits and traits.add then
            table.insert(traitLists, traits)
        end
    end

    local descriptor = player and player.getDescriptor and player:getDescriptor() or nil
    if descriptor and descriptor.getTraits then
        local descriptorTraits = descriptor:getTraits()
        if descriptorTraits and descriptorTraits.add then
            table.insert(traitLists, descriptorTraits)
        end
    end

    return traitLists
end

local function removeTraitFromPlayer(player, traitId)
    if not player or not traitId or not playerHasTrait(player, traitId) then
        return true
    end

    local attempts = getTraitAttemptValues(traitId)
    local traitLists = getPlayerTraitLists(player)

    for _, traits in ipairs(traitLists) do
        if traits.remove then
            for _, entry in ipairs(attempts) do
                pcall(function()
                    traits:remove(entry)
                end)
            end
        end
    end

    return not playerHasTrait(player, traitId)
end

local function grantTraitToPlayer(player, traitId)
    if not player or not traitId or playerHasTrait(player, traitId) then
        return true
    end

    local oppositeTrait = OPPOSITE_TRAITS[traitId]
    if oppositeTrait then
        removeTraitFromPlayer(player, oppositeTrait)
    end

    local attempts = getTraitAttemptValues(traitId)
    local traitLists = getPlayerTraitLists(player)

    for _, traits in ipairs(traitLists) do
        for _, entry in ipairs(attempts) do
            local ok = pcall(function()
                traits:add(entry)
            end)
            if ok and playerHasTrait(player, traitId) then
                if player.resetModel then
                    pcall(function()
                        player:resetModel()
                    end)
                end
                return true
            end
        end
    end

    return false
end

function S4_IE_Teaching:new(S4_IE, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.S4_IE = S4_IE
    o.player = S4_IE.player
    o.backgroundColor = {r = 1, g = 1, b = 1, a = 1}
    o.borderColor = {r = 0, g = 0, b = 0, a = 1}
    return o
end

function S4_IE_Teaching:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Teaching:createChildren()
    ISPanel.createChildren(self)

    self.gridSize = 64
    self.gridGap = 10
    self.cols = 4
    self.rows = 3
    self.offerCols = 3
    self.offerRows = 2

    self.Courses = {{
        name = teachingText("IGUI_S4_Teaching_Name_Carpentry", "Carpentry"),
        id = "Carpentry",
        perk = Perks.Woodwork,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookCarpentrySet", "Base.Hammer", "Base.Saw", "Base.GardenSaw"},
            name = teachingText("IGUI_S4_Teaching_Req_Carpentry", "Carpentry material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Cooking", "Cooking"),
        id = "Cooking",
        perk = Perks.Cooking,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookCookingSet", "Base.KitchenKnife", "Base.FryingPan", "Base.Saucepan"},
            name = teachingText("IGUI_S4_Teaching_Req_Cooking", "Cooking material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Medicine", "Medicine"),
        id = "Medicine",
        perk = Perks.Doctor,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookFirstAidSet", "Base.FirstAidKit", "Base.FirstAidKit_Military", "Base.Bag_MedicalBag"},
            name = teachingText("IGUI_S4_Teaching_Req_Medicine", "Medical material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Welding", "Welding"),
        id = "Welding",
        perk = Perks.MetalWelding,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookMetalWeldingSet", "Base.BlowTorch", "Base.WeldingMask", "Base.SheetMetal"},
            name = teachingText("IGUI_S4_Teaching_Req_Welding", "Welding material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Mechanics", "Mechanics"),
        id = "Mechanics",
        perk = Perks.Mechanics,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookMechanicsSet", "Base.Jack", "Base.LugWrench", "Base.Wrench", "Base.PipeWrench"},
            name = teachingText("IGUI_S4_Teaching_Req_Mechanics", "Mechanics material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Electricity", "Electricity"),
        id = "Electricity",
        perk = Perks.Electricity,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookElectricianSet", "Base.Screwdriver", "Base.ElectronicsScrap"},
            name = teachingText("IGUI_S4_Teaching_Req_Electricity", "Electrical material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Agriculture", "Agriculture"),
        id = "Agriculture",
        perk = Perks.Farming,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookFarmingSet", "Base.HandShovel", "Base.GardeningSprayMilk", "Base.PlasterTrowel"},
            name = teachingText("IGUI_S4_Teaching_Req_Agriculture", "Agriculture material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Maintenance", "Maintenance"),
        id = "Maintenance",
        perk = Perks.Maintenance,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookMaintenanceSet", "Base.GunCleaningTools", "Base.DuctTape", "Base.Whetstone"},
            name = teachingText("IGUI_S4_Teaching_Req_Maintenance", "Weapon maintenance material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Aiming", "Aiming"),
        id = "Aiming",
        perk = Perks.Aiming,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookAimingSet", "Base.Bullets9mmCarton", "Base.ShotgunShellsCarton"},
            name = teachingText("IGUI_S4_Teaching_Req_Aiming", "Aiming material")
        }}
    }, {
        name = teachingText("IGUI_S4_Teaching_Name_Reloading", "Reloading"),
        id = "Reloading",
        perk = Perks.Reloading,
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        requirements = {{
            types = {"Base.BookReloadingSet", "Base.BulletPressTool", "Base.Bullets9mmCarton", "Base.ShotgunShellsCarton"},
            name = teachingText("IGUI_S4_Teaching_Req_Reloading", "Reloading material")
        }}
    }}

    self.TraitOffers = {{
        name = teachingText("IGUI_S4_Teaching_Trait_Handy", "Inventive"),
        id = "Handy",
        trait = "Handy",
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        description = teachingText("IGUI_S4_Teaching_Trait_Handy_Desc", "Permanent Handy trait")
    }, {
        name = teachingText("IGUI_S4_Teaching_Trait_FastLearner", "Fast Learner"),
        id = "FastLearner",
        trait = "FastLearner",
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        description = teachingText("IGUI_S4_Teaching_Trait_FastLearner_Desc", "Permanent Fast Learner trait")
    }, {
        name = teachingText("IGUI_S4_Teaching_Trait_SpeedDemon", "Speed Demon"),
        id = "SpeedDemon",
        trait = "SpeedDemon",
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        description = teachingText("IGUI_S4_Teaching_Trait_SpeedDemon_Desc", "Permanent Speed Demon trait")
    }, {
        name = teachingText("IGUI_S4_Teaching_Trait_Brave", "Brave"),
        id = "Brave",
        trait = "Brave",
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        description = teachingText("IGUI_S4_Teaching_Trait_Brave_Desc", "Permanent Brave trait")
    }, {
        name = teachingText("IGUI_S4_Teaching_Trait_FastReader", "Fast Reader"),
        id = "FastReader",
        trait = "FastReader",
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        description = teachingText("IGUI_S4_Teaching_Trait_FastReader_Desc", "Permanent Fast Reader trait")
    }, {
        name = teachingText("IGUI_S4_Teaching_Trait_Dextrous", "Dextrous"),
        id = "Dextrous",
        trait = "Dextrous",
        icon = "media/textures/S4_Icon/Icon_64_Jobs.png",
        description = teachingText("IGUI_S4_Teaching_Trait_Dextrous_Desc", "Permanent Dextrous trait")
    }}
end

function S4_IE_Teaching:getTraitOfferPrice(offer)
    local pData = self.player:getModData()
    local dayBucket = getTeachingDayBucket()
    local dayKey = "S4_Teaching_TraitOfferDay_" .. tostring(offer.id)
    local priceKey = "S4_Teaching_TraitOfferPrice_" .. tostring(offer.id)

    if pData[dayKey] ~= dayBucket or not pData[priceKey] then
        local roll = ZombRand(100)
        local price

        if roll < TEACHING_TRAIT_HIGH_PRICE_CHANCE then
            price = ZombRand(TEACHING_TRAIT_HIGH_PRICE_MIN, TEACHING_TRAIT_PRICE_MAX + 1)
        else
            price = ZombRand(TEACHING_TRAIT_PRICE_MIN, TEACHING_TRAIT_LOW_PRICE_MAX + 1)
        end

        pData[dayKey] = dayBucket
        pData[priceKey] = price
    end

    return pData[priceKey]
end

function S4_IE_Teaching:getTraitOfferBoughtKey(offer)
    return "S4_Teaching_TraitBought_" .. tostring(offer.id)
end

function S4_IE_Teaching:isTraitOfferOwned(offer)
    local pData = self.player:getModData()
    return pData[self:getTraitOfferBoughtKey(offer)] == true or playerHasTrait(self.player, offer.trait)
end

function S4_IE_Teaching:getTraitOffersStartY()
    return 20 + (self.rows * self.gridSize) + ((self.rows - 1) * self.gridGap) + 34
end

function S4_IE_Teaching:getGridIndexAt(x, y, startX, startY, cols, rows)
    if x < startX or y < startY then
        return nil
    end

    local cell = self.gridSize + self.gridGap
    local col = math.floor((x - startX) / cell)
    local row = math.floor((y - startY) / cell)

    if col < 0 or col >= cols or row < 0 or row >= rows then
        return nil
    end

    local localX = (x - startX) % cell
    local localY = (y - startY) % cell
    if localX > self.gridSize or localY > self.gridSize then
        return nil
    end

    return (row * cols) + col + 1
end

function S4_IE_Teaching:render()
    ISPanel.render(self)

    local x = 20
    local y = 20
    local index = 1

    for _ = 1, self.rows do
        for _ = 1, self.cols do
            local course = self.Courses[index]

            if course then
                self:drawRect(x, y, self.gridSize, self.gridSize, 1, 0.9, 0.9, 0.9)
                self:drawRectBorder(x, y, self.gridSize, self.gridSize, 1, 0.5, 0.5, 0.5)

                local tex = getTexture(course.icon) or getTexture("media/textures/S4_Icon/Icon_64_Network.png")
                if tex then
                    self:drawTextureScaled(tex, x + 8, y + 8, 48, 48, 1)
                else
                    self:drawTextCentre(course.name, x + 32, y + 24, 0, 0, 0, 1, UIFont.Small)
                end

                if self:isMouseOverBox(x, y, self.gridSize, self.gridSize) then
                    self:drawRect(x, y, self.gridSize, self.gridSize, 0.2, 0, 0, 1)

                    local pData = self.player:getModData()
                    local xp = pData["S4_Teaching_" .. course.id .. "_XP"] or 0
                    local details = self:GetCourseLevelDetails(xp)
                    local tooltipH = 86
                    local tooltipY = self.height - tooltipH - 10

                    self:drawText(teachingText("IGUI_S4_Teaching_Skill", "Skill") .. ": " .. course.name, 20,
                        tooltipY + 5, 0, 0, 0, 1, UIFont.Medium)
                    self:drawText(teachingText("IGUI_S4_Teaching_Rank", "Rank") .. ": " .. details.rank, 20,
                        tooltipY + 25, 0, 0, 0.6, 1, UIFont.Small)
                    self:drawText(teachingText("IGUI_S4_Teaching_XpRate", "XP Rate") .. ": " .. TEACHING_XP_PER_HOUR ..
                                      "/" .. teachingText("IGUI_S4_Teaching_HourShort", "h"), 20, tooltipY + 40, 0, 0,
                        0.6, 1, UIFont.Small)

                    local barW = 150
                    local barH = 10
                    local barX = 20
                    local barY = tooltipY + 58
                    local progress = 1

                    if details.max then
                        progress = (xp - details.min) / (details.max - details.min)
                        if progress < 0 then
                            progress = 0
                        elseif progress > 1 then
                            progress = 1
                        end
                    end

                    self:drawRect(barX, barY, barW, barH, 1, 0.8, 0.8, 0.8)
                    self:drawRectBorder(barX, barY, barW, barH, 1, 0.3, 0.3, 0.3)
                    self:drawRect(barX, barY, barW * progress, barH, 1, 0.2, 0.8, 0.2)
                    self:drawText("Lv " .. details.level, barX + barW + 10, barY - 2, 0, 0, 0, 1, UIFont.Small)

                    if details.max then
                        local remaining = math.ceil(details.max - xp)
                        self:drawText(teachingText("IGUI_S4_Teaching_NextLevel", "Next Level") .. ": " .. remaining ..
                                          " XP", 20, barY + 12, 0, 0, 0.6, 1, UIFont.Small)
                    else
                        self:drawText(teachingText("IGUI_S4_Teaching_MaxLevelReached", "Max Level Reached"), 20,
                            barY + 12, 0, 0, 0.6, 1, UIFont.Small)
                    end
                end
            end

            x = x + self.gridSize + self.gridGap
            index = index + 1
        end
        x = 20
        y = y + self.gridSize + self.gridGap
    end

    local offerTitleY = self:getTraitOffersStartY() - 26
    self:drawText("New Offers! Learn brand new skills", 20, offerTitleY, 0, 0, 0, 1, UIFont.Medium)
    self:drawText("Permanent traits. One purchase per character.", 20, offerTitleY + 16, 0.2, 0.2, 0.2, 1,
        UIFont.Small)

    local offerStartY = self:getTraitOffersStartY()
    local offerX = 20
    local offerY = offerStartY
    local offerIndex = 1

    for _ = 1, self.offerRows do
        for _ = 1, self.offerCols do
            local offer = self.TraitOffers[offerIndex]

            if offer then
                local owned = self:isTraitOfferOwned(offer)
                local price = self:getTraitOfferPrice(offer)
                local bg = owned and 0.75 or 0.92

                self:drawRect(offerX, offerY, self.gridSize, self.gridSize, 1, bg, bg, bg)
                self:drawRectBorder(offerX, offerY, self.gridSize, self.gridSize, 1, 0.5, 0.5, 0.5)

                local tex = getTexture(offer.icon) or getTexture("media/textures/S4_Icon/Icon_64_Network.png")
                if tex then
                    self:drawTextureScaled(tex, offerX + 8, offerY + 8, 48, 48, owned and 0.45 or 1)
                else
                    self:drawTextCentre(offer.name, offerX + 32, offerY + 24, 0, 0, 0, 1, UIFont.Small)
                end

                if owned then
                    self:drawTextCentre("OWNED", offerX + 32, offerY + 46, 0, 0.45, 0, 1, UIFont.Small)
                else
                    self:drawTextCentre("$" .. tostring(price), offerX + 32, offerY + 46, 0.65, 0, 0, 1,
                        UIFont.Small)
                end

                if self:isMouseOverBox(offerX, offerY, self.gridSize, self.gridSize) then
                    self:drawRect(offerX, offerY, self.gridSize, self.gridSize, 0.2, 0, 0.45, 1)

                    local tooltipH = 86
                    local tooltipY = self.height - tooltipH - 10
                    self:drawText("Offer: " .. offer.name, 220, tooltipY + 5, 0, 0, 0, 1, UIFont.Medium)
                    self:drawText(offer.description or "", 220, tooltipY + 24, 0, 0, 0.6, 1, UIFont.Small)
                    self:drawText("Price today: $" .. tostring(price), 220, tooltipY + 40, 0, 0, 0.6, 1,
                        UIFont.Small)

                    local statusText = owned and "Already learned" or "Click to buy once for this character"
                    local statusR = owned and 0 or 0
                    local statusG = owned and 0.55 or 0.35
                    local statusB = owned and 0 or 0.75
                    self:drawText(statusText, 220, tooltipY + 56, statusR, statusG, statusB, 1, UIFont.Small)
                end
            end

            offerX = offerX + self.gridSize + self.gridGap
            offerIndex = offerIndex + 1
        end
        offerX = 20
        offerY = offerY + self.gridSize + self.gridGap
    end
end

function S4_IE_Teaching:GetCourseLevelDetails(xp)
    local thresholds = {150, 400, 900, 1600, 2500, 4000, 6000, 9000, 13000}
    local ranks = {
        teachingText("IGUI_S4_Teaching_Rank_1", "Novice"),
        teachingText("IGUI_S4_Teaching_Rank_2", "Student"),
        teachingText("IGUI_S4_Teaching_Rank_3", "Apprentice"),
        teachingText("IGUI_S4_Teaching_Rank_4", "Adept"),
        teachingText("IGUI_S4_Teaching_Rank_5", "Skilled"),
        teachingText("IGUI_S4_Teaching_Rank_6", "Specialist"),
        teachingText("IGUI_S4_Teaching_Rank_7", "Instructor"),
        teachingText("IGUI_S4_Teaching_Rank_8", "Expert"),
        teachingText("IGUI_S4_Teaching_Rank_9", "Master"),
        teachingText("IGUI_S4_Teaching_Rank_10", "Grandmaster")
    }

    if xp < thresholds[1] then
        return {level = 1, min = 0, max = thresholds[1], rank = ranks[1]}
    end

    for i = 1, 8 do
        if thresholds[i + 1] and xp < thresholds[i + 1] then
            return {level = i + 1, min = thresholds[i], max = thresholds[i + 1], rank = ranks[i + 1]}
        end
    end

    return {level = 10, min = thresholds[9], max = nil, rank = ranks[10]}
end

function S4_IE_Teaching:isMouseOverBox(x, y, w, h)
    local mx = self:getMouseX()
    local my = self:getMouseY()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function S4_IE_Teaching:onMouseDown(x, y)
    local courseIndex = self:getGridIndexAt(x, y, 20, 20, self.cols, self.rows)
    if courseIndex then
        local course = self.Courses[courseIndex]
        if course then
            self:StartSelectedCourse(course)
            return
        end
    end

    local offerIndex = self:getGridIndexAt(x, y, 20, self:getTraitOffersStartY(), self.offerCols, self.offerRows)
    if offerIndex then
        local offer = self.TraitOffers[offerIndex]
        if offer then
            self:StartSelectedOffer(offer)
            return
        end
    end
end

function S4_IE_Teaching:hasCourseRequirements(course)
    if not course.requirements then
        return true, nil
    end

    local inv = self.player:getInventory()
    local missing = {}

    for _, req in ipairs(course.requirements) do
        local hasItem = false
        if req.types then
            for _, typeName in ipairs(req.types) do
                if inv:containsTypeRecurse(typeName) then
                    hasItem = true
                    break
                end
            end
        end

        if not hasItem then
            table.insert(missing, getRequirementDescription(req))
        end
    end

    if #missing > 0 then
        return false, table.concat(missing, ", ")
    end

    return true, nil
end

function S4_IE_Teaching:openCourseContext(course)
    local player = self.player
    local computer = self.S4_IE.ComUI.ComObj
    local comUI = self.S4_IE.ComUI
    self.S4_IE.ComUI:close()

    local context = ISContextMenu.get(0, getMouseX() + 60, getMouseY())
    local pData = player:getModData()
    local shiftKey = "S4_TeachingShift_" .. tostring(course.id)
    local savedShift = pData[shiftKey]

    if savedShift and savedShift.totalHours then
        local remainingHours = savedShift.remainingGameHours or 0
        if remainingHours <= 0 and savedShift.remainingTime and savedShift.totalTime and savedShift.totalTime > 0 then
            remainingHours = savedShift.totalHours * (savedShift.remainingTime / savedShift.totalTime)
        end
        if remainingHours < 0 then
            remainingHours = 0
        end

        context:addOption(teachingText("IGUI_S4_Teaching_ResumeCourse", "Resume Course") .. " (" ..
                              string.format("%.1fh", remainingHours) .. " " ..
                              teachingText("IGUI_S4_Teaching_Left", "left") .. ")", {
            player = player,
            computer = computer,
            course = course,
            savedShift = savedShift
        }, S4_IE_Teaching.OnResumeShiftStatic)
        context:addOption(teachingText("IGUI_S4_Teaching_DiscardSavedProgress", "Discard Saved Progress"), {
            player = player,
            shiftKey = shiftKey
        }, S4_IE_Teaching.OnDiscardSavedShiftStatic)
    end

    local function makeData(hours)
        return {
            player = player,
            computer = computer,
            course = course,
            hours = hours,
            cardReaderInstall = comUI and comUI.CardReaderInstall,
            cardNumber = comUI and comUI.CardNumber,
            isCardPassword = comUI and comUI.isCardPassword
        }
    end

    context:addOption(teachingText("IGUI_S4_Teaching_Study", "Study") .. " 1 " ..
                          teachingText("IGUI_S4_Teaching_Hour", "Hour") .. " ($" .. tostring(TEACHING_COST_PER_HOUR) ..
                          ")", makeData(1), S4_IE_Teaching.OnSelectTimeStatic)
    context:addOption(teachingText("IGUI_S4_Teaching_Study", "Study") .. " 2 " ..
                          teachingText("IGUI_S4_Teaching_Hours", "Hours") .. " ($" ..
                          tostring(TEACHING_COST_PER_HOUR * 2) .. ")", makeData(2), S4_IE_Teaching.OnSelectTimeStatic)
    context:addOption(teachingText("IGUI_S4_Teaching_Study", "Study") .. " 3 " ..
                          teachingText("IGUI_S4_Teaching_Hours", "Hours") .. " ($" ..
                          tostring(TEACHING_COST_PER_HOUR * 3) .. ")", makeData(3), S4_IE_Teaching.OnSelectTimeStatic)
    context:addOption(teachingText("IGUI_S4_Teaching_Study", "Study") .. " 4 " ..
                          teachingText("IGUI_S4_Teaching_Hours", "Hours") .. " ($" ..
                          tostring(TEACHING_COST_PER_HOUR * 4) .. ")", makeData(4), S4_IE_Teaching.OnSelectTimeStatic)
end

function S4_IE_Teaching:StartSelectedCourse(course)
    local ok, missing = self:hasCourseRequirements(course)
    if not ok then
        self.S4_IE.ComUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            teachingText("IGUI_S4_Teaching_MissingEquipment", "Missing material:"), missing,
            teachingText("IGUI_S4_Teaching_RequiredFor", "Required for") .. " " .. course.name)
        return
    end

    if safeGetPlayerFatigue(self.player) > 0.5 then
        self.S4_IE.ComUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            teachingText("IGUI_S4_Teaching_TooTired", "Too tired to study"),
            teachingText("IGUI_S4_Teaching_NeedRest", "You need rest."), "")
        return
    end

    local comUI = self.S4_IE.ComUI
    if not comUI.CardReaderInstall then
        comUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardReaderInstall"), "")
        return
    end

    if not comUI.CardNumber then
        comUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotShopInsertCard"), "")
        return
    end

    if not comUI.isCardPassword then
        comUI:CardPasswordCheck()
        return
    end

    self:openCourseContext(course)
end

function S4_IE_Teaching:openTraitOfferContext(offer)
    local player = self.player
    local comUI = self.S4_IE.ComUI
    local price = self:getTraitOfferPrice(offer)
    self.S4_IE.ComUI:close()

    local context = ISContextMenu.get(0, getMouseX() + 60, getMouseY())
    context:addOption("Learn permanently ($" .. tostring(price) .. ")", {
        player = player,
        offer = offer,
        price = price,
        cardReaderInstall = comUI and comUI.CardReaderInstall,
        cardNumber = comUI and comUI.CardNumber,
        isCardPassword = comUI and comUI.isCardPassword
    }, S4_IE_Teaching.OnBuyTraitOfferStatic)
end

function S4_IE_Teaching:StartSelectedOffer(offer)
    if self:isTraitOfferOwned(offer) then
        self.S4_IE.ComUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            "Offer unavailable", "This character already has " .. offer.name .. ".", "")
        return
    end

    local comUI = self.S4_IE.ComUI
    if not comUI.CardReaderInstall then
        comUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardReaderInstall"), "")
        return
    end

    if not comUI.CardNumber then
        comUI:AddMsgBox(teachingText("IGUI_S4_Teaching_ErrorTitle", "Teaching Error"), nil,
            getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotShopInsertCard"), "")
        return
    end

    if not comUI.isCardPassword then
        comUI:CardPasswordCheck()
        return
    end

    self:openTraitOfferContext(offer)
end

function S4_IE_Teaching.OnSelectTimeStatic(data)
    local player = data.player
    local computer = data.computer
    local hours = data.hours
    local course = data.course
    local pData = player:getModData()
    local shiftKey = "S4_TeachingShift_" .. tostring(course.id)
    local savedShift = pData[shiftKey]
    local maxShiftHours = 4
    local addHours = hours
    local newTotal = hours
    local mergedShift = nil

    if savedShift and savedShift.totalHours then
        local prevTotal = savedShift.totalHours or 0
        local prevRemaining = savedShift.remainingGameHours or 0

        if prevRemaining <= 0 and savedShift.remainingTime and savedShift.totalTime and savedShift.totalTime > 0 then
            prevRemaining = prevTotal * (savedShift.remainingTime / savedShift.totalTime)
        end

        newTotal = prevTotal + hours
        if newTotal > maxShiftHours then
            newTotal = maxShiftHours
        end

        addHours = newTotal - prevTotal
        if addHours < 0 then
            addHours = 0
        end

        mergedShift = {
            totalHours = newTotal,
            remainingGameHours = prevRemaining + addHours,
            courseId = course.id
        }
    end

    if addHours <= 0 then
        if player.setHaloNote then
            player:setHaloNote(course.name .. ": " ..
                                   teachingText("IGUI_S4_Teaching_AlreadyMax4h", "already at max 4h."))
        end
        return
    end

    if not data.cardReaderInstall then
        if player.setHaloNote then
            player:setHaloNote(teachingText("IGUI_S4_Teaching_NoCardReader", "Card reader required."), 220, 60, 60,
                300)
        end
        return
    end

    if not data.cardNumber then
        if player.setHaloNote then
            player:setHaloNote(teachingText("IGUI_S4_Teaching_NoCardInserted", "Insert a card to pay."), 220, 60, 60,
                300)
        end
        return
    end

    if not data.isCardPassword then
        if player.setHaloNote then
            player:setHaloNote(teachingText("IGUI_S4_Teaching_NeedCardPassword", "Card password verification required."),
                220, 60, 60, 300)
        end
        return
    end

    local cardData = S4_UI and S4_UI.getCardData and S4_UI.getCardData(data.cardNumber) or nil
    local cardMoney = cardData and tonumber(cardData.Money) or 0
    local totalCost = addHours * TEACHING_COST_PER_HOUR
    if (cardMoney - totalCost) < getCardCreditLimit() then
        if player.setHaloNote then
            player:setHaloNote(teachingText("IGUI_S4_Teaching_LowBalance", "Insufficient card balance."), 220, 60, 60,
                300)
        end
        return
    end

    if sendClientCommand then
        local logTime = "0000-00-00 00:00:00"
        if S4_Utils and S4_Utils.getLogTime then
            logTime = S4_Utils.getLogTime()
        end
        sendClientCommand("S4ED", "RemoveMoney", {data.cardNumber, totalCost})
        sendClientCommand("S4ED", "AddCardLog", {data.cardNumber, logTime, "Withdraw", totalCost,
                                                 player:getUsername(), "Teaching"})
    end

    pData[shiftKey] = nil

    if mergedShift then
        ISTimedActionQueue.add(S4_Action_Teaching:new(player, computer, mergedShift.totalHours, course, mergedShift))
        if player.setHaloNote then
            local msg = string.format("%s: +%.1fh added ($%d)", course.name, addHours, totalCost)
            if newTotal >= maxShiftHours then
                msg = msg .. " [" .. teachingText("IGUI_S4_Teaching_Max4h", "MAX 4h") .. "]"
            end
            player:setHaloNote(msg)
        end
        return
    end

    ISTimedActionQueue.add(S4_Action_Teaching:new(player, computer, hours, course, nil))
    if player.setHaloNote then
        player:setHaloNote(string.format("%s: new course %.1fh ($%d).", course.name, hours, totalCost))
    end
end

function S4_IE_Teaching.OnResumeShiftStatic(data)
    ISTimedActionQueue.add(S4_Action_Teaching:new(data.player, data.computer, data.savedShift.totalHours, data.course,
        data.savedShift))
end

function S4_IE_Teaching.OnBuyTraitOfferStatic(data)
    local player = data.player
    local offer = data.offer
    local price = tonumber(data.price) or 0
    local pData = player:getModData()
    local boughtKey = "S4_Teaching_TraitBought_" .. tostring(offer.id)

    if pData[boughtKey] or playerHasTrait(player, offer.trait) then
        if player.setHaloNote then
            player:setHaloNote(offer.name .. ": already learned.", 220, 60, 60, 300)
        end
        return
    end

    if not data.cardReaderInstall or not data.cardNumber or not data.isCardPassword then
        if player.setHaloNote then
            player:setHaloNote("Card verification required.", 220, 60, 60, 300)
        end
        return
    end

    local cardData = S4_UI and S4_UI.getCardData and S4_UI.getCardData(data.cardNumber) or nil
    local cardMoney = cardData and tonumber(cardData.Money) or 0
    if (cardMoney - price) < getCardCreditLimit() then
        if player.setHaloNote then
            player:setHaloNote(teachingText("IGUI_S4_Teaching_LowBalance", "Insufficient card balance."), 220, 60, 60,
                300)
        end
        return
    end

    local localApplied = grantTraitToPlayer(player, offer.trait)
    if sendClientCommand then
        sendClientCommand("S4PD", "AddTeachingTrait", {offer.trait})
    end

    if (not localApplied) and (not isClient or not isClient()) and (not playerHasTrait(player, offer.trait)) then
        if player.setHaloNote then
            player:setHaloNote("Could not apply trait: " .. tostring(offer.name), 220, 60, 60, 300)
        end
        return
    end

    if sendClientCommand then
        local logTime = "0000-00-00 00:00:00"
        if S4_Utils and S4_Utils.getLogTime then
            logTime = S4_Utils.getLogTime()
        end
        sendClientCommand("S4ED", "RemoveMoney", {data.cardNumber, price})
        sendClientCommand("S4ED", "AddCardLog", {data.cardNumber, logTime, "Withdraw", price,
                                                 player:getUsername(), "Teaching Trait"})
    end

    pData[boughtKey] = true
    if player.setHaloNote then
        player:setHaloNote(string.format("%s learned permanently for $%d.", offer.name, price), 80, 220, 80, 300)
    end
end

function S4_IE_Teaching.OnDiscardSavedShiftStatic(data)
    local pData = data.player:getModData()
    pData[data.shiftKey] = nil
    if data.player.setHaloNote then
        data.player:setHaloNote(teachingText("IGUI_S4_Teaching_SavedShiftDiscarded", "Saved course discarded."))
    end
end
