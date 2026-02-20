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

local function sceneDrag(scene, dx, dy)
    if not scene or not scene.javaObject then
        return
    end
    pcall(function()
        scene.javaObject:fromLua2("dragView", dx, dy)
    end)
end

local function getVectorComponent(v, axis)
    if not v then
        return 0
    end
    if axis == "x" then
        if v.x then
            local ok, n = pcall(function()
                return v:x()
            end)
            if ok and n then
                return n
            end
        end
        if v.getX then
            local ok, n = pcall(function()
                return v:getX()
            end)
            if ok and n then
                return n
            end
        end
    elseif axis == "y" then
        if v.y then
            local ok, n = pcall(function()
                return v:y()
            end)
            if ok and n then
                return n
            end
        end
        if v.getY then
            local ok, n = pcall(function()
                return v:getY()
            end)
            if ok and n then
                return n
            end
        end
    elseif axis == "z" then
        if v.z then
            local ok, n = pcall(function()
                return v:z()
            end)
            if ok and n then
                return n
            end
        end
        if v.getZ then
            local ok, n = pcall(function()
                return v:getZ()
            end)
            if ok and n then
                return n
            end
        end
    end
    return 0
end

local function toBoolText(v)
    return v and "Yes" or "No"
end

local function getVehicleScriptById(scriptId)
    if not scriptId or not getScriptManager then
        return nil
    end
    local okSm, sm = pcall(getScriptManager)
    if not okSm or not sm then
        return nil
    end
    local okFind, vs = pcall(function()
        return sm:getVehicle(scriptId)
    end)
    if okFind and vs then
        return vs
    end
    local okFind2, vs2 = pcall(function()
        return sm:getVehicleScript(scriptId)
    end)
    if okFind2 and vs2 then
        return vs2
    end
    return nil
end

local function computeMaintenancePercentFromId(scriptId)
    local s = tostring(scriptId or "Vehicle")
    local sum = 0
    for i = 1, #s do
        sum = sum + string.byte(s, i)
    end
    return 20 + (sum % 21) -- 20..40
end

local function getVehicleSpecs(vehicleScript, scriptId)
    local ext = safeCall(vehicleScript, "getExtents")
    local width = tonumber(getVectorComponent(ext, "x")) or 0
    local height = tonumber(getVectorComponent(ext, "y")) or 0
    local length = tonumber(getVectorComponent(ext, "z")) or 0
    local hp = tonumber(safeCall(vehicleScript, "getEngineForce")) or 0
    hp = hp / 10

    local hasRadio = false
    local hasHeater = false
    local hasTrunk = false
    local trunkCapacity = 0

    local partCount = tonumber(safeCall(vehicleScript, "getPartCount")) or 0
    if partCount > 0 and vehicleScript.getPart then
        for i = 0, partCount - 1 do
            local part = nil
            local okPart, partObj = pcall(function()
                return vehicleScript:getPart(i)
            end)
            if okPart then
                part = partObj
            end
            if part and part.getId then
                local pid = tostring(safeCall(part, "getId") or ""):lower()
                if string.find(pid, "radio", 1, true) then
                    hasRadio = true
                end
                if string.find(pid, "heater", 1, true) then
                    hasHeater = true
                end
                if string.find(pid, "truckbed", 1, true) or string.find(pid, "trunk", 1, true) then
                    hasTrunk = true
                end
            end
            if part and part.getContainer then
                local container = safeCall(part, "getContainer")
                if container then
                    local cap = tonumber(safeCall(container, "getCapacity")) or tonumber(safeCall(container, "capacity")) or 0
                    if cap > 0 then
                        trunkCapacity = trunkCapacity + cap
                    end
                end
            end
        end
    end
    if trunkCapacity > 0 then
        hasTrunk = true
    end

    local maintenancePct = computeMaintenancePercentFromId(scriptId)
    local specs = {
        width = width,
        height = height,
        length = length,
        engineHP = hp,
        trunkCapacity = trunkCapacity,
        hasRadio = hasRadio,
        hasHeater = hasHeater,
        hasTrunk = hasTrunk,
        maintenancePct = maintenancePct
    }
    specs.tooltip = string.format(
        "W: %.2f | H: %.2f | L: %.2f\nEngine: %.0f hp\nTrunk Cap: %.0f\nRadio: %s | Heating: %s | Trunk: %s\nMaintenance Price: %d%%",
        specs.width, specs.height, specs.length, specs.engineHP, specs.trunkCapacity, toBoolText(specs.hasRadio),
        toBoolText(specs.hasHeater), toBoolText(specs.hasTrunk), specs.maintenancePct)
    return specs
