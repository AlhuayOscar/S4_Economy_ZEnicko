require "ISUI/ISUIElement"
S4_System = ISUIElement:derive("S4_System")

local S4_Computer = {
    MyCom = S4_Sys_Mycom,
    Network = S4_Sys_Network,
    CardReader = S4_Sys_CardReader,
    Trash = S4_Sys_CardPassword, -- For testing
    MsgBox = S4_Sys_MsgBox,
    CardisPassword = S4_Sys_CardPassword,
    Settings = S4_Sys_Settings,
    UserSetting = S4_Sys_UserSettings,
    AdminMsgBox = S4_Sys_AdminMsgBox,
    BankMsgBox = S4_Sys_BankMsgBox,
}

function S4_System:initialise()
	ISUIElement.initialise(self)
    -- self.TaskY = self.ComUI.TaskBarY
    -- self.TitleHeight = S4_UI.FH_S + 6

end


function S4_System:createChildren()
    local PageClass = S4_Computer[self.PageType]
    if PageClass then
        local Px = 5
        local Py = S4_UI.FH_S + 12
        local Pw = self:getWidth() - 10
        local Ph = self:getHeight() - Py - 5
        self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
        self.MainPage:initialise()
        self:addChild(self.MainPage)
    end

end

function S4_System:render()
    local TitleHeight = S4_UI.FH_S + 2
    -- title
    self:drawRect(2, 2, self:getWidth() - 4, TitleHeight, 1, 0/255, 0/255, 120/255)
    self:drawRect(1, TitleHeight + 3, self:getWidth() - 2, 1, 0.7, 0, 0, 0)
    self:drawRect(1, TitleHeight + 4, self:getWidth() - 2, 5, 1, 169/255, 170/255, 169/255)
    self:drawText(self.TitleName, 10, 2, 1, 1, 1, 1, UIFont.Small)

    -- close button
    local BtnX = self:getWidth() - S4_UI.FH_S - 2
    local BtnY = 4
    local BtnSize = S4_UI.FH_S - 2
    if self.C_Btn then
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 169/255, 170/255, 169/255)
    else
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 189/255, 190/255, 189/255)
    end
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Close.png"), BtnX, BtnY, BtnSize, BtnSize, 1)
    BtnX = BtnX - BtnSize - 5
    self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 189/255, 190/255, 189/255)
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Large.png"), BtnX, BtnY, BtnSize, BtnSize, 1)
    BtnX = BtnX - BtnSize - 5
    if self.M_Btn then
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 169/255, 170/255, 169/255)
    else
        self:drawRect(BtnX, BtnY, BtnSize, BtnSize, 1, 189/255, 190/255, 189/255)
    end
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Minimize.png"), BtnX, BtnY, BtnSize, BtnSize, 1)

    -- icon
    if self.IconImg then
        local IconX = 40
        local IconY = S4_UI.FH_S + 36
        local IconSize = 64
        self:drawTextureScaled(self.IconImg, IconX, IconY, IconSize, IconSize, 1)
        -- self:drawTextureScaled(getTexture("media/textures/S4_Icon/Icon_64_MyCom.png"), IconX, IconY, IconSize, IconSize, 1)
    end
end

function S4_System:noBackground()
	self.background = false
end

function S4_System:prerender()
	if self.background then
		self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	end
end

-- window control function
function S4_System:FixUISize(MX, MY)
    -- if self.TitleName then
    --     local TitleW = getTextManager():MeasureStringX(UIFont.Small, self.TitleName)
    --     MX = math.max(MX, TitleW + (S4_UI.FH_S*4))
    -- end
    self.MainPage:setWidth(MX)
    self.MainPage:setHeight(MY)

    local Fw = 10 + MX
    local Fh = (S4_UI.FH_S + 17) + MY
    self:setWidth(Fw)
    self:setHeight(Fh)
    local Nh = self.ComUI:getHeight() - self.Ny
    local VX = ((self.ComUI:getWidth() - 2)/2) - (Fw/2)
    local VY = ((self.ComUI:getHeight() - Nh)/2) - (Fh/2)
    self:setX(VX)
    self.startX = VX
    self:setY(VY)
    self.startY = VY
end

function S4_System:ReloadFixUISize(MX, MY)
    self.MainPage:setWidth(MX)
    self.MainPage:setHeight(MY)
end

-- reload function
function S4_System:ReloadUI()
    self.MainPage:close()
    local PageClass = S4_Computer[self.PageType]
    if PageClass then
        local Px = 5
        local Py = S4_UI.FH_S + 12
        local Pw = self:getWidth() - 10
        local Ph = self:getHeight() - Py - 5
        self.MainPage = PageClass:new(self, Px, Py, Pw, Ph)
        self.MainPage:initialise()
        self.MainPage.Reload = true
        self:addChild(self.MainPage)
    end
end

-- Create/Remove S4_System
function S4_System:new(ComUI, x, y)
	local o = {}
    if not width or not height then
        width, height = 420, 380
    end
    if not x or not y then
        x = (ComUI:getWidth()/2) - (width/2)
        y = ((ComUI:getHeight() - (S4_UI.FH_M + 8)) / 2) - (height / 2)
    end
	--o.data = {}
	o = ISUIElement:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
	o.x = x
	o.y = y
	o.background = true
	o.backgroundColor = {r=169/255, g=170/255, b=169/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
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

function S4_System:close()
    self.ComUI:RemoveTaskBar(self)
    if self.ComUI then
        self.ComUI[self.PageType] = nil
    end
	self:setVisible(false)
    self:removeFromUIManager()
end

-- S4_System movement related code
function S4_System:onMouseUp(x, y)
    if self.NewMoveWithMouse then
        self.moving = false
    end
end

function S4_System:onMouseUpOutside(x, y)
    self.moving = false
end

function S4_System:onMouseDown(x, y)
    if self.NewMoveWithMouse then
        self.moving = true
        -- Stores the relative offset of the mouse and panel at the start of the drag
        self.dragOffsetX = x
        self.dragOffsetY = y
        self:bringToTop()
        self.ComUI.TopApp = self
    end

    if not self:isMouseOver(x, y) then return end
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

function S4_System:onMouseMoveOutside(dx, dy)
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

function S4_System:onMouseMove(dx, dy)
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
