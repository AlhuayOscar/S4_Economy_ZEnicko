require "TimedActions/ISBaseTimedAction"

S4_Action_Job_CallCenter = ISBaseTimedAction:derive("S4_Action_Job_CallCenter")

function S4_Action_Job_CallCenter:isValid()
    return true
end

function S4_Action_Job_CallCenter:update()
    self.character:faceThisObject(self.computer)
    self.character:SetVariable("LootPosition", "Mid")
    
    -- Random ambient sound (20% chance per job, checked periodically)
    if self.soundChance and not self.soundPlayed and ZombRand(100) == 0 then
        local sound = "MaleZombieIdle"
        if self.character:isFemale() then sound = "FemaleZombieIdle" end
        self.character:getEmitter():playSound(sound)
        self.soundPlayed = true
    end
end

function S4_Action_Job_CallCenter:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    self:setOverrideHandModels(nil, nil)
    self.sound = self.character:getEmitter():playSound("S4_Typing")
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
                 if myData and myData.MainCard then
                      local args = {myData.MainCard, paymentAmount}
                      sendClientCommand(char, "S4ED", "AddMoney", args)
                      
                      -- Log
                      local logArgs = {myData.MainCard, gameTime:getTimestamp(), "Salary", paymentAmount, "Call Center Zomboids Co.", username}
                      sendClientCommand(char, "S4ED", "AddCardLog", logArgs)
                 end
            end
        end
    end
    pData.S4_Job_CallCenter_DailyHours = dailyHours
    
    -- Payment (Placeholder $10/hr removed, using daily wage)
    local msg = "Job Complete: " .. hours .. "h (XP: " .. xpGained .. ")"
    if paymentAmount > 0 then
        msg = msg .. " Paid: $" .. paymentAmount
    else
        msg = msg .. " (Total Today: " .. (pData.S4_Job_CallCenter_DailyHours + (paymentAmount/200)*2) .. "h)" -- Approximate display
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
