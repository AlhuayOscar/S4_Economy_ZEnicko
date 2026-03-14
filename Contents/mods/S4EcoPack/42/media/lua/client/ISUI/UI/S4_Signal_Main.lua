S4_Signal_Main = ISPanel:derive("S4_Signal_Main")
S4_Signal_Main.instance = nil

function S4_Signal_Main:show(player)
    local square = player:getSquare()
    if S4_Signal_Main.instance == nil then
        S4_Signal_Main.instance = S4_Signal_Main:new(player)
        S4_Signal_Main.instance:initialise()
        S4_Signal_Main.instance:instantiate()
    end
    S4_Signal_Main.instance:addToUIManager()
    S4_Signal_Main.instance:setVisible(true)
    return S4_Signal_Main.instance
end

function S4_Signal_Main:new(player)
    local o = {}
    local Sw, Sh = getCore():getScreenWidth(), getCore():getScreenHeight()
    local width, height = 250, (Sh / 3)
    local x, y = (Sw / 2) - (width / 2), (Sh / 2) - (height / 2)
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player 
    o.backgroundColor = {r=43/255, g=77/255, b=0/255, a=1}
    o.borderColor = {r=0, g=0, b=0, a=1}
    o.NameCheck = false
    o.AddressCheck = false
    o.moveWithMouse = true
    o:setWantKeyEvents(true)
    return o
end

function S4_Signal_Main:initialise()
    ISPanel.initialise(self)

    local SPModData = ModData.get("S4_PlayerShopData")
    if not SPModData then self:close() end
    local PlayModData = SPModData[self.player:getUsername()]
    if not PlayModData and not PlayModData.DeliveryList then self:close() end
    self.DeliveryList = PlayModData.DeliveryList

end

function S4_Signal_Main:createChildren()
    ISPanel.createChildren(self)

    local x = 10
    local y = 10
    for i = 1, 3 do
        self["Dump"..i] = ISPanel:new(x, y, self:getWidth() - (x * 2), 10)
        self["Dump"..i].backgroundColor = {r=0, g=0, b=0, a=0.4}
        self["Dump"..i].borderColor = {r=0, g=0, b=0, a=1}
        self["Dump"..i].moveWithMouse = true
        self["Dump"..i]:initialise()
        self["Dump"..i]:instantiate()
        self:addChild(self["Dump"..i])
        y = y + 15
    end
    y = y + 10
    self.DisplayPanel = ISPanel:new(x, y, self:getWidth() - (x * 2),( S4_UI.FH_S * 3) + 20)
    self.DisplayPanel.backgroundColor = {r=186/255, g=192/255, b=29/255, a=0.9}
    self.DisplayPanel.borderColor = {r=0, g=0, b=0, a=1}
    -- self.DisplayPanel.moveWithMouse = true
    self.DisplayPanel:initialise()
    self.DisplayPanel:instantiate()
    self:addChild(self.DisplayPanel)

    y = y + 10
    self.AddressNameLable = ISLabel:new(x + 5, y, S4_UI.FH_S, "Test", 0, 0, 0, 0.7, UIFont.Small, true)
    self:addChild(self.AddressNameLable)
    y = y + S4_UI.FH_S
    self.AddressCodeLable = ISLabel:new(x + 5, y, S4_UI.FH_S, "Test", 0, 0, 0, 0.7, UIFont.Small, true)
    self:addChild(self.AddressCodeLable)
    y = y + S4_UI.FH_S
    self.AddressCheckLable = ISLabel:new(x + 5, y, S4_UI.FH_S, "Test", 0, 0, 0, 0.7, UIFont.Small, true)
    self:addChild(self.AddressCheckLable)
    y = y + S4_UI.FH_S + 20

    self.NameEntry = ISTextEntryBox:new("", x, y, self:getWidth() - (x * 2), S4_UI.FH_S + 4)
    self.NameEntry.font = UIFont.Small
    self.NameEntry.render = S4_Signal_Main.EntryRender
    self.NameEntry.EntryNameTag = "Name"
    self.NameEntry.EntryNameTag = getText("IGUI_S4_Signal_SetName")
    self.NameEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.NameEntry:initialise()
    self.NameEntry:instantiate()
    self:addChild(self.NameEntry)
    y = y + S4_UI.FH_S + 14

    self.CodeBtn = ISButton:new(x, y, self:getWidth() - (x * 2), S4_UI.FH_S + 4, getText("IGUI_S4_Signal_SetCode"), self, S4_Signal_Main.BtnClick)
    self.CodeBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.CodeBtn.internal = "SetCode"
    self.CodeBtn.tooltip = getText("IGUI_S4_Signal_SetCode_Tooltip")
    self.CodeBtn:initialise()
    self:addChild(self.CodeBtn)

    self.SetupBtn = ISButton:new(x, y, self:getWidth() - (x * 2), S4_UI.FH_S + 4, getText("IGUI_S4_Signal_Setup"), self, S4_Signal_Main.BtnClick)
    self.SetupBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.SetupBtn.internal = "Setup"
    self.SetupBtn:initialise()
    self.SetupBtn:setVisible(false)
    self:addChild(self.SetupBtn)
    y = y + S4_UI.FH_S + 14

    local NumX = x
    local NumY = y
    local NumW = ((self:getWidth() - 50) / 4)
    for i = 1, 8 do
        if i == 5 then
            NumX = x
            NumY = NumY + NumW + 10
        elseif i ~= 1 then
            NumX = NumX + NumW + 10
        end
        self["DumpNum"..i] = ISPanel:new(NumX, NumY, NumW, NumW)
        self["DumpNum"..i].backgroundColor = {r=0, g=0, b=0, a=0.4}
        self["DumpNum"..i].borderColor = {r=0, g=0, b=0, a=1}
        self["DumpNum"..i].moveWithMouse = true
        self["DumpNum"..i]:initialise()
        self["DumpNum"..i]:instantiate()
        self:addChild(self["DumpNum"..i])
    end
    NumY = NumY + NumW + 10

    self:setHeight(NumY)
    local Sy = (getCore():getScreenHeight() / 2) - (NumY / 2)
    self:setY(Sy)
