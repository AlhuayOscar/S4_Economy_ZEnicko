S4_IE_VehicleShop = ISPanel:derive("S4_IE_VehicleShop")
require('Vehicles/ISUI/ISUI3DScene')

local function safeCall(obj, fnName)
    if not obj or not fnName or not obj[fnName] then
        return nil
    end
    local ok, value = pcall(function()
        return obj[fnName](obj)
    end)
    if ok then
        return value
    end
    return nil
end

local function getNowMs()
    if getTimestampMs then
        local ok, ms = pcall(getTimestampMs)
        if ok and ms then
            return ms
        end
    end
    if getGameTime and getGameTime() and getGameTime().getWorldAgeHours then
        local ok, h = pcall(function()
            return getGameTime():getWorldAgeHours()
        end)
        if ok and h then
            return math.floor(h * 3600000)
        end
    end
    return 0
end

local function buildVehicleDisplayRow(vehicleScript)
    if not vehicleScript then
        return nil
    end
    local fullName = safeCall(vehicleScript, "getFullName")
    local name = safeCall(vehicleScript, "getName")
    local scriptId = fullName or name or "UnknownVehicle"
    local moduleName = "Unknown"
    if type(scriptId) == "string" then
        local dotPos = string.find(scriptId, "%.")
        if dotPos then
            moduleName = string.sub(scriptId, 1, dotPos - 1)
        end
    end
    return {
        text = tostring(scriptId),
        item = {
            id = tostring(scriptId),
            name = tostring(name or scriptId),
            module = moduleName,
            source = (moduleName == "Base") and "Vanilla" or "Mod"
        }
    }
end

