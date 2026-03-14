S4_Sys_Network = ISPanel:derive("S4_Sys_Network")

function S4_Sys_Network:new(SysUI, Px, Py, Pw, Ph)
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

function S4_Sys_Network:initialise()
    ISPanel.initialise(self)
    
end

function S4_Sys_Network:createChildren()
    ISPanel.createChildren(self)

    local TextSatellite = getText("IGUI_S4_Network_UnConnected")
    local TextNetwork = getText("IGUI_S4_Network_UnConnected")
    local TextIPv4 = getText("IGUI_S4_Network_UnConnected")
    local TextMedia = getText("IGUI_S4_Network_UnAvailable")
    local TextDesc = getText("IGUI_S4_Network_UnAvailable")
    local TextIP = getText("IGUI_S4_Network_UnConnected")
    local TextNetCorp = getText("IGUI_S4_Network_UnKnown")
    local TextContract = getText("IGUI_S4_Network_UnKnown")
    local TextPeriod = getText("IGUI_S4_Network_UnKnown")

    local ComModData = self.ComUI.ComObj:getModData()
    if ComModData then
        if ComModData.ComSatellite then
            TextSatellite = getText("IGUI_S4_Network_Connected")
            TextNetwork = getText("IGUI_S4_Network_Limit")
            TextIPv4 = getText("IGUI_S4_Network_Internet")
            TextMedia = getText("IGUI_S4_Network_Available")
            TextDesc = getText("IGUI_S4_Network_PCIe")
            TextIP = "127.0.0.1"
            TextNetCorp = getText("IGUI_S4_Network_Corp")
            TextContract = getText("IGUI_S4_Network_UnAvailable")
            if ComModData.ComPeriod then
                TextPeriod = ComModData.ComPeriod
            end
            if self.ComUI.NetContract then
                TextNetwork = getText("IGUI_S4_Network_Available")
                TextContract = getText("IGUI_S4_Network_Available")
            end
        end
    end

    local Tx = 40
    local Ty = 20
    if self.SysUI.IconImg then
        Tx = Tx + 40 + 64
    end
    local TextMaxX = 0
    -- System
    self.SystemLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, getText("IGUI_S4_Label_System"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SystemLabel)
    TextMaxX = math.max(TextMaxX, self.SystemLabel:getWidth())
    Ty = Ty + S4_UI.FH_S
    -- Satellite Dish
    TextSatellite = getText("IGUI_S4_Label_SatelliteDish") .. TextSatellite
    self.SatelliteDishLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextSatellite, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SatelliteDishLabel)
    TextMaxX = math.max(TextMaxX, self.SatelliteDishLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S
    -- Network State
    TextNetwork = getText("IGUI_S4_Label_NetworkState") .. TextNetwork
    self.NetStateLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextNetwork, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.NetStateLabel)
    TextMaxX = math.max(TextMaxX, self.NetStateLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S * 2

    -- Connection
    self.ConnectionLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, getText("IGUI_S4_Label_Connection"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ConnectionLabel)
    TextMaxX = math.max(TextMaxX, self.ConnectionLabel:getWidth())
    Ty = Ty + S4_UI.FH_S 
    -- IPv4 Connectivity
    TextIPv4 = getText("IGUI_S4_Label_IPv4Connectivity") .. TextIPv4
    self.IPv4ConnectivityLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextIPv4, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.IPv4ConnectivityLabel)
    TextMaxX = math.max(TextMaxX, self.IPv4ConnectivityLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S
    -- Media
    TextMedia = getText("IGUI_S4_Label_Media") .. TextMedia
    self.MediaLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextMedia, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MediaLabel)
    TextMaxX = math.max(TextMaxX, self.MediaLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S * 2

    -- Network
    self.NetworkLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, getText("IGUI_S4_Label_Network"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.NetworkLabel)
    TextMaxX = math.max(TextMaxX, self.NetworkLabel:getWidth())
    Ty = Ty + S4_UI.FH_S
    -- Description
    TextDesc = getText("IGUI_S4_Label_Description") .. TextDesc
    self.DescriptionLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextDesc, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.DescriptionLabel)
    TextMaxX = math.max(TextMaxX, self.DescriptionLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S
    -- IPv4 Address 127.000.000.000
    TextIP = getText("IGUI_S4_Label_IPv4Address") .. TextIP
    self.IPv4AddressLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextIP, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.IPv4AddressLabel)
    TextMaxX = math.max(TextMaxX, self.IPv4AddressLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S
    -- Network Provider (Contract Corp)
    TextNetCorp = getText("IGUI_S4_Label_ContractCorp") .. TextNetCorp
    self.NetCorpLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextNetCorp, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.NetCorpLabel)
    TextMaxX = math.max(TextMaxX, self.NetCorpLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S
    -- Contract State
    TextContract = getText("IGUI_S4_Label_ContractState") .. TextContract
    self.ContractStateLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextContract, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ContractStateLabel)
    TextMaxX = math.max(TextMaxX, self.ContractStateLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S
    -- Contract Period
    TextPeriod = getText("IGUI_S4_Label_ContractPeriod") .. TextPeriod
    self.PeriodLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, TextPeriod, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.PeriodLabel)
    TextMaxX = math.max(TextMaxX, self.PeriodLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S + 20

    TextMaxX = Tx + TextMaxX + 40

    local BtnX = TextMaxX - 110
    self.OKBtn = ISButton:new(BtnX, Ty, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_Network.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    Ty = Ty + self.OKBtn:getHeight() + 10

    self.SysUI:FixUISize(TextMaxX, Ty)
end

function S4_Sys_Network:BtnClick(Button)
    local internal = Button.internal
    if internal == "Ok" then
        self.SysUI:close()
    end
end

-- Functions related to moving and exiting UI
function S4_Sys_Network:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_Network:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end

function S4_Sys_Network:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
