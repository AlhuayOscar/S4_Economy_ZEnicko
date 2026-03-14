S4_Sys_Mycom = ISPanel:derive("S4_Sys_Mycom")

function S4_Sys_Mycom:new(SysUI, Px, Py, Pw, Ph)
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

function S4_Sys_Mycom:initialise()
    ISPanel.initialise(self)
end

function S4_Sys_Mycom:createChildren()
    ISPanel.createChildren(self)

    local x = 40
    local y = 20
    if self.SysUI.IconImg then
        x = x + 40 + 64
    end
    local TextMaxX = 0
    -- System: )
    self.SystemLabel = ISLabel:new(x, y, S4_UI.FH_S, getText("IGUI_S4_Label_System"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SystemLabel)
    TextMaxX = math.max(TextMaxX, self.SystemLabel:getWidth())
    y = y + S4_UI.FH_S
    -- Windows Information (Zomsoft Zomdows 88)
    self.ZomdowLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_Zomdow"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ZomdowLabel)
    TextMaxX = math.max(TextMaxX, self.ZomdowLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- Edition (First Edition)
    self.EditionLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_Edition"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.EditionLabel)
    TextMaxX = math.max(TextMaxX, self.EditionLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- Version (1.1.3412 B)
    self.VersionLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_Version"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.VersionLabel)
    TextMaxX = math.max(TextMaxX, self.VersionLabel:getWidth() + 15)
    y = y + S4_UI.FH_S * 2

    -- User information (Registered:)
    self.RegisteredLabel = ISLabel:new(x, y, S4_UI.FH_S, getText("IGUI_S4_Label_Registered"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.RegisteredLabel)
    TextMaxX = math.max(TextMaxX, self.RegisteredLabel:getWidth())
    y = y + S4_UI.FH_S
    -- OS information (Zomdows 88 First Edition)
    self.OSLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_OS"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.OSLabel)
    TextMaxX = math.max(TextMaxX, self.OSLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- OS Company (HINDSoft Corporation)
    self.OSCorpLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_OsCorp"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.OSCorpLabel)
    TextMaxX = math.max(TextMaxX, self.OSCorpLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- serial number()
    local Serial = self.ComUI.ComObj:getX().."-PRO-0"..self.ComUI.ComObj:getY().."-010"..self.ComUI.ComObj:getZ()
    self.SystemLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, Serial, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SystemLabel)
    TextMaxX = math.max(TextMaxX, self.SystemLabel:getWidth() + 15)
    y = y + S4_UI.FH_S * 2

    -- Computer:
    self.ComputerLabel = ISLabel:new(x, y, S4_UI.FH_S, getText("IGUI_S4_Label_Computer"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ComputerLabel)
    TextMaxX = math.max(TextMaxX, self.ComputerLabel:getWidth())
    y = y + S4_UI.FH_S
    -- CPU Processor (Zomtium(r) II Processor)
    self.ProcessorLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_CPU"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ProcessorLabel)
    TextMaxX = math.max(TextMaxX, self.ProcessorLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- Processor Company (Zomtel ZBX(ZB) Technology)
    self.ProcessorCoprLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_CPUCopr"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ProcessorCoprLabel)
    TextMaxX = math.max(TextMaxX, self.ProcessorCoprLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- RAM (128.0MB RAM)
    self.RamLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_MyCom_Ram"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.RamLabel)
    TextMaxX = math.max(TextMaxX, self.RamLabel:getWidth() + 15)
    y = y + S4_UI.FH_S * 2

    -- Equipment object verification code
    local ComModData = self.ComUI.ComObj:getModData()
    local TextValue1 = getText("IGUI_S4_MyCom_Uninstalled")
    local TextValue2 = getText("IGUI_S4_MyCom_Uninstalled")
    if ComModData then
        if ComModData.ComCardReader then
            TextValue1 = getText("IGUI_S4_MyCom_Installed")
        end
        if ComModData.ComSatellite then
            TextValue2 = getText("IGUI_S4_MyCom_Installed")
        end
    end

    -- Equipment:
    self.DevieceLabel = ISLabel:new(x, y, S4_UI.FH_S, getText("IGUI_S4_Label_Deviece"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.DevieceLabel)
    TextMaxX = math.max(TextMaxX, self.DevieceLabel:getWidth())
    y = y + S4_UI.FH_S
    -- Card Reader (CardReader: )
    self.CardReaderLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_Label_CardReader")..TextValue1, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.CardReaderLabel)
    TextMaxX = math.max(TextMaxX, self.CardReaderLabel:getWidth() + 15)
    y = y + S4_UI.FH_S
    -- Satellite antenna (SatelliteDish: )
    self.SatelliteDishLabel = ISLabel:new(x + 15, y, S4_UI.FH_S, getText("IGUI_S4_Label_SatelliteDish")..TextValue2, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SatelliteDishLabel)
    TextMaxX = math.max(TextMaxX, self.SatelliteDishLabel:getWidth() + 15)
    y = y + S4_UI.FH_S + 20
    -- Internet
    TextMaxX = x + TextMaxX + 40

    local BtnX = TextMaxX - 110
    self.OKBtn = ISButton:new(BtnX, y, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_Mycom.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    y = y + self.OKBtn:getHeight() + 10


    self.SysUI:FixUISize(TextMaxX, y)
end

function S4_Sys_Mycom:BtnClick(Button)
    local internal = Button.internal
    if internal == "Ok" then
        self.SysUI:close()
    end
end
-- Functions related to moving and exiting UI
function S4_Sys_Mycom:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_Mycom:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end


function S4_Sys_Mycom:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
