S4_ATM_Transfer_Cash = ISPanel:derive("S4_ATM_Transfer")

function S4_ATM_Transfer_Cash:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Transfer_Cash:initialise()
    ISPanel.initialise(self)
    self.AtmUI.MenuBtn1:setVisible(false)
    if self.AtmUI.CardNumber and self.AtmUI.CardNumber ~= "Null" then
        self.AtmUI.MenuBtn1.internal = "Transfer_Card"
        self.AtmUI.MenuBtn1:setTitle(getText("IGUI_S4_ATM_Transfer_Card"))
        self.AtmUI.MenuBtn1:setVisible(true)
    end
    self.AtmUI.MenuBtn4.internal = "Transfer_Ok"
    self.AtmUI.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Transfer_Ok"))
    self.AtmUI.MenuBtn5.internal = "Undo"
    self.AtmUI.MenuBtn5:setTitle(getText("IGUI_S4_ATM_Cancel"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn2:setVisible(false)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(true)
    self.AtmUI.MenuBtn5:setVisible(true)
    self.AtmUI.MenuBtn6:setVisible(true)

    self.CashValue = 0
    self.CashItems = {}
end

function S4_ATM_Transfer_Cash:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_Transfer")
    local InfoText = getText("IGUI_S4_ATM_Info_TransferCash")
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

    local InsertPanelY = TextY + (self:getHeight() - TextY) / 2 + 30
    self.InsertPanel = ISPanel:new(50, InsertPanelY, self:getWidth() - 100, 100)
    self.InsertPanel:initialise()
    self.InsertPanel:instantiate()
    self.InsertPanel.onMouseUp = S4_ATM_Transfer_Cash.onMouseUp_Insert
    self.InsertPanel.TransferUI = self
    self.InsertPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
    self.InsertPanel.backgroundColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self:addChild(self.InsertPanel)

    self.CashW = self.InsertPanel:getWidth()
    self.CashY = self.InsertPanel:getY() - (20 + S4_UI.FH_M + S4_UI.FH_S)
    self.InsertY = self.InsertPanel:getY()

    local ReceiverH = S4_UI.FH_M + S4_UI.FH_S + 10
    self.ReceiverY = self.CashY - 20 - ReceiverH
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
                if Username ~= "admin" then
                    local fixName = string.format(getText("IGUI_S4_ATM_Receiver_Value"), Username, Data.MainCard)
                    self.ReceiverBox:addOptionWithData(fixName, Data)
                end
            end
        end
    end
end

function S4_ATM_Transfer_Cash:render()
    ISPanel.render(self)

    -- cash deposited
    local CashH = S4_UI.FH_M + S4_UI.FH_S
    self:drawRect(50, self.CashY, self.CashW, CashH, 0.1, 1, 1, 1)
    self:drawRectBorder(50, self.CashY, self.CashW, CashH, 0.9, 0.64, 0.64, 0.64)

    local CashW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Deposit_InsertCash"))
    local CashX = (self:getWidth() / 2) - (CashW / 2)
    self:drawText(getText("IGUI_S4_ATM_Deposit_InsertCash"), CashX, self.CashY, 1, 1, 1, 1, UIFont.Small)

    local FixCash = S4_UI.getNumCommas(self.CashValue)
    local CashValue = string.format(getText("IGUI_S4_ATM_Money_Value"), FixCash)
    local CashValueW = getTextManager():MeasureStringX(UIFont.Medium, CashValue)
    local CashValueX = (self:getWidth() / 2) - (CashValueW / 2)
    self:drawText(CashValue, CashValueX, self.CashY + S4_UI.FH_S, 1, 1, 1, 1, UIFont.Medium)
    -- Current entrance inlet
    local InsertW = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Deposit_InsertBox"))
    local InsertX = (self:getWidth() / 2) - (InsertW / 2)
    self:drawText(getText("IGUI_S4_ATM_Deposit_InsertBox"), InsertX, self.InsertY + 4, 1, 1, 1, 1, UIFont.Medium)
    
    local InsertBoxW = self.CashW - 20
    local InsertBoxH = 100 - S4_UI.FH_M - 20
    local InsertBoxY = self.InsertY + S4_UI.FH_M + 10
    self:drawRect(60, InsertBoxY, InsertBoxW, InsertBoxH , 1, 0, 0, 0)
    self:drawRectBorder(60, InsertBoxY, InsertBoxW, InsertBoxH, 0.8, 1, 1, 1)

    -- Account to receive money from
    -- self.ReceiverY
    local ReceiverW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Transfer_Receiver"))
    local ReceiverX = (self:getWidth() / 2) - (ReceiverW / 2)
    self:drawText(getText("IGUI_S4_ATM_Transfer_Receiver"), ReceiverX, self.ReceiverY, 1, 1, 1, 1, UIFont.Small)

end

function S4_ATM_Transfer_Cash:AtcionTransfer()
    local selectedIndex = self.ReceiverBox.selected
    local selectedData = self.ReceiverBox:getOptionData(selectedIndex)
    if selectedData then
        if self.CashValue > 0 then
            getSoundManager():playUISound("S4_ATM_Money_Dispensing")
            self:setMsg(getText("IGUI_S4_ATM_Msg_Transfer_Action"))
            local Count = 0
            local Target = 410
            local function UpdateCount_TransferCash()
                Count = Count + 1
                self.AtmUI.EventAction = true
                if PerformanceSettings.getLockFPS() then
                    Target = PerformanceSettings.getLockFPS() * 7
                end
                if Count >= Target then
                    Events.OnTick.Remove(UpdateCount_TransferCash)
                    -- server transfer function
                    local ReceiverCardNum = selectedData.MainCard
                    local LogTime = S4_Utils.getLogTime()
                    sendClientCommand("S4ED", "TransferCash", {ReceiverCardNum, self.CashValue, LogTime})
                    -- Initialization and main screen
                    self.CashValue = 0
                    self.CashItems = {}
                    self.AtmUI.EventAction = false
                    self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_Transfer"))
                else
                    return
                end
            end
            Events.OnTick.Add(UpdateCount_TransferCash)
        end
    else
        self:setMsg(getText("IGUI_S4_ATM_Msg_Transfer_ReceiverFail"))
    end
end

function S4_ATM_Transfer_Cash:onMouseUp_Insert()
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

function S4_ATM_Transfer_Cash:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Transfer_Cash:setTitleInfo(Title, Info)
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

function S4_ATM_Transfer_Cash:close()
    if #self.CashItems > 0 then
        for _, item in pairs(self.CashItems) do
            local Inv = self.player:getInventory()
            Inv:AddItem(item)
        end
        self.CashValue = 0
        self.CashItems = {}
    end
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Transfer_Cash:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end