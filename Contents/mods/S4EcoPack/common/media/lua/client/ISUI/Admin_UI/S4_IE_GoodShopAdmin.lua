S4_IE_GoodShopAdmin = ISPanel:derive("S4_IE_GoodShopAdmin")

function S4_IE_GoodShopAdmin:new(IEUI, x, y)
    local width = IEUI.ComUI:getWidth() - 12
    local TaskH = IEUI.ComUI:getHeight() - IEUI.ComUI.TaskBarY
    local height = IEUI.ComUI:getHeight() - ((S4_UI.FH_S * 2) + 23 + TaskH)

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI -- Store parent UI reference
    o.ComUI = IEUI.ComUI -- Computer UI
    o.player = IEUI.player
    o.Moving = true
    return o
end

function S4_IE_GoodShopAdmin:initialise()
    ISPanel.initialise(self)

    local W, H, Count = S4_UI.getGoodShopSizeZ(self.ComUI)
    self.IEUI:FixUISize(W, H)
    self.MenuType = "Setup"
    self.ListCount = Count

    self.FilterItem = false
    self.AllItems = {}
    self.AllCategory = {}
    local ShopModData = ModData.get("S4_ShopData") or {}
    local AllItemList = getAllItems()
    for i=0, AllItemList:size()-1 do
        local item = AllItemList:get(i)
        if item and item:getFullName() and item:getTypeString() then
            local Data = {}
            local ListCategory = item:getDisplayCategory()
            if not ListCategory or ListCategory == "" then
                ListCategory = item:getTypeString() or "Etc"
            end

            Data.ListCategory = ListCategory
            Data.FullType = item:getFullName()
            Data.DisplayName = item:getDisplayName() or Data.FullType

            local iconTexture = nil
            if item.getNormalTexture then
                local okTexture, normalTexture = pcall(function() return item:getNormalTexture() end)
                if okTexture and normalTexture then
                    iconTexture = normalTexture
                end
            end
            if not iconTexture and item.getIcon then
                local okIcon, iconName = pcall(function() return item:getIcon() end)
                if okIcon and iconName and iconName ~= "" then
                    iconTexture = getTexture(iconName) or getTexture("Item_" .. iconName)
                end
            end
            Data.Texture = iconTexture or false
            Data.itemData = false

            if ShopModData[Data.FullType] then
                Data.DataCheck = true
                Data.BuyPrice = ShopModData[Data.FullType].BuyPrice
                Data.SellPrice = ShopModData[Data.FullType].SellPrice
                Data.Stock = ShopModData[Data.FullType].Stock
                Data.Restock = ShopModData[Data.FullType].Restock
                Data.Category = ShopModData[Data.FullType].Category
                Data.BuyAuthority = ShopModData[Data.FullType].BuyAuthority
                Data.SellAuthority = ShopModData[Data.FullType].SellAuthority
                Data.Discount = ShopModData[Data.FullType].Discount
                Data.HotItem = ShopModData[Data.FullType].HotItem
            else
                Data.DataCheck = false
            end

            local isFilterItem = (Data.FullType == "Base.Bandage_Abdomen")
            if not isFilterItem then
                table.insert(self.AllItems, Data)
                if not self.AllCategory[ListCategory] then
                    self.AllCategory[ListCategory] = ListCategory
                end
            end
        end
    end

    table.sort(self.AllItems, function(a, b)
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    table.sort(self.AllCategory, function(a, b)
        return a:lower() < b:lower()
    end)

    local serverData = ModData.get("S4_ServerData") or {}
    local lastModified = serverData.ShopDataLastModified
    if lastModified and self.ComUI and self.ComUI.AddMsgBox then
        local msgTitle = "Good Shop Admin"
        local text1 = "Shop data last modified:"
        local text2 = tostring(lastModified)
        self.ComUI:AddMsgBox(msgTitle, nil, text1, text2)
    end
end

function S4_IE_GoodShopAdmin:createChildren()
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

    self.CategoryPanel = ISPanel:new(InfoX, CategoryY, CategoryW, CategoryH)
    self.CategoryPanel.backgroundColor.a = 0
    self.CategoryPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
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
    self.CategoryBox.vscroll:setVisible(false)
    self.CategoryBox.doDrawItem = S4_IE_GoodShopAdmin.doDrawItem_CategoryBox
    -- self.CategoryBox.onMouseMove = S4_IE_GoodShopAdmin.onMouseMove_CategoryBox
    self.CategoryBox.onMouseDown = S4_IE_GoodShopAdmin.onMouseDown_CategoryBox
    self:addChild(self.CategoryBox)
    self:AddCategory()

    local BoxX = 20 + CategoryW
    local BoxW = (self:getWidth() - 20) - BoxX + 10

    self.ListBox = S4_ItemListBox:new(self, BoxX, CategoryY, BoxW, CategoryH)
    self.ListBox.backgroundColor.a = 0
    self.ListBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.ListBox.ListCount = self.ListCount
    self.ListBox.AdminAccess = true
    self:addChild(self.ListBox)

    self.InfoPanel = ISPanel:new(BoxX, InfoY, BoxW, InfoH)
    self.InfoPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.InfoPanel.borderColor.abs = 0
    self:addChild(self.InfoPanel)

    local BtnX = BoxX + 10
    local BtnW = 150
    self.AllResetBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "All Reset", self, S4_IE_GoodShopAdmin.BtnClick)
    self.AllResetBtn.internal = "AllReset"
    self.AllResetBtn.font = UIFont.Large
    self.AllResetBtn.backgroundColor.a = 0
    self.AllResetBtn.borderColor.a = 0
    self.AllResetBtn.textColor.a = 0.9
    self.AllResetBtn.tooltip = getText("IGUI_S4_ShopAdminMsgBox_AllReset_Tooltip")
    self.AllResetBtn:initialise()
    self:addChild(self.AllResetBtn)
    BtnX = BtnX + BtnW + 10

    self.UpdataBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Update Data", self, S4_IE_GoodShopAdmin.BtnClick)
    self.UpdataBtn.internal = "UpdateData"
    self.UpdataBtn.font = UIFont.Large
    self.UpdataBtn.backgroundColor.a = 0
    self.UpdataBtn.borderColor.a = 0
    self.UpdataBtn.textColor.a = 0.9
    self.UpdataBtn.tooltip = getText("IGUI_S4_ShopAdminMsgBox_UpdateData_Tooltip")
    self.UpdataBtn:initialise()
    self:addChild(self.UpdataBtn)
    BtnX = BtnX + BtnW + 10

    self.AddDataBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Add Data", self, S4_IE_GoodShopAdmin.BtnClick)
    self.AddDataBtn.internal = "AddData"
    self.AddDataBtn.font = UIFont.Large
    self.AddDataBtn.backgroundColor.a = 0
    self.AddDataBtn.borderColor.a = 0
    self.AddDataBtn.textColor.a = 0.9
    self.AddDataBtn.tooltip = getText("IGUI_S4_ShopAdminMsgBox_AddData_Tooltip")
    self.AddDataBtn:initialise()
    self:addChild(self.AddDataBtn)
    BtnX = BtnX + BtnW + 10

    self.ExportBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Export Data", self, S4_IE_GoodShopAdmin.BtnClick)
    self.ExportBtn.internal = "ExportShopData"
    self.ExportBtn.font = UIFont.Large
    self.ExportBtn.backgroundColor.a = 0
    self.ExportBtn.borderColor.a = 0
    self.ExportBtn.textColor.a = 0.9
    self.ExportBtn.tooltip = getText("IGUI_S4_ShopAdminMsgBox_ExportData_Tooltip")
    self.ExportBtn:initialise()
    self:addChild(self.ExportBtn)
    BtnX = BtnX + BtnW + 10
