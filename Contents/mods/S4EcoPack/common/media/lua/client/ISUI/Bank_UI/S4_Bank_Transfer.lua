S4_Bank_Transfer = ISPanel:derive("S4_Bank_Transfer")
local function getCardCreditLimit()
    local maxNegative = 1000
    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.MaxNegativeBalance then
        maxNegative = SandboxVars.S4SandBox.MaxNegativeBalance
    end
    if maxNegative < 0 then
        maxNegative = 0
    end
    return -maxNegative
end

function S4_Bank_Transfer:new(BankUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=0}
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    o.BankUI = BankUI
    o.ComUI = BankUI.ComUI
    o.player = BankUI.player
    return o
end

function S4_Bank_Transfer:initialise()
    ISPanel.initialise(self)
    self:setData()
end

function S4_Bank_Transfer:setData()
    if self.ComUI.CardNumber then
        local CardModData = ModData.get("S4_CardData")
        if CardModData and CardModData[self.ComUI.CardNumber] then
            self.CardNumber = self.ComUI.CardNumber
            self.CardMaster = CardModData[self.ComUI.CardNumber].Master
            self.CardMoney = CardModData[self.ComUI.CardNumber].Money
            self:setLable()
        end
    end
    local PlayerModData = ModData.get("S4_PlayerData")
    self.Account = {}
    if PlayerModData then
        for UserName, Data in pairs(PlayerModData) do
            if Data.MainCard then
                self.Account[UserName] = Data.MainCard
            end
        end
    end
end

