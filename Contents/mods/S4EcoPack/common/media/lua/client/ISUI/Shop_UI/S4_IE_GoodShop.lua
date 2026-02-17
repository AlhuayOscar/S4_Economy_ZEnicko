S4_IE_GoodShop = ISPanel:derive("S4_IE_GoodShop")

function S4_IE_GoodShop:new(IEUI, x, y)
    local width = IEUI.ComUI:getWidth() - 12
    local TaskH = IEUI.ComUI:getHeight() - IEUI.ComUI.TaskBarY
    local height = IEUI.ComUI:getHeight() - ((S4_UI.FH_S * 2) + 23 + TaskH)

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    }
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    o.IEUI = IEUI -- Save parent UI reference
    o.ComUI = IEUI.ComUI -- computer ui
    o.player = IEUI.player
    o.Moving = true
    o.PlayerBuyAuthority = 0
    o.PlayerSellAuthority = 0
    return o
end

function S4_IE_GoodShop:initialise()
    ISPanel.initialise(self)
    self.InvItems = S4_Utils.getPlayerItems(self.player)
    local PlayerName = self.player:getUsername()
    local W, H, Count = S4_UI.getGoodShopSizeZ(self.ComUI)
    self.IEUI:FixUISize(W, H)
    self.MenuType = "Home"
    self.ListCount = Count
    self.AllItems = {}
    self.BuyCategory = {}
    self.SellCategory = {}
    local ShopModData = ModData.get("S4_ShopData") or {}
    local PlayerShopRoot = ModData.get("S4_PlayerShopData") or {}
    local PlayerShopModData = PlayerShopRoot[PlayerName]
    if not PlayerShopModData then
        return
    end
    for FullType, MData in pairs(ShopModData) do
        local itemCashe = S4_Utils.setItemCashe(FullType)
        if itemCashe then
            local Data = {}
            Data.FullType = itemCashe:getFullType()
            Data.DisplayName = itemCashe:getDisplayName()
            Data.Texture = itemCashe:getTex()
            Data.itemData = itemCashe
            Data.BuyPrice = ShopModData[Data.FullType].BuyPrice or 0
            Data.SellPrice = ShopModData[Data.FullType].SellPrice or 0
            Data.Stock = ShopModData[Data.FullType].Stock or 0
            Data.Restock = ShopModData[Data.FullType].Restock or 0
            Data.Category = ShopModData[Data.FullType].Category or "None"
            Data.BuyAuthority = ShopModData[Data.FullType].BuyAuthority or 0
            Data.SellAuthority = ShopModData[Data.FullType].SellAuthority or 0
            Data.Discount = ShopModData[Data.FullType].Discount or 0
            Data.HotItem = ShopModData[Data.FullType].HotItem or 0
            if PlayerShopModData.FavoriteList[Data.FullType] then
                Data.Favorite = true
            end
            if Data.BuyPrice > 0 then
                if not self.BuyCategory[Data.Category] then
                    self.BuyCategory[Data.Category] = Data.Category
                end
            end
            if Data.SellPrice > 0 then
                if not self.SellCategory[Data.Category] then
                    self.SellCategory[Data.Category] = Data.Category
                end
            end
            if PlayerShopModData then
                if Data.BuyAuthority > PlayerShopModData.BuyAuthority then
                    Data.BuyAccessFail = true
                end
                if Data.SellAuthority > PlayerShopModData.SellAuthority then
                    Data.SellAccessFail = true
                end
            end
            if self.InvItems and self.InvItems[Data.FullType] then
                Data.InvStock = self.InvItems[Data.FullType].Amount
            else
                Data.InvStock = false
            end
            -- table.insert(self.AllItems, Data)
            if not self.AllItems[Data.FullType] then
                self.AllItems[Data.FullType] = Data
            end
        end
    end
    if PlayerShopModData.Cart then
        for CartItem, Amount in pairs(PlayerShopModData.Cart) do
            if not self.ComUI.BuyCart[CartItem] then
                self.ComUI.BuyCart[CartItem] = Amount
            end
        end
    end
    if PlayerShopModData.BuyAuthority then
        self.PlayerBuyAuthority = PlayerShopModData.BuyAuthority
    end
    if PlayerShopModData.SellAuthority then
        self.PlayerSellAuthority = PlayerShopModData.SellAuthority
    end