end

function S4_IE_GoodShopAdmin:render()
    ISPanel.render(self)
    -- if self.MenuType then
    --     local x, y, w, h = self[self.MenuType.."Btn"]:getX(), self[self.MenuType.."Btn"]:getY() + 1, self[self.MenuType.."Btn"]:getWidth(), self[self.MenuType.."Btn"]:getHeight() - 2
    --     self:drawRect(x, y, w, h, 0.2, 1, 1, 1)
    -- end
end

function S4_IE_GoodShopAdmin:AddCategory()
    self.CategoryBox:clear()
    -- self.CategoryBox:addItem("PopularProducts", "PopularProducts")
    self.CategoryBox:addItem("Reg", "Reg")
    self.CategoryBox:addItem("All", "All")
    for Category, CategoryName in pairs(self.AllCategory) do
        self.CategoryBox:addItem(CategoryName, CategoryName)
    end
end

function S4_IE_GoodShopAdmin:AddItems()
    self.ListBox:clear()
    for _, Data in pairs(self.AllItems) do
        local Category = Data.ListCategory
        -- if self.FilterItem:getTex() ~= Data.Texture then
            if self.CategoryBox.CategoryType == Category then
                self.ListBox:AddItem(Data)
            elseif self.CategoryBox.CategoryType == "All" then
                self.ListBox:AddItem(Data)
            elseif self.CategoryBox.CategoryType == "Reg" then
                if Data.DataCheck then
                    self.ListBox:AddItem(Data)
                end
            elseif self.CategoryBox.CategoryType == "Search" then
                if not self.ListBox or not self.ListBox.SearchEntry then return end
                if Data.FullType and Data.DisplayName then
                    local ST = self.ListBox.SearchEntry:getText()
                    if ST ~= "" then
                        ST = string.lower(ST):gsub("%s+", "")
                        local SD = string.lower(Data.DisplayName):gsub("%s+", "")
                        local SF = string.lower(Data.FullType):gsub("%s+", "")
                        if SD:find(ST) or SF:find(ST) then
                            self.ListBox:AddItem(Data)
                        end
                    end
                end
            end
        -- end
    end
