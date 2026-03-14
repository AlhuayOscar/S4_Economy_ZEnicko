S4_ItemSettingBox = ISPanel:derive("S4_ItemSettingBox")

function S4_ItemSettingBox:new(ParentsUI, x, y, w, h)
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

function S4_ItemSettingBox:initialise()
    ISPanel.initialise(self)
    
end

function S4_ItemSettingBox:createChildren()
    ISPanel.createChildren(self)

    local Cx = self:getWidth() - S4_UI.FH_S - 5
    local Cy = 5
    self.Closebtn = ISButton:new(Cx, Cy, S4_UI.FH_S, S4_UI.FH_S, 'X', self, S4_ItemSettingBox.BtnClick)
    self.Closebtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.Closebtn.internal = "close"
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
    self.ItemNameLabel = ISLabel:new(NameX, NameY, S4_UI.FH_L, "", 1, 1, 1, 0.8, UIFont.Large, true)
    self:addChild(self.ItemNameLabel)
    NameY = NameY + S4_UI.FH_L

    self.CategoryLabel = ISLabel:new(NameX + 5, NameY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.CategoryLabel)
    NameY = NameY + S4_UI.FH_M

    self.StateLabel = ISLabel:new(NameX + 5, NameY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.StateLabel)

    local EntryX = IconX
    local EntryY = (IconY * 2) + IconWH
    local EntryW = (self:getWidth() / 2) - 125
    local EnrtyH = S4_UI.FH_M + 4
    local BtnX = EntryX + EntryW + 10
    local EntryX2 = BtnX + 110
    local EntryY2 = (IconY * 2) + IconWH
    local BtnX2 = EntryX2 + EntryW + 10
    -- Row 1
    self.BuyPriceEntry = ISTextEntryBox:new("", EntryX, EntryY, EntryW, EnrtyH)
    self.BuyPriceEntry.font = UIFont.Medium
    self.BuyPriceEntry.tooltip = getText("IGUI_S4_ShopAdmin_BuyPriceEntry")
    self.BuyPriceEntry.render = S4_ItemSettingBox.EntryRender
    self.BuyPriceEntry.EntryNameTag = getText("BuyPrice")
    self.BuyPriceEntry:initialise()
    self.BuyPriceEntry:instantiate()
    self.BuyPriceEntry:setOnlyNumbers(true)
    self:addChild(self.BuyPriceEntry)
    EnrtyH = self.BuyPriceEntry:getHeight()

    self.BuyPriceBtn = ISButton:new(BtnX, EntryY, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.BuyPriceBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.BuyPriceBtn.internal = "BuyPrice"
    self.BuyPriceBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.BuyPriceBtn:initialise()
    self:addChild(self.BuyPriceBtn)
    EntryY = EntryY + EnrtyH +10

    self.SellPriceEntry = ISTextEntryBox:new("", EntryX, EntryY, EntryW, EnrtyH)
    self.SellPriceEntry.font = UIFont.Medium
    self.SellPriceEntry.tooltip = getText("IGUI_S4_ShopAdmin_SellPriceEntry")
    self.SellPriceEntry.render = S4_ItemSettingBox.EntryRender
    self.SellPriceEntry.EntryNameTag = getText("SellPrice")
    self.SellPriceEntry:initialise()
    self.SellPriceEntry:instantiate()
    self.SellPriceEntry:setOnlyNumbers(true)
    self:addChild(self.SellPriceEntry)

    self.SellPriceBtn = ISButton:new(BtnX, EntryY, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.SellPriceBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.SellPriceBtn.internal = "SellPrice"
    self.SellPriceBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.SellPriceBtn:initialise()
    self:addChild(self.SellPriceBtn)
    EntryY = EntryY + EnrtyH +10
    
    self.StockEntry = ISTextEntryBox:new("", EntryX, EntryY, EntryW, EnrtyH)
    self.StockEntry.font = UIFont.Medium
    self.StockEntry.tooltip = getText("IGUI_S4_ShopAdmin_StockEntry")
    self.StockEntry.render = S4_ItemSettingBox.EntryRender
    self.StockEntry.EntryNameTag = getText("Stock")
    self.StockEntry:initialise()
    self.StockEntry:instantiate()
    self.StockEntry:setOnlyNumbers(true)
    self:addChild(self.StockEntry)

    self.StockBtn = ISButton:new(BtnX, EntryY, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.StockBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.StockBtn.internal = "Stock"
    self.StockBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.StockBtn:initialise()
    self:addChild(self.StockBtn)
    EntryY = EntryY + EnrtyH +10

    self.RestockEntry = ISTextEntryBox:new("", EntryX, EntryY, EntryW, EnrtyH)
    self.RestockEntry.font = UIFont.Medium
    self.RestockEntry.tooltip = getText("IGUI_S4_ShopAdmin_RestockEntry")
    self.RestockEntry.render = S4_ItemSettingBox.EntryRender
    self.RestockEntry.EntryNameTag = getText("Restock")
    self.RestockEntry:initialise()
    self.RestockEntry:instantiate()
    self.RestockEntry:setOnlyNumbers(true)
    self:addChild(self.RestockEntry)

    self.RestockBtn = ISButton:new(BtnX, EntryY, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.RestockBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.RestockBtn.internal = "Restock"
    self.RestockBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.RestockBtn:initialise()
    self:addChild(self.RestockBtn)
    EntryY = EntryY + EnrtyH +10

    self.DiscountEntry = ISTextEntryBox:new("", EntryX, EntryY, EntryW, EnrtyH)
    self.DiscountEntry.font = UIFont.Medium
    self.DiscountEntry.tooltip = getText("IGUI_S4_ShopAdmin_DiscountEntry")
    self.DiscountEntry.render = S4_ItemSettingBox.EntryRender
    self.DiscountEntry.EntryNameTag = getText("Discount")
    self.DiscountEntry:initialise()
    self.DiscountEntry:instantiate()
    self.DiscountEntry:setOnlyNumbers(true)
    self:addChild(self.DiscountEntry)

    self.DiscountBtn = ISButton:new(BtnX, EntryY, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.DiscountBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.DiscountBtn.internal = "Discount"
    self.DiscountBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.DiscountBtn:initialise()
    self:addChild(self.DiscountBtn)
    
    -- 2nd row
    self.BuyAuthorityBox = ISComboBox:new(EntryX2, EntryY2, EntryW, EnrtyH, self)
    self.BuyAuthorityBox.font = UIFont.Medium
    self.BuyAuthorityBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.BuyAuthorityBox.render = S4_ItemSettingBox.ComboBoxRender
    self.BuyAuthorityBox.EntryNameTag = getText("BuyAuthority")
    self.BuyAuthorityBox.tooltip = getText("IGUI_S4_ShopAdmin_BuyAuthorityBox")
    self:addChild(self.BuyAuthorityBox)
    for i = 0, 5 do self.BuyAuthorityBox:addOptionWithData(getText("IGUI_S4_Shop_Authority"..i), i) end

    self.BuyAuthorityBtn = ISButton:new(BtnX2, EntryY2, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.BuyAuthorityBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.BuyAuthorityBtn.internal = "BuyAuthority"
    self.BuyAuthorityBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.BuyAuthorityBtn:initialise()
    self:addChild(self.BuyAuthorityBtn)
    EntryY2 = EntryY2 + EnrtyH +10

    self.SellAuthorityBox = ISComboBox:new(EntryX2, EntryY2, EntryW, EnrtyH, self)
    self.SellAuthorityBox.font = UIFont.Medium
    self.SellAuthorityBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.SellAuthorityBox.render = S4_ItemSettingBox.ComboBoxRender
    self.SellAuthorityBox.EntryNameTag = getText("SellAuthority")
    self.SellAuthorityBox.tooltip = getText("IGUI_S4_ShopAdmin_SellAuthorityBox")
    self:addChild(self.SellAuthorityBox)
    for i = 0, 5 do self.SellAuthorityBox:addOptionWithData(getText("IGUI_S4_Shop_Authority"..i), i) end

    self.SellAuthorityBtn = ISButton:new(BtnX2, EntryY2, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.SellAuthorityBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.SellAuthorityBtn.internal = "SellAuthority"
    self.SellAuthorityBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.SellAuthorityBtn:initialise()
    self:addChild(self.SellAuthorityBtn)
    EntryY2 = EntryY2 + EnrtyH +10

    self.CategoryBox = ISComboBox:new(EntryX2, EntryY2, EntryW, EnrtyH, self)
    self.CategoryBox.font = UIFont.Medium
    self.CategoryBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.CategoryBox.render = S4_ItemSettingBox.ComboBoxRender
    self.CategoryBox.EntryNameTag = getText("Category")
    self.CategoryBox.tooltip = getText("IGUI_S4_ShopAdmin_CategoryBox")
    self:addChild(self.CategoryBox)

    self.CategoryBtn = ISButton:new(BtnX2, EntryY2, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.CategoryBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.CategoryBtn.internal = "Category"
    self.CategoryBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.CategoryBtn:initialise()
    self:addChild(self.CategoryBtn)
    EntryY2 = EntryY2 + EnrtyH +10

    self.HotItemBox = ISComboBox:new(EntryX2, EntryY2, EntryW, EnrtyH, self)
    self.HotItemBox.font = UIFont.Medium
    self.HotItemBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.HotItemBox.render = S4_ItemSettingBox.ComboBoxRender
    self.HotItemBox.EntryNameTag = getText("HotItem")
    self.HotItemBox.tooltip = getText("IGUI_S4_ShopAdmin_HotItem")
    self:addChild(self.HotItemBox)
    self.HotItemBox:addOptionWithData(getText("IGUI_S4_ShopAdmin_Not_Reg"), 0) 
    self.HotItemBox:addOptionWithData(getText("IGUI_S4_ShopAdmin_Set_Reg"), 1) 

    self.HotItemBtn = ISButton:new(BtnX2, EntryY2, 100, EnrtyH, getText("IGUI_S4_ShopAdmin_Single_Set"), self, S4_ItemSettingBox.BtnClick)
    self.HotItemBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.HotItemBtn.internal = "HotItem"
    self.HotItemBtn.tooltip = getText("IGUI_S4_ShopAdmin_Single_Set_Tooltip")
    self.HotItemBtn:initialise()
    self:addChild(self.HotItemBtn)
    EntryY2 = EntryY2 + EnrtyH +10

    local BtnW = ((EntryW + 100 + 20) / 2) - 10
    self.AllSetBtn = ISButton:new(EntryX2, EntryY2, BtnW, EnrtyH, getText("IGUI_S4_ShopAdmin_All_Set"), self, S4_ItemSettingBox.BtnClick)
    self.AllSetBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.AllSetBtn.internal = "AllSet"
    self.AllSetBtn.tooltip = getText("IGUI_S4_ShopAdmin_All_Set_Tooltip")
    self.AllSetBtn:initialise()
    self:addChild(self.AllSetBtn)

    self.AllResetBtn = ISButton:new(EntryX2 + BtnW + 10 , EntryY2, BtnW, EnrtyH, getText("IGUI_S4_ShopAdmin_All_Reset"), self, S4_ItemSettingBox.BtnClick)
    self.AllResetBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.AllResetBtn.internal = "AllReset"
    self.AllResetBtn.tooltip = getText("IGUI_S4_ShopAdmin_All_Reset_Tooltip")
    self.AllResetBtn:initialise()
    self:addChild(self.AllResetBtn)
    EntryY2 = EntryY2 + EnrtyH +10

    self:DataUpdate()
    -- setTooltip(text)
end

function S4_ItemSettingBox:DataUpdate()
    if not self.ItemData then self:close() end
    local Category = S4_Category.Category
    for _, Data in pairs(Category) do
        self.CategoryBox:addOptionWithData(getText("IGUI_S4_ItemCat_"..Data.Category), Data.Category)
    end
    if self.ItemData.DataCheck then
        self.BuyPriceEntry:setText(""..self.ItemData.BuyPrice)
        self.SellPriceEntry:setText(""..self.ItemData.SellPrice)
        self.StockEntry:setText(""..self.ItemData.Stock)
        self.RestockEntry:setText(""..self.ItemData.Restock)
        self.DiscountEntry:setText(""..self.ItemData.Discount)
        self.CategoryBox:selectData(self.ItemData.Category)
        self.BuyAuthorityBox:selectData(self.ItemData.BuyAuthority)
        self.SellAuthorityBox:selectData(self.ItemData.SellAuthority)
        self.HotItemBox:selectData(self.ItemData.HotItem)
    end
    if self.ItemData.FullType and self.ItemData.DisplayName and self.ItemData.ListCategory then
        -- ItemNameLabel/CategoryLabel/StateLabel
        local MaxString = self:getWidth() - S4_UI.FH_L + (S4_UI.FH_M * 2) - 30
        local FixItemName = S4_UI.TextLimitOne(self.ItemData.DisplayName, MaxString, UIFont.Large)
        local MixItemInfo = string.format(getText("IGUI_S4_ShopAdmin_ItemInfo"), self.ItemData.FullType, self.ItemData.ListCategory)
        local FixItemInfo = S4_UI.TextLimitOne(MixItemInfo, MaxString - 5, UIFont.Medium)
        self.ItemNameLabel:setName(FixItemName)
        self.CategoryLabel:setName(FixItemInfo)

        if self.ItemData.DataCheck then
            self.StateLabel:setName(getText("IGUI_S4_ShopAdmin_ShopReg"))
        else
            self.StateLabel:setName(getText("IGUI_S4_ShopAdmin_NotShopReg"))
        end
    end
end

function S4_ItemSettingBox:BtnClick(Button)
    local internal = Button.internal
    if internal == "close" then
        self:close()
    elseif internal == "AllSet" then
        self:SetAllData()
        self:close()
    elseif internal == "AllReset" then
        sendClientCommand("S4SD", "RemoveShopData", {self.ItemData.FullType})
        self.ItemData.DataCheck = false
        self:close()
    else
        local Value = false
        if internal == "BuyPrice" then
            Value = self.BuyPriceEntry:getText()
        elseif internal == "SellPrice" then
            Value = self.SellPriceEntry:getText()
        elseif internal == "Stock" then
            Value = self.StockEntry:getText()
        elseif internal == "Restock" then
            Value = self.RestockEntry:getText()
        elseif internal == "Discount" then
            Value = self.DiscountEntry:getText()
        elseif internal == "BuyAuthority" then
            Value = self.BuyAuthorityBox:getOptionData(self.BuyAuthorityBox.selected)
        elseif internal == "SellAuthority" then
            Value = self.SellAuthorityBox:getOptionData(self.SellAuthorityBox.selected)
        elseif internal == "Category" then
            Value = self.CategoryBox:getOptionData(self.CategoryBox.selected)
        elseif internal == "HotItem" then
            Value = self.HotItemBox:getOptionData(self.HotItemBox.selected)
        end
        if type(Value) == "string" and self[internal.."Entry"]then
            local filteredText = Value:gsub("[^%d]", "")
            filteredText = filteredText:gsub("^0+", "")
            if filteredText == "" then filteredText = "0" end
            self[internal.."Entry"]:setText(filteredText)

            Value = tonumber(filteredText)
        end
        if self.ItemData.DataCheck then
            if self.ItemData.FullType then
                local updatedData = {
                    ItemName = self.ItemData.FullType,
                }
                -- print("Value: "..tostring(Value))
                updatedData[internal] = Value
                sendClientCommand("S4SD", "UpdateShopData", updatedData)
                self.ItemData[internal] = Value
            end
        else
            self:SetNoData(internal, Value)
        end
    end
end

function S4_ItemSettingBox:SetAllData()
    local function FixText(Value)
        local filteredText = Value:gsub("[^%d]", "")
        filteredText = filteredText:gsub("^0+", "")
        if filteredText == "" then filteredText = "0" end
        local ReturnValue = tonumber(filteredText)
        return ReturnValue
    end
    local Setting = {
        ItemName = self.ItemData.FullType,
        BuyPrice = FixText(self.BuyPriceEntry:getText()),
        SellPrice = FixText(self.SellPriceEntry:getText()),
        Stock = FixText(self.StockEntry:getText()),
        Restock = FixText(self.RestockEntry:getText()),
        Discount = FixText(self.DiscountEntry:getText()),
        BuyAuthority = self.BuyAuthorityBox:getOptionData(self.BuyAuthorityBox.selected),
        SellAuthority = self.SellAuthorityBox:getOptionData(self.SellAuthorityBox.selected),
        Category = self.CategoryBox:getOptionData(self.CategoryBox.selected),
        HotItem = self.HotItemBox:getOptionData(self.HotItemBox.selected),
    }
    
    self.BuyPriceEntry:setText(tostring(Setting.BuyPrice))
    self.SellPriceEntry:setText(tostring(Setting.SellPrice))
    self.StockEntry:setText(tostring(Setting.Stock))
    self.RestockEntry:setText(tostring(Setting.Restock))
    self.DiscountEntry:setText(tostring(Setting.Discount))
    sendClientCommand("S4SD", "UpdateShopData", Setting)

    self.ItemData.DataCheck = true
    self.ItemData.BuyPrice = Setting.BuyPrice
    self.ItemData.SellPrice = Setting.SellPrice
    self.ItemData.Stock = Setting.Stock
    self.ItemData.Restock = Setting.Restock
    self.ItemData.Category = Setting.Category
    self.ItemData.BuyAuthority = Setting.BuyAuthority
    self.ItemData.SellAuthority = Setting.SellAuthority
    self.ItemData.Discount = Setting.Discount
    self.ItemData.HotItem = Setting.HotItem
end

function S4_ItemSettingBox:ReseteData()
    -- sendClientCommand("S4SD", "ResetShopData", {nil})
end

function S4_ItemSettingBox:SetNoData(DataType, Value)
    if not self.ItemData.FullType then return end
    local updatedData = {
        ItemName = self.ItemData.FullType,
        BuyPrice = 0,
        SellPrice = 0,
        Stock = 0,
        Restock = 0,
        Category = "Etc",
        BuyAuthority = 0,
        SellAuthority = 0,
        Discount = 0,
        HotItem = 0,
    }
    local Check = false
    -- Check if the entered item is valid and update the value
    if updatedData[DataType] ~= nil then
        updatedData[DataType] = Value  -- set the value
        Check = true
    end
    if Check then
        sendClientCommand("S4SD", "UpdateShopData", updatedData)
        self.ItemData.DataCheck = true
        self.ItemData.BuyPrice = updatedData.BuyPrice
        self.ItemData.SellPrice = updatedData.SellPrice
        self.ItemData.Stock = updatedData.Stock
        self.ItemData.Restock = updatedData.Restock
        self.ItemData.Category = updatedData.Category
        self.ItemData.BuyAuthority = updatedData.BuyAuthority
        self.ItemData.SellAuthority = updatedData.SellAuthority
        self.ItemData.Discount = updatedData.Discount
        self.ItemData.HotItem = updatedData.HotItem
        self.ParentsUI:OpenSettingBox(self.ItemData)
    end
    -- Changed data output
    -- print("Updated item data:")
    -- for k, v in pairs(updatedData) do
    --     print(k .. ": " .. tostring(v))
    -- end
end
function S4_ItemSettingBox:EntryRender()
    if self.EntryNameTag and not self.javaObject:isFocused() then
        self:drawText(self.EntryNameTag, self:getWidth() / 2, 2, 1, 1, 1, 0.5, UIFont.Medium)
    end
end

function S4_ItemSettingBox:ComboBoxRender()
    ISComboBox.render(self)
    if self.EntryNameTag and not self.expanded then
        self:drawText(self.EntryNameTag, self:getWidth() / 2, 2, 1, 1, 1, 0.5, UIFont.Medium)
    end
    if self:isMouseOver() and self.tooltip then
        local text = self.tooltip;
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
        end
        if not self.tooltipUI:getIsVisible() then
            if string.contains(self.tooltip, "\n") then
                self.tooltipUI.maxLineWidth = 1000
            else
                self.tooltipUI.maxLineWidth = 300
            end
            self.tooltipUI:addToUIManager()
            self.tooltipUI:setVisible(true)
            self.tooltipUI:setAlwaysOnTop(true)
        end
        self.tooltipUI.description = text
        self.tooltipUI:setX(self:getMouseX() + 23)
        self.tooltipUI:setY(self:getMouseY() + 23)
    else
        if self.tooltipUI and self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(false)
            self.tooltipUI:removeFromUIManager()
        end
    end
end

function S4_ItemSettingBox:close()
    self.ParentsUI.SettingBox = nil
    self.ParentsUI.ListBox:setItemBtn()
    self.ParentsUI.ListBox:setVisible(true)
    self:setVisible(false)
    self:removeFromUIManager()
end