function S4_Bank_Transfer:createChildren()
    ISPanel.createChildren(self)

    local x, y = 10, 10
    self.TextLabel1 = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_ATM_Info_TransferCard"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.TextLabel1)
    y = y + S4_UI.FH_M * 2

    self.MyCardLabel = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Label_MyCardInfo"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.MyCardLabel)
    y = y + S4_UI.FH_M
    local CardNumber = getText("IGUI_S4_Label_CardNumber") .. getText("IGUI_S4_CardReader_UnInsert")
    self.CardNumLabel = ISLabel:new(x, y, S4_UI.FH_M, CardNumber, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.CardNumLabel)
    y = y + S4_UI.FH_M
    local CardBalance = getText("IGUI_S4_Label_CardBalance") .. getText("IGUI_S4_Network_UnKnown")
    self.CardBalanceLable = ISLabel:new(x, y, S4_UI.FH_M, CardBalance, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.CardBalanceLable)
    y = y + S4_UI.FH_M
    local CardMaster = getText("IGUI_S4_Label_CardMaster") .. getText("IGUI_S4_Network_UnKnown")
    self.CardMasterLabel = ISLabel:new(x, y, S4_UI.FH_M, CardMaster, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.CardMasterLabel)
    y = y + S4_UI.FH_M

    local EntryW = self:getWidth() / 3
    local EntryH = S4_UI.FH_M
    local EntryX = self:getWidth() - EntryW - 10
    local EntryY = self:getHeight() - (EntryH * 2) - 10

    self.SendBtn= ISButton:new(EntryX, EntryY, EntryW, (EntryH * 2), "Send", self, S4_Bank_Transfer.BtnClick)
    -- self.SendBtn.internal = "Send"
    self.SendBtn.backgroundColorMouseOver.a = 0.7
    self.SendBtn.backgroundColor.a = 0
    self.SendBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.SendBtn.textColor.a = 0.9
    self.SendBtn.font = UIFont.Large
    self.SendBtn:initialise()
    self:addChild(self.SendBtn)
    EntryY = EntryY - EntryH - 14

    self.MoneyEntry = ISTextEntryBox:new("0", EntryX, EntryY, EntryW, EntryH + 4)
    self.MoneyEntry.font = UIFont.Medium
    self.MoneyEntry.backgroundColor.a = 0
    self.MoneyEntry.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.MoneyEntry:initialise()
    self.MoneyEntry:instantiate()
    self.MoneyEntry:setTextRGBA(1, 1, 1, 0.9)
    self.MoneyEntry:setOnlyNumbers(true)
    self:addChild(self.MoneyEntry)
    EntryY = EntryY - S4_UI.FH_M

    local Option1X = EntryX + (EntryW / 2) - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Transfer_SendMoney")) / 2)
    self.OptionLabel1 = ISLabel:new(Option1X, EntryY, S4_UI.FH_M, getText("IGUI_S4_ATM_Transfer_SendMoney"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.OptionLabel1)
    EntryY = EntryY - EntryH - 10

    self.AccountBox = ISComboBox:new(EntryX, EntryY, EntryW, EntryH, self)
    self.AccountBox.backgroundColor = {r=88/255, g=14/255, b=145/255, a=1}
    self.AccountBox.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self:addChild(self.AccountBox)
    for UserName, CardNum in pairs(self.Account) do
        if self.CardNumber ~= CardNum then
            self.AccountBox:addOptionWithData(UserName, CardNum)
        end
    end
    EntryY = EntryY - S4_UI.FH_M

    local Option2X = EntryX + (EntryW / 2) - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Transfer_Receiver")) / 2)
    self.OptionLabel2 = ISLabel:new(Option2X, EntryY, S4_UI.FH_M, getText("IGUI_S4_ATM_Transfer_Receiver"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.OptionLabel2)
    self:setLable()
end

function S4_Bank_Transfer:setLable()
    if self.CardNumLabel and self.CardNumber then
        self.CardNumLabel:setName(getText("IGUI_S4_Label_CardNumber") .. self.CardNumber)
    end
    if self.CardMasterLabel and self.CardMaster then
        self.CardMasterLabel:setName(getText("IGUI_S4_Label_CardMaster") .. self.CardMaster)
    end
    if self.CardBalanceLable and self.CardMoney then
        self.CardBalanceLable:setName(getText("IGUI_S4_Label_CardBalance") .. "$ " .. S4_UI.getNumCommas(self.CardMoney))
        if self.CardMoney < 0 then
            self.CardBalanceLable:setColor(1, 0, 0)
        else
            self.CardBalanceLable:setColor(1, 1, 1)
        end
    end
end

function S4_Bank_Transfer:BtnClick(Button)
    local selectedIndex = self.AccountBox.selected
    local selectedData = self.AccountBox:getOptionData(selectedIndex)
    if selectedData then
        local CardModData = ModData.get("S4_CardData")
        if CardModData[self.CardNumber] then
            if self.ComUI.isCardPassword then
                local MyMoney = CardModData[self.CardNumber].Money
                local ValueText, ValueNum = S4_UI.getFixPasswordNum(self.MoneyEntry:getText())
                self.MoneyEntry:setText(ValueText)
                if ValueNum > 0 then
                    if (MyMoney - ValueNum) >= getCardCreditLimit() then
                        local LogTime = S4_Utils.getLogTime()
                        sendClientCommand("S4ED", "TransferCard", {self.CardNumber, selectedData, ValueNum, LogTime})
                        -- Transfer completed
                        self.ComUI:AddMsgBox(getText("IGUI_S4_ATM_Transfer"), nil, getText("IGUI_S4_ATM_CompleteMsg_Transfer"))
                        self.BankUI:setMain("Home")
                    else -- insufficient balance
                        self.ComUI:AddMsgBox("Error - ZomBank", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_LowBalance"))
                    end
                else -- 0 won remittance not possible
                    self.ComUI:AddMsgBox("Error - ZomBank", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_EntryZero"))
                end
            else -- Password input required
                self.ComUI:CardPasswordCheck()
                self.ComUI:AddMsgBox("Error - ZomBank", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardPassword"), getText("IGUI_S4_ATM_Msg_NotCardPasswordTry"))
            end
        end
    else -- No one to receive money
        self.ComUI:AddMsgBox("Error - ZomBank", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_Transfer_ReceiverFail"))
    end
end

function S4_Bank_Transfer:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Bank_Transfer:onMouseDown(x, y)
    if self.BankUI.moveWithMouse then
        self.BankUI.moving = true
        self.BankUI.dragOffsetX = x
        self.BankUI.dragOffsetY = y
        self.BankUI:bringToTop()
    end
end
