S4_Bank_Account = ISPanel:derive("S4_Bank_Account")

function S4_Bank_Account:new(BankUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=0}
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=0}
    o.BankUI = BankUI
    o.ComUI = BankUI.ComUI
    o.player = BankUI.player
    o.MyCards = {}
    o.AllList = {}
    o.DepositList = {}
    o.WithdrawList = {}
    o.FilterType = "All"
    o.NowPage = 1
    o.PageMax = 1
    return o
end

function S4_Bank_Account:initialise()
    ISPanel.initialise(self)
    self:setData()
end

function S4_Bank_Account:setData()
    local PlayerName = self.player:getUsername()
    local CardModData = ModData.get("S4_CardData")
    if not CardModData then return end
    for CardNum, OriginalData in pairs(CardModData) do
        local Data = copyTable(OriginalData)
        if Data.Master == PlayerName then
            Data.CardNumber = CardNum
            self.MyCards[CardNum] = Data
        end
    end
end

function S4_Bank_Account:createChildren()
    ISPanel.createChildren(self)

    local x, y = 0, 0
    local ListW = ((self:getWidth() - 5) / 3) * 2
    local ListH = self:getHeight()
    self.ListPanel = ISPanel:new(x, y, ListW, ListH)
    self.ListPanel.AccountUI = self
    self.ListPanel.createChildren = S4_Bank_Account.ListChildren
    self.ListPanel.backgroundColor.a = 0
    self.ListPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.ListPanel:initialise()
    self.ListPanel:instantiate()
    self:addChild(self.ListPanel)

    x = ListW + 5
    local ControlW = (self:getWidth() - 5) / 3
    self.ControlPanel = ISPanel:new(x, y, ControlW, ListH)
    self.ControlPanel:initialise()
    self.ControlPanel:instantiate()
    self.ControlPanel.backgroundColor.a = 0
    self.ControlPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self:addChild(self.ControlPanel)
    y = y + 5

    self.MyCardBox = ISComboBox:new(x + 5, y, ControlW - 10, S4_UI.FH_M, self)
    self.MyCardBox.backgroundColor = {r=88/255, g=14/255, b=145/255, a=1}
    self.MyCardBox.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.MyCardBox.onChange = S4_Bank_Account.onChangeMyCard
    self:addChild(self.MyCardBox)
    if self.MyCards then
        for CardNumber, Data in pairs(self.MyCards) do
            local DisplayName = getText("IGUI_S4_Label_CardNumber") .. CardNumber
            self.MyCardBox:addOptionWithData(DisplayName, Data)
        end
    end
    y = y + S4_UI.FH_M + 10

    self.AllBtn = ISButton:new(x + 5, y, ControlW - 10, S4_UI.FH_M, getText("IGUI_S4_Bank_Btn_AllFilter"), self, S4_Bank_Account.FilterBtnClick)
    self.AllBtn.internal = "All"
    self.AllBtn.backgroundColorMouseOver.a = 0.7
    self.AllBtn.backgroundColor.a = 0
    self.AllBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.AllBtn.textColor.a = 0.9
    self.AllBtn:initialise()
    self:addChild(self.AllBtn)
    y = y + S4_UI.FH_M + 10

    self.DepositBtn = ISButton:new(x + 5, y, ControlW - 10, S4_UI.FH_M, getText("IGUI_S4_Bank_Btn_DepositFilter"), self, S4_Bank_Account.FilterBtnClick)
    self.DepositBtn.internal = "Deposit"
    self.DepositBtn.backgroundColorMouseOver.a = 0.7
    self.DepositBtn.backgroundColor.a = 0
    self.DepositBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.DepositBtn.textColor.a = 0.9
    self.DepositBtn:initialise()
    self:addChild(self.DepositBtn)
    y = y + S4_UI.FH_M + 10

    self.WithdrawBtn = ISButton:new(x + 5, y, ControlW - 10, S4_UI.FH_M, getText("IGUI_S4_Bank_Btn_WithdrawFilter"), self, S4_Bank_Account.FilterBtnClick)
    self.WithdrawBtn.internal = "Withdraw"
    self.WithdrawBtn.backgroundColorMouseOver.a = 0.7
    self.WithdrawBtn.backgroundColor.a = 0
    self.WithdrawBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.WithdrawBtn.textColor.a = 0.9
    self.WithdrawBtn:initialise()
    self:addChild(self.WithdrawBtn)
    y = y + S4_UI.FH_M + 10

    local PageBtnY = self:getHeight() - S4_UI.FH_M - 10
    self.LastBtn = ISButton:new(x + 5, PageBtnY, ControlW - 10, S4_UI.FH_M, getText("IGUI_S4_Bank_Btn_LastPage"), self, S4_Bank_Account.FilterBtnClick)
    self.LastBtn.internal = "LastPage"
    self.LastBtn.backgroundColorMouseOver.a = 0.7
    self.LastBtn.backgroundColor.a = 0
    self.LastBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.LastBtn.textColor.a = 0.9
    self.LastBtn:initialise()
    self:addChild(self.LastBtn)
    PageBtnY = PageBtnY - S4_UI.FH_M - 10
    
    self.FirstBtn = ISButton:new(x + 5, PageBtnY, ControlW - 10, S4_UI.FH_M, getText("IGUI_S4_Bank_Btn_FirstPage"), self, S4_Bank_Account.FilterBtnClick)
    self.FirstBtn.internal = "FirstPage"
    self.FirstBtn.backgroundColorMouseOver.a = 0.7
    self.FirstBtn.backgroundColor.a = 0
    self.FirstBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.FirstBtn.textColor.a = 0.9
    self.FirstBtn:initialise()
    self:addChild(self.FirstBtn)
    
    self:onChangeMyCard()