end

function S4_IE_GoodShop:createChildren()
    ISPanel.createChildren(self)

    local InfoX = 10
    local InfoY = 10
    local InfoH = (S4_UI.FH_S * 2) + 20

    local LogoText = "Good"
    local LogoTextW = getTextManager():MeasureStringX(UIFont.Medium, LogoText)
    local LogoX = 10 + ((S4_UI.FH_L * 3) + 20) - (LogoTextW / 2) - 10
    local LogoY = 20
    self.LogoLabel1 = ISLabel:new(LogoX, LogoY, S4_UI.FH_S, LogoText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.LogoLabel1)
    LogoX = LogoX + (LogoTextW / 2) - 10
    LogoY = LogoY + S4_UI.FH_S
    self.LogoLabel2 = ISLabel:new(LogoX, LogoY, S4_UI.FH_S, "Shop", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.LogoLabel2)

    local CategoryW = (((S4_UI.FH_L * 3) + 20) * 2) - 10
    local CategoryY = (InfoY * 2) + InfoH
    local CategoryH = self:getHeight() - ((InfoY * 3) + InfoH)

    self.HomePanel = S4_Shop_Home:new(self, InfoX, CategoryY, self:getWidth() - 20, CategoryH)
    self.HomePanel.backgroundColor.a = 0
    self.HomePanel.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self.HomePanel:initialise()
    self:addChild(self.HomePanel)

    self.CartPanel = S4_Shop_Cart:new(self, InfoX, CategoryY, self:getWidth() - 20, CategoryH)
    self.CartPanel.backgroundColor.a = 0
    self.CartPanel.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self.CartPanel:initialise()
    self:addChild(self.CartPanel)

    self.CategoryPanel = ISPanel:new(InfoX, CategoryY, CategoryW, CategoryH)
    self.CategoryPanel.backgroundColor.a = 0
    self.CategoryPanel.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self:addChild(self.CategoryPanel)

    local CText = "Category"
    local CTextW = getTextManager():MeasureStringX(UIFont.Medium, CText)
    local CTextX = 10 + (CategoryW / 2) - (CTextW / 2)
    self.CategoryLabel = ISLabel:new(CTextX, CategoryY - 1, S4_UI.FH_M, CText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.CategoryLabel)

    local ListBoxY = CategoryY + S4_UI.FH_M
    local ListBoxH = CategoryH - S4_UI.FH_M
    self.CategoryBox = ISScrollingListBox:new(InfoX, ListBoxY, CategoryW, ListBoxH)
    self.CategoryBox:initialise()
    self.CategoryBox:instantiate()
    self.CategoryBox.drawBorder = true
    self.CategoryBox.borderColor.a = 1
    self.CategoryBox.backgroundColor.a = 0
    self.CategoryBox.parentUI = self
    self.CategoryBox.vscroll:setX(30000)
    self.CategoryBox.doDrawItem = S4_IE_GoodShop.doDrawItem_CategoryBox
    -- self.CategoryBox.onMouseMove = S4_IE_GoodShop.onMouseMove_CategoryBox
    self.CategoryBox.onMouseDown = S4_IE_GoodShop.onMouseDown_CategoryBox
    self:addChild(self.CategoryBox)
    -- self:AddCategory()

    local BoxX = 20 + CategoryW
    local BoxW = (self:getWidth() - 20) - BoxX + 10

    self.ListBox = S4_ItemListBox:new(self, BoxX, CategoryY, BoxW, CategoryH)
    self.ListBox.backgroundColor.a = 0
    self.ListBox.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self.ListBox.ListCount = self.ListCount
    self:addChild(self.ListBox)

    self.InfoPanel = ISPanel:new(BoxX, InfoY, BoxW, InfoH)
    self.InfoPanel.backgroundColor.a = 0
    self.InfoPanel.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self:addChild(self.InfoPanel)

    local BtnX = BoxX + 10
    local BtnW = (S4_UI.FH_L * 3) + 20
    self.HomeBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Home", self, S4_IE_GoodShop.BtnClick)
    self.HomeBtn.internal = "Home"
    self.HomeBtn.font = UIFont.Large
    self.HomeBtn.backgroundColor.a = 0
    self.HomeBtn.borderColor.a = 0
    self.HomeBtn.textColor.a = 0.9
    self.HomeBtn:initialise()
    self:addChild(self.HomeBtn)
    BtnX = BtnX + BtnW + 10

    self.BuyBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Buy", self, S4_IE_GoodShop.BtnClick)
    self.BuyBtn.internal = "Buy"
    self.BuyBtn.font = UIFont.Large
    self.BuyBtn.backgroundColor.a = 0
    self.BuyBtn.borderColor.a = 0
    self.BuyBtn.textColor.a = 0.9
    self.BuyBtn:initialise()
    self:addChild(self.BuyBtn)
    BtnX = BtnX + BtnW + 10

    self.SellBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Sell", self, S4_IE_GoodShop.BtnClick)
    self.SellBtn.internal = "Sell"
    self.SellBtn.font = UIFont.Large
    self.SellBtn.backgroundColor.a = 0
    self.SellBtn.borderColor.a = 0
    self.SellBtn.textColor.a = 0.9
    self.SellBtn:initialise()
    self:addChild(self.SellBtn)
    BtnX = BtnX + BtnW + 10

    self.CartBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Cart", self, S4_IE_GoodShop.BtnClick)
    self.CartBtn.internal = "Cart"
    self.CartBtn.font = UIFont.Large
    self.CartBtn.backgroundColor.a = 0
    self.CartBtn.borderColor.a = 0
    self.CartBtn.textColor.a = 0.9
    self.CartBtn:initialise()
    self:addChild(self.CartBtn)

    self:ShopBoxVisible(false)
    self.HomePanel:setVisible(true)
