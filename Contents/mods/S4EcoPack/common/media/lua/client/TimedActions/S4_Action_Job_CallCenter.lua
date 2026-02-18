require "TimedActions/ISBaseTimedAction"

S4_Action_Job_CallCenter = ISBaseTimedAction:derive("S4_Action_Job_CallCenter")

function S4_Action_Job_CallCenter:isValid()
    return true
end

function S4_Action_Job_CallCenter:calculatePainRisk()
    local char = self.character
    local pData = char:getModData()
    local gameTime = GameTime:getInstance()
    local currentDay = gameTime:getDay()
    local lastDay = pData.S4_Job_CallCenter_LastDay or -1
    local dailyHours = pData.S4_Job_CallCenter_DailyHours or 0
    
    -- Reset check (simulation)
    if currentDay ~= lastDay then dailyHours = 0 end
    
    -- Base Risk
    local risk = 10
    
    -- 1. Daily Hours Factor (Every 2 hours adds 15% risk)
    risk = risk + (math.floor(dailyHours / 2) * 15)
    
    -- 2. Stats Factor
    local stats = char:getStats()
    risk = risk + (stats:getHunger() * 30)   -- 0-1 scale
    risk = risk + (stats:getFatigue() * 50)  -- Fatigue is major factor
    risk = risk + (stats:getStress() * 25)
    risk = risk + (stats:getThirst() * 15)
    
    -- 3. Level Factor (Higher levels = Less risk)
    -- Calculate Level
    local currentXP = pData.S4_Job_CallCenter_Hours or 0
    local level = 1
    if currentXP >= 13000 then level = 10
    elseif currentXP >= 9000 then level = 9
    elseif currentXP >= 6000 then level = 8
    elseif currentXP >= 4000 then level = 7
    elseif currentXP >= 2500 then level = 6
    elseif currentXP >= 1600 then level = 5
    elseif currentXP >= 900 then level = 4
    elseif currentXP >= 400 then level = 3
    elseif currentXP >= 150 then level = 2
    end
    
    -- Factor: Level 1 = 1.0x, Level 10 = 0.5x (Examples)
    -- Let's say Level 10 is very resilient.
    local resilience = (level - 1) * 5 -- 0 to 45 reduction?
    risk = risk - resilience
    
    if risk < 0 then risk = 0 end
    if risk > 90 then risk = 90 end -- Cap at 90%
    
    return risk
end

function S4_Action_Job_CallCenter:update()
    self.character:faceThisObject(self.computer)
    self.character:SetVariable("LootPosition", "Mid")
    
    -- Periodic Pain Sound (Every 10-30 in-game minutes)
    self.tickCounter = self.tickCounter + 1
    if self.tickCounter >= self.nextSoundTick then
        -- Play sound based on calculated risk
        if ZombRand(100) < self.painRisk then
            local sound = "MalePain"
            if self.character:isFemale() then sound = "FemalePain" end
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
    
    -- Initialize Pain Sound Timer
    self.painRisk = self:calculatePainRisk()
    self.tickCounter = 0
    self.nextSoundTick = ZombRand(50, 150)
end