end

local function getAutoPreviewZoom(specs)
    local baseZoom = 4.0
    if not specs then
        return baseZoom
    end
    local baseHeight = 1.06
    local baseLength = 4.92
    local hStep = 0.30
    local lStep = 0.40

    local hOver = math.max(0, (tonumber(specs.height) or 0) - baseHeight)
    local lOver = math.max(0, (tonumber(specs.length) or 0) - baseLength)

    -- Apply when either dimension grows.
    local hLevel = math.floor(hOver / hStep)
    local lLevel = math.floor(lOver / lStep)
    local level = math.max(hLevel, lLevel)

    -- "Two zoom outs" per level ~= -0.8 in this UI (each click is 0.4).
    -- Extra global margin for oversized mod vehicles: two more zoom-outs.
    local zoom = baseZoom - 0.8 - (level * 0.8)
    if zoom < 1.2 then
        zoom = 1.2
    end
    return zoom
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
    local mechanicType = safeCall(vehicleScript, "getMechanicType") or 0
    local vehicleClass = "Other"
    if mechanicType == 1 then
        vehicleClass = "Standard"
    elseif mechanicType == 2 then
        vehicleClass = "Commercial"
    elseif mechanicType == 3 then
        vehicleClass = "Sport"
    end
    local specs = getVehicleSpecs(vehicleScript, scriptId)
    return {
        text = tostring(scriptId),
        item = {
            id = tostring(scriptId),
            name = tostring(name or scriptId),
            module = moduleName,
            source = (moduleName == "Base") and "Vanilla" or "Mod",
            mechanicType = mechanicType,
            vehicleClass = vehicleClass,
            specs = specs
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

    if self.VehiclePreviewScene and self.VehiclePreviewCine then
        local now = getNowMs()
        local lastInput = self.VehiclePreviewLastInputMs or 0
        local canAuto = (now > 0) and ((now - lastInput) >= 1600)
        if canAuto then
            self:updateVehiclePreviewCinematic(now)
        end
    end
end

function S4_IE_VehicleShop:buildPreviewCinematic()
    -- One-shot sequence requested:
    -- 1) Start "far left" and ease into center once.
    -- 2) Right -> Left -> Top (nose toward bottom) -> Front.
    return {
        {
            type = "view",
            view = "Right",
            hold = 350
        },
        {
            -- Push toward right first (entry start point).
            type = "drag",
            dxPerTick = 18.0,
            dyPerTick = 0.0,
            duration = 520
        },
        {
            -- Switch to opposite angle before returning (simulated driving back).
            type = "view",
            view = "Left",
            hold = 260
        },
        {
            type = "drag",
            -- Return to center while facing left.
            dxPerTick = -5.7,
            dyPerTick = 0.0,
            duration = 1650
        },
        {
            type = "view",
            view = "Right",
            hold = 820
        },
        {
            type = "view",
            view = "Left",
            hold = 900
        },
        {
            type = "view",
            view = "Top",
            hold = 300
        },
        {
            -- Top: drift upward.
            type = "drag",
            dxPerTick = 0.0,
            dyPerTick = -3.2,
            duration = 520
        },
        {
            -- Top: drift downward.
            type = "drag",
            dxPerTick = 0.0,
            dyPerTick = 3.2,
            duration = 520
        },
        {
            type = "view",
            view = "Front",
            hold = 520
        },
        {
            -- Front: drift to left.
            type = "drag",
            dxPerTick = -3.2,
            dyPerTick = 0.0,
            duration = 520
        },
        {
            -- Front: drift to right.
            type = "drag",
            dxPerTick = 3.2,
            dyPerTick = 0.0,
            duration = 520
        },
        {
            -- Final recenter nudge.
            type = "drag",
            dxPerTick = -1.5,
            dyPerTick = 0.0,
            duration = 450
        },
        {
            type = "view",
            view = "Right",
            hold = 700
        }
    }
