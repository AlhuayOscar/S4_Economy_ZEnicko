S4_Shop_Cart = ISPanel:derive("S4_Shop_Cart")
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

function S4_Shop_Cart:new(ParentsUI, x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.76, g=0.76, b=0.76, a=0.1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.ParentsUI = ParentsUI -- ShopUI
    o.IEUI = ParentsUI.IEUI
    o.ComUI = ParentsUI.ComUI
    o.player = ParentsUI.player
    o.CartType = "Buy"
    o.ItemPage = 1
    o.ItemPageMax = 1
    o.PageItemCount = 0
    o.Items = {}
    return o
end

function S4_Shop_Cart:initialise()
    ISPanel.initialise(self)
end

function S4_Shop_Cart:createChildren()
    ISPanel.createChildren(self)

    local x = 10 
    local y = 10
    local setW = ((S4_UI.FH_L * 3) + 20) * 3
    local InfoW = self:getWidth() - setW - 30
    self.InfoPanel = ISPanel:new(x, y, InfoW, S4_UI.FH_M + 20)
    self.InfoPanel.backgroundColor.a = 0
    self.InfoPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.InfoPanel)

    local Cx = 20
    local Cy = y + 10
    self.CartTypeLabel = ISLabel:new(Cx, Cy, S4_UI.FH_M, getText("IGUI_S4_Cart_BuyCart"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.CartTypeLabel)

    Cx = self.CartTypeLabel:getRight() + 10
    self.CartTypeBtn = ISButton:new(Cx, Cy, 100, S4_UI.FH_M, getText("IGUI_S4_Cart_Change"), self, S4_Shop_Cart.BtnClick)
    self.CartTypeBtn.font = UIFont.Medium
    self.CartTypeBtn.internal = "ChangCartType"
    self.CartTypeBtn.backgroundColor.a = 0
    self.CartTypeBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.CartTypeBtn.textColor.a = 0.8
    self.CartTypeBtn:initialise()
    self:addChild(self.CartTypeBtn)

    local PageW = getTextManager():MeasureStringX(UIFont.Medium, "000 / 000")
    local Px = InfoW - PageW - 20
    self.PageLabel = ISLabel:new(Px, Cy, S4_UI.FH_M, "000 / 000", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PageLabel)

    local Sx = InfoW + 20
    local Sy = y
    self.SetPanel = ISPanel:new(Sx, Sy, setW, self:getHeight() - 20)
    self.SetPanel.backgroundColor.a = 0
    self.SetPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.SetPanel)

    self.TotalAmountLabel = ISLabel:new(Sx + 10, Sy, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalAmountLabel)
    Sy = Sy + S4_UI.FH_M
    self.TotalPriceLabel = ISLabel:new(Sx + 10, Sy, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalPriceLabel)
    Sy = Sy + S4_UI.FH_M
    self.TotalSDLabel = ISLabel:new(Sx + 10, Sy, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalSDLabel)
    Sy = Sy + S4_UI.FH_M
    Sy = Sy + S4_UI.FH_M
    self.TotalFixPriceLabel = ISLabel:new(Sx + 10, Sy, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalFixPriceLabel)
    Sy = Sy + S4_UI.FH_M

    local BtnY = self:getHeight() - (S4_UI.FH_M * 2) - 20
    self.BuySellBtn = ISButton:new(Sx + 10, BtnY, setW - 20, S4_UI.FH_M * 2, getText("IGUI_S4_Cart_Buy"), self, S4_Shop_Cart.BtnClick)
    self.BuySellBtn.internal = "BuySell"
    self.BuySellBtn.font = UIFont.Medium
    self.BuySellBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.BuySellBtn:initialise()
    self:addChild(self.BuySellBtn)

    local EnrtyH = S4_UI.FH_M + 4
    local EnrtyY = BtnY - S4_UI.FH_M - 14
    self.DeliveryBox = ISComboBox:new(Sx + 10, EnrtyY, setW - 20, EnrtyH, self)
    self.DeliveryBox.font = UIFont.Medium
    self.DeliveryBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.DeliveryBox:setVisible(false)
    self:addChild(self.DeliveryBox)
    -- self.DeliveryBox:addOptionWithData(""..i, i)
    local PlayerShopModData = ModData.get("S4_PlayerShopData")[self.player:getUsername()]
    local DeliveryCheck = true
    if PlayerShopModData and PlayerShopModData.DeliveryList then
        for Code, Name in pairs(PlayerShopModData.DeliveryList) do
            self.DeliveryBox:addOptionWithData(Name, Code)
            DeliveryCheck = false
        end
    end
    if DeliveryCheck then
        self.DeliveryBox:addOptionWithData(getText("IGUI_S4_Signal_NotInput"), "None")
    end

    local Dy = EnrtyY - S4_UI.FH_M - 5
    self.DeliveryLabel = ISLabel:new(Sx + 10, Dy, S4_UI.FH_M, getText("IGUI_S4_Cart_Delivery"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self.DeliveryLabel:setVisible(false)
    self:addChild(self.DeliveryLabel)

    local NormalDeliveryPrice = 0
    local QuickDeliveryPrice = 0
    if SandboxVars and SandboxVars.S4SandBox then
        NormalDeliveryPrice = SandboxVars.S4SandBox.DeliveryCommission or 0
        QuickDeliveryPrice = SandboxVars.S4SandBox.QuickDeliveryCommission or 0
    end
    local TickY = Dy - (S4_UI.FH_S * 2) - 10
    self.QuickBox = ISTickBox:new(Sx + 10, TickY, S4_UI.FH_S, S4_UI.FH_S, "", self)
    self.QuickBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.QuickBox.onMouseUp = S4_Shop_Cart.QuickBoxOnMouseUp
    self.QuickBox.CartUI = self
    self.QuickBox:initialise()
    self.QuickBox:addOption(string.format(getText("IGUI_S4_Cart_NormalDelivery"), S4_UI.getNumCommas(NormalDeliveryPrice)))
    self.QuickBox:addOption(string.format(getText("IGUI_S4_Cart_QuickDelivery"), S4_UI.getNumCommas(QuickDeliveryPrice)))
    self.QuickBox:setVisible(false)
    self:addChild(self.QuickBox)
    self.QuickBox:setSelected(1, true)

    local By = S4_UI.FH_L + 40
    local Bh = (S4_UI.FH_L * 3) + 20
    for i = 1, 10 do
        if i == 1 then
            self["CartItem"..i] = S4_CartItemBox:new(self, x, By, InfoW, Bh)
            self["CartItem"..i].backgroundColor.a = 0
            self["CartItem"..i].borderColor = {r=0.4, g=0.4, b=0.4, a=1}
            self:addChild(self["CartItem"..i])
        else
            if By + Bh + 10 > self:getHeight() - 20 then
                self.ListCount = i - 1
                break
            else
                By = By + Bh + 10
            end
            self["CartItem"..i] = S4_CartItemBox:new(self, x, By, InfoW, Bh)
            self["CartItem"..i].backgroundColor.a = 0
            self["CartItem"..i].borderColor = {r=0.4, g=0.4, b=0.4, a=1}
            self:addChild(self["CartItem"..i])
        end
    end
    self:setPage()
    self:setTotal()
end

function S4_Shop_Cart:setTotal()
    local TotalPrice = 0
    local TotalAmount = 0
    local TotalFixPrice = 0
    local TotalCD = 0
    local Commission = 0
    for _, Data in pairs(self.Items) do
        if Data.ItemData then
            if self.CartType == "Buy" then
                local Price = Data.ItemData.BuyPrice or 0
                local Discount = Data.ItemData.Discount or 0
                local Amount = self.ComUI.BuyCart[Data.FullType] or 0
                local FixPrice = Price - math.floor((Price * (Discount / 100)))
                TotalPrice = TotalPrice + (Price * Amount)
                TotalAmount = TotalAmount + Amount
                TotalCD = TotalCD + (math.floor((Price * (Discount / 100))) * Amount)
                TotalFixPrice = TotalFixPrice + (FixPrice * Amount)
            elseif self.CartType == "Sell" then
                local Price = Data.ItemData.SellPrice or 0
                local itemCommission = S4_Utils.CheckCommission(self.ParentsUI.PlayerSellAuthority) or 0
                local Amount = self.ComUI.SellCart[Data.FullType] or 0
                local FixPrice = Price - math.floor((Price * (itemCommission / 100)))
                TotalPrice = TotalPrice + (Price * Amount)
                TotalAmount = TotalAmount + Amount
                TotalCD = TotalCD + (math.floor((Price * (itemCommission / 100))) * Amount)
                TotalFixPrice = TotalFixPrice + (FixPrice * Amount)
            end
        end
    end
    local SDText = ""
    local PriceText = ""
    local FixPriceText = ""
    local AmountText = string.format(getText("IGUI_S4_Cart_TotalAmount"), S4_UI.getNumCommas(TotalAmount))
    if self.CartType == "Buy" then
        local deliveryFee = 0
        local quickFee = 0
        if SandboxVars and SandboxVars.S4SandBox then
            deliveryFee = SandboxVars.S4SandBox.DeliveryCommission or 0
            quickFee = SandboxVars.S4SandBox.QuickDeliveryCommission or 0
        end

        if self.QuickBox:isSelected(1) then
            TotalFixPrice = TotalFixPrice + deliveryFee
        elseif self.QuickBox:isSelected(2) then
            TotalFixPrice = TotalFixPrice + quickFee
        end
        PriceText = string.format(getText("IGUI_S4_Cart_TotalBuy"), S4_UI.getNumCommas(TotalPrice))
        SDText = string.format(getText("IGUI_S4_Shop_TotalDiscount"), S4_UI.getNumCommas(TotalCD))
        FixPriceText = string.format(getText("IGUI_S4_Shop_TotalFixBuyPrice"), S4_UI.getNumCommas(TotalFixPrice))
        self.BuySellBtn:setTitle(getText("IGUI_S4_Cart_Buy"))
        self.DeliveryBox:setVisible(true)
        self.DeliveryLabel:setVisible(true)
        self.QuickBox:setVisible(true)
    elseif self.CartType == "Sell" then
        PriceText = string.format(getText("IGUI_S4_Cart_TotalSell"), S4_UI.getNumCommas(TotalPrice))
        SDText = string.format(getText("IGUI_S4_Shop_TotalCommission"), S4_UI.getNumCommas(TotalCD))
        FixPriceText = string.format(getText("IGUI_S4_Shop_TotalFixSellPrice"), S4_UI.getNumCommas(TotalFixPrice))
        self.BuySellBtn:setTitle(getText("IGUI_S4_Cart_Sell"))
        self.DeliveryBox:setVisible(false)
        self.DeliveryLabel:setVisible(false)
        self.QuickBox:setVisible(false)
    end
    self.TotalAmountLabel:setName(AmountText)
    self.TotalPriceLabel:setName(PriceText)
    self.TotalSDLabel:setName(SDText)
    self.TotalFixPriceLabel:setName(FixPriceText)
end

function S4_Shop_Cart:clear()
    self.Items = {}
    self.PageItemCount = 0
    self.ItemPage = 1
    self.ItemPageMax = 1
    self:setItem()
    self:setPage()
    self:setTotal()
end

function S4_Shop_Cart:Reloadclear()
    self.Items = {}
    self.PageItemCount = 0
    self.ItemPageMax = 1
    self:setItem()
    self:setPage()
    self:setTotal()
end

function S4_Shop_Cart:setPage()
    local Page = string.format("%03d", self.ItemPage) .. " / " .. string.format("%03d", self.ItemPageMax)
    self.PageLabel:setName(Page)
end

function S4_Shop_Cart:AddItem(Data)
    self.PageItemCount = self.PageItemCount + 1
    if self.PageItemCount > self.ListCount then
        self.PageItemCount = 1
        self.ItemPageMax = self.ItemPageMax + 1
    end
    Data.ItemCount = self.PageItemCount
    Data.PageCount = self.ItemPageMax
    table.insert(self.Items, Data)
    self:setItem()
    self:setPage()
    self:setTotal()
end

function S4_Shop_Cart:setItem()
    if self.ListCount and self.ListCount > 0 then
        for i = 1, self.ListCount do
            local Check = true
            for _, Data in pairs(self.Items) do
                if Data.ItemCount == i and Data.PageCount == self.ItemPage then
                    self["CartItem"..i].Data = Data
                    Check = false
                    break
                end
            end
            if Check then
                self["CartItem"..i].Data = nil
            end   
        end
        for j = 1, self.ListCount do
            self["CartItem"..j]:SetData()
        end
    end
end

function S4_Shop_Cart:BtnClick(Button)
    local internal = Button.internal
    if internal == "ChangCartType" then
        if self.CartType == "Buy" then
            self.CartType = "Sell"
            self.CartTypeLabel:setName(getText("IGUI_S4_Cart_SellCart"))
            self.CartTypeBtn:setX(self.CartTypeLabel:getRight() + 10)
        elseif self.CartType == "Sell" then
            self.CartType = "Buy"
            self.CartTypeLabel:setName(getText("IGUI_S4_Cart_BuyCart"))
            self.CartTypeBtn:setX(self.CartTypeLabel:getRight() + 10)
        end
        self.ParentsUI:AddCartItem(false)
    elseif internal == "BuySell" then
        self:BuySellAction()
    end
end

function S4_Shop_Cart:BuySellAction()
    local UserName = self.player:getUsername()
    local ShopModData = ModData.get("S4_ShopData")
    local PlayerShopModData = ModData.get("S4_PlayerShopData")
    if self.CartType == "Buy" then
        if self.ComUI.CardNumber then
            if self.ComUI.isCardPassword then
                local CardModData = ModData.get("S4_CardData")
                if CardModData[self.ComUI.CardNumber] then
                    local CardMoney = CardModData[self.ComUI.CardNumber].Money
                    local TotalPrice = 0
                    local PlayerAuthority = PlayerShopModData[UserName].BuyAuthority
                    for itemName, Amount in pairs(self.ComUI.BuyCart) do
                        if ShopModData[itemName] then
                            local ShopStock = ShopModData[itemName].Stock
                            if ShopStock >= Amount then
                                local ShopPrice = ShopModData[itemName].BuyPrice
                                local ShopAuthority = ShopModData[itemName].BuyAuthority
                                local ShopDiscount = ShopModData[itemName].Discount
                                local FixPrice = (ShopPrice - math.floor((ShopPrice * (ShopDiscount / 100)))) * Amount
                                TotalPrice = TotalPrice + FixPrice
                                if ShopAuthority > PlayerAuthority then -- Lack of purchase rating
                                    self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotShopBuyAuthority"))
                                    self.ParentsUI:ReloadData("Buy")
                                    return
                                end
                            else -- out of stock
                                self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotShopStock"))
                                self.ParentsUI:ReloadData("Buy")
                                return
                            end
                        end
                    end
                    if TotalPrice > 0 then
                        local DeliveryType = "Normal"
                        local deliveryComm = 500
                        local quickComm = 2000
                        if SandboxVars and SandboxVars.S4SandBox then
                            deliveryComm = SandboxVars.S4SandBox.DeliveryCommission or 500
                            quickComm = SandboxVars.S4SandBox.QuickDeliveryCommission or 2000
                        end

                        if self.QuickBox:isSelected(1) then
                            TotalPrice = TotalPrice + deliveryComm
                        elseif self.QuickBox:isSelected(2) then
                            TotalPrice = TotalPrice + quickComm
                            DeliveryType = "Quick"
                        end
                        local function confirmBuy(self, DeliveryType, TotalPrice, DeliveryAddress)
                            local LogTime = S4_Utils.getLogTime()
                            sendClientCommand("S4SD", "ShopBuy", {LogTime, DeliveryType, self.ComUI.CardNumber, TotalPrice, self.ComUI.BuyCart, DeliveryAddress})
                            self.ComUI.BuyCart = {}
                            self.ParentsUI:ReloadData("Buy")
                            self:close()
                        end

                        if (CardMoney - TotalPrice) >= getCardCreditLimit() then
                            local DeliveryAddress = self.DeliveryBox:getOptionData(self.DeliveryBox.selected)
                            if DeliveryAddress ~= "None" then
                                if (CardMoney - TotalPrice) < 0 then
                                    -- Show credit card confirmation
                                    if self.ComUI.ShopMsgBox then self.ComUI.ShopMsgBox:close() end
                                    self.ComUI.ShopMsgBox = S4_System:new(self.ComUI)
                                    self.ComUI.ShopMsgBox.TitleName = "Credit Purchase"
                                    self.ComUI.ShopMsgBox.PageType = "BankMsgBox"
                                    self.ComUI.ShopMsgBox.CheckType = "CreditBuy"
                                    self.ComUI.ShopMsgBox.MsgText1 = getText("IGUI_S4_Cart_CreditConfirm")
                                    self.ComUI.ShopMsgBox.pUI = self
                                    self.ComUI.ShopMsgBox.onConfirm = function() confirmBuy(self, DeliveryType, TotalPrice, DeliveryAddress) end
                                    self.ComUI.ShopMsgBox:initialise()
                                    self.ComUI:addChild(self.ComUI.ShopMsgBox)
                                    self.ComUI:AddTaskBar(self.ComUI.ShopMsgBox)
                                else
                                    confirmBuy(self, DeliveryType, TotalPrice, DeliveryAddress)
                                end
                            else -- No shipping address
                                self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotDeliveryAddress"), getText("IGUI_S4_ATM_Msg_NotDeliveryAddressTry"))
                                return
                            end
                        else -- Insufficient card balance (Exceeds credit limit)
                            self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_LowBalance"))
                            return
                        end
                    else -- There is nothing to buy
                        self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_EmptyCart"))
                        return
                    end 
                end
            else -- Card password not confirmed
                self.ComUI:CardPasswordCheck()
                self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardPassword"), getText("IGUI_S4_ATM_Msg_NotCardPasswordTry"))
                return
            end
        else
            if self.ComUI.CardReaderInstall then -- Card not inserted
                self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotShopInsertCard"))
                return
            else -- Card reader not installed
                self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardReaderInstall"))
                return
            end
        end
    elseif self.CartType == "Sell" then
        local PlayerModData = ModData.get("S4_PlayerData")
        if PlayerModData[UserName] and PlayerModData[UserName].MainCard then
            local BoxData = {}
            local BoxCount = 1
            local InvItems = S4_Utils.getPlayerItems(self.player)
            local TotalPrice = 0
            local PlayerAuthority = PlayerShopModData[UserName].SellAuthority
            for itemName, Amount in pairs(self.ComUI.SellCart) do
                if InvItems[itemName] and InvItems[itemName].Amount >= Amount then
                    local ItemData = S4_Utils.setItemCashe(itemName)
                    local ItemWeight = ItemData:getWeight()
                    local ShopPrice = ShopModData[itemName].SellPrice
                    local Commission = S4_Utils.CheckCommission(PlayerAuthority)
                    local FixPrice = (ShopPrice - math.floor((ShopPrice * (Commission / 100))))
                    for i = 1, Amount do
                        if BoxData[BoxCount] and BoxData[BoxCount].Weight then
                            if BoxData[BoxCount].Weight + ItemWeight > 45 then
                                BoxCount = BoxCount + 1
                            end
                        end
                        if not BoxData[BoxCount] then
                            BoxData[BoxCount] = {}
                            BoxData[BoxCount].ItemList = {}
                            BoxData[BoxCount].ItemList[itemName] = 1
                            BoxData[BoxCount].Weight = ItemWeight
                            BoxData[BoxCount].Price = FixPrice
                        else
                            if BoxData[BoxCount].ItemList[itemName] then
                                BoxData[BoxCount].ItemList[itemName] = BoxData[BoxCount].ItemList[itemName] + 1
                            else
                                BoxData[BoxCount].ItemList[itemName] = 1
                            end
                            BoxData[BoxCount].Weight = BoxData[BoxCount].Weight + ItemWeight
                            BoxData[BoxCount].Price = BoxData[BoxCount].Price + FixPrice
                        end
                    end
                    local ShopAuthority = ShopModData[itemName].SellAuthority
                    if ShopAuthority > PlayerAuthority then -- lack of rating
                        self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotShopSellAuthority"))
                        return
                    end
                else -- lack of belongings
                    self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotInvItems"))
                    return
                end
            end
            -- action
            local SellAction = S4_Action_Sell:new(self.player, BoxCount, BoxData, PlayerModData[UserName].MainCard, self.ParentsUI)
            ISTimedActionQueue.add(SellAction)
        else
            -- Main account not set up message
            self.ComUI:AddMsgBox("Error - Good Shop", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotMainCard"))
            return
        end
    end
    self:close()
end

function S4_Shop_Cart:QuickBoxOnMouseUp()
    if self.clickedOption then
        if self.clickedOption == 1 and self:isSelected(2) then
            self:setSelected(2, false)
        elseif self.clickedOption == 2 and self:isSelected(1) then
            self:setSelected(1, false)
        end
    end
    ISTickBox.onMouseUp(self)

    self.CartUI:setTotal()
end

function S4_Shop_Cart:onMouseWheel(del)
    if del then
        local SetPage = self.ItemPage + del
        if self.ItemPageMax >= SetPage and SetPage > 0 then
            self.ItemPage = SetPage
            self:setItem()
            self:setPage()
        end
    end
    return true
end

function S4_Shop_Cart:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