end

function S4_IE_GoodShop:render()
    ISPanel.render(self)

    if self.MenuType then
        local targetBtn = self[self.MenuType .. "Btn"]
        if targetBtn then
            local x, y, w, h = targetBtn:getX(), targetBtn:getY() + 1,
                targetBtn:getWidth(), targetBtn:getHeight() - 2
            self:drawRect(x, y, w, h, 0.2, 1, 1, 1)
        end
    end
end

-- Item purchase/sale information window
function S4_IE_GoodShop:OpenBuyBox(Data)
    if self.BuyBox then
        self.BuyBox:close()
    end
    self.BuyBox = S4_Shop_BuyBox:new(self, self.ListBox:getX(), self.ListBox:getY(), self.ListBox:getWidth(),
        self.ListBox:getHeight())
    self.BuyBox.backgroundColor.a = 0
    self.BuyBox.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self.BuyBox.ItemData = Data
    self.BuyBox:initialise()
    self:addChild(self.BuyBox)
    self.ListBox:setVisible(false)
end
function S4_IE_GoodShop:OpenSellBox(Data)
    if self.SellBox then
        self.SellBox:close()
    end
    self.SellBox = S4_Shop_SellBox:new(self, self.ListBox:getX(), self.ListBox:getY(), self.ListBox:getWidth(),
        self.ListBox:getHeight())
    self.SellBox.backgroundColor.a = 0
    self.SellBox.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self.SellBox.ItemData = Data
    self.SellBox:initialise()
    self:addChild(self.SellBox)
    self.ListBox:setVisible(false)
end

