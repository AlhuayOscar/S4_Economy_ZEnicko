require "TimedActions/ISBaseTimedAction"

S4_Action_Job_CallCenter = ISBaseTimedAction:derive("S4_Action_Job_CallCenter")

local function getShiftKey(jobId)
    return "S4_JobShift_" .. tostring(jobId or "CallCenter")
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

local function getNextShiftBonusKey(jobId)
    return "S4_Job_" .. tostring(jobId or "Designer") .. "_NextShiftBonus"
end

function S4_Action_Job_CallCenter:rollDesignerEventId()
    if self.forcedEventId then
        return self.forcedEventId
    end

    -- 50% chance to have an event at all.
    if ZombRand(100) >= 50 then
        return nil
    end

    -- Weighted inside the 50% bucket:
    -- 40% -> 20% absolute, 20% -> 10% absolute, 10% -> 5% absolute, 4% -> 2% absolute.
    local roll = ZombRand(100)
    if roll < 40 then
        return "bad_feedback"
    elseif roll < 60 then
        return "tools_broken"
    elseif roll < 70 then
        return "tip"
    elseif roll < 74 then
        return "speciality_recommendation"
    end
    return nil
end

function S4_Action_Job_CallCenter:isValid()
    return true
end

function S4_Action_Job_CallCenter:calculatePainRisk()
    local char = self.character
    local pData = char:getModData()
    local gameTime = GameTime:getInstance()
    local currentDay = gameTime:getDay()

    local jobId = self.job.id
    local hoursKey = "S4_Job_" .. jobId .. "_Hours"
    local lastDayKey = "S4_Job_" .. jobId .. "_LastDay"
    local dailyHoursKey = "S4_Job_" .. jobId .. "_DailyHours"

    local lastDay = pData[lastDayKey] or -1
    local dailyHours = pData[dailyHoursKey] or 0

    -- Reset check (simulation)
    if currentDay ~= lastDay then
        dailyHours = 0
    end

    -- Base Risk
    local risk = 10

    -- 1. Daily Hours Factor (Every 2 hours adds 15% risk)
    risk = risk + (math.floor(dailyHours / 2) * 15)

    -- 2. Stats Factor
    local stats = char:getStats()
    risk = risk + (stats:getHunger() * 30) -- 0-1 scale
    risk = risk + (stats:getFatigue() * 50) -- Fatigue is major factor
    risk = risk + (stats:getStress() * 25)
    risk = risk + (stats:getThirst() * 15)

    -- 3. Level Factor (Higher levels = Less risk)
    -- Calculate Level
    local currentXP = pData[hoursKey] or 0
    local level = 1
    if currentXP >= 13000 then
        level = 10
    elseif currentXP >= 9000 then
        level = 9
    elseif currentXP >= 6000 then
        level = 8
    elseif currentXP >= 4000 then
        level = 7
    elseif currentXP >= 2500 then
        level = 6
    elseif currentXP >= 1600 then
        level = 5
    elseif currentXP >= 900 then
        level = 4
    elseif currentXP >= 400 then
        level = 3
    elseif currentXP >= 150 then
        level = 2
    end

    -- Factor: Level 1 = 1.0x, Level 10 = 0.5x (Examples)
    -- Let's say Level 10 is very resilient.
    local resilience = (level - 1) * 5 -- 0 to 45 reduction?
    risk = risk - resilience

    if risk < 0 then
        risk = 0
    end
    if risk > 90 then
        risk = 90
    end -- Cap at 90%

    return risk
end

function S4_Action_Job_CallCenter:update()
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
    end
    if delta > 1 then
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

    -- Periodic Pain Sound (Every 10-30 in-game minutes)
    self.tickCounter = self.tickCounter + 1
    if self.tickCounter >= self.nextSoundTick then
        -- Play sound based on calculated risk
        if ZombRand(100) < self.painRisk then
            local sound = "MalePain"
            if self.character:isFemale() then
                sound = "FemalePain"
            end
            self.character:getEmitter():playSound(sound)
        end

        -- Reset timer for next sound
        self.tickCounter = 0
        self.nextSoundTick = ZombRand(50, 150) -- 50-150 ticks (approx 10-30 in-game mins at 300 ticks/hr)
    end
