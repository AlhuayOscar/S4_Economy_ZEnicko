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
    TextMaxX = math.max(x + TextMaxX + 40, x + 380)

    local BtnX = TextMaxX - 110
    self.SignalListBtn = ISButton:new(BtnX - 180, y, 170, S4_UI.FH_S, "Listados de Signals", self, S4_Sys_Mycom.BtnClick)
    self.SignalListBtn.internal = "SignalList"
    self.SignalListBtn.textColor = {r=0, g=0, b=0, a=1}
    self.SignalListBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.SignalListBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.SignalListBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.SignalListBtn:initialise()
    self:addChild(self.SignalListBtn)

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
    elseif internal == "SignalList" then
        self.SysUI.PageType = "SignalList"
        self.SysUI.TitleName = "System Properties - Signals"
        self.SysUI:ReloadUI()
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

S4_Sys_SignalList = ISPanel:derive("S4_Sys_SignalList")

local function S4_getSignalAccount(player)
    local root = ModData.get("S4_PlayerShopData")
    if not root or not player then
        return nil
    end
    return root[player:getUsername()]
end

local function S4_buildSignalRows(account)
    local rows = {}
    if not account or not account.DeliveryList then
        return rows
    end

    local seen = {}
    local order = account.DeliveryOrder or {}
    for i = 1, #order do
        local code = order[i]
        if code and account.DeliveryList[code] and not seen[code] then
            rows[#rows + 1] = {code = code, name = account.DeliveryList[code]}
            seen[code] = true
        end
    end

    local missing = {}
    for code, name in pairs(account.DeliveryList) do
        if not seen[code] then
            missing[#missing + 1] = {code = code, name = name}
        end
    end
    table.sort(missing, function(a, b)
        return tostring(a.name) < tostring(b.name)
    end)
    for i = 1, #missing do
        rows[#rows + 1] = missing[i]
    end
    return rows
end

local function S4_applySignalOrder(player, rows)
    local account = S4_getSignalAccount(player)
    if not account then
        return
    end
    account.DeliveryOrder = {}
    for i = 1, #rows do
        account.DeliveryOrder[#account.DeliveryOrder + 1] = rows[i].code
    end
    sendClientCommand("S4PD", "SetDeliveryOrder", account.DeliveryOrder)
end

local function S4_styleSignalButton(button)
    button.textColor = {r=0, g=0, b=0, a=1}
    button.borderColor = {r=0, g=0, b=0, a=1}
    button.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    button.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
end

function S4_Sys_SignalList:new(SysUI, Px, Py, Pw, Ph)
    local o = ISPanel:new(Px, Py, Pw, Ph)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=189/255, g=190/255, b=189/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
    o.SysUI = SysUI
    o.ComUI = SysUI.ComUI
    o.player = SysUI.player
    o.Moving = true
    return o
end

function S4_Sys_SignalList:initialise()
    ISPanel.initialise(self)
end

function S4_Sys_SignalList:createChildren()
    ISPanel.createChildren(self)

    self.rows = S4_buildSignalRows(S4_getSignalAccount(self.player))
    local TextMaxX = 560
    local x = 24
    local y = 20

    self.TitleLabel = ISLabel:new(x, y, S4_UI.FH_S, "Listados de Signals", 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.TitleLabel)
    y = y + S4_UI.FH_S + 4
    self.InfoLabel = ISLabel:new(x, y, S4_UI.FH_S, "Usa Subir/Bajar para definir cual aparece primero en Delivery.", 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel)
    y = y + S4_UI.FH_S + 10

    if #self.rows == 0 then
        self.EmptyLabel = ISLabel:new(x, y, S4_UI.FH_S, "No hay Signals instaladas.", 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.EmptyLabel)
        y = y + S4_UI.FH_S + 20
    else
        for i = 1, #self.rows do
            local row = self.rows[i]
            local rowText = string.format("%02d. %s", i, tostring(row.name or "Signal"))
            local codeText = tostring(row.code or "")

            self["SignalName" .. i] = ISLabel:new(x, y, S4_UI.FH_S, rowText, 0, 0, 0, 1, UIFont.Small, true)
            self:addChild(self["SignalName" .. i])

            self["SignalCode" .. i] = ISLabel:new(x + 18, y + S4_UI.FH_S, S4_UI.FH_S, codeText, 0.25, 0.25, 0.25, 1, UIFont.Small, true)
            self:addChild(self["SignalCode" .. i])

            self["SignalUp" .. i] = ISButton:new(TextMaxX - 235, y, 55, S4_UI.FH_S, "Subir", self, S4_Sys_SignalList.BtnClick)
            self["SignalUp" .. i].internal = "Up"
            self["SignalUp" .. i].index = i
            S4_styleSignalButton(self["SignalUp" .. i])
            self["SignalUp" .. i]:initialise()
            self:addChild(self["SignalUp" .. i])

            self["SignalDown" .. i] = ISButton:new(TextMaxX - 175, y, 55, S4_UI.FH_S, "Bajar", self, S4_Sys_SignalList.BtnClick)
            self["SignalDown" .. i].internal = "Down"
            self["SignalDown" .. i].index = i
            S4_styleSignalButton(self["SignalDown" .. i])
            self["SignalDown" .. i]:initialise()
            self:addChild(self["SignalDown" .. i])

            self["SignalDelete" .. i] = ISButton:new(TextMaxX - 115, y, 90, S4_UI.FH_S, "Eliminar", self, S4_Sys_SignalList.BtnClick)
            self["SignalDelete" .. i].internal = "Delete"
            self["SignalDelete" .. i].index = i
            S4_styleSignalButton(self["SignalDelete" .. i])
            self["SignalDelete" .. i]:initialise()
            self:addChild(self["SignalDelete" .. i])

            y = y + (S4_UI.FH_S * 2) + 10
        end
        y = y + 5
    end

    self.BackBtn = ISButton:new(TextMaxX - 220, y, 100, S4_UI.FH_S, "Volver", self, S4_Sys_SignalList.BtnClick)
    self.BackBtn.internal = "Back"
    S4_styleSignalButton(self.BackBtn)
    self.BackBtn:initialise()
    self:addChild(self.BackBtn)

    self.OKBtn = ISButton:new(TextMaxX - 110, y, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_SignalList.BtnClick)
    self.OKBtn.internal = "Ok"
    S4_styleSignalButton(self.OKBtn)
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    y = y + self.OKBtn:getHeight() + 10

    if self.Reload then
        self.SysUI:ReloadFixUISize(TextMaxX, y)
    else
        self.SysUI:FixUISize(TextMaxX, y)
    end
end

function S4_Sys_SignalList:BtnClick(Button)
    local internal = Button.internal
    local index = Button.index or 0
    if internal == "Ok" then
        self.SysUI:close()
    elseif internal == "Back" then
        self.SysUI.PageType = "MyCom"
        self.SysUI.TitleName = "System Properties - System"
        self.SysUI:ReloadUI()
    elseif internal == "Up" and index > 1 then
        self.rows[index], self.rows[index - 1] = self.rows[index - 1], self.rows[index]
        S4_applySignalOrder(self.player, self.rows)
        self.SysUI:ReloadUI()
    elseif internal == "Down" and index > 0 and index < #self.rows then
        self.rows[index], self.rows[index + 1] = self.rows[index + 1], self.rows[index]
        S4_applySignalOrder(self.player, self.rows)
        self.SysUI:ReloadUI()
    elseif internal == "Delete" and self.rows[index] then
        local account = S4_getSignalAccount(self.player)
        local code = self.rows[index].code
        if account and account.DeliveryList then
            account.DeliveryList[code] = nil
        end
        table.remove(self.rows, index)
        S4_applySignalOrder(self.player, self.rows)
        sendClientCommand("S4PD", "RemoveDeliveryList", {code})
        self.SysUI:ReloadUI()
    end
end

function S4_Sys_SignalList:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_SignalList:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end

function S4_Sys_SignalList:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