-- Item settings
function S4_IE_GoodShop:AddItems(Reload)
    if not Reload then
        self.ListBox:clear()
    else
        self.ListBox:Reloadclear()
    end
    for _, Data in pairs(self.AllItems) do
        local Category = Data.Category
        if self.CategoryBox.CategoryType == Category then
            if self.MenuType == "Buy" and Data.BuyPrice > 0 then
                self.ListBox:AddItem(Data)
            elseif self.MenuType == "Sell" and Data.SellPrice > 0 then
                self.ListBox:AddItem(Data)
            end
        elseif self.CategoryBox.CategoryType == "All" then
            if self.MenuType == "Buy" and Data.BuyPrice > 0 then
                self.ListBox:AddItem(Data)
            end
        elseif self.CategoryBox.CategoryType == "Favorite" then
            if self.MenuType == "Buy" and Data.BuyPrice > 0 then
                if Data.Favorite then
                    self.ListBox:AddItem(Data)
                end
            end
        elseif self.CategoryBox.CategoryType == "AllView" then
            if self.MenuType == "Sell" and Data.SellPrice > 0 then
                self.ListBox:AddItem(Data)
            end
        elseif self.CategoryBox.CategoryType == "InvItem" then
            if self.MenuType == "Sell" and Data.SellPrice > 0 then
                if Data.InvStock then
                    self.ListBox:AddItem(Data)
                end
            end
        elseif self.CategoryBox.CategoryType == "HotItem" and self.MenuType == "Buy" then
            if Data.HotItem ~= 0 then
                self.ListBox:AddItem(Data)
            end
        elseif self.CategoryBox.CategoryType == "Search" then
            if not self.ListBox or not self.ListBox.SearchEntry then
                return
            end
            if Data.FullType and Data.DisplayName then
                local ST = self.ListBox.SearchEntry:getText()
                if ST ~= "" then
                    ST = string.lower(ST):gsub("%s+", "")
                    local SD = string.lower(Data.DisplayName):gsub("%s+", "")
                    local SF = string.lower(Data.FullType):gsub("%s+", "")
                    if SD:find(ST) or SF:find(ST) then
                        if self.MenuType == "Buy" and Data.BuyPrice > 0 then
                            self.ListBox:AddItem(Data)
                        elseif self.MenuType == "Sell" and Data.SellPrice > 0 then
                            self.ListBox:AddItem(Data)
                        end
                    end
                end
            end
        end
    end
end

function S4_IE_GoodShop:AddCartItem(Reload)
    if not Reload then
        self.CartPanel:clear()
    else
        self.CartPanel:Reloadclear()
    end
    if self.CartPanel.CartType == "Buy" then
        for Iname, Amount in pairs(self.ComUI.BuyCart) do
            local Data = {}
            if self.AllItems[Iname] then
                Data.FullType = Iname
                Data.DisplayName = self.AllItems[Iname].DisplayName
                Data.Texture = self.AllItems[Iname].Texture
                Data.Amount = Amount
                Data.ItemData = self.AllItems[Iname]
                self.CartPanel:AddItem(Data)
            end
        end
    elseif self.CartPanel.CartType == "Sell" then
        for Iname, Amount in pairs(self.ComUI.SellCart) do
            if self.AllItems[Iname] then
                local Data = {}
                Data.FullType = Iname
                Data.DisplayName = self.AllItems[Iname].DisplayName
                Data.Texture = self.AllItems[Iname].Texture
                Data.Amount = Amount
                Data.ItemData = self.AllItems[Iname]
                self.CartPanel:AddItem(Data)
            end
        end
    end
end

function S4_IE_GoodShop:getDefaultCategoryType()
    if self.MenuType == "Buy" then
        return "HotItem"
    elseif self.MenuType == "Sell" then
        return "InvItem"
    end
    return false
end

function S4_IE_GoodShop:getCategoryRow(CategoryType)
    if not CategoryType or not self.CategoryBox or not self.CategoryBox.items then
        return false
    end
    for i, rowData in ipairs(self.CategoryBox.items) do
        if rowData and rowData.item == CategoryType then
            return i
        end
    end
    return false
end

function S4_IE_GoodShop:getViewState()
    local data = {}
    data.MenuType = self.MenuType
    data.CategoryType = self.CategoryBox and self.CategoryBox.CategoryType or false
    data.SelectedRow = self.CategoryBox and self.CategoryBox.selectedRow or false
    data.ItemPage = 1
    data.SearchText = ""
    if self.ListBox then
        data.ItemPage = self.ListBox.ItemPage or 1
        if self.ListBox.SearchEntry then
            data.SearchText = self.ListBox.SearchEntry:getText() or ""
        end
    end
    return data
end

