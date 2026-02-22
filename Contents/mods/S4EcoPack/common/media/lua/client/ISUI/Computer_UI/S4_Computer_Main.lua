S4_Computer_Main = ISPanel:derive("S4_Computer_Main")
S4_Computer_Main.instance = nil

function S4_Computer_Main:show(player, ComObj, x, y)
    local square = player:getSquare()
    posX = square:getX()
    posY = square:getY()
    if S4_Computer_Main.instance == nil then
        S4_Computer_Main.instance = S4_Computer_Main:new(player, ComObj, x, y)
        S4_Computer_Main.instance:initialise()
        S4_Computer_Main.instance:instantiate()
    else
        -- Update player and object if we're reusing the instance
        S4_Computer_Main.instance.player = player
        S4_Computer_Main.instance.ComObj = ComObj
        S4_Computer_Main.instance:CheckModData() -- Refresh internet/card status
    end
    S4_Computer_Main.instance:addToUIManager()
    S4_Computer_Main.instance:setVisible(true)
    return S4_Computer_Main.instance
end

function S4_Computer_Main:new(player, ComObj, x, y)
    local o = {}
    local width, height = S4_UI.getScreenSize()
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.ComObj = ComObj
    o.backgroundColor = {
        r = 0 / 255,
        g = 128 / 255,
        b = 128 / 255,
        a = 1
    }
    o.borderColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    }
    o.moveWithMouse = true
    o.TaskBar = {}
    o.BuyCart = {}
    o.SellCart = {}
    o.BlackJackTotal = 0
    o:setWantKeyEvents(true)
    return o
end

function S4_Computer_Main:initialise()
    ISPanel.initialise(self)
    -- self.Taskbar = {}

    self.UI_Font = S4_UI.getFontType(2)
    self.BtnMaxW = 150

    self:CheckModData()
end

function S4_Computer_Main:CheckModData()
    -- Reset flags to avoid stale data from other computers
    self.CardReaderInstall = false
    self.CardNumber = nil
    self.CardMaster = nil
    self.CardMoney = 0
    self.CardPassword = nil
    self.isCardPassword = false
    self.SatelliteInstall = false
    self.NetPeriod = nil
    self.NetContract = false

    -- Whether card reader/satellite antenna is installed
    -- If a card reader is installed, retrieve the saved card number
    local ComModData = self.ComObj:getModData()
    if ComModData.ComCardReader then -- Check card data
        self.CardReaderInstall = true
        if ComModData.S4CardNumber then
            self.CardNumber = ComModData.S4CardNumber
            self.CardMaster = ComModData.S4CardMaster
            local CardModData = ModData.get("S4_CardData")
            if CardModData[ComModData.S4CardNumber] then
                self.CardMoney = CardModData[ComModData.S4CardNumber].Money
                self.CardPassword = CardModData[ComModData.S4CardNumber].Password
            end
        end
    end
    if ComModData.ComSatellite then -- Check satellite antenna installation
        if ComModData.ComSatelliteXYZ and S4_Utils.CheckSatelliteDish(self.ComObj) then
            self.SatelliteInstall = true
        else
            self.SatelliteInstall = false
            -- Do not wipe ComSatelliteXYZ here, as it might just be in an unloaded chunk.
            -- Wiping it here makes the internet permanently 'broken' until reinstalled.
            -- ComModData.ComSatelliteXYZ = false
            -- S4_Utils.SnycObject(self.ComObj)
        end

        if ComModData.ComPeriod then -- Internet contract confirmation
            self.NetPeriod = ComModData.ComPeriod
            self.NetContract = S4_Utils.getTimeOver(ComModData.ComPeriod)
        end
    end
    if ComModData.ComPassword then
        self.ComPassword = ComModData.ComPassword
        if ComModData.ComLock then
            self.LockSettings = ComModData.ComLock
        end
    end
    if ComModData.ComTime then
        self.TimeSettings = ComModData.ComTime
    end
end

