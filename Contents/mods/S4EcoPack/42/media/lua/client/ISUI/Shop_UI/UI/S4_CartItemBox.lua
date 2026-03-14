S4_CartItemBox = ISPanel:derive("S4_CartItemBox")

function S4_CartItemBox:new(ParentsUI, x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.76, g=0.76, b=0.76, a=0.1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.ParentsUI = ParentsUI -- cartUI
	o.ShopUI = ParentsUI.ParentsUI
    o.IEUI = ParentsUI.IEUI
    o.ComUI = ParentsUI.ComUI
    o.player = ParentsUI.player
    return o
end

function S4_CartItemBox:initialise()
    ISPanel.initialise(self)
end

function S4_CartItemBox:createChildren()
	ISPanel.createChildren(self)

    local x = 10
    local y = 10
    local Bh = (S4_UI.FH_L * 3) + 20

    self.IconPanel = ISPanel:new(x, y, self:getHeight() - 20, self:getHeight() - 20)
    self.IconPanel.backgroundColor.a = 0
    self.IconPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.IconPanel)

    local Lx = self:getHeight()
    local Ly = y
    self.NameLabel = ISLabel:new(Lx, Ly, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Large, true)
    self:addChild(self.NameLabel)
    Ly = Ly + S4_UI.FH_L
    self.InfoLabel = ISLabel:new(Lx, Ly, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.InfoLabel)
    Ly = Ly + S4_UI.FH_L
    self.TotalLabel = ISLabel:new(Lx, Ly, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalLabel)
    -- Ly = Ly + S4_UI.FH_L

    local EntryW = getTextManager():MeasureStringX(UIFont.Medium, "000000")
    local EntryX = self:getWidth() - EntryW - S4_UI.FH_M - 20
    local EntryY = self:getHeight() - S4_UI.FH_M - 10
    self.AmountPanel = ISPanel:new(EntryX, EntryY, EntryW, S4_UI.FH_M)
    self.AmountPanel.backgroundColor.a = 0
    self.AmountPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.AmountPanel:setVisible(false)
    self:addChild(self.AmountPanel)
    self.AmountLabel = ISLabel:new(EntryX, EntryY-1, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.AmountLabel)

    self.DownBtn = ISButton:new(EntryX - S4_UI.FH_M - 10, EntryY, S4_UI.FH_M, S4_UI.FH_M, "-", self, S4_CartItemBox.BtnClick)
    self.DownBtn.font = UIFont.Medium
    self.DownBtn.internal = "Down"
    self.DownBtn.backgroundColor.a = 0
    self.DownBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.DownBtn.textColor.a = 0.8
    self.DownBtn:setVisible(false)
    self.DownBtn:initialise()
    self:addChild(self.DownBtn)

    local UpX = EntryX + self.AmountPanel:getWidth() + 10
    self.UpBtn = ISButton:new(UpX, EntryY, S4_UI.FH_M, S4_UI.FH_M, "+", self, S4_CartItemBox.BtnClick)
    self.UpBtn.font = UIFont.Medium
    self.UpBtn.internal = "Up"
    self.UpBtn.backgroundColor.a = 0
    self.UpBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.UpBtn.textColor.a = 0.8
    self.UpBtn:setVisible(false)
    self.UpBtn:initialise()
    self:addChild(self.UpBtn)

    local RW = self.AmountPanel:getWidth() + self.UpBtn:getWidth() + self.DownBtn:getWidth() + 20
    local Rx = EntryX - S4_UI.FH_M - 10
    local RY = EntryY - S4_UI.FH_M - 5
    self.RemoveBtn = ISButton:new(Rx, RY, RW, S4_UI.FH_M, getText("IGUI_S4_Cart_Remove"), self, S4_CartItemBox.BtnClick)
    -- self.RemoveBtn.font = UIFont.Medium
    self.RemoveBtn.internal = "Remove"
    self.RemoveBtn.backgroundColor.a = 0
    self.RemoveBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.RemoveBtn.textColor.a = 0.9
    self.RemoveBtn:setVisible(false)
    self.RemoveBtn:initialise()
    self:addChild(self.RemoveBtn)
end