end

function S4_Signal_Main:render()
    ISPanel.render(self)
    if self.NameEntry:getText() then
        local Name = getText("IGUI_S4_Signal_Name") .. self.NameEntry:getText()
        if self.NameEntry:getText() == "" then
            self.NameCheck = false
            Name = Name .. getText("IGUI_S4_Signal_NotInput")
        else
            self.NameCheck = true
        end
        self.AddressNameLable:setName(Name)
    end
    local CodeName = getText("IGUI_S4_Signal_Code")
    if self.CodeX and self.CodeY and self.CodeZ then
        local XYZ = "X" .. self.CodeX .. "Y" .. self.CodeY .. "Z" .. self.CodeZ
        if self.DeliveryList[XYZ] then
            CodeName = CodeName .. getText("IGUI_S4_Signal_Duplicate")
            self.AddressCheck = false
        else
            CodeName = CodeName .. self.CodeX .. "99" .. self.CodeY .. "98" .. self.CodeZ
            self.AddressCheck = true
        end
    else
        CodeName = CodeName .. getText("IGUI_S4_Signal_NotInput")
    end
    self.AddressCodeLable:setName(CodeName)
    if self.NameCheck and self.AddressCheck then
        self.CodeBtn:setVisible(false)
        self.SetupBtn:setVisible(true)
        self.AddressCheckLable:setName(getText("IGUI_S4_Signal_Setting"))
    else
        self.CodeBtn:setVisible(true)
        self.SetupBtn:setVisible(false)
        self.AddressCheckLable:setName(getText("IGUI_S4_Signal_NotSetting"))
    end
end

function S4_Signal_Main:BtnClick(Button)
    local internal = Button.internal
    if internal == "SetCode" then
        local SignalCursor = ISSignalCursor:new(self.player)
        getCell():setDrag(SignalCursor, SignalCursor.player)
        self:setVisible(false)
    elseif internal == "Setup" then
        self:SetupSignal()
    end
end

function S4_Signal_Main:SetupSignal()
    if self.NameCheck and self.AddressCheck then
        local IvnItems = S4_Utils.getPlayerItems(self.player)
        if not IvnItems["S4Item.Signal"] then return end
        if self.CodeX and self.CodeY and self.CodeZ and self.NameEntry:getText() ~= "" then
            local square = getCell():getGridSquare(self.CodeX , self.CodeY, self.CodeZ)
            if square and square:getObjects():get(0) then
                local Obj = square:getObjects():get(0)
                local adjacent = S4_Utils.getAdjacent(self.player, Obj, 0, 0)
                if adjacent then
                    local WalkAction = ISWalkToTimedAction:new(self.player, adjacent)
                    ISTimedActionQueue.add(WalkAction)
            
                    WalkAction:setOnComplete(function()
                        local XYZ = "X" .. self.CodeX .. "Y" .. self.CodeY .. "Z" .. self.CodeZ
                        local Name = self.NameEntry:getText()
                        local MaxTime = PerformanceSettings.getLockFPS() * 2
                        local InstallAction = S4_Action_Install:new(self.player, Obj, IvnItems, "Signal", MaxTime, 1, XYZ, Name)
                        ISTimedActionQueue.add(InstallAction)
                        self:close()
                    end)
                end
                
            end
            -- sendClientCommand("S4PD", "AddDeliveryList", {XYZ, Name})
        end
    end
end

function S4_Signal_Main:EntryRender()
    if self.EntryNameTag and not self.javaObject:isFocused() and self:getText() == "" then
        local TextW = getTextManager():MeasureStringX(UIFont.Small, self.EntryNameTag)
        local X = (self:getWidth() / 2 ) - (TextW / 2)
        self:drawText(self.EntryNameTag, 10, 2, 1, 1, 1, 0.5, UIFont.Small)
    end
end

function S4_Signal_Main:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function S4_Signal_Main:onKeyRelease(key)
    if self.EventAction then return end
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

function S4_Signal_Main:close()
    S4_Signal_Main.instance = nil
    ISPanel.close(self)
    self:removeFromUIManager()
end