function S4_Computer_Main:createChildren()
    ISPanel.createChildren(self)

    S4_Category.ComputerIconData["Twitboid"] = {
        Name = "Twitboid",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Twitboid.png")
    }
    S4_Category.ComputerIconData["Crimeboid"] = {
        Name = "Crimeboid.net",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Crimeboid.png")
    }
    S4_Category.ComputerIconData["Zeddit"] = {
        Name = "Zeddit",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Network.png")
    }
    S4_Category.ComputerIconData["Logistics"] = {
        Name = "S4 Logistics",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Logistics.png")
    }
    S4_Category.ComputerIconData["Taxes"] = {
        Name = "S4 Regional Taxes",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Taxes.png")
    }
    S4_Category.ComputerIconData["Community"] = {
        Name = "Community Hub",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Community.png")
    }
    S4_Category.ComputerIconData["FarmWatch"] = {
        Name = "FarmWatch",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_FarmWatch.png")
    }
    S4_Category.ComputerIconData["Recon"] = {
        Name = "Scout & Recon",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Recon.png")
    }
    S4_Category.ComputerIconData["Recover"] = {
        Name = "Corpse Recovery",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_RecoverBody.png")
    }
    S4_Category.ComputerIconData["Repair"] = {
        Name = "Tool Repair",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Repair.png")
    }
    S4_Category.ComputerIconData["Weather"] = {
        Name = "Knox Weather",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Weather.png")
    }
    S4_Category.ComputerIconData["MyCom"] = {
        Name = "My Computer",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_MyCom.png")
    }
    S4_Category.ComputerIconData["MyDoc"] = {
        Name = "My Documents",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_MyDoc.png")
    }
    S4_Category.ComputerIconData["IE"] = {
        Name = "Internet Explorer",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_IE.png")
    }
    S4_Category.ComputerIconData["Network"] = {
        Name = "Network Neighborhood",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Network.png")
    }
    S4_Category.ComputerIconData["Trash"] = {
        Name = "Trash",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Trash.png")
    }
    S4_Category.ComputerIconData["Settings"] = {
        Name = "Settings",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Setting.png")
    }
    S4_Category.ComputerIconData["CardReader"] = {
        Name = "Card Reader",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_CardReader.png")
    }
    S4_Category.ComputerIconData["UserSetting"] = {
        Name = "User Setting",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_UserSetting.png")
    }
    S4_Category.ComputerIconData["News"] = {
        Name = "Knox News",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_News.png")
    }
    S4_Category.ComputerIconData["ZomBank"] = {
        Name = "Zom Bank",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_ZomBank.png")
    }
    S4_Category.ComputerIconData["GoodShop"] = {
        Name = "Good Shop",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_GS.png")
    }
    S4_Category.ComputerIconData["VehicleShop"] = {
        Name = "Vehicle Shop",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Vehicle.png")
    }

    S4_Category.ComputerIconData["Jobs"] = {
        Name = "Jobs",
        Icon = getTexture("media/textures/S4_Icon/Icon_64_Jobs.png")
    }

    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.Blackjack then
        S4_Category.ComputerIconData["BlackJack"] = {
            Name = "Black Jack",
            Icon = getTexture("media/textures/S4_Icon/Icon_64_BlackJack.png")
        }
    end

    local IconSize = S4_UI.FH_S * 2
    local BtnH = (S4_UI.FH_S * 4) + 12
    local BtnW = 120
    local BtnX = 15
    local BtnY = 20
    local TaskFont = S4_UI.getFontType(2)
    local TaskBarH = getTextManager():getFontFromEnum(TaskFont):getLineHeight() + 7

    local orderedIcons = {
        "MyCom", "MyDoc", "Twitboid", "Zeddit", "Crimeboid", "News", "Logistics", "Taxes", "Community", "FarmWatch", "Recon", "Recover", "Repair", "Weather", "ZomBank", "GoodShop", "VehicleShop", "Jobs", "BlackJack", "IE", "Network", "Settings", "CardReader", "UserSetting", "Trash"
    }
    local renderedIcons = {}
    for _, k in ipairs(orderedIcons) do
        if S4_Category.ComputerIconData[k] then
            table.insert(renderedIcons, k)
        end
    end
    for k, _ in pairs(S4_Category.ComputerIconData) do
        local found = false
        for _, ordered in ipairs(renderedIcons) do
            if ordered == k then found = true; break end
        end
        if not found then table.insert(renderedIcons, k) end
    end

    for _, BtnType in ipairs(renderedIcons) do
        local BtnData = S4_Category.ComputerIconData[BtnType]
        if BtnY + BtnH >= self:getHeight() - TaskBarH then
            BtnX = BtnX + BtnW + 10
            BtnY = 20
        end
        local BtnName = BtnData.Name
        local BtnIcon = BtnData.Icon
        self["Btn_" .. BtnType] = ISButton:new(BtnX, BtnY, BtnW, BtnH, "", self, S4_Computer_Main.BtnClick)
        self["Btn_" .. BtnType].font = UIFont.Small
        self["Btn_" .. BtnType].internal = BtnType
        self["Btn_" .. BtnType].borderColor.a = 0
        self["Btn_" .. BtnType].backgroundColor.a = 0
        self["Btn_" .. BtnType].backgroundColorMouseOver = {
            r = 189 / 255,
            g = 190 / 255,
            b = 189 / 255,
            a = 0.3
        }
        self["Btn_" .. BtnType].IconName = BtnData.Name
        self["Btn_" .. BtnType]:setImage(BtnData.Icon)
        self["Btn_" .. BtnType]:forceImageSize(IconSize, IconSize)
        self["Btn_" .. BtnType].render = S4_Computer_Main.BtnRender
        self["Btn_" .. BtnType]:initialise()
        self:addChild(self["Btn_" .. BtnType])

        BtnY = BtnY + BtnH + 10
    end

    if self.player:isAccessLevel("admin") or getDebug() then
        local ABtnX = self:getWidth() - BtnW - 16
        self.Btn_GoodshopAdmin = ISButton:new(ABtnX, 20, BtnW, BtnH, "", self, S4_Computer_Main.BtnClick)
        self.Btn_GoodshopAdmin.font = UIFont.Small
        self.Btn_GoodshopAdmin.internal = "GoodShopAdmin"
        self.Btn_GoodshopAdmin.borderColor.a = 0
        self.Btn_GoodshopAdmin.backgroundColor.a = 0
        self.Btn_GoodshopAdmin.backgroundColorMouseOver = {
            r = 189 / 255, g = 190 / 255, b = 189 / 255, a = 0.3
        }
        self.Btn_GoodshopAdmin.IconName = "Good Shop Admin"
        self.Btn_GoodshopAdmin:setImage(getTexture("media/textures/S4_Icon/Icon_64_IE.png"))
        self.Btn_GoodshopAdmin:forceImageSize(IconSize, IconSize)
        self.Btn_GoodshopAdmin.render = S4_Computer_Main.BtnRender
        self.Btn_GoodshopAdmin:initialise()
        self:addChild(self.Btn_GoodshopAdmin)
        
        self.Btn_KarmaAdmin = ISButton:new(ABtnX, 20 + BtnH + 10, BtnW, BtnH, "", self, S4_Computer_Main.BtnClick)
        self.Btn_KarmaAdmin.font = UIFont.Small
        self.Btn_KarmaAdmin.internal = "KarmaAdmin"
        self.Btn_KarmaAdmin.borderColor.a = 0
        self.Btn_KarmaAdmin.backgroundColor.a = 0
        self.Btn_KarmaAdmin.backgroundColorMouseOver = {
            r = 189 / 255, g = 190 / 255, b = 189 / 255, a = 0.3
        }
        self.Btn_KarmaAdmin.IconName = "Karma Admin"
        self.Btn_KarmaAdmin:setImage(getTexture("media/textures/S4_Icon/Icon_64_Settings.png"))
        self.Btn_KarmaAdmin:forceImageSize(IconSize, IconSize)
        self.Btn_KarmaAdmin.render = S4_Computer_Main.BtnRender
        self.Btn_KarmaAdmin:initialise()
        self:addChild(self.Btn_KarmaAdmin)
    end