local function getAllVehicleScriptsRows()
    if not getScriptManager then
        return {}
    end
    local okSm, sm = pcall(getScriptManager)
    if not okSm or not sm then
        return {}
    end
    if not sm.getAllVehicleScripts then
        return {}
    end
    local okList, vehicleScripts = pcall(function()
        return sm:getAllVehicleScripts()
    end)
    if not okList or not vehicleScripts or not vehicleScripts.size then
        return {}
    end
    local rows = {}
    for i = 0, vehicleScripts:size() - 1 do
        local vs = vehicleScripts:get(i)
        local row = buildVehicleDisplayRow(vs)
        if row and row.item and row.item.id then
            rows[#rows + 1] = row
        end
    end
    table.sort(rows, function(a, b)
        return tostring(a.item.id) < tostring(b.item.id)
    end)
    return rows
end

function S4_IE_VehicleShop:new(IEUI, x, y)
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

function S4_IE_VehicleShop:initialise()
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

function S4_IE_VehicleShop:createChildren()
    ISPanel.createChildren(self)

    local InfoX = 10
    local InfoY = 10
    local InfoH = (S4_UI.FH_S * 2) + 20

    local LogoText = "Vehicle"
    local LogoTextW = getTextManager():MeasureStringX(UIFont.Medium, LogoText)
    local LogoX = 10 + ((S4_UI.FH_L * 3) + 20) - (LogoTextW / 2) - 10
    local LogoY = 20
    self.LogoLabel1 = ISLabel:new(LogoX, LogoY, S4_UI.FH_S, LogoText, 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.LogoLabel1)
    LogoX = LogoX + (LogoTextW / 2) - 10
    LogoY = LogoY + S4_UI.FH_S
    self.LogoLabel2 = ISLabel:new(LogoX, LogoY, S4_UI.FH_S, "Market", 1, 1, 1, 0.8, UIFont.Medium, true)
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
    self.CategoryBox.doDrawItem = S4_IE_VehicleShop.doDrawItem_CategoryBox
    -- self.CategoryBox.onMouseMove = S4_IE_VehicleShop.onMouseMove_CategoryBox
    self.CategoryBox.onMouseDown = S4_IE_VehicleShop.onMouseDown_CategoryBox
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
    self.ListBox:setVisible(false)

    self.CenterEmptyPanel = ISPanel:new(BoxX, CategoryY, BoxW, CategoryH)
    self.CenterEmptyPanel.backgroundColor.a = 0
    self.CenterEmptyPanel.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self:addChild(self.CenterEmptyPanel)

    local headerText = "Installed vehicles (Vanilla + Mods)"
    self.CenterEmptyLabel = ISLabel:new(BoxX + 12, CategoryY + 8, S4_UI.FH_M, headerText, 0.9, 0.9, 0.9, 0.95,
        UIFont.Medium, true)
    self:addChild(self.CenterEmptyLabel)

    self.VehicleRefreshBtn = ISButton:new(BoxX + BoxW - 130, CategoryY + 5, 118, 24, "Refresh List", self,
        S4_IE_VehicleShop.onRefreshVehicleList)
    self.VehicleRefreshBtn.internal = "VehicleRefresh"
    self.VehicleRefreshBtn:initialise()
    self:addChild(self.VehicleRefreshBtn)

    self.VehicleCountLabel = ISLabel:new(BoxX + 12, CategoryY + 34, S4_UI.FH_S, "Total: 0", 0.75, 0.9, 0.75, 0.9,
        UIFont.Small, true)
    self:addChild(self.VehicleCountLabel)

    self.VehicleListBox = ISScrollingListBox:new(BoxX + 8, CategoryY + 52, BoxW - 16, CategoryH - 60)
    self.VehicleListBox:initialise()
    self.VehicleListBox:instantiate()
    self.VehicleListBox.drawBorder = true
    self.VehicleListBox.borderColor.a = 1
    self.VehicleListBox.backgroundColor.a = 0.15
    self.VehicleListBox.parentUI = self
    self.VehicleListBox.itemheight = math.max(20, S4_UI.FH_M + 6)
    self.VehicleListBox.doDrawItem = S4_IE_VehicleShop.doDrawItem_VehicleList
    self.VehicleListBox.onMouseDown = S4_IE_VehicleShop.onMouseDown_VehicleList
    self:addChild(self.VehicleListBox)

    self:reloadVehicleList()

    self.VehicleHomePanel = ISPanel:new(BoxX, CategoryY, BoxW, CategoryH)
    self.VehicleHomePanel.backgroundColor.a = 0
    self.VehicleHomePanel.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    self:addChild(self.VehicleHomePanel)

    local hy = 14
    local homeLines = {
        "Vehicle Shop Service",
        "Use Buy/Sell to browse all installed vehicles (Vanilla + Mods).",
        "Select a model, then use your Vehicles Flare drop point for delivery.",
        "Pricing rules:",
        "- Base minimum price starts at $450,000.",
        "- Markup can increase from +40% up to +430%.",
        "- Random discounts are lower: only -10% to -25%."
    }
    for i = 1, #homeLines do
        local font = (i == 1) and UIFont.Medium or UIFont.Small
        local color = (i == 1) and {0.95, 0.95, 0.95, 1} or {0.82, 0.82, 0.82, 0.95}
        local lbl = ISLabel:new(14, hy, S4_UI.FH_M, homeLines[i], color[1], color[2], color[3], color[4], font, true)
        self.VehicleHomePanel:addChild(lbl)
        hy = hy + ((i == 1) and (S4_UI.FH_M + 8) or (S4_UI.FH_S + 8))
    end

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
    self.HomeBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Home", self, S4_IE_VehicleShop.BtnClick)
    self.HomeBtn.internal = "Home"
    self.HomeBtn.font = UIFont.Large
    self.HomeBtn.backgroundColor.a = 0
    self.HomeBtn.borderColor.a = 0
    self.HomeBtn.textColor.a = 0.9
    self.HomeBtn:initialise()
    self:addChild(self.HomeBtn)
    BtnX = BtnX + BtnW + 10

    self.BuyBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Buy", self, S4_IE_VehicleShop.BtnClick)
    self.BuyBtn.internal = "Buy"
    self.BuyBtn.font = UIFont.Large
    self.BuyBtn.backgroundColor.a = 0
    self.BuyBtn.borderColor.a = 0
    self.BuyBtn.textColor.a = 0.9
    self.BuyBtn:initialise()
    self:addChild(self.BuyBtn)
    BtnX = BtnX + BtnW + 10

    self.SellBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Sell", self, S4_IE_VehicleShop.BtnClick)
    self.SellBtn.internal = "Sell"
    self.SellBtn.font = UIFont.Large
    self.SellBtn.backgroundColor.a = 0
    self.SellBtn.borderColor.a = 0
    self.SellBtn.textColor.a = 0.9
    self.SellBtn:initialise()
    self:addChild(self.SellBtn)
    BtnX = BtnX + BtnW + 10

    self.CartBtn = ISButton:new(BtnX, InfoY, BtnW, InfoH, "Cart", self, S4_IE_VehicleShop.BtnClick)
    self.CartBtn.internal = "Cart"
    self.CartBtn.font = UIFont.Large
    self.CartBtn.backgroundColor.a = 0
    self.CartBtn.borderColor.a = 0
    self.CartBtn.textColor.a = 0.9
    self.CartBtn:initialise()
    self:addChild(self.CartBtn)

    self:ShopBoxVisible(false)
    self.HomePanel:setVisible(false)
    if self.VehicleHomePanel then
        self.VehicleHomePanel:setVisible(true)
    end
end

function S4_IE_VehicleShop:render()
    ISPanel.render(self)

    if self.MenuType then
        local targetBtn = self[self.MenuType .. "Btn"]
        if targetBtn then
            local x, y, w, h = targetBtn:getX(), targetBtn:getY() + 1,
                targetBtn:getWidth(), targetBtn:getHeight() - 2
            self:drawRect(x, y, w, h, 0.2, 1, 1, 1)
        end
    end

    if self.VehiclePreviewScene and self.VehiclePreviewAutoSequence and #self.VehiclePreviewAutoSequence > 0 then
        local now = getNowMs()
        local lastInput = self.VehiclePreviewLastInputMs or 0
        local nextSwitch = self.VehiclePreviewNextSwitchMs or 0
        local canAuto = (now > 0) and ((now - lastInput) >= 1800)
        if canAuto and now >= nextSwitch then
            local idx = self.VehiclePreviewAutoIndex or 1
            local viewName = self.VehiclePreviewAutoSequence[idx]
            if viewName then
                pcall(function()
                    self.VehiclePreviewScene:setView(viewName)
                end)
                idx = idx + 1
                if idx > #self.VehiclePreviewAutoSequence then
                    idx = 1
                end
                self.VehiclePreviewAutoIndex = idx
                self.VehiclePreviewNextSwitchMs = now + 1900
            end
        end
    end
end

function S4_IE_VehicleShop:onRefreshVehicleList()
    self:reloadVehicleList()
end

function S4_IE_VehicleShop:reloadVehicleList()
    if not self.VehicleListBox then
        return
    end
    self.VehicleListBox:clear()
    local rows = getAllVehicleScriptsRows()
    for i = 1, #rows do
        self.VehicleListBox:addItem(rows[i].text, rows[i].item)
    end
    if self.VehicleCountLabel then
        self.VehicleCountLabel:setName("Total: " .. tostring(#rows))
    end
end

function S4_IE_VehicleShop:doDrawItem_VehicleList(y, item, alt)
    local h = self.itemheight or 20
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), h, 0.25, 0.3, 0.55, 0.8)
    end
    local data = item.item or {}
    local sourceColor = {r = 0.8, g = 0.8, b = 0.8}
    if data.source == "Mod" then
        sourceColor = {r = 0.65, g = 0.9, b = 1}
    end
    self:drawText(tostring(data.name or item.text or "Vehicle"), 8, y + 2, 0.95, 0.95, 0.95, 1, UIFont.Small)
    self:drawText(tostring(data.id or "Unknown"), 8, y + 11, 0.7, 0.7, 0.7, 1, UIFont.Small)
    self:drawTextRight(tostring(data.source or "Unknown"), self:getWidth() - 8, y + 6, sourceColor.r, sourceColor.g,
        sourceColor.b, 1, UIFont.Small)
    return y + h
end

function S4_IE_VehicleShop:onMouseDown_VehicleList(x, y)
    ISScrollingListBox.onMouseDown(self, x, y)
    local parentUI = self.parentUI
    if not parentUI then
        return true
    end
    if parentUI.MenuType ~= "Buy" and parentUI.MenuType ~= "Sell" then
        return true
    end
    local row = self:rowAt(x, y)
    if row and row > 0 and self.items and self.items[row] then
        local data = self.items[row].item
        if data and data.id then
            parentUI:openVehiclePreview(data.id, data.name or data.id)
        end
    end
    return true
end

function S4_IE_VehicleShop:closeVehiclePreview()
    if self.VehiclePreviewOverlay then
        self:removeChild(self.VehiclePreviewOverlay)
        self.VehiclePreviewOverlay = nil
    end
    self.VehiclePreviewPanel = nil
    self.VehiclePreviewScene = nil
    self.VehiclePreviewAutoSequence = nil
    self.VehiclePreviewAutoIndex = nil
    self.VehiclePreviewLastInputMs = nil
    self.VehiclePreviewNextSwitchMs = nil
end

function S4_IE_VehicleShop:openVehiclePreview(scriptName, displayName)
    if not scriptName then
        return
    end
    self:closeVehiclePreview()

    local overlay = ISPanel:new(0, 0, self:getWidth(), self:getHeight())
    overlay.backgroundColor = {r = 0, g = 0, b = 0, a = 0.45}
    overlay.borderColor = {r = 0, g = 0, b = 0, a = 0}
    overlay:initialise()
    self:addChild(overlay)
    self.VehiclePreviewOverlay = overlay

    local pw = math.floor(self:getWidth() * 0.58)
    local ph = math.floor(self:getHeight() * 0.68)
    local px = math.floor((self:getWidth() - pw) / 2)
    local py = math.floor((self:getHeight() - ph) / 2)

    local panel = ISPanel:new(px, py, pw, ph)
    panel.backgroundColor = {r = 0.08, g = 0.08, b = 0.08, a = 0.96}
    panel.borderColor = {r = 0.55, g = 0.55, b = 0.55, a = 1}
    panel:initialise()
    overlay:addChild(panel)
    self.VehiclePreviewPanel = panel

    local title = ISLabel:new(12, 8, S4_UI.FH_M, "Preview: " .. tostring(displayName or scriptName), 0.95, 0.95, 0.95,
        1, UIFont.Medium, true)
    panel:addChild(title)

    local closeBtn = ISButton:new(pw - 40, 6, 30, 24, "X", self, S4_IE_VehicleShop.closeVehiclePreview)
    closeBtn:initialise()
    panel:addChild(closeBtn)

    local scene = ISUI3DScene:new(12, 34, pw - 24, ph - 46)
    scene:initialise()
    scene:instantiate()
    scene.backgroundColor = {r = 1, g = 1, b = 1, a = 1}
    panel:addChild(scene)
    self.VehiclePreviewScene = scene
    self.VehiclePreviewZoom = 4
    self.VehiclePreviewAutoSequence = {"Top", "Right", "Front", "Left"}
    self.VehiclePreviewAutoIndex = 1
    self.VehiclePreviewLastInputMs = getNowMs()
    self.VehiclePreviewNextSwitchMs = (self.VehiclePreviewLastInputMs or 0) + 1400

    local ok = pcall(function()
        scene.javaObject:fromLua1("setDrawGrid", false)
        scene.javaObject:fromLua1("setZoom", self.VehiclePreviewZoom)
        scene:setView("Top")
        scene.javaObject:fromLua1("createVehicle", "vehicle")
        scene.javaObject:fromLua2("setVehicleScript", "vehicle", scriptName)
    end)

    if not ok then
        local errLbl = ISLabel:new(18, ph - 24, S4_UI.FH_S, "3D preview not available for this vehicle script.", 1, 0.6,
            0.6, 1, UIFont.Small, true)
        panel:addChild(errLbl)
    end

    local controls = ISPanel:new(12, ph - 40, pw - 24, 28)
    controls.backgroundColor = {r = 0, g = 0, b = 0, a = 0.25}
    controls.borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1}
    controls:initialise()
    panel:addChild(controls)

    local bx = 6
    local function addControl(label, internal, width)
        local w = width or 44
        local btn = ISButton:new(bx, 2, w, 24, label, self, S4_IE_VehicleShop.onPreviewControl)
        btn.internal = internal
        btn:initialise()
        controls:addChild(btn)
        bx = bx + w + 4
    end

    addControl("Front", "view_front", 52)
    addControl("Back", "view_back", 52)
    addControl("Left", "view_left", 48)
    addControl("Right", "view_right", 52)
    addControl("Top", "view_top", 42)
    addControl("-", "zoom_out", 28)
    addControl("+", "zoom_in", 28)
    addControl("Reset", "reset", 50)