function S4_Action_Job_CallCenter:stop()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
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
    
    -- Calculate Level and Multiplier
    local pData = char:getModData()
    local currentXP = pData.S4_Job_CallCenter_Hours or 0
    local level = 1
    if currentXP >= 13000 then level = 10
    elseif currentXP >= 9000 then level = 9
    elseif currentXP >= 6000 then level = 8
    elseif currentXP >= 4000 then level = 7
    elseif currentXP >= 2500 then level = 6
    elseif currentXP >= 1600 then level = 5
    elseif currentXP >= 900 then level = 4
    elseif currentXP >= 400 then level = 3
    elseif currentXP >= 150 then level = 2
    end
    
    local mult = 1.0
    if level == 2 then mult = 0.9
    elseif level == 3 then mult = 0.8
    elseif level == 4 then mult = 0.7
    elseif level == 5 then mult = 0.6
    elseif level == 6 then mult = 0.5
    elseif level == 7 then mult = 0.4
    elseif level == 8 then mult = 0.6
    elseif level == 9 then mult = 0.8
    elseif level == 10 then mult = 1.0
    end

    -- Apply Stats (Scale 0-1) with Multiplier
    -- Hunger: Reduced by 25% (was 0.125) -> ~0.09 per hour * mult
    stats:setHunger(stats:getHunger() + (0.09 * hours * mult))
    
    -- Thirst: 25% for 4 hours -> 0.0625 per hour * mult
    stats:setThirst(stats:getThirst() + (0.0625 * hours * mult))
    
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
    pData.S4_Job_CallCenter_Hours = currentXP + xpGained
    
    -- Payment Logic
    local gameTime = GameTime:getInstance()
    local currentDay = gameTime:getDay()
    local lastDay = pData.S4_Job_CallCenter_LastDay or -1
    local dailyHours = pData.S4_Job_CallCenter_DailyHours or 0
    
    if currentDay ~= lastDay then
        dailyHours = 0
        pData.S4_Job_CallCenter_LastDay = currentDay
    end
    
    dailyHours = dailyHours + hours
    local paymentAmount = 0
    
    if dailyHours >= 2 then
        local payments = math.floor(dailyHours / 2)
        if payments > 0 then
            paymentAmount = payments * 200
            dailyHours = dailyHours % 2 -- Remainder
            
            -- Send Payment Command
            local globalPlayerData = ModData.get("S4_PlayerData")
            if globalPlayerData then
                 local username = char:getUsername()
                 local myData = globalPlayerData[username]
                 if myData and myData.MainCard and sendClientCommand then
                      local args = {myData.MainCard, paymentAmount}
                      sendClientCommand(char, "S4ED", "AddMoney", args)
                      
                      -- Log
                      local ts = "0000-00-00 00:00:00"
                      if S4_Utils and S4_Utils.getLogTime then
                          ts = S4_Utils.getLogTime()
                      end
                      local logArgs = {myData.MainCard, ts, "Salary", paymentAmount, "Call Center Zomboids Co.", username}
                      sendClientCommand(char, "S4ED", "AddCardLog", logArgs)
                 end
            end
        end
    end
    pData.S4_Job_CallCenter_DailyHours = dailyHours
    
    -- Back Pain Inducer: Calculated Risk
    local painRisk = self:calculatePainRisk()
    if ZombRand(100) < painRisk then
        local bodyPart = nil
        local parts = bodyDamage:getBodyParts()
        for i=0, parts:size()-1 do
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
    local msg = "Job Complete: " .. hours .. "h (XP: " .. xpGained .. ")"
    if paymentAmount > 0 then
        msg = msg .. " Paid: $" .. paymentAmount
    else
        -- Calculate remaining hours needed for next payment
        local needed = 2 - dailyHours
        if needed < 0 then needed = 0 end -- Should not happen due to modulo, but safe check
        msg = msg .. " (Paid Daily: Need " .. needed .. "h more)" -- Wait, modulo resets it.
        -- If dailyHours became 1 (after 3 hours total -> 2 paid, 1 remaining).
        -- dailyHours is correct remainder.
    end
    
    -- Display message safely
    if char.setHaloNote then
        char:setHaloNote(msg)
    elseif HaloTextHelper then
         HaloTextHelper.addText(char, msg, HaloTextHelper.getColorGreen())
    end
    
    -- Finish
    ISBaseTimedAction.perform(self)
end

function S4_Action_Job_CallCenter:new(character, computer, hours)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.computer = computer
    o.stopOnWalk = true
    o.stopOnRun = true
    o.hours = hours
    o.maxTime = hours * 300 -- 300 ticks per hour (approx 10s IRL)
    if character:isTimedActionInstant() then o.maxTime = 1; end
    
    -- Sound Probability (20%)
    o.soundChance = ZombRand(100) < 20
    o.soundPlayed = false
    
    return o
end