end

function S4_Action_Job_CallCenter:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    self:setOverrideHandModels(nil, nil)
    self.sound = self.character:getEmitter():playSound("S4_Typing")

    local now = getWorldAgeHours()
    local initialRemaining = self.remainingGameHours or self.hours or 0
    self.startWorldHours = now
    self.endWorldHours = now + initialRemaining
    self.remainingGameHours = initialRemaining

    -- Initialize Pain Sound Timer
    self.painRisk = self:calculatePainRisk()
    self.tickCounter = 0
    self.nextSoundTick = ZombRand(50, 150)
end

function S4_Action_Job_CallCenter:stop()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
    end
    local pData = self.character:getModData()
    local shiftKey = getShiftKey(self.job and self.job.id)
    local remaining = self.remainingGameHours or 0
    if remaining > 0 and self.totalGameHours and self.totalGameHours > 0 then
        pData[shiftKey] = {
            totalHours = self.hours,
            totalTime = self.totalTime,
            remainingTime = self.maxTime,
            remainingGameHours = remaining,
            jobId = self.job and self.job.id
        }
    end
    ISBaseTimedAction.stop(self)
end

function S4_Action_Job_CallCenter:perform()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
    end

    local hours = self.hours
    local char = self.character
    local stats = char:getStats()
    local pData = char:getModData()

    local jobId = self.job.id
    local jobName = self.job.name
    local jobSalary2h = self.job.salary or 125
    local difficulty = self.job.difficulty or 1.0
    local shiftKey = getShiftKey(jobId)
    local paymentMult = 1.0
    local flatPaymentBonus = 0
    local eventNotes = {}
    local eventHaloLines = {}

    local hoursKey = "S4_Job_" .. jobId .. "_Hours"
    local currentXP = pData[hoursKey] or 0

    -- Calculate Level (Generic function ideally, but local here)
    -- Scaling thresholds by difficulty
    local function t(v)
        return math.ceil(v * difficulty)
    end
    local level = 1
    if currentXP >= t(13000) then
        level = 10
    elseif currentXP >= t(9000) then
        level = 9
    elseif currentXP >= t(6000) then
        level = 8
    elseif currentXP >= t(4000) then
        level = 7
    elseif currentXP >= t(2500) then
        level = 6
    elseif currentXP >= t(1600) then
        level = 5
    elseif currentXP >= t(900) then
        level = 4
    elseif currentXP >= t(400) then
        level = 3
    elseif currentXP >= t(150) then
        level = 2
    end

    local mult = 1.0
    if level == 2 then
        mult = 0.9
    elseif level == 3 then
        mult = 0.8
    elseif level == 4 then
        mult = 0.7
    elseif level == 5 then
        mult = 0.6
    elseif level == 6 then
        mult = 0.5
    elseif level == 7 then
        mult = 0.4
    elseif level == 8 then
        mult = 0.6
    elseif level == 9 then
        mult = 0.8
    elseif level == 10 then
        mult = 1.0
    end

    -- Apply Stats (Scale 0-1) with Multiplier
    -- Safety cap: avoid pushing Hunger/Thirst into lethal ranges.
    local maxJobHunger = 0.70
    local maxJobThirst = 0.70

    -- Hunger: Reduced by 25% (was 0.125) -> ~0.09 per hour * mult
    local hungerDelta = (0.09 * hours * mult)
    local hungerNow = stats:getHunger()
    local hungerAfter = hungerNow + hungerDelta
    if hungerAfter > maxJobHunger then
        hungerAfter = maxJobHunger
    end
    stats:setHunger(hungerAfter)

    -- Thirst: 25% for 4 hours -> 0.0625 per hour * mult
    local thirstDelta = (0.0625 * hours * mult)
    local thirstNow = stats:getThirst()
    local thirstAfter = thirstNow + thirstDelta
    if thirstAfter > maxJobThirst then
        thirstAfter = maxJobThirst
    end
    stats:setThirst(thirstAfter)

    -- Fatigue: 50% for 4 hours -> 0.125 per hour * mult
    stats:setFatigue(stats:getFatigue() + (0.125 * hours * mult))

    -- Stress: 45% for 4 hours -> 0.1125 per hour * mult
    stats:setStress(stats:getStress() + (0.1125 * hours * mult))

    -- Boredom: +10 per hour (0-100 scale) * mult
    stats:setBoredom(stats:getBoredom() + (10 * hours * mult))

    -- Unhappiness: +5 per hour (0-100 scale) * mult
    local bodyDamage = char:getBodyDamage()
    bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() + (5 * hours * mult))

    -- Job Leveling (Store on Player ModData)
    local xpGained = hours * 6 -- Equates to 6, 12, 18, 24 XP (Target: 5-25 range)
    -- pData is local Java ModData, distinct from S4_PlayerData global table
    pData[hoursKey] = currentXP + xpGained

    -- Payment Logic
    local gameTime = GameTime:getInstance()
    local currentDay = gameTime:getDay()
    local lastDayKey = "S4_Job_" .. jobId .. "_LastDay"
    local dailyHoursKey = "S4_Job_" .. jobId .. "_DailyHours"

    local lastDay = pData[lastDayKey] or -1
    local dailyHours = pData[dailyHoursKey] or 0

    if currentDay ~= lastDay then
        dailyHours = 0
        pData[lastDayKey] = currentDay
    end

    dailyHours = dailyHours + hours
    local paymentAmount = 0
    local basePaymentAmount = 0

    if dailyHours >= 2 then
        local payments = math.floor(dailyHours / 2)
        if payments > 0 then
            paymentAmount = payments * jobSalary2h
            basePaymentAmount = paymentAmount
            dailyHours = dailyHours % 2 -- Remainder
        end
    end
    pData[dailyHoursKey] = dailyHours

    -- Designer special events
    if jobId == "Designer" then
        local nextShiftBonusKey = getNextShiftBonusKey(jobId)
        local pendingNextShiftBonus = pData[nextShiftBonusKey] or 0
        if pendingNextShiftBonus > 0 then
            paymentMult = paymentMult * (1 + pendingNextShiftBonus)
            table.insert(eventNotes, "Speciality bonus +" .. tostring(math.floor(pendingNextShiftBonus * 100)) .. "%")
            table.insert(eventHaloLines, {
                text = "Evento: bonus especial +" .. tostring(math.floor(pendingNextShiftBonus * 100)) .. "%",
                color = "green"
            })
            pData[nextShiftBonusKey] = nil
        end

        local eventId = self:rollDesignerEventId()
        if eventId == "bad_feedback" then
            paymentMult = paymentMult * 0.5
            table.insert(eventNotes, "No le gusto tu trabajo (-50% pago)")
            table.insert(eventHaloLines, {
                text = "Evento: No le gusto tu trabajo (-50%)",
                color = "red"
            })
        elseif eventId == "tools_broken" then
            paymentMult = paymentMult * 0.8
            table.insert(eventNotes, "Se te rompieron herramientas (-20% pago)")
            table.insert(eventHaloLines, {
                text = "Evento: Herramientas rotas (-20%)",
                color = "red"
            })
        elseif eventId == "tip" then
            local tipBonus = math.floor((jobSalary2h * 0.5) * 0.15)
            flatPaymentBonus = flatPaymentBonus + tipBonus
            table.insert(eventNotes, "Dejaron propina (+$" .. tostring(tipBonus) .. ")")
            table.insert(eventHaloLines, {
                text = "Evento: Propina +$" .. tostring(tipBonus),
                color = "green"
            })
        elseif eventId == "speciality_recommendation" then
            pData[nextShiftBonusKey] = 0.20
            table.insert(eventNotes, "Recomendacion: proximo shift +20%")
            table.insert(eventHaloLines, {
                text = "Evento: Proximo shift +20%",
                color = "green"
            })
        end
    end

    if paymentAmount > 0 or flatPaymentBonus > 0 then
        paymentAmount = math.floor((paymentAmount * paymentMult) + flatPaymentBonus)
        if paymentAmount < 0 then
            paymentAmount = 0
        end
    end

    if paymentAmount > 0 then
        local globalPlayerData = ModData.get("S4_PlayerData")
        if globalPlayerData then
            local username = char:getUsername()
            local myData = globalPlayerData[username]
            if myData and myData.MainCard and sendClientCommand then
                local args = {myData.MainCard, paymentAmount}
                sendClientCommand(char, "S4ED", "AddMoney", args)

                local ts = "0000-00-00 00:00:00"
                if S4_Utils and S4_Utils.getLogTime then
                    ts = S4_Utils.getLogTime()
                end
                local logArgs = {myData.MainCard, ts, "Salary", paymentAmount, jobName .. " Co.", username}
                sendClientCommand(char, "S4ED", "AddCardLog", logArgs)
            end
        end
    end

    -- Back Pain Inducer: Calculated Risk
    local painRisk = self:calculatePainRisk()
    if ZombRand(100) < painRisk then
        local bodyPart = nil
        local parts = bodyDamage:getBodyParts()
        for i = 0, parts:size() - 1 do
            local part = parts:get(i)
            if part and part.getType then
                local typeVal = part:getType()
                if typeVal and tostring(typeVal) == "Torso_Lower" then
                    bodyPart = part
                    break
                end
            end
        end

        if bodyPart then
            local currentPain = bodyPart:getAdditionalPain()
            local intensity = 10 + (painRisk / 3) -- Base 10 + scaling
            bodyPart:setAdditionalPain(currentPain + intensity)
        end
    end

    -- Payment (Placeholder $10/hr removed, using daily wage)
    local msg = jobName .. ": " .. hours .. "h (XP: " .. xpGained .. ")"
    if paymentAmount > 0 then
        msg = msg .. " Paid: $" .. paymentAmount
    else
        -- Calculate remaining hours needed for next payment
        local needed = 2 - dailyHours
        if needed < 0 then
            needed = 0
        end -- Should not happen due to modulo, but safe check
        msg = msg .. " (Accumulated: " .. dailyHours .. "h / Next Pay in " .. needed .. "h)"
    end
    if #eventNotes > 0 then
        msg = msg .. " | " .. table.concat(eventNotes, " | ")
    end

    -- Display message safely
    local function pushHalo(text, color)
        if not char.setHaloNote then
            return
        end
        if color == "red" then
            char:setHaloNote(text, 220, 60, 60, 300)
        elseif color == "green" then
            char:setHaloNote(text, 80, 220, 80, 300)
        else
            char:setHaloNote(text)
        end
    end

    pushHalo(msg, "green")
    for _, line in ipairs(eventHaloLines) do
        pushHalo(line.text, line.color)
    end
    local deltaFromEvents = paymentAmount - basePaymentAmount
    if deltaFromEvents < 0 then
        pushHalo("Ajuste eventos: -$" .. tostring(math.abs(deltaFromEvents)), "red")
    elseif deltaFromEvents > 0 then
        pushHalo("Ajuste eventos: +$" .. tostring(deltaFromEvents), "green")
    end

    -- Finish
    pData[shiftKey] = nil
    ISBaseTimedAction.perform(self)
end

function S4_Action_Job_CallCenter:new(character, computer, hours, job, savedShift, forcedEventId)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.computer = computer
    o.job = job or {
        id = "CallCenter",
        name = "Call Center",
        salary = 125,
        difficulty = 1.0
    } -- Default fallback
    o.stopOnWalk = true
    o.stopOnRun = true
    o.hours = hours
    o.totalGameHours = hours
    o.remainingGameHours = hours
    o.totalTime = calculateTicksForIngameHours(hours)
    o.maxTime = o.totalTime
    o.savedShift = savedShift
    o.forcedEventId = forcedEventId
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
        o.maxTime = 1;
    end

    -- Sound Probability (20%)
    o.soundChance = ZombRand(100) < 20
    o.soundPlayed = false

    return o
end