end

function S4_IE_VehicleShop:onPreviewControl(button)
    if not button or not button.internal then
        return
    end
    local scene = self.VehiclePreviewScene
    if not scene or not scene.javaObject then
        return
    end

    local internal = button.internal
    self.VehiclePreviewLastInputMs = getNowMs()
    self.VehiclePreviewNextSwitchMs = (self.VehiclePreviewLastInputMs or 0) + 2500
    if internal == "view_front" then
        scene:setView("Front")
    elseif internal == "view_back" then
        scene:setView("Back")
    elseif internal == "view_left" then
        scene:setView("Left")
    elseif internal == "view_right" then
        scene:setView("Right")
    elseif internal == "view_top" then
        scene:setView("Top")
    elseif internal == "zoom_in" then
        self.VehiclePreviewZoom = math.min(8, (self.VehiclePreviewZoom or 4) + 0.4)
        pcall(function()
            scene.javaObject:fromLua1("setZoom", self.VehiclePreviewZoom)
        end)
    elseif internal == "zoom_out" then
        self.VehiclePreviewZoom = math.max(1.2, (self.VehiclePreviewZoom or 4) - 0.4)
        pcall(function()
            scene.javaObject:fromLua1("setZoom", self.VehiclePreviewZoom)
        end)
    elseif internal == "reset" then
        self.VehiclePreviewZoom = 4
        pcall(function()
            scene:setView("Top")
            scene.javaObject:fromLua1("setZoom", self.VehiclePreviewZoom)
        end)
    end
