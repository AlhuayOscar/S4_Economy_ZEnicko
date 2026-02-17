S4_ATM_Withdraw = ISPanel:derive("S4_ATM_Withdraw")
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

function S4_ATM_Withdraw:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Withdraw:initialise()
    ISPanel.initialise(self)

    self.AtmUI.MenuBtn4.internal = "Withdraw_Ok"
    self.AtmUI.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Withdraw_Ok"))
    self.AtmUI.MenuBtn5.internal = "Undo"
    self.AtmUI.MenuBtn5:setTitle(getText("IGUI_S4_ATM_Cancel"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn1:setVisible(false)
    self.AtmUI.MenuBtn2:setVisible(false)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(true)
    self.AtmUI.MenuBtn5:setVisible(true)
    self.AtmUI.MenuBtn6:setVisible(true)
    local CardModData = ModData.get("S4_CardData")
    if CardModData[self.AtmUI.CardNumber] then
        self.CardMoney = CardModData[self.AtmUI.CardNumber].Money
    end
end

function S4_ATM_Withdraw:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_Withdraw")
    local InfoText = getText("IGUI_S4_ATM_Info_Withdraw")
    local MsgText = ""

    local TitleW = getTextManager():MeasureStringX(UIFont.Medium, TitleText)
    local TitleX = (self:getWidth() / 2) - (TitleW / 2)
    local TextY = 10
    self.TitleLabel = ISLabel:new(TitleX, TextY, S4_UI.FH_M, TitleText, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.TitleLabel)
    TextY = TextY + S4_UI.FH_M

    local InfoW = getTextManager():MeasureStringX(UIFont.Small, InfoText)
    local InfoX = (self:getWidth() / 2) - (InfoW / 2)
    self.InfoLabel = ISLabel:new(InfoX, TextY, S4_UI.FH_S, InfoText, 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel)
    TextY = TextY + S4_UI.FH_S

    local MsgW = getTextManager():MeasureStringX(UIFont.Small, MsgText)
    local MsgX = (self:getWidth() / 2) - (MsgW / 2)
    self.MsgLabel = ISLabel:new(MsgX, TextY, S4_UI.FH_S, MsgText, 1, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel)
    self.MsgLabel:setVisible(false)

    local InputPanelH = S4_UI.FH_M + S4_UI.FH_L + 20
    local InputPanelY = TextY + (self:getHeight() - TextY) / 2 - (InputPanelH / 2)
    self.InputPanel = ISPanel:new(50, InputPanelY, self:getWidth() - 100, InputPanelH)
    self.InputPanel:initialise()
    self.InputPanel:instantiate()
    self.InputPanel.onMouseUp = S4_ATM_Deposit.onMouseUp_Insert
    self.InputPanel.DepositUI = self
    self.InputPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
    self.InputPanel.backgroundColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self:addChild(self.InputPanel)

    
    local InputW = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Withdraw_Box"))
    local InputX = (self:getWidth() / 2) - (InputW / 2)
    local InputY = self.InputPanel:getY()
    self.InputLabel = ISLabel:new(InputX, InputY, S4_UI.FH_M, getText("IGUI_S4_ATM_Withdraw_Box"), 0, 0, 0, 1, UIFont.Medium, true)
    self:addChild(self.InputLabel)

    local EntryX = self.InputPanel:getX() + 10
    local EntryY = InputY + S4_UI.FH_M + 10
    self.MoneyEntry = ISTextEntryBox:new("0", EntryX, EntryY, self:getWidth() - 120, S4_UI.FH_L)
    self.MoneyEntry.font = UIFont.Medium
    self.MoneyEntry.backgroundColor = {r=1, g=1, b=1, a=0.8}
    self.MoneyEntry.borderColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self.MoneyEntry:initialise()
    self.MoneyEntry:instantiate()
    self.MoneyEntry:setTextRGBA(0, 0, 0, 1)
    self.MoneyEntry:setOnlyNumbers(true)
    self:addChild(self.MoneyEntry)

    self.CashW = self.InputPanel:getWidth()
    self.CashY = self.InputPanel:getY() - (20 + S4_UI.FH_M + S4_UI.FH_S)
end

function S4_ATM_Withdraw:render()
    ISPanel.initialise(self)

    local CashH = S4_UI.FH_M + S4_UI.FH_S
    self:drawRect(50, self.CashY, self.CashW, CashH, 0.1, 1, 1, 1)
    self:drawRectBorder(50, self.CashY, self.CashW, CashH, 0.9, 0.64, 0.64, 0.64)

    local CashW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Withdraw_Cash"))
    local CashX = (self:getWidth() / 2) - (CashW / 2)
    self:drawText(getText("IGUI_S4_ATM_Withdraw_Cash"), CashX, self.CashY + 1, 1, 1, 1, 1, UIFont.Small)

    local FixCash = S4_UI.getNumCommas(self.CardMoney)
    local CashValue = string.format(getText("IGUI_S4_ATM_Money_Value"), FixCash)
    local CashValueW = getTextManager():MeasureStringX(UIFont.Medium, CashValue)
    local CashValueX = (self:getWidth() / 2) - (CashValueW / 2)
    self:drawText(CashValue, CashValueX, self.CashY + S4_UI.FH_S, 1, 1, 1, 1, UIFont.Medium)
end

function S4_ATM_Withdraw:ActionWithdraw()
    local CardModData = ModData.get("S4_CardData")
    local CardNum = self.AtmUI.CardNumber
    if CardModData[CardNum] then
        local MoneyBalance = CardModData[CardNum].Money
        local Text = self.MoneyEntry:getText()
        if Text == "" then Text = "0" end
        local filteredText = Text:gsub("[^%d]", "")
        if filteredText == "" then filteredText = "0" end
        filteredText = filteredText:gsub("^0+", "")
        if filteredText == "" then filteredText = "0" end
        self.MoneyEntry:setText(filteredText)
        local Value = tonumber(filteredText)
        if Value > 0 then
            if (MoneyBalance - Value) >= getCardCreditLimit() then
                getSoundManager():playUISound("S4_ATM_Money_Dispensing")
                self:setMsg(getText("IGUI_S4_ATM_Msg_Withdraw_Action"))
                local Count = 0
                local Target = 410
                local function UpdateCount_Withdraw()
                    Count = Count + 1
                    self.AtmUI.EventAction = true
                    if PerformanceSettings.getLockFPS() then
                        Target = PerformanceSettings.getLockFPS() * 7
                    end
                    if Count >= Target then
                        Events.OnTick.Remove(UpdateCount_Withdraw)
                        -- server transfer function
                        local LogTime = S4_Utils.getLogTime()
                        sendClientCommand("S4ED", "RemoveMoney", {CardNum, Value})
                        sendClientCommand("S4ED", "AddCardLog", {CardNum, LogTime, "Withdraw", Value, "Card", "ATM"})
                        -- Withdrawal function
                        S4_Utils.giveWithdrawMoney(self.player, Value)
                        self.AtmUI.EventAction = false
                        self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_Withdraw"))
                    else
                        return
                    end
                end
                Events.OnTick.Add(UpdateCount_Withdraw)
            else
                self:setMsg(getText("IGUI_S4_ATM_Msg_LowBalance"))
            end
        else
            self:setMsg(getText("IGUI_S4_ATM_Msg_EntryZero"))
        end
    end
end

function S4_ATM_Withdraw:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Withdraw:setTitleInfo(Title, Info)
    self.TitleLabel:setName(Title)
    local TitleString = getTextManager():MeasureStringX(UIFont.Medium, Title)
    local TitleX = (self:getWidth() / 2) - (TitleString / 2)
    self.TitleLabel:setX(TitleX)

    self.InfoLabel:setName(Info)
    local InfoString = getTextManager():MeasureStringX(UIFont.Small, Info)
    local InfoX = (self:getWidth() / 2) - (InfoString / 2)
    self.InfoLabel:setX(InfoX)

    self.MsgLabel:setVisible(false)
end

function S4_ATM_Withdraw:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Withdraw:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end
