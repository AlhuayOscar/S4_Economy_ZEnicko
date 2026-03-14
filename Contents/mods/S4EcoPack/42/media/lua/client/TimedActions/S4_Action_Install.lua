require "TimedActions/ISBaseTimedAction"
S4_Action_Install = ISBaseTimedAction:derive("S4_Action_Install")

function S4_Action_Install:isValid()
    return true
end

function S4_Action_Install:waitToStart()
    self.character:faceThisObject(self.Obj)
	return self.character:shouldBeTurning()
end

function S4_Action_Install:update()
    self.character:faceThisObject(self.Obj)
end

function S4_Action_Install:start()
    self:setActionAnim("Loot")
    if self.InstallType == "Signal" then
        self.character:SetVariable("LootPosition", "Low")
    else
	    self.character:SetVariable("LootPosition", "Mid")
    end
    -- getSoundManager():PlayWorldSound("ATM_Money_Dispensing", self.Obj:getSquare(), 0, 4, 1, true)
end

function S4_Action_Install:stop()
    ISBaseTimedAction.stop(self)
end

function S4_Action_Install:perform()
    local IvnItems = self.IvnItems
    local ComObj = self.Obj
    local ComModData = ComObj:getModData()
    local ActionType = self.InstallType
    local player = self.character

    if ActionType == "CardReader" then
        local item = IvnItems["S4Item.CardReader"].items[1]
        item:getContainer():Remove(item)

        ComModData.ComCardReader = true
        S4_Utils.SnycObject(ComObj)
    elseif ActionType == "Satellite" then
        local ItemAmount = IvnItems["Base.ElectricWire"].Amount
        local RemoveAmount = self.ItemAmount
        if ItemAmount >= RemoveAmount then
            for i = 1, RemoveAmount do
                local item = IvnItems["Base.ElectricWire"].items[i]
                item:getContainer():Remove(item)
            end
            ComModData.ComSatellite = true
            ComModData.ComSatelliteWire = RemoveAmount
            ComModData.ComSatelliteXYZ = self.XYZCode
            S4_Utils.SnycObject(ComObj)
        end
    elseif ActionType == "PowerBar" then
        local item = IvnItems["Base.PowerBar"].items[1]
        item:getContainer():Remove(item)

        ComModData.ComPowerBar = true
        S4_Utils.SnycObject(ComObj)
    elseif ActionType == "Signal" then
        local item = IvnItems["S4Item.Signal"].items[1]
        item:getContainer():Remove(item)

        sendClientCommand("S4PD", "AddDeliveryList", {self.XYZCode, self.DName})
    end
    ISBaseTimedAction.perform(self)
end

function S4_Action_Install:new(character, Obj, IvnItems, InstallType, MaxTime, ItemAmount, XYZCode, DName)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.Obj = Obj
    o.InstallType = InstallType
    o.IvnItems = IvnItems
    o.ItemAmount = ItemAmount or 0
    o.XYZCode = XYZCode or false
    o.DName = DName or getText("IGUI_S4_Signal_NotInput")
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = MaxTime or 100
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o
end 