end

-- Item purchase/sale information window
function S4_IE_VehicleShop:OpenBuyBox(Data)
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
function S4_IE_VehicleShop:OpenSellBox(Data)
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
function S4_IE_VehicleShop:AddItems(Reload)
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

function S4_IE_VehicleShop:AddCartItem(Reload)
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

function S4_IE_VehicleShop:getDefaultCategoryType()
    if self.MenuType == "Buy" then
        return "HotItem"
    elseif self.MenuType == "Sell" then
        return "InvItem"
    end
    return false
end

function S4_IE_VehicleShop:getCategoryRow(CategoryType)
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

function S4_IE_VehicleShop:getViewState()
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

function S4_IE_VehicleShop:applyViewState(viewState)
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
function S4_IE_VehicleShop:ReloadData(ReloadType, PreserveView, hadChanges)
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

function S4_IE_VehicleShop:CheckDebt()
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
function S4_IE_VehicleShop:AddCategory()
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

function S4_IE_VehicleShop:SoftRefreshData(hadChanges)
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

function S4_IE_VehicleShop:OnShopDataUpdated(key)
    if key ~= "S4_ShopData" and key ~= "S4_PlayerShopData" then
        return
    end
    self:SoftRefreshData(true)
end

-- button click
function S4_IE_VehicleShop:BtnClick(Button)
    local internal = Button.internal
    if not internal then
        return
    end
    if self.BuyBox or self.SellBox then
        return
    end
    self:closeVehiclePreview()
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
        self.HomePanel:setVisible(false)
        if self.VehicleHomePanel then
            self.VehicleHomePanel:setVisible(true)
        end
    elseif internal == "Cart" then
        self:AddCartItem(false)
        self:ShopBoxVisible(false)
        self.CartPanel:setVisible(true)
    end
