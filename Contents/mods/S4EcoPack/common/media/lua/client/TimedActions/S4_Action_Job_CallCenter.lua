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
    -- self.sound = self.character:getEmitter():playSound("ReadBook") -- Optional sound
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
    
    -- Apply Stats (Scale 0-1)
    -- Hunger: 50% for 4 hours -> 0.125 per hour
    stats:setHunger(stats:getHunger() + (0.125 * hours))
    
    -- Thirst: 25% for 4 hours -> 0.0625 per hour
    stats:setThirst(stats:getThirst() + (0.0625 * hours))
    
    -- Fatigue: 50% for 4 hours -> 0.125 per hour
    stats:setFatigue(stats:getFatigue() + (0.125 * hours))
    
    -- Stress: 45% for 4 hours -> 0.1125 per hour
    stats:setStress(stats:getStress() + (0.1125 * hours))
    
    -- Boredom: +10 per hour (0-100 scale)
    stats:setBoredom(stats:getBoredom() + (10 * hours))
    
    -- Unhappiness: +5 per hour (0-100 scale)
    local bodyDamage = char:getBodyDamage()
    bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() + (5 * hours))
    
    -- Job Leveling (Store on Player ModData)
    local pData = char:getModData()
    pData.S4_Job_CallCenter_Hours = (pData.S4_Job_CallCenter_Hours or 0) + hours
    
    -- Payment (Placeholder $10/hr)
    -- In future, integrate with S4 Economy bank transfer
    -- For now, just log XP
    local msg = "Job Complete: " .. hours .. "h (Total XP: " .. pData.S4_Job_CallCenter_Hours .. ")"
    if char:isPlayer() then -- Only clear validation
        char:setHaloNote(msg)
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