end

function S4_Computer_Main:render()
    ISPanel.render(self)
    local UI_Font = self.UI_Font

    if self.BlackJack then
        if self.CardReader then
            self.CardReader:close()
        end
        if self.Settings then
            self.Settings:close()
        end
    end

    -- TaskBar
    local FontHeightLine = getTextManager():getFontFromEnum(UI_Font):getLineHeight()
    local TaskWidth = self:getWidth() - 2
    local TaskHeight = FontHeightLine + 8
    local TaskY = self:getHeight() - TaskHeight - 1
    self:drawRect(1, TaskY, TaskWidth, TaskHeight, 1, 192 / 255, 192 / 255, 192 / 255)
    -- Top of TaskBar
    self:drawRect(1, TaskY - 2, TaskWidth, 2, 1, 132 / 255, 132 / 255, 132 / 255)
    -- Start Button
    local StartTextWidth = getTextManager():MeasureStringX(UI_Font, "Start")
    local StartBtnWidth = 10 + FontHeightLine + StartTextWidth
    local StartBtnHeight = FontHeightLine + 2
    local StartY = TaskY + 3
    if self.StartBtnAction then
        self:drawRect(3, StartY, StartBtnWidth, StartBtnHeight, 1, 127 / 255, 127 / 255, 127 / 255)
        self:drawRectBorder(3, StartY, StartBtnWidth, StartBtnHeight, 1, 0, 0, 0)
    else
        if self:isMouseOver() and self.StartBtn then
            self:drawRect(3, StartY, StartBtnWidth, StartBtnHeight, 0.6, 147 / 255, 147 / 255, 147 / 255)
            self:drawRectBorder(3, StartY, StartBtnWidth, StartBtnHeight, 0.9, 0, 0, 0)
        else
            self:drawRect(3, StartY, StartBtnWidth, StartBtnHeight, 1, 187 / 255, 187 / 255, 187 / 255)
            self:drawRectBorder(3, StartY, StartBtnWidth, StartBtnHeight, 0.8, 0, 0, 0)
        end
    end
    -- Start Text
    local StartTextY = TaskY + 2
    local StartImgY = StartTextY + 2
    local StartTextX = 8 + FontHeightLine
    self:drawTextureScaled(getTexture("media/textures/S4_Icon/Icon_Windows_Start.png"), 5, StartImgY, FontHeightLine,
        FontHeightLine, 1)
    self:drawText("Start", StartTextX, StartTextY, 0, 0, 0, 1, UI_Font)
    -- Save global function size
    self.StartBtnWidth = StartBtnWidth
    self.StartBtnHeight = StartBtnHeight
    self.StartY = StartY
    self.TaskBarY = TaskY
    self.TaskBarH = TaskHeight

    -- Time/App
    local DumpAM = getTextManager():MeasureStringX(UI_Font, getText("IGUI_S4_COM_AM") .. " 00:00")
    local DumpPM = getTextManager():MeasureStringX(UI_Font, getText("IGUI_S4_COM_PM") .. " 00:00")
    local DumpTimeW = math.max(DumpAM, DumpPM)
    local AppImgSize = FontHeightLine - 4
    local AppImgY = StartImgY + 3
    local TimeX = self:getWidth() - DumpTimeW - (AppImgSize * 2) - 25
    local TimeW = DumpTimeW + (AppImgSize * 2) + 20
    self:drawRect(TimeX, StartY, TimeW, StartBtnHeight, 0.6, 147 / 255, 147 / 255, 147 / 255)
    self:drawRectBorder(TimeX, StartY, TimeW, StartBtnHeight, 0.9, 0, 0, 0)
    TimeX = TimeX + 5
    -- if change image after checking whether object mode data is installed
    local CardReaderImg = getTexture("media/textures/S4_Icon/Icon_64_CardReader_UnInstall.png")
    local NetworkImg = getTexture("media/textures/S4_Icon/Icon_64_Network_Fail.png")
    if self.SatelliteInstall then
        NetworkImg = getTexture("media/textures/S4_Icon/Icon_64_Network_Error.png")
        if self.NetContract then
            NetworkImg = getTexture("media/textures/S4_Icon/Icon_64_Network.png")
        end
    end
    if self.CardReaderInstall then
        CardReaderImg = getTexture("media/textures/S4_Icon/Icon_64_CardReader.png")
        if self.CardNumber then
            CardReaderImg = getTexture("media/textures/S4_Icon/Icon_64_CardReader_NotNetwork.png")
            if self.SatelliteInstall then
                CardReaderImg = getTexture("media/textures/S4_Icon/Icon_64_CardPassword.png")
                if self.isCardPassword then
                    CardReaderImg = getTexture("media/textures/S4_Icon/Icon_64_CardReader_Insert.png")
                end
            end
        end
    end
    self:drawTextureScaled(CardReaderImg, TimeX, AppImgY, AppImgSize, AppImgSize, 1)
    TimeX = TimeX + AppImgSize + 5
    self:drawTextureScaled(NetworkImg, TimeX, AppImgY, AppImgSize, AppImgSize, 1)
    TimeX = TimeX + AppImgSize + 5
    local TimeValue = S4_UI.getComputerTime(false) -- Add 24-hour clock setting
    self:drawText(TimeValue, TimeX, StartTextY + 2, 0, 0, 0, 1, UI_Font)
    self.TimeAppX = self:getWidth() - DumpTimeW - (AppImgSize * 2) - 30

    -- TaskBar Icon
    -- Knox News Notification Logic
    local newsModData = ModData.getOrCreate("S4_KnoxNews")
    if self.Btn_News then
        if newsModData.IsNew then
            self.Btn_News.image = getTexture("media/textures/S4_Icon/Icon_64_NewsIncoming.png")
        else
            self.Btn_News.image = getTexture("media/textures/S4_Icon/Icon_64_News.png")
        end
    end

    for i, TaskBarUI in ipairs(self.TaskBar) do
        if self["Task" .. i] then
            local TaskX = self["Task" .. i]:getX()
            local TaskY = self["Task" .. i]:getY()
            local TaskW = self["Task" .. i]:getWidth()
            local TaskH = self["Task" .. i]:getHeight()
            local BtnName = S4_UI.TextLimitOne(TaskBarUI.TitleName, self.BtnMaxW, self.UI_Font)
            -- Highlight top-level window TaskBar
            if self.TopApp == self["Task" .. i].App then
                self:drawRect(TaskX, TaskY, TaskW, TaskH, 0.6, 127 / 255, 127 / 255, 127 / 255)
                self:drawRectBorder(TaskX, TaskY, TaskW, TaskH, 0.9, 0, 0, 0)
                self:drawText(BtnName, TaskX + 3, TaskY, 0, 0, 0, 1, UI_Font)
            else
                self:drawRect(TaskX, TaskY, TaskW, TaskH, 0.6, 187 / 255, 187 / 255, 187 / 255)
                self:drawRectBorder(TaskX, TaskY, TaskW, TaskH, 0.9, 0, 0, 0)
                self:drawText(BtnName, TaskX + 3, TaskY, 0, 0, 0, 1, UI_Font)
            end
        end
    end

