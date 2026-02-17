S4_Shop_SellBox = ISPanel:derive("S4_Shop_SellBox")

function S4_Shop_SellBox:new(ParentsUI, x, y, w, h)
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

function S4_Shop_SellBox:initialise()
    ISPanel.initialise(self)
end

function S4_Shop_SellBox:createChildren()
    ISPanel.createChildren(self)

    local Cx = self:getWidth() - S4_UI.FH_S - 5
    local Cy = 5
    self.Closebtn = ISButton:new(Cx, Cy, S4_UI.FH_S, S4_UI.FH_S, 'X', self, S4_Shop_SellBox.BtnClick)
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
        -- self.IconImage.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
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

    local PriceText = string.format(getText("IGUI_S4_Shop_SellPrice"), S4_UI.getNumCommas(self.ItemData.SellPrice))
    self.PriceLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, PriceText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PriceLabel)
    NameY = NameY + S4_UI.FH_M

    local AuthorityText = string.format(getText("IGUI_S4_Shop_SellAuthority"), getText("IGUI_S4_Shop_Authority"..self.ItemData.SellAuthority))
    self.AuthorityLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, AuthorityText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.AuthorityLabel)
    NameY = NameY + S4_UI.FH_M

    local SellCommission = S4_Utils.CheckCommission(self.ParentsUI.PlayerSellAuthority)
    -- if SandboxVars.S4SandBox.SellCommission then
    --     SellCommission = SandboxVars.S4SandBox.SellCommission
    -- end
    local CommissionPrice = math.floor(self.ItemData.SellPrice * (SellCommission / 100))
    local CommissionText = string.format(getText("IGUI_S4_Shop_Commission"), S4_UI.getNumCommas(SellCommission), "%", S4_UI.getNumCommas(CommissionPrice))
    self.CommissionLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, CommissionText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.CommissionLabel)
    NameY = NameY + S4_UI.FH_M

    local BtnW = ((self:getWidth() - NameX) / 2) - 5
    local BtnX = NameX + BtnW
    local IvnAmountText = string.format(getText("IGUI_S4_Shop_InvStock"), "0")
    if self.ItemData.InvStock then
        IvnAmountText = string.format(getText("IGUI_S4_Shop_InvStock"), S4_UI.getNumCommas(self.ItemData.InvStock))

        self.AmountEntry = ISTextEntryBox:new("", BtnX, BtnY, BtnW, S4_UI.FH_M + 4)
        self.AmountEntry.font = UIFont.Medium
        self.AmountEntry.render = S4_Shop_SellBox.EntryRender
        self.AmountEntry.EntryNameTag = getText("IGUI_S4_Shop_BuyAmount")
        self.AmountEntry:initialise()
        self.AmountEntry:instantiate()
        self.AmountEntry:setOnlyNumbers(true)
        self:addChild(self.AmountEntry)
        BtnY = BtnY + S4_UI.FH_M + 14

        self.CartBtn = ISButton:new(BtnX, BtnY, BtnW, S4_UI.FH_M * 2, getText("IGUI_S4_Shop_AddCart"), self, S4_Shop_SellBox.BtnClick)
        self.CartBtn.font = UIFont.Medium
        self.CartBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
        self.CartBtn.internal = "Cart"
        self.CartBtn:initialise()
        self:addChild(self.CartBtn)
    end
    self.InvAmountLabel = ISLabel:new(NameX, NameY, S4_UI.FH_M, IvnAmountText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.InvAmountLabel)
    NameY = NameY + S4_UI.FH_M
end

function S4_Shop_SellBox:BtnClick(Button)
    local internal = Button.internal
    if internal == "Close" then
        self:close()
    elseif internal == "Cart" then
        local ItemAmount = self.AmountEntry:getText()
        local filteredText = ItemAmount:gsub("[^%d]", "")
        filteredText = filteredText:gsub("^0+", "")
        if filteredText == "" then filteredText = "1" end
        self.AmountEntry:setText(filteredText)
        local Amount = tonumber(filteredText)
        if self.ComUI.SellCart[self.ItemData.FullType] then
            self.ComUI.SellCart[self.ItemData.FullType] = self.ComUI.SellCart[self.ItemData.FullType] + Amount
        else 
            self.ComUI.SellCart[self.ItemData.FullType] = Amount
        end
        self:close()
    end
end

function S4_Shop_SellBox:close()
    self.ParentsUI.SellBox = nil
    self.ParentsUI.ListBox:setItemBtn()
    self.ParentsUI.ListBox:setVisible(true)
    self:setVisible(false)
    self:removeFromUIManager()
end

function S4_Shop_SellBox:EntryRender()
    if self.EntryNameTag and not self.javaObject:isFocused() and self:getText() == "" then
        local TextW = getTextManager():MeasureStringX(UIFont.Medium, self.EntryNameTag)
        local X = (self:getWidth() / 2 ) - (TextW / 2)
        self:drawText(self.EntryNameTag, 10, 2, 1, 1, 1, 0.5, UIFont.Medium)
    end
end