function S4_IE_GoodShop:applyViewState(viewState)
    if not viewState then
        return false
    end
    if self.MenuType ~= "Buy" and self.MenuType ~= "Sell" then
        return false
    end

    local searchText = viewState.SearchText or ""
    if self.ListBox and self.ListBox.SearchEntry then
        self.ListBox.SearchEntry:setText(searchText)
    end

    local categoryType = viewState.CategoryType or self:getDefaultCategoryType()
    local selectedRow = false
    if categoryType == "Search" then
        if searchText == "" then
            categoryType = self:getDefaultCategoryType()
        end
    end

    if categoryType ~= "Search" then
        selectedRow = self:getCategoryRow(categoryType)
        if not selectedRow then
            categoryType = self:getDefaultCategoryType()
            selectedRow = self:getCategoryRow(categoryType)
        end
    end

    self.CategoryBox.CategoryType = categoryType
    self.CategoryBox.selectedRow = selectedRow or false
    self:AddItems(true)

    if self.ListBox then
        local page = tonumber(viewState.ItemPage) or 1
        if page < 1 then
            page = 1
        end
        if page > self.ListBox.ItemPageMax then
            page = self.ListBox.ItemPageMax
        end
        if page < 1 then
            page = 1
        end
        self.ListBox.ItemPage = page
        self.ListBox:setItemBtn()
        self.ListBox:setPage()
    end
    return true
end

-- Reset item data
function S4_IE_GoodShop:ReloadData(ReloadType, PreserveView, hadChanges)
    local savedView = nil
    if PreserveView then
        savedView = self:getViewState()
    end

    self.AllItems = {}
    self.BuyCategory = {}
    self.SellCategory = {}
    self.InvItems = {}
    self.InvItems = S4_Utils.getPlayerItems(self.player)
    if ReloadType == "Sell" and not PreserveView then
        self.ComUI.SellCart = {}
    end

    local Count = 0
    local Target = 10
    local function UpdateCount_DataSetup()
        Count = Count + 1
        if Count >= Target then
            Events.OnTick.Remove(UpdateCount_DataSetup)
            local PlayerName = self.player:getUsername()
            local ShopModData = ModData.get("S4_ShopData") or {}
            local PlayerShopRoot = ModData.get("S4_PlayerShopData") or {}
            local PlayerShopModData = PlayerShopRoot[PlayerName]
            if not PlayerShopModData then
                if PreserveView and self.ListBox and self.ListBox.markRefreshApplied then
                    self.ListBox:markRefreshApplied()
                end
                return
            end
            for FullType, MData in pairs(ShopModData) do
                local itemCashe = S4_Utils.setItemCashe(FullType)
                if itemCashe then
                    local Data = {}
                    Data.FullType = itemCashe:getFullType()
                    Data.DisplayName = itemCashe:getDisplayName()
                    Data.Texture = itemCashe:getTex()
                    Data.itemData = itemCashe
                    Data.BuyPrice = ShopModData[Data.FullType].BuyPrice or 0
                    Data.SellPrice = ShopModData[Data.FullType].SellPrice or 0
                    Data.Stock = ShopModData[Data.FullType].Stock or 0
                    Data.Restock = ShopModData[Data.FullType].Restock or 0
                    Data.Category = ShopModData[Data.FullType].Category or "None"
                    Data.BuyAuthority = ShopModData[Data.FullType].BuyAuthority or 0
                    Data.SellAuthority = ShopModData[Data.FullType].SellAuthority or 0
                    Data.Discount = ShopModData[Data.FullType].Discount or 0
                    Data.HotItem = ShopModData[Data.FullType].HotItem or 0
                    if PlayerShopModData.FavoriteList[Data.FullType] then
                        Data.Favorite = true
                    end
                    if Data.BuyPrice > 0 then
                        if not self.BuyCategory[Data.Category] then
                            self.BuyCategory[Data.Category] = Data.Category
                        end
                    end
                    if Data.SellPrice > 0 then
                        if not self.SellCategory[Data.Category] then
                            self.SellCategory[Data.Category] = Data.Category
                        end
                    end
                    if PlayerShopModData then
                        if Data.BuyAuthority > PlayerShopModData.BuyAuthority then
                            Data.BuyAccessFail = true
                        end
                        if Data.SellAuthority > PlayerShopModData.SellAuthority then
                            Data.SellAccessFail = true
                        end
                    end
                    if self.InvItems and self.InvItems[Data.FullType] then
                        Data.InvStock = self.InvItems[Data.FullType].Amount
                    else
                        Data.InvStock = false
                    end
                    -- table.insert(self.AllItems, Data)
                    if not self.AllItems[Data.FullType] then
                        self.AllItems[Data.FullType] = Data
                    end
                end
            end
            if PlayerShopModData.Cart then
                for CartItem, Amount in pairs(PlayerShopModData.Cart) do
                    if not self.ComUI.BuyCart[CartItem] then
                        self.ComUI.BuyCart[CartItem] = Amount
                    end
                end
            end
            if PlayerShopModData.BuyAuthority then
                self.PlayerBuyAuthority = PlayerShopModData.BuyAuthority
            end
            if PlayerShopModData.SellAuthority then
                self.PlayerSellAuthority = PlayerShopModData.SellAuthority
            end
            self:AddCategory()

            local targetMenu = ReloadType
            if targetMenu ~= "Buy" and targetMenu ~= "Sell" then
                targetMenu = self.MenuType
            end

            if targetMenu == "Buy" or targetMenu == "Sell" then
                self.MenuType = targetMenu
            end

            local restored = false
            if PreserveView and savedView and self.MenuType == savedView.MenuType then
                restored = self:applyViewState(savedView)
            end

            if not restored then
                if ReloadType == "Buy" then
                    self.MenuType = "Buy"
                    self:AddItems(false)
                elseif ReloadType == "Sell" then
                    self.MenuType = "Sell"
                    self:AddCartItem(false)
                end
            end
            self:ShopBoxVisible(true, restored)

            if PreserveView and self.ListBox and self.ListBox.markRefreshApplied then
                self.ListBox:markRefreshApplied(hadChanges)
            end
        else
            return
        end
    end
    Events.OnTick.Add(UpdateCount_DataSetup)