end

function S4_Bank_Account:ListChildren()
    ISPanel.createChildren(self)

    local x, y = 5, 5
    self.FilterLabel = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Bank_AllFilter"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.FilterLabel)
    local PageW = getTextManager():MeasureStringX(UIFont.Medium, "9999/9999")
    local PageX = self:getWidth() - PageW - 10
    self.PageLabel = ISLabel:new(PageX, y, S4_UI.FH_M, "0001/0001", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.PageLabel)

    local PanelY = S4_UI.FH_M + 10
    local PanelW = self:getWidth()
    local PanelH = math.floor(S4_UI.FH_M + 4)
    for i = 1, 20 do
        if i == 1 then
            self["Panel"..i] = ISPanel:new(0, PanelY, PanelW, PanelH)
            self["Panel"..i].createChildren = S4_Bank_Account.PanelChildren
            self["Panel"..i].backgroundColor.a = 0
            self["Panel"..i].borderColor = {r=0.7, g=0.7, b=0.7, a=1}
            self["Panel"..i]:initialise()
            self["Panel"..i]:instantiate()
            self:addChild(self["Panel"..i])
            PanelY = PanelY + PanelH - 1
        else
            if PanelY + PanelH - 1 > self:getHeight() then
                self.AccountUI.ListCount = i - 1
                break
            else
                self["Panel"..i] = ISPanel:new(0, PanelY, PanelW, PanelH)
                self["Panel"..i].createChildren = S4_Bank_Account.PanelChildren
                self["Panel"..i].backgroundColor.a = 0
                self["Panel"..i].borderColor = {r=0.7, g=0.7, b=0.7, a=1}
                self["Panel"..i]:initialise()
                self["Panel"..i]:instantiate()
                self:addChild(self["Panel"..i])
                PanelY = PanelY + PanelH - 1
            end
        end
    end
end

