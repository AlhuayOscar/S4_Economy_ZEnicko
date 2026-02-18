require "TimedActions/ISBaseTimedAction"

S4_Action_Job_CallCenter = ISBaseTimedAction:derive("S4_Action_Job_CallCenter")

function S4_Action_Job_CallCenter:isValid()
    return true
end

function S4_Action_Job_CallCenter:update()
    self.character:faceThisObject(self.computer)
    self.character:SetVariable("LootPosition", "Mid")
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
    local pData = char:getModData()
    pData.S4_Job_CallCenter_Hours = (pData.S4_Job_CallCenter_Hours or 0) + xpGained
    
    -- Payment (Placeholder $10/hr)
    -- In future, integrate with S4 Economy bank transfer
    -- For now, just log XP
    local msg = "Job Complete: " .. hours .. "h (XP Gained: " .. xpGained .. " | Total: " .. pData.S4_Job_CallCenter_Hours .. ")"
    
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
    return o
end
