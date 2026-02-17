S4_ItemListBox = ISPanel:derive("S4_ItemListBox")

function S4_ItemListBox:new(ParentsUI, x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.76, g=0.76, b=0.76, a=0.1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.ParentsUI = ParentsUI
    o.IEUI = ParentsUI.IEUI
    o.ComUI = ParentsUI.ComUI
    o.player = ParentsUI.player
    o.ItemPage = 1
    o.ItemPageMax = 1
    o.PageItemCount = 0
    o.Items = {}
    return o
end

function S4_ItemListBox:initialise()
    ISPanel.initialise(self)
end

function S4_ItemListBox:createChildren()
    ISPanel.createChildren(self)
    -- 10 x 3 = 30 items
    -- MaxW = 10 + ((S4_UI.FH_L * 3) + 20) * 10
    -- MaxH = 10 + ((S4_UI.FH_L * 3) + 20) * 3
    local x = 10 
    local y = 10
    self.InfoPanel = ISPanel:new(x, y, self:getWidth() - 20, S4_UI.FH_M + 20)
    self.InfoPanel.backgroundColor.a = 0
    self.InfoPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.InfoPanel)

    local Sx = 20
    local Sy = 18
    local Sw = ((self:getWidth() - 20) / 2) - 20
    local Sh = S4_UI.FH_M + 4
    self.SearchEntry = ISTextEntryBox:new("", Sx, Sy, Sw, Sh)
    self.SearchEntry.font = UIFont.Medium
    self.SearchEntry.backgroundColor.a = 0
    self.SearchEntry.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.SearchEntry.render = S4_ItemListBox.EntryRender
    self:addChild(self.SearchEntry)
    Sx = Sx + Sw + 10

    self.SearchBtn = ISButton:new(Sx, Sy, 100, Sh, "Search", self, S4_ItemListBox.BtnClick)
    self.SearchBtn.font = UIFont.Medium
    self.SearchBtn.internal = "Search"
    self.SearchBtn.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.SearchBtn.textColor.a = 0.8
    self.SearchBtn:initialise()
    self:addChild(self.SearchBtn)
    Sx = Sx + 110

    self.RefreshBtn = ISButton:new(Sx, Sy, 90, Sh, "Refresh", self, S4_ItemListBox.BtnClick)
    self.RefreshBtn.font = UIFont.Medium
    self.RefreshBtn.internal = "Refresh"
    self.RefreshBtn.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.RefreshBtn.textColor.a = 0.8
    self.RefreshBtn:initialise()
    self:addChild(self.RefreshBtn)

    local PageT = "000 / 000"
    local PageTw = getTextManager():MeasureStringX(UIFont.Medium, PageT)
    local Lsx = self:getWidth() - PageTw - 30

    self.PageLabel = ISLabel:new(Lsx, Sy + 2, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PageLabel)

    y = y + S4_UI.FH_L + 30
    local Bs = (S4_UI.FH_L * 3) + 20
    for i = 1, 100 do
        if i == 1 then
            self["Btn"..i] = S4_ItemBoxButton:new(x, y, Bs, Bs, "", self, S4_ItemListBox.BtnClick)
            self["Btn"..i].internal = "item"..i
            self["Btn"..i].borderColor = {r=0.3, g=0.3, b=0.3, a=1}
            self["Btn"..i].backgroundColor.a = 0
            self["Btn"..i].backgroundColorMouseOver.a = 0.4
            self["Btn"..i].ParentsUI = self.ParentsUI
            self["Btn"..i]:forceImageSize(Bs - 40, Bs - 40)
            self["Btn"..i]:initialise()
            self["Btn"..i]:instantiate()
            self:addChild(self["Btn"..i])
        else
            if x + Bs + 20 > self:getWidth() then
                x = 10
                y = y + Bs + 10
            else
                x = x + Bs + 10
            end
            if y + Bs + 10 > self:getHeight() then
                break
            end
            self["Btn"..i] = S4_ItemBoxButton:new(x, y, Bs, Bs, "", self, S4_ItemListBox.BtnClick)
            self["Btn"..i].internal = "item"..i
            self["Btn"..i].borderColor = {r=0.3, g=0.3, b=0.3, a=1}
            self["Btn"..i].backgroundColor.a = 0
            self["Btn"..i].backgroundColorMouseOver.a = 0.4
            self["Btn"..i].ParentsUI = self.ParentsUI
            self["Btn"..i]:forceImageSize(Bs - 40, Bs - 40)
            self["Btn"..i]:initialise()
            self["Btn"..i]:instantiate()
            self:addChild(self["Btn"..i])
        end
    end
    self:setPage()