end

function S4_IE_GoodShopAdmin:ReloadData()
    local ShopModData = ModData.get("S4_ShopData") or {}
    for _, Data in pairs(self.AllItems) do
        local ShopData = ShopModData[Data.FullType]
        if ShopData then
            Data.DataCheck = true
            Data.BuyPrice = ShopData.BuyPrice
            Data.SellPrice = ShopData.SellPrice
            Data.Stock = ShopData.Stock
            Data.Restock = ShopData.Restock
            Data.Category = ShopData.Category
            Data.BuyAuthority = ShopData.BuyAuthority
            Data.SellAuthority = ShopData.SellAuthority
            Data.Discount = ShopData.Discount
            Data.HotItem = ShopData.HotItem
        else
            Data.DataCheck = false
            Data.BuyPrice = 0
            Data.SellPrice = 0
            Data.Stock = 0
            Data.Restock = 0
            Data.Category = Data.ListCategory or "Etc"
            Data.BuyAuthority = 0
            Data.SellAuthority = 0
            Data.Discount = 0
            Data.HotItem = 0
        end
    end
    self:AddItems()
end

function S4_IE_GoodShopAdmin:BtnClick(Button)
    local internal = Button.internal
    -- if not internal or self.SettingBox then return end
    if not internal then return end
    local MsgTitle = getText("IGUI_S4_ShopAdminMsgBox")
    if internal == "AllReset" then
        local Text1 = getText("IGUI_S4_ShopAdminMsgBox_AllReset1")
        local Text2 = getText("IGUI_S4_ShopAdminMsgBox_AllReset2")
        local Text3 = getText("IGUI_S4_ShopAdminMsgBox_AllReset3")
        self.ComUI:AddAdminMsgBox(internal, MsgTitle, false, Text1, Text2, Text3)
    elseif internal == "UpdateData" then
        local Text1 = getText("IGUI_S4_ShopAdminMsgBox_UpdateData1")
        local Text2 = getText("IGUI_S4_ShopAdminMsgBox_UpdateData2")
        local Text3 = getText("IGUI_S4_ShopAdminMsgBox_UpdateData3")
        self.ComUI:AddAdminMsgBox(internal, MsgTitle, false, Text1, Text2, Text3)
    elseif internal == "AddData" then
        local Text1 = getText("IGUI_S4_ShopAdminMsgBox_AddData1")
        local Text2 = getText("IGUI_S4_ShopAdminMsgBox_AddData2")
        local Text3 = getText("IGUI_S4_ShopAdminMsgBox_AddData3")
        self.ComUI:AddAdminMsgBox(internal, MsgTitle, false, Text1, Text2, Text3)
    elseif internal == "ExportShopData" then
        local Text1 = getText("IGUI_S4_ShopAdminMsgBox_ExportData1")
        local Text2 = getText("IGUI_S4_ShopAdminMsgBox_ExportData2")
        local Text3 = getText("IGUI_S4_ShopAdminMsgBox_ExportData3")
        self.ComUI:AddAdminMsgBox(internal, MsgTitle, false, Text1, Text2, Text3)
    end