end

-- button function
function S4_Computer_Main:BtnClick(Button)
    local internal = Button.internal
    if internal == "MyCom" then
        if self.MyCom then
            if not self.MyCom:isVisible() then
                self.MyCom:setVisible(true)
            end
            self.MyCom:bringToTop()
        else
            self.MyCom = S4_System:new(self)
            self.MyCom:initialise()
            self.MyCom.TitleName = "System Properties - System"
            self.MyCom.PageType = internal
            self.MyCom.IconImg = getTexture("media/textures/S4_Icon/Icon_64_MyCom.png")
            self:addChild(self.MyCom)
            self:AddTaskBar(self.MyCom)
        end
        self.TopApp = self.MyCom
    elseif internal == "MyDoc" then
        if self.MyDoc then
            if not self.MyDoc:isVisible() then
                self.MyDoc:setVisible(true)
            end
            self.MyDoc:bringToTop()
        else
            self.MyDoc = S4_InternetExplorer:new(self)
            self.MyDoc:initialise()
            self.MyDoc.TitleName = "My Documents - Internet Explorer"
            self.MyDoc.AddressText = "file://C:/Users/" .. self.player:getUsername() .. "/Documents"
            self.MyDoc.PageType = internal
            self:addChild(self.MyDoc)
            self:AddTaskBar(self.MyDoc)
        end
        self.TopApp = self.MyDoc
    elseif internal == "Twitboid" then
        if self.Twitboid then
            if not self.Twitboid:isVisible() then
                self.Twitboid:setVisible(true)
            end
            self.Twitboid:bringToTop()
        else
            self.Twitboid = S4_InternetExplorer:new(self)
            self.Twitboid:initialise()
            self.Twitboid.TitleName = "Twitboid - Internet Explorer"
            self.Twitboid.AddressText = "http://twitboid.com/home"
            self.Twitboid.PageType = internal
            self:addChild(self.Twitboid)
            self:AddTaskBar(self.Twitboid)
        end
        self.TopApp = self.Twitboid
    elseif internal == "Crimeboid" then
        if self.Crimeboid then
            if not self.Crimeboid:isVisible() then
                self.Crimeboid:setVisible(true)
            end
            self.Crimeboid:bringToTop()
        else
            self.Crimeboid = S4_InternetExplorer:new(self)
            self.Crimeboid:initialise()
            self.Crimeboid.TitleName = "Crimeboid.net - Internet Explorer"
            self.Crimeboid.AddressText = "https://crimeboid.net/hidden"
            self.Crimeboid.PageType = internal
            self:addChild(self.Crimeboid)
            self:AddTaskBar(self.Crimeboid)
        end
        self.TopApp = self.Crimeboid
    elseif internal == "Zeddit" then
        if self.Zeddit then
            if not self.Zeddit:isVisible() then
                self.Zeddit:setVisible(true)
            end
            self.Zeddit:bringToTop()
        else
            self.Zeddit = S4_InternetExplorer:new(self)
            self.Zeddit:initialise()
            self.Zeddit.TitleName = "Zeddit - The Front Page of Knox"
            self.Zeddit.AddressText = "http://zeddit.com/frontpage"
            self.Zeddit.PageType = internal
            self:addChild(self.Zeddit)
            self:AddTaskBar(self.Zeddit)
        end
        self.TopApp = self.Zeddit
    elseif internal == "Logistics" then
        if self.Logistics then
            if not self.Logistics:isVisible() then
                self.Logistics:setVisible(true)
            end
            self.Logistics:bringToTop()
        else
            self.Logistics = S4_InternetExplorer:new(self)
            self.Logistics:initialise()
            self.Logistics.TitleName = "S4 Logistics - Global Supply Chain"
            self.Logistics.AddressText = "https://s4-logistics.knox/dashboard"
            self.Logistics.PageType = internal
            self:addChild(self.Logistics)
            self:AddTaskBar(self.Logistics)
        end
        self.TopApp = self.Logistics
    elseif internal == "Taxes" then
        if self.Taxes then
            if not self.Taxes:isVisible() then
                self.Taxes:setVisible(true)
            end
            self.Taxes:bringToTop()
        else
            self.Taxes = S4_InternetExplorer:new(self)
            self.Taxes:initialise()
            self.Taxes.TitleName = "Regional Collection Agency"
            self.Taxes.AddressText = "gov://knox.gov/taxes"
            self.Taxes.PageType = internal
            self:addChild(self.Taxes)
            self:AddTaskBar(self.Taxes)
        end
        self.TopApp = self.Taxes
    elseif internal == "Community" then
        if self.Community then
            if not self.Community:isVisible() then self.Community:setVisible(true) end
            self.Community:bringToTop()
        else
            self.Community = S4_InternetExplorer:new(self)
            self.Community:initialise()
            self.Community.TitleName = "Knox Community Hub"
            self.Community.AddressText = "http://knox.community.gov/index"
            self.Community.PageType = internal
            self:addChild(self.Community)
            self:AddTaskBar(self.Community)
        end
        self.TopApp = self.Community
    elseif internal == "FarmWatch" then
        if self.FarmWatch then
            if not self.FarmWatch:isVisible() then self.FarmWatch:setVisible(true) end
            self.FarmWatch:bringToTop()
        else
            self.FarmWatch = S4_InternetExplorer:new(self)
            self.FarmWatch:initialise()
            self.FarmWatch.TitleName = "FarmWatch Agrosystems"
            self.FarmWatch.AddressText = "https://farmwatch.corp/market"
            self.FarmWatch.PageType = internal
            self:addChild(self.FarmWatch)
            self:AddTaskBar(self.FarmWatch)
        end
        self.TopApp = self.FarmWatch
    elseif internal == "Recon" then
        if self.Recon then
            if not self.Recon:isVisible() then self.Recon:setVisible(true) end
            self.Recon:bringToTop()
        else
            self.Recon = S4_InternetExplorer:new(self)
            self.Recon:initialise()
            self.Recon.TitleName = "Recon & Survival Mapping"
            self.Recon.AddressText = "local://recon_suite.exe"
            self.Recon.PageType = internal
            self:addChild(self.Recon)
            self:AddTaskBar(self.Recon)
        end
        self.TopApp = self.Recon
    elseif internal == "Recover" then
        if self.Recover then
            if not self.Recover:isVisible() then self.Recover:setVisible(true) end
            self.Recover:bringToTop()
        else
            self.Recover = S4_InternetExplorer:new(self)
            self.Recover:initialise()
            self.Recover.TitleName = "Body Recovery Services"
            self.Recover.AddressText = "http://recovery.knox/request"
            self.Recover.PageType = internal
            self:addChild(self.Recover)
            self:AddTaskBar(self.Recover)
        end
        self.TopApp = self.Recover
    elseif internal == "Repair" then
        if self.Repair then
            if not self.Repair:isVisible() then self.Repair:setVisible(true) end
            self.Repair:bringToTop()
        else
            self.Repair = S4_InternetExplorer:new(self)
            self.Repair:initialise()
            self.Repair.TitleName = "HandyMan Online Repairs"
            self.Repair.AddressText = "http://repair.handyman.com/service"
            self.Repair.PageType = internal
            self:addChild(self.Repair)
            self:AddTaskBar(self.Repair)
        end
        self.TopApp = self.Repair
    elseif internal == "Weather" then
        if self.Weather then
            if not self.Weather:isVisible() then self.Weather:setVisible(true) end
            self.Weather:bringToTop()
        else
            self.Weather = S4_InternetExplorer:new(self)
            self.Weather:initialise()
            self.Weather.TitleName = "Knox Meteorological Data"
            self.Weather.AddressText = "192.168.1.100:8080/weather_monitor"
            self.Weather.PageType = internal
            self:addChild(self.Weather)
            self:AddTaskBar(self.Weather)
        end
        self.TopApp = self.Weather
    elseif internal == "KarmaAdmin" then
        if self.KarmaAdmin then
            if not self.KarmaAdmin:isVisible() then
                self.KarmaAdmin:setVisible(true)
            end
            self.KarmaAdmin:bringToTop()
        else
            self.KarmaAdmin = S4_InternetExplorer:new(self)
            self.KarmaAdmin:initialise()
            self.KarmaAdmin.TitleName = "System - S4 PlayerStats Admin Tool"
            self.KarmaAdmin.AddressText = "local://root/admin/karma_manager.exe"
            self.KarmaAdmin.PageType = internal
            self:addChild(self.KarmaAdmin)
            self:AddTaskBar(self.KarmaAdmin)
        end
        self.TopApp = self.KarmaAdmin
    elseif internal == "IE" then
        if self.IE then
            if not self.IE:isVisible() then
                self.IE:setVisible(true)
            end
            self.IE:bringToTop()
        else
            self.IE = S4_InternetExplorer:new(self)
            self.IE:initialise()
            self.IE.TitleName = "Servivor Network - Internet Explorer"
            self.IE.AddressText = "http://hind.com/ServivorNetwork/home"
            self.IE.PageType = internal
            self:addChild(self.IE)
            self:AddTaskBar(self.IE)
        end
        self.TopApp = self.IE
    elseif internal == "Network" then
        if self.Network then
            if not self.Network:isVisible() then
                self.Network:setVisible(true)
            end
            self.Network:bringToTop()
        else
            self.Network = S4_System:new(self)
            self.Network:initialise()
            self.Network.TitleName = "Network - System"
            self.Network.PageType = internal
            self.Network.IconImg = getTexture("media/textures/S4_Icon/Icon_64_Network.png")
            self:addChild(self.Network)
            self:AddTaskBar(self.Network)
        end
        self.TopApp = self.Network
    elseif internal == "Settings" then
        if self.Settings then
            if not self.Settings:isVisible() then
                self.Settings:setVisible(true)
            end
            self.Settings:bringToTop()
        else
            self.Settings = S4_System:new(self)
            self.Settings:initialise()
            self.Settings.TitleName = "Settings - System"
            self.Settings.PageType = internal
            self.Settings.IconImg = getTexture("media/textures/S4_Icon/Icon_64_Setting.png")
            self:addChild(self.Settings)
            self:AddTaskBar(self.Settings)
        end
        self.TopApp = self.Settings
    elseif internal == "Trash" then
        -- if self.Trash then
        --     if not self.Trash:isVisible() then
        --         self.Trash:setVisible(true)
        --     end
        --     self.Trash:bringToTop()
        -- else
        --     self.Trash = S4_System:new(self)
        --     self.Trash:initialise()
        --     self.Trash.TitleName = "Trash UI Test"
        --     self.Trash.PageType = internal
        --     self.Trash.IconImg = getTexture("media/textures/S4_Icon/Icon_64_CardPassword.png")
        --     self:addChild(self.Trash)
        --     self:AddTaskBar(self.Trash)
        -- end
        -- self.TopApp = self.Trash
    elseif internal == "CardReader" then
        if self.CardReader then
            if not self.CardReader:isVisible() then
                self.CardReader:setVisible(true)
            end
            self.CardReader:bringToTop()
        else
            self.CardReader = S4_System:new(self)
            self.CardReader:initialise()
            self.CardReader.TitleName = "CardReader - System"
            self.CardReader.PageType = internal
            self.CardReader.IconImg = getTexture("media/textures/S4_Icon/Icon_64_CardReader.png")
            self:addChild(self.CardReader)
            self:AddTaskBar(self.CardReader)
        end
        self.TopApp = self.CardReader
    elseif internal == "UserSetting" then
        if self.UserSetting then
            if not self.UserSetting:isVisible() then
                self.UserSetting:setVisible(true)
            end
            self.UserSetting:bringToTop()
        else
            self.UserSetting = S4_System:new(self)
            self.UserSetting:initialise()
            self.UserSetting.TitleName = "User Settings - System"
            self.UserSetting.PageType = internal
            self.UserSetting.IconImg = getTexture("media/textures/S4_Icon/Icon_64_UserSetting.png")
            self:addChild(self.UserSetting)
            self:AddTaskBar(self.UserSetting)
        end
        self.TopApp = self.UserSetting
    elseif internal == "News" then
        if self.News then
            if not self.News:isVisible() then
                self.News:setVisible(true)
            end
            if self.News.ReloadUI then
                self.News:ReloadUI()
            end
            self.News:bringToTop()
        else
            self.News = S4_InternetExplorer:new(self)
            self.News:initialise()
            self.News.TitleName = "Knox News - Internet Explorer"
            self.News.AddressText = "http://hind.com/KnoxNews/home"
            self.News.PageType = internal
            self:addChild(self.News)
            self:AddTaskBar(self.News)
        end
        self.TopApp = self.News
    elseif internal == "ZomBank" then
        if self.ZomBank then
            if not self.ZomBank:isVisible() then
                self.ZomBank:setVisible(true)
            end
            self.ZomBank:bringToTop()
        else
            self.ZomBank = S4_InternetExplorer:new(self)
            self.ZomBank:initialise()
            self.ZomBank.TitleName = "Zom Bank - Internet Explorer"
            self.ZomBank.AddressText = "http://hind.com/ZomBank/home"
            self.ZomBank.PageType = internal
            self:addChild(self.ZomBank)
            self:AddTaskBar(self.ZomBank)
        end
        self.TopApp = self.ZomBank
    elseif internal == "GoodShop" then
        if self.GoodShop then
            ModData.request("S4_ShopData")
            ModData.request("S4_PlayerShopData")
            if not self.GoodShop:isVisible() then
                self.GoodShop:setVisible(true)
            end
            if self.GoodShop.ReloadUI then
                self.GoodShop:ReloadUI()
            end
            self.GoodShop:bringToTop()
        else
            self.GoodShop = S4_InternetExplorer:new(self)
            self.GoodShop:initialise()
            self.GoodShop.TitleName = "Good Shop - Internet Explorer"
            self.GoodShop.AddressText = "http://hind.com/GoodShop/home"
            self.GoodShop.PageType = internal
            self:addChild(self.GoodShop)
            self:AddTaskBar(self.GoodShop)
        end
        self.TopApp = self.GoodShop
    elseif internal == "VehicleShop" then
        if self.VehicleShop then
            ModData.request("S4_ShopData")
            ModData.request("S4_PlayerShopData")
            if not self.VehicleShop:isVisible() then
                self.VehicleShop:setVisible(true)
            end
            if self.VehicleShop.ReloadUI then
                self.VehicleShop:ReloadUI()
            end
            self.VehicleShop:bringToTop()
        else
            self.VehicleShop = S4_InternetExplorer:new(self)
            self.VehicleShop:initialise()
            self.VehicleShop.TitleName = "Vehicle Shop - Internet Explorer"
            self.VehicleShop.AddressText = "http://hind.com/VehicleShop/home"
            self.VehicleShop.PageType = internal
            self:addChild(self.VehicleShop)
            self:AddTaskBar(self.VehicleShop)
        end
        self.TopApp = self.VehicleShop
    elseif internal == "GoodShopAdmin" then
        if self.GoodShopAdmin then
            ModData.request("S4_ShopData")
            if not self.GoodShopAdmin:isVisible() then
                self.GoodShopAdmin:setVisible(true)
            end
            if self.GoodShopAdmin.ReloadUI then
                self.GoodShopAdmin:ReloadUI()
            end
            self.GoodShopAdmin:bringToTop()
        else
            self.GoodShopAdmin = S4_InternetExplorer:new(self)
            self.GoodShopAdmin:initialise()
            self.GoodShopAdmin.TitleName = "Good Shop Admin - Internet Explorer"
            self.GoodShopAdmin.AddressText = "http://hind.com/GoodShop/admin"
            self.GoodShopAdmin.PageType = internal
            self:addChild(self.GoodShopAdmin)
            self:AddTaskBar(self.GoodShopAdmin)
        end
        self.TopApp = self.GoodShopAdmin
    elseif internal == "BlackJack" then
        if self.BlackJack then
            if not self.BlackJack:isVisible() then
                self.BlackJack:setVisible(true)
            end
            self.BlackJack:bringToTop()
        else
            self.BlackJack = S4_InternetExplorer:new(self)
            self.BlackJack:initialise()
            self.BlackJack.TitleName = "BlackJack - Internet Explorer"
            self.BlackJack.AddressText = "http://hind.com/BlackJack/Game"
            self.BlackJack.PageType = internal
            self:addChild(self.BlackJack)
            self:AddTaskBar(self.BlackJack)
        end
    elseif internal == "Jobs" then
        if self.Jobs then
            if not self.Jobs:isVisible() then
                self.Jobs:setVisible(true)
            end
            self.Jobs:bringToTop()
        else
            self.Jobs = S4_InternetExplorer:new(self)
            self.Jobs:initialise()
            self.Jobs.TitleName = "Knox Jobs - Internet Explorer"
            self.Jobs.AddressText = "http://hind.com/Jobs/home"
            self.Jobs.PageType = internal
            self:addChild(self.Jobs)
            self:AddTaskBar(self.Jobs)
        end
        self.TopApp = self.Jobs
    end
