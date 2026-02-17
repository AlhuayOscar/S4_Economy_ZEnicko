S4_Booting_MsgBox = ISPanel:derive("S4_Booting_MsgBox")

function S4_Booting_MsgBox:new(ComUI)
    if not width or not height then
        width, height = 420, 380
    end
    local x = (ComUI:getWidth()/2) - (width/2)
    local y = ((ComUI:getHeight() - (S4_UI.FH_M + 8)) / 2) - (height / 2)

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=189/255, g=190/255, b=189/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    -- o.moveWithMouse = true
    o.ComUI = ComUI -- Save computer UI reference (parent UI)
    o.player = ComUI.player
    o.NewMoveWithMouse = true
    -- Save initial coordinates
    o.startX = x
    o.startY = y
    -- Movement status flags and variables
    o.moving = false
    return o
end

function S4_Booting_MsgBox:initialise()
    ISPanel.initialise(self)
    
end

function S4_Booting_MsgBox:createChildren()
    ISPanel.createChildren(self)

    local TitleHeight = S4_UI.FH_S + 6

    local X = 30
    local Y = TitleHeight + 30

    local Text = "Error. Not Message"
    if self.MsgText then
        Text = self.MsgText
    end

    self.MsgLabel = ISLabel:new(X, Y, S4_UI.FH_S, Text, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel)
    Y = Y + self.MsgLabel:getHeight() + 30

    local BtnX = (self.MsgLabel:getWidth() + 60) - 110
    self.OKBtn = ISButton:new(BtnX, Y, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Booting_MsgBox.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)

    self:FixUISize()
end

function S4_Booting_MsgBox:render()
    ISPanel.render(self)
    local TitleHeight = S4_UI.FH_S + 2
    -- title
    self:drawRect(2, 2, self:getWidth() - 4, TitleHeight, 1, 0/255, 0/255, 120/255)
    self:drawRect(1, TitleHeight + 3, self:getWidth() - 2, 1, 0.7, 0, 0, 0)
    self:drawRect(1, TitleHeight + 4, self:getWidth() - 2, 5, 1, 169/255, 170/255, 169/255)
    self:drawText(self.TitleName, 10, 2, 1, 1, 1, 1, UIFont.Small)

    -- close button
    if self.C_Btn then
        self:drawRect(self:getWidth() - S4_UI.FH_S - 2, 4, S4_UI.FH_S - 2, S4_UI.FH_S - 2, 1, 169/255, 170/255, 169/255)
    else
        self:drawRect(self:getWidth() - S4_UI.FH_S - 2, 4, S4_UI.FH_S - 2, S4_UI.FH_S - 2, 1, 189/255, 190/255, 189/255)
    end
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Close.png"), self:getWidth() - S4_UI.FH_S - 2, 4, S4_UI.FH_S - 2, S4_UI.FH_S - 2, 1)

end

function S4_Booting_MsgBox:BtnClick(Button)
    local internal = Button.internal
    if internal == "Ok" then
        self:close()
    end
end

-- window control function
function S4_Booting_MsgBox:FixUISize()
    local MX = self.MsgLabel:getWidth() + 60
    local MY = self.OKBtn:getBottom() + 10
    self:setWidth(MX)
    self:setHeight(MY)
    local VX = (self.ComUI:getWidth()/2) - (MX/2)
    local VY = (self.ComUI:getHeight()/2) - (MY/2)
    self:setX(VX)
    self.startX = VX
    self:setY(VY)
    self.startY = VY
end

-- Functions related to moving and exiting UI
--
-- When mouse is pressed (start of drag)
function S4_Booting_MsgBox:onMouseDown(x, y)
    if self.NewMoveWithMouse then
        self.moving = true
        -- Stores the relative offset of the mouse and panel at the start of the drag
        self.dragOffsetX = x
        self.dragOffsetY = y
        self:bringToTop()
    end
    if self:isMouseOver(x, y) and self.C_Btn then
        self:close()
    end
end

-- When moving the mouse (while dragging)
function S4_Booting_MsgBox:onMouseMove(dx, dy)
    if self.NewMoveWithMouse and self.moving then
        self.startX = self.startX + dx
        self.startY = self.startY + dy
        -- Location settings
        if self.startX < 0 then 
            self.startX = 0 
        elseif (self.startX + self:getWidth()) > self.ComUI:getWidth() then 
            self.startX = self.ComUI:getWidth() - self:getWidth()
        end

        if self.startY < 0 then 
            self.startY = 0 
        elseif (self.startY + self:getHeight()) > self.ComUI:getHeight() then 
            self.startY = self.ComUI:getHeight() - self:getHeight()
        end

        self:setX(self.startX)
        self:setY(self.startY)
    end
    local mouseX, mouseY = self:getMouseX(), self:getMouseY()
    local C_BtnX = self:getWidth() - (S4_UI.FH_S - 2)
    local C_BtnXend = self:getWidth()
    self.C_Btn = false
    if mouseX >= C_BtnX and mouseX <= C_BtnXend then
        if mouseY >= 4 and mouseY <= 4 + (S4_UI.FH_S - 2) then
            self.C_Btn = true
        end
    end
end

-- When the mouse is released (drag ends)
function S4_Booting_MsgBox:onMouseUp(x, y)
    if self.NewMoveWithMouse then
        self.moving = false
    end
end

function S4_Booting_MsgBox:onMouseUpOutside(x, y)
    self.moving = false
end

function S4_Booting_MsgBox:close()
    -- self.ComUI.MyComUI = nil
    if self.ComUI then
        self.ComUI[self.PageType] = nil
    end
    if self.ComUI.ErrorUI and self.PageType ~= "Error" then
        self.ComUI.ErrorUI:close()
        self.ComUI.ErrorUI = nil
    end
    self:setVisible(false)
    self:removeFromUIManager()
end
