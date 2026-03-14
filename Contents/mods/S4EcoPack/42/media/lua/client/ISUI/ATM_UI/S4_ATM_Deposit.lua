S4_ATM_Deposit = ISPanel:derive("S4_ATM_Deposit")

function S4_ATM_Deposit:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Deposit:initialise()
    ISPanel.initialise(self)

    self.AtmUI.MenuBtn4.internal = "Deposit_Ok"
    self.AtmUI.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Deposit_Ok"))
    self.AtmUI.MenuBtn5.internal = "Deposit_Return"
    self.AtmUI.MenuBtn5:setTitle(getText("IGUI_S4_ATM_ReturnCash"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn1:setVisible(false)
    self.AtmUI.MenuBtn2:setVisible(false)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(true)
    self.AtmUI.MenuBtn5:setVisible(true)
    self.AtmUI.MenuBtn6:setVisible(true)

    self.CashValue = 0
    self.CashItems = {} -- This will be used only for session items if needed, but we'll rely on counts
    
    self.Username = self.player:getUsername()
    local AtmModData = self.AtmUI.Obj:getModData()
    if AtmModData.S4_PendingDeposits and AtmModData.S4_PendingDeposits[self.Username] then
        self.CashValue = AtmModData.S4_PendingDeposits[self.Username].Value or 0
    end
end

function S4_ATM_Deposit:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_Deposit")
    local InfoText = getText("IGUI_S4_ATM_Info_Deposit")
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
    TextY = TextY + S4_UI.FH_S

    local InsertPanelY = TextY + (self:getHeight() - TextY) / 2 - 50
    self.InsertPanel = ISPanel:new(50, InsertPanelY, self:getWidth() - 100, 100)
    self.InsertPanel:initialise()
    self.InsertPanel:instantiate()
    self.InsertPanel.onMouseUp = S4_ATM_Deposit.onMouseUp_Insert
    self.InsertPanel.DepositUI = self
    self.InsertPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
    self.InsertPanel.backgroundColor = {r=0.64, g=0.64, b=0.64, a=0.9}
    self:addChild(self.InsertPanel)

    self.CashW = self.InsertPanel:getWidth()
    self.CashY = self.InsertPanel:getY() - (20 + S4_UI.FH_M + S4_UI.FH_S)
    self.InsertY = self.InsertPanel:getY()

end

function S4_ATM_Deposit:render()
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
end

function S4_ATM_Deposit:onMouseUp_Insert()
    ISPanel.onMouseUp(self, x, y)
    if ISMouseDrag.dragging then
        local items = S4_Utils.getMoveItemTable(ISMouseDrag.dragging)
        if #items > 0 then
            local AtmModData = self.DepositUI.AtmUI.Obj:getModData()
            if not AtmModData.S4_PendingDeposits then AtmModData.S4_PendingDeposits = {} end
            if not AtmModData.S4_PendingDeposits[self.DepositUI.Username] then 
                AtmModData.S4_PendingDeposits[self.DepositUI.Username] = { Value = 0, Counts = {} }
            end
            local Pending = AtmModData.S4_PendingDeposits[self.DepositUI.Username]

            for _, item in pairs(items) do
                local fullType = item:getFullType()
                local val = 0
                local isConsolidated = false
                if item:hasModData() and item:getModData().S4_ConsolidatedValue then
                    val = item:getModData().S4_ConsolidatedValue
                    isConsolidated = true
                elseif S4_Setting.MoneyList[fullType] then
                    val = S4_Setting.MoneyList[fullType]
                elseif fullType == "Base.Money" or fullType == "Base.MoneyBundle" then
                    val = S4_Utils.getVanillaMoneyValue(item)
                    if val == -1 then -- Dirty money
                        if self.DepositUI.player.setHaloNote then
                            self.DepositUI.player:setHaloNote(getText("IGUI_S4_ATM_Msg_DirtyMoney"), 255, 60, 60, 300)
                        end
                        val = 0
                    end
                end

                if val > 0 or fullType == "Base.Money" or fullType == "Base.MoneyBundle" then
                    self.DepositUI.CashValue = self.DepositUI.CashValue + val
                    
                    Pending.Value = Pending.Value + val
                    if isConsolidated then
                        if not Pending.ConsolidatedItems then Pending.ConsolidatedItems = {} end
                        table.insert(Pending.ConsolidatedItems, {t = fullType, v = val})
                    else
                        Pending.Counts[fullType] = (Pending.Counts[fullType] or 0) + 1
                    end

                    if item:getWorldItem() then
                        item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
                        ISInventoryPage.dirtyUI()
                    else
                        if item:getContainer() then
                            item:getContainer():Remove(item)
                        else
                            self.DepositUI.player:getInventory():Remove(item)
                        end
                    end
                end
            end
            S4_Utils.SnycObject(self.DepositUI.AtmUI.Obj)
        end
    end
end

function S4_ATM_Deposit:ActionDeposit()
    if self.CashValue > 0 then
        if self.AtmUI.CardNumber then
            getSoundManager():playUISound("S4_ATM_Money_Dispensing")
            self:setMsg(getText("IGUI_S4_ATM_Msg_Deposit_Action"))
            local Count = 0
            local Target = 410
            local function UpdateCount_Deposit()
                Count = Count + 1
                self.AtmUI.EventAction = true
                if PerformanceSettings.getLockFPS() then
                    Target = PerformanceSettings.getLockFPS() * 7
                end
                if Count >= Target then
                    Events.OnTick.Remove(UpdateCount_Deposit)
                    -- server transfer function
                    local CardNum = self.AtmUI.CardNumber
                    local LogTime = S4_Utils.getLogTime()
                    local CashValue = self.CashValue
                    sendClientCommand("S4ED", "AddMoney", {CardNum, CashValue})
                    sendClientCommand("S4ED", "AddCardLog", {CardNum, LogTime, "Deposit", CashValue, "ATM", "Card"})
                    
                    -- Clear Pending
                    local AtmModData = self.AtmUI.Obj:getModData()
                    if AtmModData.S4_PendingDeposits then
                        AtmModData.S4_PendingDeposits[self.Username] = nil
                        S4_Utils.SnycObject(self.AtmUI.Obj)
                    end

                    -- Initialization and main screen
                    self.CashValue = 0
                    self.CashItems = {}
                    self.AtmUI.EventAction = false
                    self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_Deposit"))
                else
                    return
                end
            end
            Events.OnTick.Add(UpdateCount_Deposit)
        end
    else
        self:setMsg(getText("IGUI_S4_ATM_Msg_Deposit_NoCash"))
    end
end

function S4_ATM_Deposit:ActionReturn()
    local AtmModData = self.AtmUI.Obj:getModData()
    if AtmModData.S4_PendingDeposits and AtmModData.S4_PendingDeposits[self.Username] then
        local Pending = AtmModData.S4_PendingDeposits[self.Username]
        local Inv = self.player:getInventory()
        for type, count in pairs(Pending.Counts) do
            Inv:AddItems(type, count)
        end
        if Pending.ConsolidatedItems then
            for _, data in ipairs(Pending.ConsolidatedItems) do
                local item = Inv:AddItem(data.t)
                item:getModData().S4_ConsolidatedValue = data.v
                item:setName(tostring(data.v) .. " Bucks")
                S4_Utils.SnycObject(item)
            end
        end
        AtmModData.S4_PendingDeposits[self.Username] = nil
        S4_Utils.SnycObject(self.AtmUI.Obj)
        self.CashValue = 0
        self:setMsg(getText("IGUI_S4_ATM_Msg_Deposit_Returned"))
    end
end

function S4_ATM_Deposit:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Deposit:setTitleInfo(Title, Info)
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

function S4_ATM_Deposit:close()
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
function S4_ATM_Deposit:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end