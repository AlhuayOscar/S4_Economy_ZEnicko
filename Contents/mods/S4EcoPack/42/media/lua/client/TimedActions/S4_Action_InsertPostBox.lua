require "TimedActions/ISBaseTimedAction"
S4_Action_InsertPostBox = ISBaseTimedAction:derive("S4_Action_InsertPostBox")

function S4_Action_InsertPostBox:isValid()
    return true
end

function S4_Action_InsertPostBox:waitToStart()
    self.character:faceThisObject(self.Obj)
	return self.character:shouldBeTurning()
end

function S4_Action_InsertPostBox:update()
    self.character:faceThisObject(self.Obj)
end

function S4_Action_InsertPostBox:start()
    self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Mid")
end

function S4_Action_InsertPostBox:stop()
    ISBaseTimedAction.stop(self)
end

function S4_Action_InsertPostBox:perform()
    local player = self.character
    local BoxItem = self.BoxItem
    local BoxModData = BoxItem:getModData()
    if BoxModData.S4Price then
        if BoxItem:getWorldItem() then
            BoxItem:getWorldItem():getSquare():transmitRemoveItemFromSquare(BoxItem:getWorldItem())
            ISInventoryPage.dirtyUI()
        else
            if BoxItem:getContainer() then
                BoxItem:getContainer():Remove(BoxItem)
            else
                player:getInventory():Remove(BoxItem)
            end
        end

        local LogTime = S4_Utils.getLogTime()
        local Price = BoxModData.S4Price
        local CardNumber = BoxModData.S4CardNumber
        sendClientCommand("S4SD", "ShopSell", {CardNumber, Price, LogTime})
        local BoxUserName = BoxModData.S4Master
        sendClientCommand("S4PD", "AddSellTotal", {BoxUserName, Price})
    end
    ISBaseTimedAction.perform(self)
end

function S4_Action_InsertPostBox:new(character, BoxItem)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.BoxItem = BoxItem
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = (PerformanceSettings.getLockFPS() * 2) or 100
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o
end 