function S4_CartItemBox:SetData()
    if self.IconImage then self.IconImage:close() end
    if self.Data then
        local Lx = self:getHeight()
        local DisplayName = string.format(getText("IGUI_S4_Cart_DisplayName"), self.Data.DisplayName)
        DisplayName = S4_UI.TextLimitOne(DisplayName, self:getWidth() - Lx - 10, UIFont.Large)
        self.NameLabel:setName(DisplayName)
        if self.Data.Texture then
            self.IconImage = ISImage:new(self.IconPanel:getX() + 5, self.IconPanel:getY() + 5, self.IconPanel:getWidth() - 10, self.IconPanel:getHeight() - 10, self.Data.Texture)
            self.IconImage.autoScale = true
            self.IconImage.backgroundColor.a = 1
            self.IconImage:initialise()
            self.IconImage:instantiate()
            self:addChild(self.IconImage)
        end
        if self.Data.Amount then
            self.AmountLabel:setName(tostring(self.Data.Amount))
            self.AmountPanel:setVisible(true)
            self.DownBtn:setVisible(true)
            self.UpBtn:setVisible(true)
            self.RemoveBtn:setVisible(true)
            local AmountW = getTextManager():MeasureStringX(UIFont.Medium, tostring(self.Data.Amount))
            local setX = self.AmountPanel:getX() + (self.AmountPanel:getWidth() / 2) - (AmountW / 2)
            self.AmountLabel:setX(setX)
        end
        if self.ParentsUI.CartType == "Buy" then
            local Price = S4_UI.getNumCommas(self.Data.ItemData.BuyPrice)
            local Stock = S4_UI.getNumCommas(self.Data.ItemData.Stock)
            local Discount = S4_UI.getNumCommas(self.Data.ItemData.Discount)
            local FixPrice = math.floor(self.Data.ItemData.BuyPrice - (self.Data.ItemData.BuyPrice * (self.Data.ItemData.Discount / 100)))
            local TotalPrice = S4_UI.getNumCommas(FixPrice * self.Data.Amount) 
            local InfoText = string.format(getText("IGUI_S4_Cart_BuyInfo"), Price, Stock, Discount) .. " %"
            local TotalText = string.format(getText("IGUI_S4_Cart_TotalBuyPrice"), TotalPrice)
            self.InfoLabel:setName(InfoText)
            self.TotalLabel:setName(TotalText)
        elseif self.ParentsUI.CartType == "Sell" then
            local InvStock = S4_UI.getNumCommas(0)
            if self.ShopUI.InvItems and self.ShopUI.InvItems[self.Data.FullType] then
                InvStock = S4_UI.getNumCommas(self.ShopUI.InvItems[self.Data.FullType].Amount)
            end

            local SellCommission = S4_Utils.CheckCommission(self.ShopUI.PlayerSellAuthority)
            local Price = self.Data.ItemData.SellPrice
            local PriceFix = Price - math.floor((Price * (SellCommission / 100)))
            local TotalPrice = S4_UI.getNumCommas(math.floor(PriceFix * self.Data.Amount))
            local InfoText = string.format(getText("IGUI_S4_Cart_SellInfo"), S4_UI.getNumCommas(Price), InvStock, tostring(SellCommission)) .. " %"
            local TotalText = string.format(getText("IGUI_S4_Cart_TotalSellPrice"), TotalPrice)
            self.InfoLabel:setName(InfoText)
            self.TotalLabel:setName(TotalText)
        end
    else
        self.AmountPanel:setVisible(false)
        self.DownBtn:setVisible(false)
        self.UpBtn:setVisible(false)
        self.RemoveBtn:setVisible(false)
        self.NameLabel:setName("")
        self.InfoLabel:setName("")
        self.TotalLabel:setName("")
        self.AmountLabel:setName("")
    end
end

function S4_CartItemBox:BtnClick(Button)
    local internal = Button.internal
    if internal == "Up" or internal == "Down" then
        local Amount = tonumber(self.AmountLabel:getName())
        if internal == "Up" then
            Amount = Amount + 1
            -- Change visible value
            self.AmountLabel:setName(tostring(Amount))
            local AmountW = getTextManager():MeasureStringX(UIFont.Medium, tostring(Amount))
            local setX = self.AmountPanel:getX() + (self.AmountPanel:getWidth() / 2) - (AmountW / 2)
            self.AmountLabel:setX(setX)
            -- change data
            self.Data.Amount = Amount
            if self.ParentsUI.CartType == "Buy" then
                self.ComUI.BuyCart[self.Data.FullType] = Amount
                sendClientCommand("S4PD", "SetBuyCart", {self.Data.FullType, Amount})
            elseif self.ParentsUI.CartType == "Sell" then
                self.ComUI.SellCart[self.Data.FullType] = Amount
            end
        elseif internal == "Down" then
            Amount = Amount - 1
            if Amount > 0 then
                self.AmountLabel:setName(tostring(Amount))
                local AmountW = getTextManager():MeasureStringX(UIFont.Medium, tostring(Amount))
                local setX = self.AmountPanel:getX() + (self.AmountPanel:getWidth() / 2) - (AmountW / 2)
                self.AmountLabel:setX(setX)
                -- change data
                self.Data.Amount = Amount
                if self.ParentsUI.CartType == "Buy" then
                    self.ComUI.BuyCart[self.Data.FullType] = Amount
                    sendClientCommand("S4PD", "SetBuyCart", {self.Data.FullType, Amount})
                elseif self.ParentsUI.CartType == "Sell" then
                    self.ComUI.SellCart[self.Data.FullType] = Amount
                end
            elseif Amount == 0 then
                if self.ParentsUI.CartType == "Buy" then
                    self.ComUI.BuyCart[self.Data.FullType] = nil
                    sendClientCommand("S4PD", "SetBuyCart", {self.Data.FullType, nil})
                elseif self.ParentsUI.CartType == "Sell" then
                    self.ComUI.SellCart[self.Data.FullType] = nil
                end
                self.ShopUI:AddCartItem(true)
            end
        end
        self.ParentsUI:setTotal()
        self:SetData()
    elseif internal == "Remove" then
        if self.ParentsUI.CartType == "Buy" then
            self.ComUI.BuyCart[self.Data.FullType] = nil
            sendClientCommand("S4PD", "SetBuyCart", {self.Data.FullType, nil})
        elseif self.ParentsUI.CartType == "Sell" then
            self.ComUI.SellCart[self.Data.FullType] = nil
        end
        self.ShopUI:AddCartItem(true)
    end
end