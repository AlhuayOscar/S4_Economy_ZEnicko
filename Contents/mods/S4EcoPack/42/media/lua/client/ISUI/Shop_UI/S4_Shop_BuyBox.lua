S4_Shop_BuyBox = ISPanel:derive("S4_Shop_BuyBox")

function S4_Shop_BuyBox:new(ParentsUI, x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.76, g=0.76, b=0.76, a=0.1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.ParentsUI = ParentsUI
    o.IEUI = ParentsUI.IEUI
    o.ComUI = ParentsUI.ComUI
    o.player = ParentsUI.player
    return o
end

function S4_Shop_BuyBox:initialise()
    ISPanel.initialise(self)
end

function S4_Shop_BuyBox:createChildren()
    ISPanel.createChildren(self)

    local Cx = self:getWidth() - S4_UI.FH_S - 5
    local Cy = 5
    self.Closebtn = ISButton:new(Cx, Cy, S4_UI.FH_S, S4_UI.FH_S, 'X', self, S4_Shop_BuyBox.BtnClick)
    self.Closebtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.Closebtn.internal = "Close"
    self.Closebtn:initialise()
    self:addChild(self.Closebtn)

    local IconX = 10
    local IconY = 10
    local IconWH = S4_UI.FH_L + (S4_UI.FH_M * 2)
    if self.ItemData.Texture then
        self.IconPanel = ISPanel:new(IconX, IconY, IconWH, IconWH)
        self.IconPanel.backgroundColor.a = 0
        self.IconPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
        self:addChild(self.IconPanel)
        self.IconImage = ISImage:new(IconX + 5, IconY + 5, IconWH - 10, IconWH - 10, self.ItemData.Texture)
        self.IconImage.autoScale = true
        self.IconImage.backgroundColor.a = 1
        self.IconImage.updateTooltip = S4_Shop_BuyBox.IconTooltip
        self.IconImage.TooltipItem = self.ItemData.itemData
        self.IconImage:initialise()
        self.IconImage:instantiate()
        self:addChild(self.IconImage)
    else
        self.IconPanel = ISPanel:new(IconX, IconY, IconWH, IconWH)
        self.IconPanel.backgroundColor.a = 0
        self.IconPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
        self:addChild(self.IconPanel)
    end

    local NameX = (IconY * 2) + IconWH
    local NameY = IconY
    self.ItemNameLabel = ISLabel:new(NameX, NameY, S4_UI.FH_L, self.ItemData.DisplayName, 1, 1, 1, 0.8, UIFont.Large, true)
    self:addChild(self.ItemNameLabel)
    NameY = NameY + S4_UI.FH_L
    local BtnY = NameY
    
    local PriceText = string.format(getText("IGUI_S4_Shop_BuyPrice"), S4_UI.getNumCommas(self.ItemData.BuyPrice))
    if self.ItemData.Discount > 0 then
        local FixPrice = math.floor(self.ItemData.BuyPrice - (self.ItemData.BuyPrice * (self.ItemData.Discount / 100)))
        PriceText = string.format(getText("IGUI_S4_Shop_BuyPriceDiscount"), S4_UI.getNumCommas(FixPrice), S4_UI.getNumCommas(self.ItemData.BuyPrice))
    end
    self.PriceLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, PriceText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PriceLabel)
    NameY = NameY + S4_UI.FH_M

    local StockText = string.format(getText("IGUI_S4_Shop_Stock"), S4_UI.getNumCommas(self.ItemData.Stock))
    self.StockLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, StockText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.StockLabel)
    NameY = NameY + S4_UI.FH_M

    local AuthorityText = string.format(getText("IGUI_S4_Shop_BuyAuthority"), getText("IGUI_S4_Shop_Authority"..self.ItemData.BuyAuthority))
    self.AuthorityLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, AuthorityText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.AuthorityLabel)
    NameY = NameY + S4_UI.FH_M

    local DiscountText = string.format(getText("IGUI_S4_Shop_Discount"), self.ItemData.Discount) .. " %"
    self.DiscountLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, DiscountText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.DiscountLabel)
    NameY = NameY + S4_UI.FH_M

    local BtnW = ((self:getWidth() - NameX) / 2) - 5
    local BtnX = NameX + BtnW
    local FavoriteText = getText("IGUI_S4_Shop_Favorite")
    if self.ItemData.Favorite then
        FavoriteText = getText("IGUI_S4_Shop_FavoriteCancel")
    end
    self.FavoriteBtn = ISButton:new(BtnX, BtnY + 5, BtnW, S4_UI.FH_M + 4, FavoriteText, self, S4_Shop_BuyBox.BtnClick)
    self.FavoriteBtn.font = UIFont.Medium
    self.FavoriteBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.FavoriteBtn.internal = "Favorite"
    self.FavoriteBtn:initialise()
    self:addChild(self.FavoriteBtn)
    BtnY = BtnY + S4_UI.FH_M + 10 + 9

    if self.ItemData.Stock > 0 then
        self.AmountEntry = ISTextEntryBox:new("", BtnX, BtnY, BtnW, S4_UI.FH_M + 4)
        self.AmountEntry.font = UIFont.Medium
        self.AmountEntry.render = S4_Shop_BuyBox.EntryRender
        self.AmountEntry.EntryNameTag = getText("IGUI_S4_Shop_BuyAmount")
        self.AmountEntry:initialise()
        self.AmountEntry:instantiate()
        self.AmountEntry:setOnlyNumbers(true)
        self:addChild(self.AmountEntry)
        BtnY = BtnY + S4_UI.FH_M + 9

        self.CartBtn = ISButton:new(BtnX, BtnY, BtnW, S4_UI.FH_M * 2, getText("IGUI_S4_Shop_AddCart"), self, S4_Shop_BuyBox.BtnClick)
        self.CartBtn.font = UIFont.Medium
        self.CartBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
        self.CartBtn.internal = "Cart"
        self.CartBtn:initialise()
        self:addChild(self.CartBtn)
    end
