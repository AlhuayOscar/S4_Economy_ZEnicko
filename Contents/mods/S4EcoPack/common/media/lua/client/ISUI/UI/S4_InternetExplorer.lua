require "ISUI/ISUIElement"
S4_InternetExplorer = ISUIElement:derive("S4_InternetExplorer")

local S4_IE_Class = {
    SNetwork = "S4_IE_SNetwork",
    IE = "S4_IE_SNetwork",
    News = "S4_IE_KnoxNews",
    GoodShop = "S4_IE_GoodShop",
    VehicleShop = "S4_IE_VehicleShop",
    GoodShopAdmin = "S4_IE_GoodShopAdmin",
    BlackJack = "S4_IE_BlackJack",
    ZomBank = "S4_IE_ZomBank",
    Jobs = "S4_IE_Jobs",
    Twitboid = "S4_IE_Twitboid",
    MyDoc = "S4_IE_MyDoc",
    Crimeboid = "S4_IE_Crimeboid",
    Zeddit = "S4_IE_Zeddit",
    KarmaAdmin = "S4_IE_KarmaAdmin",
    Logistics = "S4_IE_Logistics",
    Taxes = "S4_IE_Taxes",
    Community = "S4_IE_Community",
    FarmWatch = "S4_IE_FarmWatch",
    Recon = "S4_IE_Recon",
    Recover = "S4_IE_Recover",
    Repair = "S4_IE_Repair",
    Weather = "S4_IE_Weather",
    BBS = "S4_IE_BBS",
    Mail = "S4_IE_Mail",
    MNS = "S4_IE_MNS"
}

function S4_InternetExplorer:initialise()
    ISUIElement.initialise(self)
end

function S4_InternetExplorer:createChildren()

    local className = S4_IE_Class[self.PageType]
    local PageClass = _G[className]
    if not PageClass and self.PageType == "News" then
        PageClass = S4_IE_KnoxNews
    end
    local Px = 5
    local Py = (S4_UI.FH_S * 2) + 17
    local Pw = self:getWidth() - 10
    local Ph = self:getHeight() - Py - 5
    if self.ComUI.NetContract then
        if PageClass then
            self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
            self.MainPage:initialise()
            self:addChild(self.MainPage)
        end
    else
        if PageClass then
            if self.ComUI.SatelliteInstall and self.PageType == "IE" then
                self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
                self.MainPage:initialise()
                self:addChild(self.MainPage)
            elseif self.PageType == "News" then
                self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
                self.MainPage:initialise()
                self:addChild(self.MainPage)
            elseif self.PageType == "GoodShopAdmin" then
                self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
                self.MainPage:initialise()
                self:addChild(self.MainPage)
            else
                self.MainPage = S4_IE_Error:new(self, Px, Py, Pw, Ph)
                self.MainPage:initialise()
                self:addChild(self.MainPage)
            end
        end
    end
end

function S4_InternetExplorer:render()
    ISPanel.render(self)
    local TitleHeight = S4_UI.FH_S + 2
    local TitleBarH = (S4_UI.FH_S * 2) + 12
    -- title background
    self:drawRect(1, 0, self:getWidth() - 2, TitleBarH, 1, 169 / 255, 170 / 255, 169 / 255)
    self:drawRect(1, TitleBarH + 1, self:getWidth() - 2, 1, 0.7, 0, 0, 0)
    -- title
    self:drawRect(2, 2, self:getWidth() - 4, TitleHeight, 1, 0 / 255, 0 / 255, 120 / 255)
    self:drawText(self.TitleName, 10, 2, 1, 1, 1, 1, UIFont.Small)
    -- Address bar Address
    local AddressW = getTextManager():MeasureStringX(UIFont.Small, "Address")
    local AddressH = TitleHeight + 6
    self:drawText("Address", 6, AddressH + 1, 0, 0, 0, 1, UIFont.Small)
    -- Address bar Link
    local LinkW = getTextManager():MeasureStringX(UIFont.Small, "Link")
    local LinkX = self:getWidth() - LinkW - 6
    self:drawText("Link", LinkX, AddressH + 1, 0, 0, 0, 1, UIFont.Small)
    -- address bar
    local AddressX = AddressW + 18
    local AddressWidth = self:getWidth() - LinkW - AddressX - 18
    self:drawRect(AddressX, AddressH, AddressWidth, TitleHeight, 1, 1, 1, 1)
    self:drawRectBorder(AddressX, AddressH, AddressWidth, TitleHeight, 1, 0, 0, 0)
    local AddressText = S4_UI.TextLimit("http://www.hind.com/", AddressWidth, UIFont.Small)
    if self.AddressText then
        AddressText = S4_UI.TextLimit(self.AddressText, AddressWidth, UIFont.Small)
    end
    self:drawText(AddressText, AddressX + 4, AddressH + 1, 0, 0, 0, 1, UIFont.Small)
    -- Address bar division
    self:drawRect(AddressW + 10, AddressH, 2, TitleHeight, 1, 199 / 255, 200 / 255, 199 / 255)
    self:drawRect(LinkX - 6, AddressH, 2, TitleHeight, 1, 199 / 255, 200 / 255, 199 / 255)

    -- close/resize/minimize buttons
    local BtnX = self:getWidth() - S4_UI.FH_S - 2
    local BtnY = 4
    local BtnSize = S4_UI.FH_S - 2
    if self.C_Btn then
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 169 / 255, 170 / 255, 169 / 255)
    else
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 189 / 255, 190 / 255, 189 / 255)
    end
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Close.png"), BtnX, BtnY, BtnSize, BtnSize, 1)
    BtnX = BtnX - BtnSize - 5
    self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 189 / 255, 190 / 255, 189 / 255)
    if self.UIFullSize then
        self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Small.png"), BtnX, BtnY, BtnSize, BtnSize, 1)
    else
        self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Large.png"), BtnX, BtnY, BtnSize, BtnSize, 1)
    end
    BtnX = BtnX - BtnSize - 5
    if self.M_Btn then
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 169 / 255, 170 / 255, 169 / 255)
    else
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 189 / 255, 190 / 255, 189 / 255)
    end
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Minimize.png"), BtnX, BtnY, BtnSize, BtnSize, 1)
end