end

function S4_IE_GoodShop:CheckDebt()
    if self.ComUI.CardNumber then
        local CardModData = ModData.get("S4_CardData")
        local LoanModData = ModData.get("S4_LoanData")
        local UserName = self.player:getUsername()
        
        if CardModData and CardModData[self.ComUI.CardNumber] then
            local money = CardModData[self.ComUI.CardNumber].Money
            
            local totalLoanDebt = 0
            if LoanModData and LoanModData[UserName] then
                for _, loan in pairs(LoanModData[UserName]) do
                    if loan.Status == "Active" then
                        totalLoanDebt = totalLoanDebt + (loan.TotalToPay - (loan.Repaid or 0))
                    end
                end
            end

            -- Block if net debt is positive (Loans > balance)
            if (totalLoanDebt - money) > 0 then
                return true
            end
        end
    end
    return false
end

-- Category settings
function S4_IE_GoodShop:AddCategory()
    self.CategoryBox:clear()
    -- self.CategoryBox:addItem("PopularProducts", "PopularProducts")
    if self.MenuType == "Buy" then
        self.CategoryBox:addItem("HotItem", "HotItem")
        self.CategoryBox:addItem("Favorite", "Favorite")
        self.CategoryBox:addItem("All", "All")
        for Category, CategoryName in pairs(self.BuyCategory) do
            if CategoryName ~= "All" then
                self.CategoryBox:addItem(CategoryName, CategoryName)
            end
        end
    elseif self.MenuType == "Sell" then
        self.CategoryBox:addItem("InvItem", "InvItem")
        self.CategoryBox:addItem("AllView", "AllView")
    end
end

function S4_IE_GoodShop:SoftRefreshData(hadChanges)
    if self.BuyBox or self.SellBox then
        return
    end
    if self.MenuType ~= "Buy" and self.MenuType ~= "Sell" then
        if self.ListBox and self.ListBox.markRefreshApplied then
            self.ListBox:markRefreshApplied(hadChanges)
        end
        return
    end
    self:ReloadData(self.MenuType, true, hadChanges)
end

function S4_IE_GoodShop:OnShopDataUpdated(key)
    if key ~= "S4_ShopData" and key ~= "S4_PlayerShopData" then
        return
    end
    self:SoftRefreshData(true)
end