end

function S4_IE_VehicleShop:updateVehiclePreviewCinematic(now)
    if not self.VehiclePreviewScene or not self.VehiclePreviewCine then
        return
    end
    local cine = self.VehiclePreviewCine
    if cine.finished then
        return
    end
    local steps = cine.steps or {}
    if #steps == 0 then
        return
    end
    local idx = cine.index or 1
    if idx < 1 or idx > #steps then
        idx = 1
    end
    local step = steps[idx]
    if not step then
        return
    end

    if not cine.stepInit then
        cine.stepInit = true
        cine.stepStartMs = now
        cine.lastTickMs = now
        if step.type == "view" and step.view then
            pcall(function()
                self.VehiclePreviewScene:setView(step.view)
            end)
        end
    end

    local elapsed = now - (cine.stepStartMs or now)
    local holdOrDuration = step.hold or step.duration or 1000

    if step.type == "drag" then
        local lastTick = cine.lastTickMs or now
        local dt = now - lastTick
        if dt < 16 then
            return
        end
        local factor = dt / 16
        sceneDrag(self.VehiclePreviewScene, (step.dxPerTick or 0) * factor, (step.dyPerTick or 0) * factor)
        cine.lastTickMs = now
    end

    if elapsed >= holdOrDuration then
        idx = idx + 1
        if idx > #steps then
            cine.finished = true
            return
        end
        cine.index = idx
        cine.stepInit = false
    end
end

function S4_IE_VehicleShop:onRefreshVehicleList()
    self:reloadVehicleList()
end

function S4_IE_VehicleShop:initVehicleCategoryBox()
    if not self.CategoryBox then
        return
    end
    self.CategoryBox:clear()
    self.CategoryBox:addItem("All", "All")
    self.CategoryBox:addItem("Standard", "Standard")
    self.CategoryBox:addItem("Commercial", "Commercial")
    self.CategoryBox:addItem("Sport", "Sport")
    self.CategoryBox:addItem("Vanilla", "Vanilla")
    self.CategoryBox:addItem("Modded", "Modded")
end

function S4_IE_VehicleShop:passesVehicleFilter(item)
    local filter = self.VehicleListCategory or "All"
    if filter == "All" then
        return true
    end
    if filter == "Vanilla" then
        return item.source == "Vanilla"
    end
    if filter == "Modded" then
        return item.source ~= "Vanilla"
    end
    return item.vehicleClass == filter
end

