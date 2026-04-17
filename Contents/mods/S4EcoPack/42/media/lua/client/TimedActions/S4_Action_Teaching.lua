require "TimedActions/ISBaseTimedAction"

S4_Action_Teaching = ISBaseTimedAction:derive("S4_Action_Teaching")

local TEACHING_XP_PER_HOUR = 100

local function getShiftKey(courseId)
    return "S4_TeachingShift_" .. tostring(courseId or "Carpentry")
end

local function calculateTicksForIngameHours(hours)
    local gameTime = GameTime:getInstance()
    local minutesPerDay = 60
    if gameTime and gameTime.getMinutesPerDay then
        minutesPerDay = gameTime:getMinutesPerDay()
    end

    local fps = PerformanceSettings.getLockFPS()
    if not fps or fps <= 0 then
        fps = 30
    end

    local secondsPerGameHour = (minutesPerDay * 60) / 24
    local ticks = math.floor((hours or 1) * secondsPerGameHour * fps)
    if ticks < 1 then
        ticks = 1
    end
    return ticks
end

local function getWorldAgeHours()
    local gameTime = GameTime:getInstance()
    if gameTime and gameTime.getWorldAgeHours then
        return gameTime:getWorldAgeHours()
    end
    return 0
end

local function getTeachingBonusData(pData)
    local worldAgeHours = getWorldAgeHours()
    local dayBucket = math.floor(worldAgeHours / 24)
    local storedDay = pData.S4_Teaching_BonusDay
    local count = pData.S4_Teaching_BonusCount or 0

    if storedDay ~= dayBucket then
        count = 0
        pData.S4_Teaching_BonusDay = dayBucket
    end

    count = count + 1
    pData.S4_Teaching_BonusCount = count

    return count
end

local function getTeachingLevelFromXP(xp)
    if xp >= 13000 then
        return 10
    elseif xp >= 9000 then
        return 9
    elseif xp >= 6000 then
        return 8
    elseif xp >= 4000 then
        return 7
    elseif xp >= 2500 then
        return 6
    elseif xp >= 1600 then
        return 5
    elseif xp >= 900 then
        return 4
    elseif xp >= 400 then
        return 3
    elseif xp >= 150 then
        return 2
    end

    return 1
end

local function getTeachingBonusStep(level)
    if level >= 8 then
        return 200
    elseif level >= 4 then
        return 100
    end

    return 50
end

local function calculateTeachingBonusXP(currentXP, dailyCount)
    local level = getTeachingLevelFromXP(currentXP or 0)
    local step = getTeachingBonusStep(level)
    local bonusXP = dailyCount * step

    return bonusXP, dailyCount, level, step
end

local function calculateTeachingLevelBonusXP(hours, level)
    local step = getTeachingBonusStep(level)
    return (hours or 1) * step, step
end

local function getTeachingSessionMultiplier(level)
    if (level or 1) >= 8 then
        return 15
    end
    return 1
end

local function safeGetStat(stats, methodName, defaultValue)
    if stats and stats[methodName] then
        local value = stats[methodName](stats)
        if value ~= nil then
            return value
        end
    end
    return defaultValue
end

local function safeSetStat(stats, methodName, value)
    if stats and stats[methodName] then
        stats[methodName](stats, value)
        return true
    end
    return false
end

local function safeGetBodyDamageUnhappiness(bodyDamage)
    if not bodyDamage then
        return 0
    end
    if bodyDamage.getUnhappynessLevel then
        return bodyDamage:getUnhappynessLevel() or 0
    end
    if bodyDamage.getUnhappinessLevel then
        return bodyDamage:getUnhappinessLevel() or 0
    end
    return 0
end

local function safeSetBodyDamageUnhappiness(bodyDamage, value)
    if not bodyDamage then
        return false
    end
    if bodyDamage.setUnhappynessLevel then
        bodyDamage:setUnhappynessLevel(value)
        return true
    end
    if bodyDamage.setUnhappinessLevel then
        bodyDamage:setUnhappinessLevel(value)
        return true
    end
    return false
end

function S4_Action_Teaching:isValid()
    return true
end

function S4_Action_Teaching:update()
    self.character:faceThisObject(self.computer)
    self.character:SetVariable("LootPosition", "Mid")

    local now = getWorldAgeHours()
    local remainingGameHours = self.remainingGameHours or self.hours or 0
    if self.endWorldHours then
        remainingGameHours = self.endWorldHours - now
        if remainingGameHours < 0 then
            remainingGameHours = 0
        end
    end
    self.remainingGameHours = remainingGameHours

    local delta = 0
    if self.totalGameHours and self.totalGameHours > 0 then
        delta = 1 - (remainingGameHours / self.totalGameHours)
    end
    if delta < 0 then
        delta = 0
    elseif delta > 1 then
        delta = 1
    end

    self.jobDelta = delta
    if self.setJobDelta then
        self:setJobDelta(delta)
    end

    if remainingGameHours <= 0 then
        self.maxTime = 0
        self.currentTime = 0
    end