function S4_InternetExplorer:noBackground()
    self.background = false
end

function S4_InternetExplorer:prerender()
    if self.background then
        self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r,
            self.backgroundColor.g, self.backgroundColor.b);
        self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r,
            self.borderColor.g, self.borderColor.b);
    end
end

-- window control function
function S4_InternetExplorer:FixUISize(MX, MY)
    self.MainPage:setWidth(MX)
    self.MainPage:setHeight(MY)

    local Fw = 10 + MX
    local Fh = (S4_UI.FH_S * 2) + 22 + MY
    -- if Fw > self.ComUI:getWidth() - 2 then
    --     print("Test Fw")
    -- end
    -- if Fh > self.Ny - 1 then
    --     print("Test FH")
    -- end
    self:setWidth(Fw)
    self:setHeight(Fh)
    local Nh = self.ComUI:getHeight() - self.Ny - 1
    local VX = ((self.ComUI:getWidth()) / 2) - (Fw / 2)
    local VY = ((self.ComUI:getHeight() - Nh) / 2) - (Fh / 2)
    self:setX(VX)
    self.startX = VX
    self:setY(VY)
    self.startY = VY
end

function S4_InternetExplorer:ReloadFixUISize(MX, MY)
    self.MainPage:setWidth(MX)
    self.MainPage:setHeight(MY)
end

-- reload function
function S4_InternetExplorer:ReloadUI()
    if self.MainPage then
        self.MainPage:close()
    end

    local className = S4_IE_Class[self.PageType]
    local PageClass = _G[className]
    if not PageClass and self.PageType == "News" then
        PageClass = S4_IE_KnoxNews
    end
    if PageClass then
        local Px = 5
        local Py = (S4_UI.FH_S * 2) + 17
        local Pw = self:getWidth() - 10
        local Ph = self:getHeight() - Py - 5
        self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
        self.MainPage:initialise()
        self.MainPage.Reload = true
        self:addChild(self.MainPage)
    end
end

-- Create/Remove S4_IE
function S4_InternetExplorer:new(ComUI, x, y, width, height)
    local o = {}
    if not width or not height then
        width, height = 800, 600
    end
    if not x or not y then
        x = (ComUI:getWidth() / 2) - (width / 2)
        y = ((ComUI:getHeight() - (S4_UI.FH_M + 8)) / 2) - (height / 2)
    end
    -- o.data = {}
    o = ISUIElement:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.background = true
    o.backgroundColor = {
        r = 169 / 255,
        g = 170 / 255,
        b = 169 / 255,
        a = 1
    }
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    o.width = width
    o.height = height
    o.ComUI = ComUI
    o.player = ComUI.player
    o.anchorLeft = true
    o.anchorRight = false
    o.anchorTop = true
    o.anchorBottom = false
    o.moveWithMouse = false
    -- Move function related
    o.NewMoveWithMouse = true
    o.startX = x
    o.startY = y
    o.Ny = ComUI.TaskBarY
    o.moving = false
    return o