end

function S4_Computer_Main:AddMsgBox(MsgTitle, IconImg, Text1, Text2, Text3)
    if self.MsgBox then
        self.MsgBox:close()
    end
    self.MsgBox = S4_System:new(self)
    self.MsgBox:initialise()
    self.MsgBox.TitleName = MsgTitle
    self.MsgBox.PageType = "MsgBox"
    self.MsgBox.MsgText1 = Text1
    if IconImg then
        self.MsgBox.IconImg = IconImg
    end
    if Text2 then
        self.MsgBox.MsgText2 = Text2
    end
    if Text3 then
        self.MsgBox.MsgText3 = Text3
    end
    self:addChild(self.MsgBox)
    self:AddTaskBar(self.MsgBox)
end

function S4_Computer_Main:AddAdminMsgBox(CheckType, MsgTitle, IconImg, Text1, Text2, Text3)
    if self.AdminMsgBox then
        self.AdminMsgBox:close()
    end
    self.AdminMsgBox = S4_System:new(self)
    self.AdminMsgBox.TitleName = MsgTitle
    self.AdminMsgBox.PageType = "AdminMsgBox"
    self.AdminMsgBox.CheckType = CheckType
    self.AdminMsgBox.MsgText1 = Text1
    if IconImg then
        self.AdminMsgBox.IconImg = IconImg
    end
    if Text2 then
        self.AdminMsgBox.MsgText2 = Text2
    end
    if Text3 then
        self.AdminMsgBox.MsgText3 = Text3
    end
    self.AdminMsgBox:initialise()
    self:addChild(self.AdminMsgBox)
    self:AddTaskBar(self.AdminMsgBox)