end

function S4_Action_Teaching:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    self:setOverrideHandModels(nil, nil)
    self.sound = self.character:getEmitter():playSound("S4_Typing")

    local now = getWorldAgeHours()
    local initialRemaining = self.remainingGameHours or self.hours or 0
    self.startWorldHours = now
    self.endWorldHours = now + initialRemaining
    self.remainingGameHours = initialRemaining
end

function S4_Action_Teaching:stop()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
    end

    local pData = self.character:getModData()
    local shiftKey = getShiftKey(self.course and self.course.id)
    local remaining = self.remainingGameHours or 0
    if remaining > 0 and self.totalGameHours and self.totalGameHours > 0 then
        pData[shiftKey] = {
            totalHours = self.hours,
            totalTime = self.totalTime,
            remainingTime = self.maxTime,
            remainingGameHours = remaining,
            courseId = self.course and self.course.id
        }
    end

    ISBaseTimedAction.stop(self)
end

function S4_Action_Teaching:perform()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
    end

    local hours = self.hours or 1
    local char = self.character
    local stats = char:getStats()
    local pData = char:getModData()
    local course = self.course or {id = "Carpentry", name = "Carpentry", perk = Perks.Woodwork}
    local shiftKey = getShiftKey(course.id)

    local hungerDelta = 0.06 * hours
    local thirstDelta = 0.05 * hours
    local fatigueDelta = 0.10 * hours
    local stressDelta = 0.06 * hours
    local boredomDelta = 14 * hours
    local unhappinessDelta = 7 * hours

    safeSetStat(stats, "setHunger", math.min(0.70, safeGetStat(stats, "getHunger", 0) + hungerDelta))
    safeSetStat(stats, "setThirst", math.min(0.70, safeGetStat(stats, "getThirst", 0) + thirstDelta))
    safeSetStat(stats, "setFatigue", safeGetStat(stats, "getFatigue", 0) + fatigueDelta)
    safeSetStat(stats, "setStress", safeGetStat(stats, "getStress", 0) + stressDelta)
    safeSetStat(stats, "setBoredom", safeGetStat(stats, "getBoredom", 0) + boredomDelta)
    safeSetBodyDamageUnhappiness(char:getBodyDamage(),
        safeGetBodyDamageUnhappiness(char:getBodyDamage()) + unhappinessDelta)

    local hoursKey = "S4_Teaching_" .. tostring(course.id) .. "_XP"
    local currentXP = pData[hoursKey] or 0
    local dailyCount = getTeachingBonusData(pData)
    local dailyBonusXP, _, level, step = calculateTeachingBonusXP(currentXP, dailyCount)
    local levelBonusXP = calculateTeachingLevelBonusXP(hours, level)
    local sessionMultiplier = getTeachingSessionMultiplier(level)
    local xpBase = (hours * TEACHING_XP_PER_HOUR) + levelBonusXP + dailyBonusXP
    local xpGained = xpBase * sessionMultiplier
    pData[hoursKey] = currentXP + xpGained

    local xpSystem = char:getXp()
    if xpSystem and xpSystem.AddXP and course.perk then
        pcall(function()
            xpSystem:AddXP(course.perk, xpGained)
        end)
    end

    if char.setHaloNote then
        char:setHaloNote(string.format("%s: %dh (+%d XP, lvl +%d, daily +%d, x%d, step %d, lv %d, day #%d)",
            tostring(course.name), hours, xpGained, levelBonusXP, dailyBonusXP, sessionMultiplier, step, level,
            dailyCount), 80, 220, 80, 300)
    end

    pData[shiftKey] = nil
    ISBaseTimedAction.perform(self)
end

function S4_Action_Teaching:new(character, computer, hours, course, savedShift)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.computer = computer
    o.course = course or {id = "Carpentry", name = "Carpentry", perk = Perks.Woodwork}
    o.stopOnWalk = true
    o.stopOnRun = true
    o.hours = hours
    o.totalGameHours = hours
    o.remainingGameHours = hours
    o.totalTime = calculateTicksForIngameHours(hours)
    o.maxTime = o.totalTime
    o.savedShift = savedShift
    o.resumeShift = false

    if savedShift and savedShift.totalHours then
        o.hours = savedShift.totalHours
        o.totalGameHours = savedShift.totalHours
        if savedShift.remainingGameHours then
            o.remainingGameHours = savedShift.remainingGameHours
        end
        o.totalTime = calculateTicksForIngameHours(o.totalGameHours)
        o.maxTime = calculateTicksForIngameHours(o.remainingGameHours)
        o.resumeShift = true
    end

    if character:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o
end
