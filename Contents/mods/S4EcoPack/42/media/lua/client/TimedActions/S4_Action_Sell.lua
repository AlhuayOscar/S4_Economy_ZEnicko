require "TimedActions/ISBaseTimedAction"
S4_Action_Sell = ISBaseTimedAction:derive("S4_Action_Sell")

function S4_Action_Sell:isValid()
    return true
end

function S4_Action_Sell:waitToStart()
    self.character:faceThisObject(self.Obj)
	return self.character:shouldBeTurning()
end

function S4_Action_Sell:update()
    self.character:faceThisObject(self.Obj)
end

function S4_Action_Sell:start()
    self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Low")
end

function S4_Action_Sell:stop()
    ISBaseTimedAction.stop(self)
end

function S4_Action_Sell:perform()
    local player = self.character
    local UserName = player:getUsername()
    local sq = player:getSquare()
    if sq then
        for BoxNumber, Data in pairs(self.BoxData) do
            local ItemList = Data.ItemList
            local BoxPrice = Data.Price
            local BoxWeight = Data.Weight
            local InvItems = S4_Utils.getPlayerItems(player)
            for ItemName, Amount in pairs(ItemList) do
                if InvItems[ItemName] and InvItems[ItemName].Amount >= Amount then
                    for i = 1, Amount do
                        local RemoveItem = InvItems[ItemName].items[i]
                        if RemoveItem:getWorldItem() then
                            RemoveItem:getWorldItem():getSquare():transmitRemoveItemFromSquare(RemoveItem:getWorldItem())
                            ISInventoryPage.dirtyUI()
                        else
                            if RemoveItem:getContainer() then
                                RemoveItem:getContainer():Remove(RemoveItem)
                            else
                                player:getInventory():Remove(RemoveItem)
                            end
                        end
                    end
                else
                    break
                end
            end
            local BoxItem = sq:AddWorldInventoryItem("S4Item.SellPackingBox", 0.5, 0.5, 0)
            local BoxItemModData = BoxItem:getModData()
            BoxItem:setWeight(BoxWeight)
            BoxItem:setActualWeight(BoxWeight)
            BoxItem:setCustomWeight(true)
            ISInventoryPage.dirtyUI()
            BoxItemModData.S4ItemList = ItemList
            BoxItemModData.S4Price = BoxPrice
            BoxItemModData.S4CardNumber = self.CardNumber
            BoxItemModData.S4Master = UserName
            S4_Utils.SnycObject(BoxItem)
        end
        self.ParentsUI:ReloadData("Sell")
    end
    ISBaseTimedAction.perform(self)
end

function S4_Action_Sell:new(character, BoxCount, BoxData, CardNumber, ParentsUI)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.BoxCount = BoxCount
    o.BoxData = BoxData
    o.CardNumber = CardNumber
    o.ParentsUI = ParentsUI
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = (PerformanceSettings.getLockFPS() * BoxCount) or 100
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o
end 