end

function S4_Computer_Main:CardPasswordCheck()
    if self.CardisPassword then
        if not self.CardisPassword:isVisible() then
            self.CardisPassword:setVisible(true)
        end
        self.CardisPassword:bringToTop()
    else
        self.CardisPassword = S4_System:new(self)
        self.CardisPassword:initialise()
        self.CardisPassword.TitleName = "Enter Card Password - System"
        self.CardisPassword.PageType = "CardisPassword"
        self.CardisPassword.IconImg = getTexture("media/textures/S4_Icon/Icon_64_CardPassword.png")
        self:addChild(self.CardisPassword)
        self:AddTaskBar(self.CardisPassword)
    end
    self.TopApp = self.CardisPassword
end

function S4_Computer_Main:TaskBtnClick(Button)
    local internal = Button.internal
    if internal and self["Task" .. internal] and self["Task" .. internal].App then
        if not self["Task" .. internal].App:isVisible() then
            self["Task" .. internal].App:setVisible(true)
        end
        self["Task" .. internal].App:bringToTop()
        self.TopApp = self["Task" .. internal].App
    end
end

-- TaskBar Add/Remove Functions
function S4_Computer_Main:AddTaskBar(UI)
    table.insert(self.TaskBar, UI)

    self:setTaskBarBtn()