function S4_Bank_Account:PanelChildren()
    ISPanel.createChildren(self)
    local TextX = 10
    local TextY = 2 + (S4_UI.FH_M - S4_UI.FH_S) / 2
    self.TimeLabel = ISLabel:new(TextX, TextY, S4_UI.FH_S, "", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.TimeLabel)

    local TimeW = getTextManager():MeasureStringX(UIFont.Small, "[9999-99-99 99:99]")
    TextX = TextX + TimeW + 10

    self.DumpPanel1 = ISPanel:new(TextX, 1, 1, self:getHeight() - 2)
    self.DumpPanel1.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.DumpPanel1.borderColor.a = 0
    self.DumpPanel1:initialise()
    self.DumpPanel1:instantiate()
    self:addChild(self.DumpPanel1)

    TextX = TextX + 10
    self.TypeLabel = ISLabel:new(TextX, TextY, S4_UI.FH_S, "", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.TypeLabel)
    local Text2W = math.max(getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Deposit")), getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Withdraw")))
    TextX = TextX + Text2W + 10

    self.DumpPanel2 = ISPanel:new(TextX, 1, 1, self:getHeight() - 2)
    self.DumpPanel2.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.DumpPanel2.borderColor.a = 0
    self.DumpPanel2:initialise()
    self.DumpPanel2:instantiate()
    self:addChild(self.DumpPanel2)
    TextX = TextX + 10

    self.MoneyLabel = ISLabel:new(TextX, TextY, S4_UI.FH_S, "", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.MoneyLabel)
    local Text3W = getTextManager():MeasureStringX(UIFont.Small, "$ 999,999,999")
    TextX = TextX + Text3W + 10

    self.DumpPanel3 = ISPanel:new(TextX, 1, 1, self:getHeight() - 2)
    self.DumpPanel3.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.DumpPanel3.borderColor.a = 0
    self.DumpPanel3:initialise()
    self.DumpPanel3:instantiate()
    self:addChild(self.DumpPanel3)
    TextX = TextX + 10

    self.NameLabel = ISLabel:new(TextX, TextY, S4_UI.FH_S, "", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.NameLabel)
    local Text3W = getTextManager():MeasureStringX(UIFont.Small, "Survivor Network")
    TextX = TextX + Text3W + 10

    -- self.DumpPanel4 = ISPanel:new(TextX, 1, 1, self:getHeight() - 2)
    -- self.DumpPanel4.backgroundColor = {r=0.7, g=0.7, b=0.7, a=1}
    -- self.DumpPanel4.borderColor.a = 0
    -- self.DumpPanel4:initialise()
    -- self.DumpPanel4:instantiate()
    -- self:addChild(self.DumpPanel4)
    -- TextX = TextX + 10

    -- local BtnW = self:getWidth() - TextX - 10
    -- self.InfoBtn = ISButton:new(TextX, TextY - 2, BtnW, S4_UI.FH_S + 4, "Info", self, S4_Bank_Account.InfoBtnClick)
    -- self.InfoBtn.backgroundColorMouseOver.a = 0.7
    -- self.InfoBtn.backgroundColor.a = 0
    -- self.InfoBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    -- self.InfoBtn.textColor.a = 0.9
    -- self.InfoBtn:initialise()
    -- self.InfoBtn:setVisible(false)
    -- self:addChild(self.InfoBtn)
end

function S4_Bank_Account:onChangeMyCard()
    if self.MyCardBox and self.MyCardBox:getSelected() then
        local Select = self.MyCardBox:getSelected()
        local SelectCardData = self.MyCardBox:getOptionData(Select)
        if Select and SelectCardData and SelectCardData.CardNumber then
            local CardLogModData = ModData.get("S4_CardLog")
            if CardLogModData[SelectCardData.CardNumber] then
                self.DepositList, self.WithdrawList, self.AllList = {}, {}, {}

                local DeCount, WiCount, AlCount = 0, 0, 0
                self.DeMax, self.WiMax, self.AlMax = 1, 1, 1
                for Tiem, Original in pairs(CardLogModData[SelectCardData.CardNumber]) do
                    local Data = copyTable(Original)
                    if Data.Type == "Deposit" then
                        local DeData = copyTable(Data)
                        DeCount = DeCount + 1
                        if DeCount > self.ListCount then
                            DeCount = 1
                            self.DeMax = self.DeMax + 1
                        end
                        DeData.DisplayName = Data.Sender
                        DeData.ItemCount = DeCount
                        DeData.Page = self.DeMax
                        table.insert(self.DepositList, DeData)
                        Data.DisplayName = Data.Sender
                    elseif Data.Type == "Withdraw" then
                        local WiData = copyTable(Data)
                        WiCount = WiCount + 1
                        if WiCount > self.ListCount then
                            WiCount = 1
                            self.WiMax = self.WiMax + 1
                        end
                        WiData.DisplayName = Data.Receiver
                        WiData.ItemCount = WiCount
                        WiData.Page = self.WiMax
                        table.insert(self.WithdrawList, WiData)
                        Data.DisplayName = Data.Receiver
                    else
                        Data.DisplayName = Data.Receiver
                    end
                    AlCount = AlCount + 1
                    if AlCount > self.ListCount then
                        AlCount = 1
                        self.AlMax = self.AlMax + 1
                    end
                    Data.ItemCount = AlCount
                    Data.Page = self.AlMax
                    table.insert(self.AllList, Data)
                end
                self.PageMax = 1
                self.NowPage = 1
                self:setPage()
            end
        end
    end
