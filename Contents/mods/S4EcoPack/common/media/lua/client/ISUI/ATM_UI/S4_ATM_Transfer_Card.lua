S4_ATM_Transfer_Card = ISPanel:derive("S4_ATM_Transfer")
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

function S4_ATM_Transfer_Card:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Transfer_Card:initialise()
    ISPanel.initialise(self)

    self.AtmUI.MenuBtn1.internal = "Transfer_Cash"
    self.AtmUI.MenuBtn1:setTitle(getText("IGUI_S4_ATM_Transfer_Cash"))
    self.AtmUI.MenuBtn4.internal = "Transfer_Ok"
    self.AtmUI.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Transfer_Ok"))
    self.AtmUI.MenuBtn5.internal = "Undo"
    self.AtmUI.MenuBtn5:setTitle(getText("IGUI_S4_ATM_Cancel"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn1:setVisible(true)
    self.AtmUI.MenuBtn2:setVisible(false)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(true)
    self.AtmUI.MenuBtn5:setVisible(true)
    self.AtmUI.MenuBtn6:setVisible(true)

end

function S4_ATM_Transfer_Card:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_Transfer")
    local InfoText = getText("IGUI_S4_ATM_Info_TransferCard")
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

    local EntryH = 20 + (S4_UI.FH_M * 2)
    local EntryY = TextY + (self:getHeight() - TextY) / 2 - (EntryH / 2)
    self.EntryPanel = ISPanel:new(50, EntryY, self:getWidth() - 100, EntryH)
    self.EntryPanel:initialise()
    self.EntryPanel:instantiate()
    self.EntryPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
    self.EntryPanel.backgroundColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self:addChild(self.EntryPanel)

    local EntryX = self.EntryPanel:getX() + 10
    self.MoneyEntry = ISTextEntryBox:new("0", EntryX, EntryY + S4_UI.FH_M + 7, self:getWidth() - 120, S4_UI.FH_M)
    self.MoneyEntry.font = UIFont.Medium
    self.MoneyEntry.backgroundColor = {r=1, g=1, b=1, a=0.8}
    self.MoneyEntry.borderColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self.MoneyEntry:initialise()
    self.MoneyEntry:instantiate()
    self.MoneyEntry:setTextRGBA(0, 0, 0, 1)
    self.MoneyEntry:setOnlyNumbers(true)
    self:addChild(self.MoneyEntry)

    self.CashW = self.EntryPanel:getWidth()
    self.CashY = self.EntryPanel:getY() - (20 + S4_UI.FH_M + S4_UI.FH_S)
    self.InsertY = self.EntryPanel:getY()

    local ReceiverH = S4_UI.FH_M + S4_UI.FH_S + 10
    self.ReceiverY = self.CashY - 10
    self.ReceiverPanel = ISPanel:new(50, self.ReceiverY, self:getWidth() - 100, ReceiverH)
    self.ReceiverPanel:initialise()
    self.ReceiverPanel:instantiate()
    self.ReceiverPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
    self.ReceiverPanel.backgroundColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self:addChild(self.ReceiverPanel)

    self.ReceiverBox = ISComboBox:new(60, self.ReceiverY + S4_UI.FH_S , self:getWidth() - 120, S4_UI.FH_M, self)
    self.ReceiverBox.backgroundColor = {r=0, g=0, b=0, a=1}
    self.ReceiverBox.borderColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self:addChild(self.ReceiverBox)

    local PlayerModData = ModData.get("S4_PlayerData")
    if PlayerModData then
        for Username, Data in pairs(PlayerModData) do
            if Data.MainCard then
                if Username ~= "admin" and Data.MainCard ~= self.AtmUI.CardNumber then
                    local fixName = string.format(getText("IGUI_S4_ATM_Receiver_Value"), Username, Data.MainCard)
                    self.ReceiverBox:addOptionWithData(fixName, Data)
                end
            end
        end
    end
end

function S4_ATM_Transfer_Card:render()
    ISPanel.initialise(self)

    -- Current entrance inlet
    local InsertW = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Transfer_SendMoney"))
    local InsertX = (self:getWidth() / 2) - (InsertW / 2)
    self:drawText(getText("IGUI_S4_ATM_Transfer_SendMoney"), InsertX, self.InsertY + 4, 1, 1, 1, 1, UIFont.Medium)
    
    -- Account to receive money from
    local ReceiverW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Transfer_Receiver"))
    local ReceiverX = (self:getWidth() / 2) - (ReceiverW / 2)
    self:drawText(getText("IGUI_S4_ATM_Transfer_Receiver"), ReceiverX, self.ReceiverY, 1, 1, 1, 1, UIFont.Small)

end

function S4_ATM_Transfer_Card:AtcionTransfer()
    local selectedIndex = self.ReceiverBox.selected
    local selectedData = self.ReceiverBox:getOptionData(selectedIndex)
    if selectedData then
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
                    local LogTime = S4_Utils.getLogTime()
                    local ReceiverCardNum = selectedData.MainCard
                    sendClientCommand("S4ED", "TransferCard", {CardNum, ReceiverCardNum, Value, LogTime})
                    self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_Transfer"))
                else -- insufficient balance
                    self:setMsg(getText("IGUI_S4_ATM_Msg_LowBalance"))
                end
            else -- 0 won remittance not possible
                self:setMsg(getText("IGUI_S4_ATM_Msg_EntryZero"))
            end
        end
    else -- No one to receive money
        self:setMsg(getText("IGUI_S4_ATM_Msg_Transfer_ReceiverFail"))
    end
end

function S4_ATM_Transfer_Card:onMouseUp_Insert()
    ISPanel.onMouseUp(self, x, y)
    if ISMouseDrag.dragging then
        local items = S4_Utils.getMoveItemTable(ISMouseDrag.dragging)
        if #items > 0 then
            for _, item in pairs(items) do
                if item and S4_Setting.MoneyList[item:getFullType()] then
                    self.TransferUI.CashValue = self.TransferUI.CashValue + S4_Setting.MoneyList[item:getFullType()]
                    table.insert(self.TransferUI.CashItems, item)
                    if item:getWorldItem() then
                        item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
                        ISInventoryPage.dirtyUI()
                    else
                        if item:getContainer() then
                            item:getContainer():Remove(item)
                        else
                            self.TransferUI.player:getInventory():Remove(item)
                        end
                    end
                end
            end
        end
    end
end

function S4_ATM_Transfer_Card:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Transfer_Card:setTitleInfo(Title, Info)
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

function S4_ATM_Transfer_Card:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Transfer_Card:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end