end

function S4_Computer_Main:RemoveTaskBar(UI)
    -- Find the index containing a value
    local indexToRemove = nil
    for i, v in ipairs(self.TaskBar) do
        if v == UI then
            indexToRemove = i
            break
        end
    end

    -- Remove the value at that index
    if indexToRemove then
        table.remove(self.TaskBar, indexToRemove)
    end
    self:setTaskBarBtn()
end

function S4_Computer_Main:setTaskBarBtn()
    for j = 1, 15 do
        if self["Task" .. j] then
            self:removeChild(self["Task" .. j])
            self["Task" .. j] = nil
        end
    end

    for i, v in ipairs(self.TaskBar) do
        local Bx = 16 + self.StartBtnWidth

        if i ~= 1 and self["Task" .. (i - 1)] then
            Bx = self["Task" .. (i - 1)]:getRight() + 5
        end
        if i ~= 1 and not self["Task" .. (i - 1)] then
            return
        end
        if Bx + self.BtnMaxW <= self.TimeAppX then
            local BtnName = S4_UI.TextLimitOne(v.TitleName, self.BtnMaxW, self.UI_Font)
            self["Task" .. i] = ISButton:new(Bx, self.StartY, 0, self.StartBtnHeight, BtnName, self,
                S4_Computer_Main.TaskBtnClick)
            self["Task" .. i].internal = i
            self["Task" .. i].App = self[v.PageType]
            self["Task" .. i]:initialise()
            self["Task" .. i]:setFont(self.UI_Font)
            self["Task" .. i]:setWidthToTitle(50, false)
            self:addChild(self["Task" .. i])
        end
        -- Later... add the remaining Btn by adding a window
    end
end

-- mouse movement
function S4_Computer_Main:onMouseMove(dx, dy)
    local mouseX, mouseY = self:getMouseX(), self:getMouseY()

    -- TaskBar
    self.StartBtn = false
    if self.StartBtnWidth and self.StartY and self.StartBtnHeight then
        if mouseX >= 3 and mouseX <= 3 + self.StartBtnWidth then
            if mouseY >= self.StartY and mouseY <= self.StartY + self.StartBtnHeight then
                self.StartBtn = true
            end
        end
    end

    -- movement related
    if not self.moveWithMouse then
        return;
    end
    self.mouseOver = true;

    if self.moving then
        if self.parent then
            self.parent:setX(self.parent.x + dx);
            self.parent:setY(self.parent.y + dy);
        else
            self:setX(self.x + dx);
            self:setY(self.y + dy);
            self:bringToTop();
        end
    end
end