function S4_IE_VehicleShop:reloadVehicleList()
    if not self.VehicleListBox then
        return
    end
    self.VehicleListBox:clear()
    local rows = getAllVehicleScriptsRows()
    local shown = 0
    for i = 1, #rows do
        if self:passesVehicleFilter(rows[i].item) then
            local row = self.VehicleListBox:addItem(rows[i].text, rows[i].item)
            if row and rows[i].item and rows[i].item.specs and rows[i].item.specs.tooltip then
                row.tooltip = rows[i].item.specs.tooltip
            end
            shown = shown + 1
        end
    end
    if self.VehicleCountLabel then
        self.VehicleCountLabel:setName("Total: " .. tostring(shown) .. " / " .. tostring(#rows))
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
    self:drawTextRight(tostring(data.source or "Unknown"), self:getWidth() - 8, y + 1, sourceColor.r, sourceColor.g,
        sourceColor.b, 1, UIFont.Small)
    self:drawTextRight(tostring(data.vehicleClass or "Other"), self:getWidth() - 8, y + 12, 0.78, 0.88, 0.78, 1,
        UIFont.Small)
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
            parentUI:openVehiclePreview(data)
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
    self.VehiclePreviewCine = nil
    self.VehiclePreviewLastInputMs = nil
end

function S4_IE_VehicleShop:openVehiclePreview(data)
    if not data or not data.id then
        return
    end
    local scriptName = data.id
    local displayName = data.name or data.id
    local specs = data.specs
    if not specs then
        local vehicleScript = getVehicleScriptById(scriptName)
        specs = getVehicleSpecs(vehicleScript, scriptName)
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

    local scene = ISUI3DScene:new(12, 34, pw - 24, ph - 136)
    scene:initialise()
    scene:instantiate()
    scene.backgroundColor = {r = 1, g = 1, b = 1, a = 1}
    panel:addChild(scene)
    self.VehiclePreviewScene = scene
    self.VehiclePreviewBaseZoom = getAutoPreviewZoom(specs)
    self.VehiclePreviewZoom = self.VehiclePreviewBaseZoom
    self.VehiclePreviewCine = {
        steps = self:buildPreviewCinematic(),
        index = 1,
        stepInit = false,
        stepStartMs = 0,
        lastTickMs = 0,
        finished = false
    }
    self.VehiclePreviewLastInputMs = getNowMs()

    local ok = pcall(function()
        scene.javaObject:fromLua1("setDrawGrid", false)
        scene.javaObject:fromLua1("setZoom", self.VehiclePreviewZoom)
        scene:setView("Right")
        scene.javaObject:fromLua1("createVehicle", "vehicle")
        scene.javaObject:fromLua2("setVehicleScript", "vehicle", scriptName)
    end)

    if not ok then
        local errLbl = ISLabel:new(18, ph - 24, S4_UI.FH_S, "3D preview not available for this vehicle script.", 1, 0.6,
            0.6, 1, UIFont.Small, true)
        panel:addChild(errLbl)
    end

    local infoY = scene:getBottom() + 6
    local infoLines = {"No specs available."}
    if specs then
        infoLines = {
            string.format("Width: %.2f  Height: %.2f  Length: %.2f", specs.width or 0, specs.height or 0,
                specs.length or 0),
            string.format("Engine Power: %.0f hp  Trunk Capacity: %.0f", specs.engineHP or 0, specs.trunkCapacity or 0),
            string.format("Radio: %s  Heating: %s  Trunk: %s", toBoolText(specs.hasRadio),
                toBoolText(specs.hasHeater), toBoolText(specs.hasTrunk)),
            string.format("Maintenance Price: %d%%", tonumber(specs.maintenancePct) or 20)
        }
    end
    for i = 1, #infoLines do
        local line = ISLabel:new(14, infoY + ((i - 1) * (S4_UI.FH_S + 2)), S4_UI.FH_S, infoLines[i], 0.88, 0.92, 0.88,
            1, UIFont.Small, true)
        panel:addChild(line)
    end

    local controls = ISPanel:new(12, ph - 34, pw - 24, 28)
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
    if self.VehiclePreviewCine then
        self.VehiclePreviewCine.stepInit = false
    end
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
        self.VehiclePreviewZoom = self.VehiclePreviewBaseZoom or 4
        pcall(function()
            scene:setView("Right")
            scene.javaObject:fromLua1("setZoom", self.VehiclePreviewZoom)
        end)
        if self.VehiclePreviewCine then
            self.VehiclePreviewCine.index = 1
            self.VehiclePreviewCine.stepInit = false
        end
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
        self.VehicleListCategory = self.VehicleListCategory or "All"
        self:initVehicleCategoryBox()
        self.CategoryBox.selectedRow = 1
        self.CategoryBox.CategoryType = self.VehicleListCategory
        self:reloadVehicleList()
        self:ShopBoxVisible(true)
    elseif internal == "Sell" then
        self.VehicleListCategory = self.VehicleListCategory or "All"
        self:initVehicleCategoryBox()
        self.CategoryBox.selectedRow = 1
        self.CategoryBox.CategoryType = self.VehicleListCategory
        self:reloadVehicleList()
        self:ShopBoxVisible(true)
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
    if self.MenuType == "Buy" or self.MenuType == "Sell" then
        if not KeepCurrentView or not self.CategoryBox.CategoryType then
            self:initVehicleCategoryBox()
            self.CategoryBox.selectedRow = 1
            self.CategoryBox.CategoryType = self.VehicleListCategory or "All"
        end
        self:reloadVehicleList()
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
            ShopUI.VehicleListCategory = list.CategoryType or "All"
            ShopUI:reloadVehicleList()
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