end

function S4_InternetExplorer:close()
    if self.PageType == "BlackJack" then
        if self.ComUI.BlackJackTotal and self.ComUI.BlackJackTotal ~= 0 and self.ComUI.CardNumber then
            local LogTime = S4_Utils.getLogTime()
            if self.ComUI.BlackJackTotal < 0 then
                sendClientCommand("S4ED", "AddCardLog",
                    {self.ComUI.CardNumber, LogTime, "Withdraw", math.abs(self.ComUI.BlackJackTotal),
                     self.player:getUsername(), "BlackJack"})
            else
                sendClientCommand("S4ED", "AddCardLog", {self.ComUI.CardNumber, LogTime, "Deposit",
                                                         self.ComUI.BlackJackTotal, "BlackJack",
                                                         self.player:getUsername()})
            end
            self.ComUI.BlackJackTotal = 0
        end
    end
    self.ComUI:RemoveTaskBar(self)
    if self.ComUI then
        self.ComUI[self.PageType] = nil
    end
    self:setVisible(false)
    self:removeFromUIManager()
end

-- S4_IE Movement related code
function S4_InternetExplorer:onMouseUp(x, y)
    if self.NewMoveWithMouse then
        self.moving = false
    end
end

function S4_InternetExplorer:onMouseUpOutside(x, y)
    self.moving = false
end

function S4_InternetExplorer:onMouseDown(x, y)
    if self.NewMoveWithMouse then
        self.moving = true
        -- Stores the relative offset of the mouse and panel at the start of the drag
        self.dragOffsetX = x
        self.dragOffsetY = y
        self:bringToTop()
        self.ComUI.TopApp = self
    end

    if not self:isMouseOver(x, y) then
        return
    end
    if self.C_Btn then
        self.moving = false
        self.M_Btn = false
        self:close()
    elseif self:getMouseX() >= self:getWidth() - (S4_UI.FH_S - 2) and self:getMouseX() <= self:getWidth() then
        if self:getMouseY() >= 4 and self:getMouseY() <= 4 + (S4_UI.FH_S - 2) then
            self.moving = false
            self.M_Btn = false
            self:close()
        end
    elseif self.M_Btn then
        self.moving = false
        self.M_Btn = false
        self:setVisible(false)
        if self.ComUI.TopApp == self then
            self.ComUI.TopApp = nil
        end
    end
end

function S4_InternetExplorer:onMouseMoveOutside(dx, dy)
    if self.NewMoveWithMouse and self.moving then
        self.mouseOver = false

        self.startX = self.startX + dx
        self.startY = self.startY + dy
        -- Location settings
        if self.startX < 1 then
            self.startX = 1
        elseif (self.startX + self:getWidth()) > self.ComUI:getWidth() - 1 then
            self.startX = self.ComUI:getWidth() - self:getWidth() - 1
        end

        if self.startY < 1 then
            self.startY = 1
        elseif (self.startY + self:getHeight()) > self.Ny then
            self.startY = self.Ny - self:getHeight()
        end

        self:setX(self.startX)
        self:setY(self.startY)
    end
end

function S4_InternetExplorer:onMouseMove(dx, dy)
    if self.NewMoveWithMouse and self.moving then
        self.startX = self.startX + dx
        self.startY = self.startY + dy
        -- Location settings
        if self.startX < 1 then
            self.startX = 1
        elseif (self.startX + self:getWidth()) > self.ComUI:getWidth() - 1 then
            self.startX = self.ComUI:getWidth() - self:getWidth() - 1
        end

        if self.startY < 1 then
            self.startY = 1
        elseif (self.startY + self:getHeight()) > self.Ny then
            self.startY = self.Ny - self:getHeight()
        end

        self:setX(self.startX)
        self:setY(self.startY)
    end
    local mouseX, mouseY = self:getMouseX(), self:getMouseY()
    local BtnSize = S4_UI.FH_S - 2
    local C_BtnX = self:getWidth() - BtnSize - 2
    local C_BtnXend = self:getWidth() - 2
    local M_BtnX = C_BtnX - (BtnSize * 2) - 13
    local M_BtnXend = C_BtnX - BtnSize - 13
    self.C_Btn = false
    self.M_Btn = false
    if mouseY >= 4 and mouseY <= 4 + BtnSize then
        if mouseX >= C_BtnX and mouseX <= C_BtnXend then
            self.C_Btn = true
        elseif mouseX >= M_BtnX and mouseX <= M_BtnXend then
            self.M_Btn = true
        end
    end
end