-- button click
function S4_IE_GoodShop:BtnClick(Button)
    local internal = Button.internal
    if not internal then
        return
    end
    if self.BuyBox or self.SellBox then
        return
    end
    if internal == "Buy" then
        if self:CheckDebt() then
            self.ComUI:AddMsgBox(getText("IGUI_S4_ATM_Msg_Error"), nil, getText("IGUI_S4_NoMoneyDebt"), getText("IGUI_S4_ATM_Msg_LowBalance"))
            return
        end
    end
    self.MenuType = internal
    if internal == "Buy" then
        ModData.request("S4_ShopData")
        ModData.request("S4_PlayerShopData")
        if self.ListBox then self.ListBox.SyncLevel = 0 end
        self:ReloadData("Buy")
    elseif internal == "Sell" then
        ModData.request("S4_ShopData")
        ModData.request("S4_PlayerShopData")
        if self.ListBox then self.ListBox.SyncLevel = 0 end
        self:ReloadData("Sell")
    elseif internal == "Home" then
        self:ShopBoxVisible(false)
        self.HomePanel:setVisible(true)
    elseif internal == "Cart" then
        self:AddCartItem(false)
        self:ShopBoxVisible(false)
        self.CartPanel:setVisible(true)
    end
end

-- Reset Category Settings, Category Visible Settings
function S4_IE_GoodShop:ShopBoxVisible(Value, KeepCurrentView)
    if self.MenuType == "Buy" then
        if not KeepCurrentView or not self.CategoryBox.CategoryType then
            self.CategoryBox.selectedRow = 1
            self.CategoryBox.CategoryType = "HotItem"
            self:AddItems()
        end
    elseif self.MenuType == "Sell" then
        if not KeepCurrentView or not self.CategoryBox.CategoryType then
            self.CategoryBox.selectedRow = 1
            self.CategoryBox.CategoryType = "InvItem"
            self:AddItems()
        end
    else
        self.CategoryBox.selectedRow = false
        self.CategoryBox.CategoryType = false
    end
    self.HomePanel:setVisible(false)
    self.CartPanel:setVisible(false)
    self.CategoryPanel:setVisible(Value)
    self.CategoryLabel:setVisible(Value)
    self.CategoryBox:setVisible(Value)
    self.ListBox:setVisible(Value)
end

-- Category Rendering
function S4_IE_GoodShop:doDrawItem_CategoryBox(y, item, alt)
    local yOffset = 2
    local Cw = self:getWidth() - 2
    local Ch = (yOffset * 2) + S4_UI.FH_M

    local BorderW = Cw - (Cw / 4)
    local BorderX = ((Cw / 4) / 2) + 1

    if self.selectedRow == item.index then
        self:drawRect(1, y, Cw, Ch, 0.2, 1, 1, 1)
    end
    self:drawRectBorder(BorderX, y + Ch, BorderW, 1, 0.4, 1, 1, 1)

    local CNameKey = "IGUI_S4_ItemCat_" .. item.item
    local CNameT = getText(CNameKey)
    if CNameT == CNameKey then
        CNameT = item.item
    end
    local CNameFT = S4_UI.TextLimitOne(CNameT, Cw - 8, UIFont.Medium)
    local CNameW = getTextManager():MeasureStringX(UIFont.Medium, CNameFT)
    local CNamex = (Cw / 2) - (CNameW / 2)
    self:drawText(CNameFT, CNamex, y + yOffset, 0.9, 0.9, 0.9, 1, UIFont.Medium)
    return y + Ch
end

-- Click on Category
function S4_IE_GoodShop:onMouseDown_CategoryBox(x, y)
    local ShopUI = self.parentUI
    if ShopUI.SettingBox then
        return
    end
    if ShopUI.BuyBox or ShopUI.SellBox then
        return
    end
    if ShopUI.MenuType == "Buy" or ShopUI.MenuType == "Sell" then
        ISScrollingListBox.onMouseDown(self, x, y)
        local list = self
        local rowIndex = list:rowAt(x, y)
        if rowIndex > 0 then
            list.selectedRow = rowIndex
            list.CategoryType = self.items[rowIndex].item
            ShopUI:AddItems()
        end
    end
end

-- Functions related to moving and exiting UI
function S4_IE_GoodShop:onMouseDown(x, y)
    if not self.Moving then
        return
    end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_GoodShop:onMouseUpOutside(x, y)
    if not self.Moving then
        return
    end
    self.IEUI.moving = false
end

function S4_IE_GoodShop:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