end

function S4_Bank_Account:setPage()
    self.PageMax = self.AlMax
    local TypeText = getText("IGUI_S4_Bank_AllFilter")
    if self.FilterType == "Deposit" then
        self.PageMax = self.DeMax
        TypeText = getText("IGUI_S4_Bank_DepositFilter")
    elseif self.FilterType == "Withdraw" then
        self.PageMax = self.WiMax
        TypeText = getText("IGUI_S4_Bank_WithdrawFilter")
    end
    self.ListPanel.FilterLabel:setName(TypeText)
    local PageText = string.format("%04d", self.NowPage) .. "/" .. string.format("%04d", self.PageMax)
    self.ListPanel.PageLabel:setName(PageText)
    self:setLogData()
end

function S4_Bank_Account:setLogData()
    local DataType = self.AllList
    if self.FilterType == "Deposit" then
        DataType = self.DepositList
    elseif self.FilterType == "Withdraw" then
        DataType = self.WithdrawList
    end
    if not DataType then return end
    if self.ListCount and self.ListCount > 0 then
        for i = 1, self.ListCount do
            local noData = true
            for _, CopyData in pairs(DataType) do
                if CopyData.Page == self.NowPage and CopyData.ItemCount == i then
                    self.ListPanel["Panel"..i].TimeLabel:setName("[" .. CopyData.DisplayTime .. "]")
                    self.ListPanel["Panel"..i].TypeLabel:setName(getText("IGUI_S4_ATM_" .. CopyData.Type))
                    -- self.ListPanel["Panel"..i].TypeLabel:setName(Data.Type)
                    local MoneyText = "$ " .. S4_UI.getNumCommas(CopyData.Money)
                    self.ListPanel["Panel"..i].MoneyLabel:setName(MoneyText)
                    -- local NameW = getTextManager():MeasureStringX(UIFont.Small, "Survivor Network")
                    -- local DisplayName = S4_UI.TextLimitOne(Data.DisplayName, NameW, UIFont.Small)
                    -- self.ListPanel["Panel"..i].NameLabel:setName(DisplayName)
                    self.ListPanel["Panel"..i].NameLabel:setName(CopyData.DisplayName)
                    -- self.ListPanel["Panel"..i].InfoBtn:setVisible(true)
                    noData = false
                end
            end
            if noData then
                self.ListPanel["Panel"..i].TimeLabel:setName("")
                self.ListPanel["Panel"..i].TypeLabel:setName("")
                self.ListPanel["Panel"..i].MoneyLabel:setName("")
                self.ListPanel["Panel"..i].NameLabel:setName("")
                -- self.ListPanel["Panel"..i].InfoBtn:setVisible(false)
            end
        end
    end
end

function S4_Bank_Account:FilterBtnClick(Button)
    local internal = Button.internal
    if internal == "All" or internal == "Deposit" or internal == "Withdraw" then
        self.FilterType = internal
        self.PageMax = 1
        self.NowPage = 1
        self:setPage()
    elseif internal == "FirstPage" then
        self.NowPage = 1
        self:setPage()
    elseif internal == "LastPage" then
        self.NowPage = self.PageMax
        self:setPage()
    end
end

function S4_Bank_Account:onMouseWheel(del)
    if del then
        local MaxPage = self.AlMax
        if self.FilterType == "Deposit" then
            MaxPage = self.DeMax
        elseif self.FilterType == "Withdraw" then
            MaxPage = self.WiMax
        end
        local SetPage = self.NowPage + del
        if MaxPage >= SetPage and SetPage > 0 then
            self.NowPage = SetPage
            self:setPage()
        end
    end
    return true
end

function S4_Bank_Account:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Bank_Account:onMouseDown(x, y)
    if self.BankUI.moveWithMouse then
        self.BankUI.moving = true
        self.BankUI.dragOffsetX = x
        self.BankUI.dragOffsetY = y
        self.BankUI:bringToTop()
    end
end