end

-- Reset Category Settings, Category Visible Settings
function S4_IE_VehicleShop:ShopBoxVisible(Value, KeepCurrentView)
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
    if self.VehicleHomePanel then
        self.VehicleHomePanel:setVisible(false)
    end
    self.CategoryPanel:setVisible(Value)
    self.CategoryLabel:setVisible(Value)
    self.CategoryBox:setVisible(Value)
    self.ListBox:setVisible(false)
    local showVehicleList = Value and (self.MenuType == "Buy" or self.MenuType == "Sell")
    if self.CenterEmptyPanel then
        self.CenterEmptyPanel:setVisible(showVehicleList)
    end
    if self.CenterEmptyLabel then
        self.CenterEmptyLabel:setVisible(showVehicleList)
    end
    if self.VehicleListBox then
        self.VehicleListBox:setVisible(showVehicleList)
    end
    if self.VehicleCountLabel then
        self.VehicleCountLabel:setVisible(showVehicleList)
    end
    if self.VehicleRefreshBtn then
        self.VehicleRefreshBtn:setVisible(showVehicleList)
    end
    if self.VehicleHomePanel then
        self.VehicleHomePanel:setVisible(self.MenuType == "Home")
    end
end

-- Category Rendering
function S4_IE_VehicleShop:doDrawItem_CategoryBox(y, item, alt)
    local yOffset = 2
    local Cw = self:getWidth() - 2
    local Ch = (yOffset * 2) + S4_UI.FH_M

    local BorderW = Cw - (Cw / 4)
    local BorderX = ((Cw / 4) / 2) + 1

    if self.selectedRow == item.index then
        self:drawRect(1, y, Cw, Ch, 0.2, 1, 1, 1)
    end
    self:drawRectBorder(BorderX, y + Ch, BorderW, 1, 0.4, 1, 1, 1)

    local CNameT = getText("IGUI_S4_ItemCat_" .. item.item)
    -- If S4 translation fails, try the standard translation key used by many mods
    if CNameT == "IGUI_S4_ItemCat_" .. item.item or CNameT == "[IGUI_S4_ItemCat_" .. item.item .. "]" then
        CNameT = getText("IGUI_ItemCat_" .. item.item)
    end

    -- Universal fallback: if the result still looks like a translation key (IGUI_...), 
    -- strip the key and use the raw category name
    if string.find(CNameT, "^IGUI_") or (string.find(CNameT, "^%[IGUI_") and string.find(CNameT, "%]$")) then
        CNameT = item.item
    end
    local CNameFT = S4_UI.TextLimitOne(CNameT, Cw - 8, UIFont.Medium)
    local CNameW = getTextManager():MeasureStringX(UIFont.Medium, CNameFT)
    local CNamex = (Cw / 2) - (CNameW / 2)
    self:drawText(CNameFT, CNamex, y + yOffset, 0.9, 0.9, 0.9, 1, UIFont.Medium)
    return y + Ch
end

-- Click on Category
function S4_IE_VehicleShop:onMouseDown_CategoryBox(x, y)
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
function S4_IE_VehicleShop:onMouseDown(x, y)
    if not self.Moving then
        return
    end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_VehicleShop:onMouseUpOutside(x, y)
    if not self.Moving then
        return
    end
    self.IEUI.moving = false
end

function S4_IE_VehicleShop:close()
    self:closeVehiclePreview()
    self:setVisible(false)
    self:removeFromUIManager()
end