end

function S4_ItemListBox:BtnClick(Button)
    local internal = Button.internal
    if internal == "Search" then
        self.ParentsUI.CategoryBox.selectedRow = false
        self.ParentsUI.CategoryBox.CategoryType = internal
        self.ParentsUI:AddItems()
        return
    elseif internal == "Refresh" then
        sendClientCommand("S4SD", "RefreshShopDataFromLua", {nil})
        ModData.request("S4_ShopData")
        ModData.request("S4_PlayerShopData")
        if self.ParentsUI and self.ParentsUI.ReloadData then
            if self.ParentsUI.MenuType == "Buy" or self.ParentsUI.MenuType == "Sell" then
                self.ParentsUI:ReloadData(self.ParentsUI.MenuType)
            else
                self.ParentsUI:ReloadData()
            end
        end
        return
    end
    local Data = Button.item
    if Data and not self.ParentsUI.SettingBox and self.AdminAccess then
        self.ParentsUI:OpenSettingBox(Data)
        -- self:setVisible(false)
    elseif Data and self.ParentsUI.MenuType == "Buy" and not Data.BuyAccessFail then
        self.ParentsUI:OpenBuyBox(Data)
        -- self:setVisible(false)
    elseif Data and self.ParentsUI.MenuType == "Sell" and not Data.BuyAccessFail then
        self.ParentsUI:OpenSellBox(Data)
        -- self:setVisible(false)
    end
end

function S4_ItemListBox:setPage()
    local Page = string.format("%03d", self.ItemPage) .. " / " .. string.format("%03d", self.ItemPageMax)
    self.PageLabel:setName(Page)
end

function S4_ItemListBox:clear()
    self.Items = {}
    self.PageItemCount = 0
    self.ItemPage = 1
    self.ItemPageMax = 1
    self:setItemBtn()
    self:setPage()
end

function S4_ItemListBox:Reloadclear()
    self.Items = {}
    self.PageItemCount = 0
    self.ItemPageMax = 1
    self:setItemBtn()
    self:setPage()
end

function S4_ItemListBox:AddItem(Data)
    self.PageItemCount = self.PageItemCount + 1
    if self.PageItemCount > self.ListCount then
        self.PageItemCount = 1
        self.ItemPageMax = self.ItemPageMax + 1
    end
    Data.ItemCount = self.PageItemCount
    Data.PageCount = self.ItemPageMax
    table.insert(self.Items, Data)
    self:setItemBtn()
    self:setPage()
end