end


function S4_Shop_BuyBox:IconTooltip()
    if self.mouseover then
        if not self.tooltipUI and self.TooltipItem then
            self.tooltipUI = ISToolTipInv:new(self.TooltipItem)
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
			self.tooltipUI:setAlwaysOnTop(true)
        end
        if not self.tooltipUI:getIsVisible() then
            self.tooltipUI:addToUIManager()
            self.tooltipUI:setVisible(true)
        end
    else
        if self.tooltipUI and self.tooltipUI:getIsVisible() then
			self.tooltipUI:setVisible(false)
			self.tooltipUI:removeFromUIManager()
		end
    end
end

function S4_Shop_BuyBox:BtnClick(Button)
    local internal = Button.internal
    local player = self.player
    if internal == "Close" then
        self:close()
    elseif internal == "Favorite" then
        sendClientCommand("S4PD", "setFavorite", {self.ItemData.FullType})
        if self.ItemData.Favorite then
            self.ItemData.Favorite = false
        else 
            self.ItemData.Favorite = true
        end
    elseif internal == "Cart" then
        local ItemAmount = self.AmountEntry:getText()
        local filteredText = ItemAmount:gsub("[^%d]", "")
        filteredText = filteredText:gsub("^0+", "")
        if filteredText == "" then filteredText = "1" end
        self.AmountEntry:setText(filteredText)
        local Amount = tonumber(filteredText)

        sendClientCommand("S4PD", "AddBuyCart", {self.ItemData.FullType, Amount})
        if self.ComUI.BuyCart[self.ItemData.FullType] then
            self.ComUI.BuyCart[self.ItemData.FullType] = self.ComUI.BuyCart[self.ItemData.FullType] + Amount
        else 
            self.ComUI.BuyCart[self.ItemData.FullType] = Amount
        end
        self:close()
    end
end

function S4_Shop_BuyBox:close()
    if self.ParentsUI.CategoryBox.CategoryType == "Favorite" then
        self.ParentsUI:AddItems(true)
    end
    self.ParentsUI.BuyBox = nil
    self.ParentsUI.ListBox:setItemBtn()
    self.ParentsUI.ListBox:setVisible(true)
    self:setVisible(false)
    self:removeFromUIManager()
end

function S4_Shop_BuyBox:EntryRender()
    if self.EntryNameTag and not self.javaObject:isFocused() and self:getText() == "" then
        local TextW = getTextManager():MeasureStringX(UIFont.Medium, self.EntryNameTag)
        local X = (self:getWidth() / 2 ) - (TextW / 2)
        self:drawText(self.EntryNameTag, 10, 2, 1, 1, 1, 0.5, UIFont.Medium)
    end
end