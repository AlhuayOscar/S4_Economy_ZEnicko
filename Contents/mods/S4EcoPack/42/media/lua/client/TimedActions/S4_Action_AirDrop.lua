require "TimedActions/ISBaseTimedAction"
S4_Action_AirDrop = ISBaseTimedAction:derive("S4_Action_AirDrop")

function S4_Action_AirDrop:isValid()
    self.ItemCheck = true
    return true
end

function S4_Action_AirDrop:waitToStart()
    self.character:faceThisObject(self.Obj)
	return self.character:shouldBeTurning()
end

function S4_Action_AirDrop:update()
    self.character:faceThisObject(self.Obj)
    local WorldItem = self.BoxItem:getWorldItem()
    if not WorldItem then
        self.ItemCheck = false
    end
end

function S4_Action_AirDrop:start()
    self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Low")
end

function S4_Action_AirDrop:stop()
    ISBaseTimedAction.stop(self)
end

function S4_Action_AirDrop:perform()
    local player = self.character
    local UserName = player:getUsername()
    if self.ItemCheck then
        local FullType = self.BoxItem:getFullType()
        local DropType = "Etc"
        if FullType == "S4Item.AirDropBox_Weapon" then DropType = "Weapon"
        elseif FullType == "S4Item.AirDropBox_Ammo" then DropType = "Ammo"
        elseif FullType == "S4Item.AirDropBox_Food" then DropType = "Food"
        elseif FullType == "S4Item.AirDropBox_Medical" then DropType = "Medical"
        elseif FullType == "S4Item.AirDropBox_Materials" then DropType = "Materials"
        elseif FullType == "S4Item.AirDropBox_Etc" then DropType = "Etc" end
        local DropItemsData = S4_AirdropData[DropType]
        if self.BoxItem:getWorldItem() and self.BoxItem:getWorldItem():getSquare() then
            local Square = self.BoxItem:getWorldItem():getSquare()
            if Square then
                for i = 1, 10 do 
                    if DropItemsData["List"..i] then
                        local Chance =  DropItemsData["Chance"..i]
                        local Count = #DropItemsData["List"..i]
                        if Chance and Count then
                            for j = 1, Chance do
                                local ItemR = ZombRand(1, Count + 1)
                                local FullType = DropItemsData["List"..i][ItemR]
                                if S4_Utils.setItemCashe(FullType) then
                                    Square:AddWorldInventoryItem(FullType, ZombRand(0.5, 1), ZombRand(0.5, 1), 0)
                                end
                            end
                        end
                    else
                        break
                    end
                end
                if self.BoxItem and self.BoxItem:getWorldItem() then
                    self.BoxItem:getWorldItem():getSquare():transmitRemoveItemFromSquare(self.BoxItem:getWorldItem())
                    ISInventoryPage.dirtyUI()
                end
            end
        end
    else

    end
    ISBaseTimedAction.perform(self)
end

function S4_Action_AirDrop:new(character, BoxItem)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.BoxItem = BoxItem
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = (PerformanceSettings.getLockFPS() * 10) or 100
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o
end 