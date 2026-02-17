S4_Sys_Settings = ISPanel:derive("S4_Sys_Settings")

function S4_Sys_Settings:new(SysUI, Px, Py, Pw, Ph)
    local o = ISPanel:new(Px, Py, Pw, Ph)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=189/255, g=190/255, b=189/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
    o.SysUI = SysUI -- Sys UI Reference (Parent UI)
    o.ComUI = SysUI.ComUI -- Com UI Reference
    o.player = SysUI.player
    o.Moving = true
    return o
end

function S4_Sys_Settings:initialise()
    ISPanel.initialise(self)
    
end

function S4_Sys_Settings:createChildren()
    ISPanel.createChildren(self)

    local TextMaxX = 0
    local Tx = 40
    local Ty = 40
    local IconNextY = 20
    if self.SysUI.IconImg then
        Tx = Tx + 64 + 20
        IconNextY = IconNextY + 84
    end

    local InfoText1 = getText("IGUI_S4_Settings_Info")
    local InfoTextW1 = getTextManager():MeasureStringX(UIFont.Small, InfoText1)
    self.Info1Label = ISLabel:new(Tx, Ty, S4_UI.FH_S, InfoText1, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.Info1Label)
    TextMaxX = math.max(TextMaxX, Tx + InfoTextW1 + 30)

    local SetupX = 40
    local SetupY = 104
    self.ComLockBox = ISTickBox:new(SetupX, SetupY, S4_UI.FH_S, S4_UI.FH_S, "", self)
    self.ComLockBox.borderColor = {r=0, g=0, b=0, a=1}
    self.ComLockBox.choicesColor = {r=0, g=0, b=0, a=1}
    self.ComLockBox.changeOptionMethod = S4_Sys_Settings.onChangeComLock
    self.ComLockBox.tooltip = getText("Tooltip_S4_ComLockBox")
    self.ComLockBox:initialise()
    self.ComLockBox:instantiate()
    self.ComLockBox:addOption(getText("IGUI_S4_Settings_ComLock"))
    self:addChild(self.ComLockBox)
    TextMaxX = math.max(TextMaxX, self.ComLockBox:getWidth() + 60)
    -- self.ComLockBox:forceClick() 
    SetupY = SetupY + self.ComLockBox:getHeight() + 5

    self.ComTimeBox = ISTickBox:new(SetupX, SetupY, S4_UI.FH_S, S4_UI.FH_S, "", self)
    self.ComTimeBox.borderColor = {r=0, g=0, b=0, a=1}
    self.ComTimeBox.choicesColor = {r=0, g=0, b=0, a=1}
    self.ComTimeBox.changeOptionMethod = S4_Sys_Settings.onChangeComTime
    self.ComTimeBox.tooltip = getText("Tooltip_S4_ComTimeBox")
    self.ComTimeBox:initialise()
    self.ComTimeBox:instantiate()
    self.ComTimeBox:addOption(getText("IGUI_S4_Settings_Time24"))
    self:addChild(self.ComTimeBox)
    TextMaxX = math.max(TextMaxX, self.ComTimeBox:getWidth() + 60) 
    SetupY = SetupY + self.ComTimeBox:getHeight() + S4_UI.FH_S

    local BtnW = TextMaxX - 100

    self.PowerBarBtn = ISButton:new(SetupX, SetupY, BtnW, S4_UI.FH_M, getText("IGUI_S4_Settings_RemovePowerBar"), self, S4_Sys_Settings.BtnClick)
    self.PowerBarBtn.internal = "RemovePowerBar"
    self.PowerBarBtn.textColor = {r=0, g=0, b=0, a=1}
    self.PowerBarBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.PowerBarBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.PowerBarBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.PowerBarBtn:initialise()
    self.PowerBarBtn:setTooltip(getText("Tooltip_S4_Remove_PowerBar"))
    self:addChild(self.PowerBarBtn)
    SetupY = SetupY + self.PowerBarBtn:getHeight() + 5

    if self.ComUI.CardReaderInstall then
        self.CardReaderBtn = ISButton:new(SetupX, SetupY, BtnW, S4_UI.FH_M, getText("IGUI_S4_Settings_RemoveCardReader"), self, S4_Sys_Settings.BtnClick)
        self.CardReaderBtn.internal = "RemoveCardReader"
        self.CardReaderBtn.textColor = {r=0, g=0, b=0, a=1}
        self.CardReaderBtn.borderColor = {r=0, g=0, b=0, a=1}
        self.CardReaderBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
        self.CardReaderBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
        self.CardReaderBtn:initialise()
        self.CardReaderBtn:setTooltip(getText("Tooltip_S4_Remove_CardReader"))
        self:addChild(self.CardReaderBtn)
        SetupY = SetupY + self.CardReaderBtn:getHeight() + 5
    end

    if self.ComUI.SatelliteInstall then
        self.SatelliteBtn = ISButton:new(SetupX, SetupY, BtnW, S4_UI.FH_M, getText("IGUI_S4_Settings_RemoveSatellite"), self, S4_Sys_Settings.BtnClick)
        self.SatelliteBtn.internal = "RemoveSatellite"
        self.SatelliteBtn.textColor = {r=0, g=0, b=0, a=1}
        self.SatelliteBtn.borderColor = {r=0, g=0, b=0, a=1}
        self.SatelliteBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
        self.SatelliteBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
        self.SatelliteBtn:initialise()
        self.SatelliteBtn:setTooltip(getText("Tooltip_S4_Remove_Satellite"))
        self:addChild(self.SatelliteBtn)
        SetupY = SetupY + self.SatelliteBtn:getHeight() + 5
    end

    SetupY = SetupY + S4_UI.FH_S - 5
    local BtnX = TextMaxX - 110
    self.OKBtn = ISButton:new(BtnX, SetupY, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_Network.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    SetupY = SetupY + self.OKBtn:getHeight() + 10

    self:SetTickBox()

    if self.Reload then
        self.SysUI:ReloadFixUISize(TextMaxX, SetupY)
    else
        self.SysUI:FixUISize(TextMaxX, SetupY)
    end
end

function S4_Sys_Settings:BtnClick(Button)
    local internal = Button.internal
    local ComModData = self.ComUI.ComObj:getModData()
    if internal == "Ok" then
        self.SysUI:close()
    elseif internal == "RemovePowerBar" then
        local CreatePowerBar = instanceItem("Base.PowerBar")
        self.player:getInventory():AddItem(CreatePowerBar)
        ComModData.ComPowerBar = false
        S4_Utils.SnycObject(self.ComUI.ComObj)
        self.ComUI:close()
    elseif internal == "RemoveCardReader" then
        if self.ComUI.CardNumber then
            local CardName = string.format(getText("IGUI_S4_Item_CreditCard"), self.ComUI.CardMaster) .. string.format(getText("IGUI_S4_Item_CardNumber"), self.ComUI.CardNumber)
            local CreateCard = instanceItem("Base.CreditCard")
            local ReturnCarditem = self.player:getInventory():AddItem(CreateCard)
            ReturnCarditem:setName(CardName)
            local CardModData = ReturnCarditem:getModData()
            CardModData.S4CardNumber = self.ComUI.CardNumber
            S4_Utils.SnycObject(ReturnCarditem)
        end
        local CreateCardReader = instanceItem("S4Item.CardReader")
        self.player:getInventory():AddItem(CreateCardReader)

        self.ComUI.CardReaderInstall = false
        self.ComUI.CardNumber = false
        self.ComUI.CardMaster = false
        self.ComUI.CardMoney = false
        self.ComUI.CardPassword = false
        ComModData.ComCardReader = false
        ComModData.S4CardNumber = false
        ComModData.S4CardMaster = false
        S4_Utils.SnycObject(self.ComUI.ComObj)
        self.SysUI:close()
    elseif internal == "RemoveSatellite" then
        for i = 1, ComModData.ComSatelliteWire do
            local CreateWire = instanceItem("Base.ElectricWire")
            self.player:getInventory():AddItem(CreateWire)
        end
        self.ComUI.SatelliteInstall = false
        self.ComUI.NetContract = false
        ComModData.ComSatellite = false
        ComModData.ComSatelliteWire = false
        ComModData.ComSatelliteXYZ = false
        S4_Utils.SnycObject(self.ComUI.ComObj)
        self.SysUI:close()
    end
end

function S4_Sys_Settings:SetTickBox()
    if self.ComUI.LockSettings then
        self.ComLockBox.joypadIndex = 1
        self.ComLockBox:forceClick() 
    end
    if self.ComUI.TimeSettings then
        self.ComTimeBox.joypadIndex = 1
        self.ComTimeBox:forceClick() 
    end

end

function S4_Sys_Settings:onChangeComLock()
    if self.ComLockBox:isSelected(1) then
        if self.ComUI.ComPassword then
            self.ComUI.LockSettings = true
            local ComModData = self.ComUI.ComObj:getModData()
            ComModData.ComLock = true
            S4_Utils.SnycObject(self.ComUI.ComObj)
        end
    else
        self.ComUI.LockSettings = false
        local ComModData = self.ComUI.ComObj:getModData()
        ComModData.ComLock = false
        S4_Utils.SnycObject(self.ComUI.ComObj)
    end
end

function S4_Sys_Settings:onChangeComTime()
    if self.ComTimeBox:isSelected(1) then
        self.ComUI.TimeSettings = true
        local ComModData = self.ComUI.ComObj:getModData()
        ComModData.ComTime = true
        S4_Utils.SnycObject(self.ComUI.ComObj)
    else
        self.ComUI.TimeSettings = false
        local ComModData = self.ComUI.ComObj:getModData()
        ComModData.ComTime = false
        S4_Utils.SnycObject(self.ComUI.ComObj)
    end
end

-- Functions related to moving and exiting UI
function S4_Sys_Settings:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_Settings:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end

function S4_Sys_Settings:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