function S4_ItemListBox:setItemBtn()
    if self.ListCount and self.ListCount > 0 then
        for i = 1, self.ListCount do
            local Check = false
            for _, Data in pairs(self.Items) do
                if Data.PageCount == self.ItemPage and Data.ItemCount == i then
                    self["Btn"..i].item = Data
                    self["Btn"..i].ItemName = Data.DisplayName
                    self["Btn"..i].ItemImg = Data.Texture
                    self["Btn"..i].Authority = false
                    self["Btn"..i].SoldOut = false
                    if self.AdminAccess then
                        local TooltipText = Data.DisplayName .. " <LINE> " .. Data.FullType
                        if Data.DataCheck then
                            TooltipText = TooltipText .. " <LINE> " .. getText("IGUI_S4_ShopAdmin_ShopReg_Tooltip")
                            if Data.BuyPrice ~= 0 then -- Available for purchase
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_ShopAdmin_Buy_Available"), Data.BuyPrice)
                            end
                            if Data.SellPrice ~= 0 then -- Available for sale
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_ShopAdmin_Sell_Available"), Data.SellPrice)
                            end
                            if Data.HotItem ~= 0 then
                                TooltipText = TooltipText .. " <LINE> " .. getText("IGUI_S4_ShopAdmin_Hotitem_Available")
                            end
                            if Data.Discount then
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_ShopAdmin_Item_Info"), Data.Stock, Data.Restock, Data.Category, getText("IGUI_S4_Shop_Authority"..Data.BuyAuthority), getText("IGUI_S4_Shop_Authority"..Data.SellAuthority), Data.Discount) .. " %"
                            end
                        else
                            TooltipText = TooltipText .. " <LINE> "  .. getText("IGUI_S4_ShopAdmin_NotShopReg_Tooltip")
                        end
                        self["Btn"..i]:setTooltip(TooltipText)
                    else
                        local TooltipText = string.format(getText("IGUI_S4_Shop_Info_DisplayName"), Data.DisplayName)
                        if self.ParentsUI.MenuType == "Buy" then
                            local MoneyText = S4_UI.getNumCommas(Data.BuyPrice)
                            TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_Shop_Info_Buy"), MoneyText, Data.Stock)
                            if Data.BuyAuthority > 0 then -- Show purchase rating
                                local Authority = getText("IGUI_S4_Shop_Authority"..Data.BuyAuthority)
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_Shop_BuyAuthority"), Authority)
                            end
                            if Data.Discount > 0 then
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_Shop_Discount"), Data.Discount) .. " %"
                            end
                            if Data.BuyAccessFail then -- Lack of purchase rating
                                TooltipText = TooltipText .. " <LINE> " .. getText("IGUI_S4_Shop_BuyAuthorityFail")
                                self["Btn"..i].Authority = true
                            end
                            if Data.Stock < 1 then -- Out of stock in store
                                TooltipText = TooltipText .. " <LINE> " .. getText("IGUI_S4_Shop_BuyStockFail")
                                self["Btn"..i].SoldOut = true
                            end
                        elseif self.ParentsUI.MenuType == "Sell" then
                            local MoneyText = S4_UI.getNumCommas(Data.SellPrice)
                            TooltipText = TooltipText .. " <LINE> " ..  string.format(getText("IGUI_S4_Shop_SellPrice"), MoneyText)
                            if Data.SellAuthority > 0 then -- Show sales rating
                                local Authority = getText("IGUI_S4_Shop_Authority"..Data.BuyAuthority)
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_Shop_SellAuthority"), Data.SellAuthority)
                            end
                            if Data.InvStock then
                                local InvStock = S4_UI.getNumCommas(self.ParentsUI.InvItems[Data.FullType].Amount)
                                TooltipText = TooltipText .. " <LINE> " .. string.format(getText("IGUI_S4_Shop_InvStock"), InvStock)
                            else
                                TooltipText = TooltipText .. " <LINE> " .. getText("IGUI_S4_Shop_SellAmountFail")
                                self["Btn"..i].Authority = true
                            end
                            if Data.SellAccessFail then -- lack of sell rating
                                TooltipText = TooltipText .. " <LINE> " .. getText("IGUI_S4_Shop_SellAuthorityFail")
                                self["Btn"..i].Authority = true
                            end
                        end
                        self["Btn"..i]:setTooltip(TooltipText)
                    end
                    Check = true
                    break
                end
            end
            if not Check then
                self["Btn"..i].item = nil
                self["Btn"..i].ItemName = "No item"
                self["Btn"..i].ItemImg = nil
                self["Btn"..i].tooltip = nil
                self["Btn"..i].Authority = false
                self["Btn"..i].SoldOut = false
            end
        end
    end
end

function S4_ItemListBox:onMouseWheel(del)
    if del then
        local SetPage = self.ItemPage + del
        if self.ItemPageMax >= SetPage and SetPage > 0 then
            self.ItemPage = SetPage
            self:setItemBtn()
            self:setPage()
        end
    end
    return true
end

function S4_ItemListBox:EntryRender()
    if self:getText() == "" and not self.javaObject:isFocused() then
        self:drawText("Search(Item Name/Code)", 4, 2, 1, 1, 1, 0.5, UIFont.Medium)
    end
end