-- mouse click
function S4_Computer_Main:onMouseDown(x, y)
    if self:isMouseOver(x, y) and self.StartBtn then
        if self.StartBtnAction then
            self.StartBtnAction = false
            self.StartPanel:close()
        else
            self.StartBtnAction = true
            local FontH = getTextManager():getFontFromEnum(self.UI_Font):getLineHeight()
            local StartW = math.max(self:getWidth() / 4, FontH)
            local StartH = (self:getHeight() / 2)
            local StartY = self.TaskBarY - StartH
            self.StartPanel = S4_Computer_Start:new(self, 1, StartY, StartW, StartH)
            self.StartPanel.FontH = FontH
            self.StartPanel:initialise()
            self:addChild(self.StartPanel)
        end
    end

    -- movement related
    if not self.moveWithMouse then
        return true;
    end
    if not self:getIsVisible() then
        return;
    end
    if not self:isMouseOver() then
        return -- this happens with setCapture(true)
    end

    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function S4_Computer_Main:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        -- Turn off the computer
        self:close()
    end
end

function S4_Computer_Main:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function S4_Computer_Main:close()
    if self.BlackJack then
        self.BlackJack:close()
    end
    S4_Computer_Main.instance = nil
    self.UICheck = false
    ISPanel.close(self)
    self:removeFromUIManager()
end

function S4_Computer_Main:BtnRender()
    if self.image ~= nil then
        local alpha = self.textureColor.a
        if self.blinkImage then
            if not self.blinkImageAlpha then
                self.blinkImageAlpha = 1
                self.blinkImageAlphaIncrease = false
            end

            if not self.blinkImageAlphaIncrease then
                self.blinkImageAlpha = self.blinkImageAlpha - 0.1 * (UIManager.getMillisSinceLastRender() / 33.3)
                if self.blinkImageAlpha < 0 then
                    self.blinkImageAlpha = 0
                    self.blinkImageAlphaIncrease = true
                end
            else
                self.blinkImageAlpha = self.blinkImageAlpha + 0.1 * (UIManager.getMillisSinceLastRender() / 33.3)
                if self.blinkImageAlpha > 1 then
                    self.blinkImageAlpha = 1
                    self.blinkImageAlphaIncrease = false
                end
            end

            alpha = self.blinkImageAlpha
        end
        if self.forcedWidthImage and self.forcedHeightImage then
            self:drawTextureScaledAspect(self.image, (self.width / 2) - (self.forcedWidthImage / 2), 2,
                self.forcedWidthImage, self.forcedHeightImage, alpha, self.textureColor.r, self.textureColor.g,
                self.textureColor.b)
        elseif self.image:getWidthOrig() <= self.width and self.image:getHeightOrig() <= self.height then
            self:drawTexture(self.image, (self.width / 2) - (self.image:getWidthOrig() / 2),
                (self.height / 2) - (self.image:getHeightOrig() / 2), alpha, self.textureColor.r, self.textureColor.g,
                self.textureColor.b)
        else
            self:drawTextureScaledAspect(self.image, 0, 0, self.width, self.height, alpha, self.textureColor.r,
                self.textureColor.g, self.textureColor.b)
        end
    end
    local textW = getTextManager():MeasureStringX(self.font, self.title)
    local height = getTextManager():MeasureStringY(self.font, self.title)
    local x = self.width / 2 - textW / 2
    if self.isJoypad and self.joypadTexture then
        local texWH = self.joypadTextureWH
        local texX = x - 5 - texWH
        local texY = self.height / 2 - 20 / 2
        texX = math.max(5, texX)
        x = texX + texWH + 5
        self:drawTextureScaled(self.joypadTexture, texX, texY, texWH, texWH, 1, 1, 1, 1)
    end
    if self.enable then
        self:drawText(self.title, x, 2 + self.forcedHeightImage + 8, self.textColor.r, self.textColor.g,
            self.textColor.b, self.textColor.a, self.font)
    elseif self.displayBackground and not self.isJoypad and self.joypadFocused then
        self:drawText(self.title, x, 2 + self.forcedHeightImage + 8, 0, 0, 0, 1, self.font)
    else
        self:drawText(self.title, x, 2 + self.forcedHeightImage + 8, 0.3, 0.3, 0.3, 1, self.font)
    end
    if self.overlayText then
        self:drawTextRight(self.overlayText, self.width, self.height - 10, 1, 1, 1, 0.5, UIFont.Small)
    end
    if self.IconName then
        if getTextManager():MeasureStringX(UIFont.Small, self.IconName) >= self.forcedWidthImage + 68 then
            -- Text output after separating text
            local TextTable = S4_UI.SplitText(self.IconName, 110)
            for TextNum, lineText in ipairs(TextTable) do -- Result output
                local NameX = self.width / 2 - getTextManager():MeasureStringX(self.font, lineText) / 2
                local lineTextY = 2 + self.forcedHeightImage + 8
                if TextNum == 2 then
                    lineTextY = lineTextY + S4_UI.FH_S
                end
                self:drawText(lineText, NameX, lineTextY, 1, 1, 1, self.textColor.a, self.font)
            end
        else
            local NameX = self.width / 2 - getTextManager():MeasureStringX(self.font, self.IconName) / 2
            self:drawText(self.IconName, NameX, 2 + self.forcedHeightImage + 8, 1, 1, 1, self.textColor.a, self.font)
        end
    end

    if (self.mouseOver and self.onmouseover) then
        self.onmouseover(self.target, self, x, y)
    end

    if self.textureOverride then
        self:drawTexture(self.textureOverride, (self.width / 2) - (self.textureOverride:getWidth() / 2),
            (self.height / 2) - (self.textureOverride:getHeight() / 2), 1, 1, 1, 1)
    end

    if false and self.mouseOver and self.tooltip then
        self:drawRect(self:getMouseX() + 23, self:getMouseY() + 23,
            getTextManager():MeasureStringX(UIFont.Small, self.tooltip) + 24, 32 + 24, 0.7, 0.05, 0.05, 0.05)
        self:drawRectBorder(self:getMouseX() + 23, self:getMouseY() + 23,
            getTextManager():MeasureStringX(UIFont.Small, self.tooltip) + 24, 32 + 24, 0.5, 0.9, 0.9, 1)
        self:drawText(self.tooltip, self:getMouseX() + 23 + 12, self:getMouseY() + 23 + 12, 1, 1, 1, 1)
    end
end