end

function S4_IE_GoodShopAdmin:doDrawItem_CategoryBox(y, item, alt)
    local yOffset = 2
    local Cw = self:getWidth() - 2
    local Ch = (yOffset * 2) + S4_UI.FH_M

    local BorderW = Cw - (Cw / 4)
    local BorderX = ((Cw / 4) / 2) + 1

    if self.selectedRow == item.index then
        self:drawRect(1, y, Cw, Ch, 0.2, 1, 1, 1)
    end
    self:drawRectBorder(BorderX, y + Ch, BorderW, 1, 0.4, 1, 1, 1)

    local CNameT = getText("IGUI_ItemCat_"..item.item)
    local CNameFT = S4_UI.TextLimitOne(CNameT, Cw - 8, UIFont.Medium)
    local CNameW = getTextManager():MeasureStringX(UIFont.Medium, CNameFT)
    local CNamex = (Cw / 2) - (CNameW / 2)
    self:drawText(CNameFT, CNamex, y + yOffset, 0.9, 0.9, 0.9, 1, UIFont.Medium)
    return y + Ch
end

function S4_IE_GoodShopAdmin:onMouseDown_CategoryBox(x, y)
    local ShopUI = self.parentUI
    if ShopUI.SettingBox then return end
    ISScrollingListBox.onMouseDown(self, x, y)
    local list = self
    local rowIndex = list:rowAt(x, y)
    if rowIndex > 0 then
        list.selectedRow = rowIndex 
        list.CategoryType = self.items[rowIndex].item
        ShopUI:AddItems()
    end
end

function S4_IE_GoodShopAdmin:OpenSettingBox(Data)
    if self.SettingBox then self.SettingBox:close() end
    if Data then
        local x, y, w, h = self.ListBox:getX(), self.ListBox:getY(), self.ListBox:getWidth(), self.ListBox:getHeight()
        self.SettingBox = S4_ItemSettingBox:new(self, x, y, w, h)
        self.SettingBox.backgroundColor.a = 0
        self.SettingBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
        self.SettingBox.ItemData = Data
        self.SettingBox:initialise()
        self:addChild(self.SettingBox)
        self.ListBox:setVisible(false)
    end
end

-- UI move/close related functions
function S4_IE_GoodShopAdmin:onMouseDown(x, y)
    if not self.Moving then return end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_GoodShopAdmin:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.IEUI.moving = false
end

function S4_IE_GoodShopAdmin:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
