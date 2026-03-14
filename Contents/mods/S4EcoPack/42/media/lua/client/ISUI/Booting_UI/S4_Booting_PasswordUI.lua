S4_Booting_PasswordUI = ISPanel:derive("S4_Booting_PasswordUI")

function S4_Booting_PasswordUI:new(ComUI)
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

function S4_Booting_PasswordUI:initialise()
    ISPanel.initialise(self)
    
end

function S4_Booting_PasswordUI:createChildren()
    ISPanel.createChildren(self)

    local TitleHeight = S4_UI.FH_S + 6

    local X = 30
    local Y = TitleHeight + 20

    self.MainLabel = ISLabel:new(X, Y, S4_UI.FH_S, "Type a user name and password to log on to Zomdows.", 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MainLabel)
    Y = Y + self.MainLabel:getHeight() + 10
    local EntryWidth = self.MainLabel:getWidth()
    local BtnWidth = (self.MainLabel:getWidth()- 10) / 2 

    self.AddressLabel = ISLabel:new(X, Y, S4_UI.FH_S, getText("IGUI_S4_Label_Username"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.AddressLabel)
    Y = Y + self.AddressLabel:getHeight()

    self.AddressEntry = ISTextEntryBox:new("Administrator", X, Y, EntryWidth, S4_UI.FH_S)
    self.AddressEntry.font = UIFont.Small
    self.AddressEntry.backgroundColor = {r=1, g=1, b=1, a=1}
    self.AddressEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.AddressEntry:initialise()
    self.AddressEntry:instantiate()
    self.AddressEntry:setTextRGBA(0, 0, 0, 1)
    self:addChild(self.AddressEntry)
    Y = Y + self.AddressEntry:getHeight() + 5

    self.PasswordLabel = ISLabel:new(X, Y, S4_UI.FH_S, getText("IGUI_S4_Label_Password"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.PasswordLabel)
    Y = Y + self.PasswordLabel:getHeight()

    self.PasswordEntry = ISTextEntryBox:new("", X, Y, EntryWidth, S4_UI.FH_S)
    self.PasswordEntry.font = UIFont.Small
    self.PasswordEntry.backgroundColor = {r=1, g=1, b=1, a=1}
    self.PasswordEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.PasswordEntry:initialise()
    self.PasswordEntry:instantiate()
    self.PasswordEntry:setTextRGBA(0, 0, 0, 1)
    self:addChild(self.PasswordEntry)
    Y = Y + self.PasswordEntry:getHeight() + 5

    self.HideBox = ISTickBox:new(X, Y, S4_UI.FH_S, S4_UI.FH_S, "", self)
    self.HideBox.borderColor = {r=0, g=0, b=0, a=1}
    self.HideBox.choicesColor = {r=0, g=0, b=0, a=1}
    self.HideBox:initialise()
    self.HideBox:instantiate()
    self.HideBox:addOption(getText("IGUI_S4_Hide_Password"))
    self:addChild(self.HideBox)
    self.HideBox.joypadIndex = 1
    self.HideBox:forceClick() 
    Y = Y + self.HideBox:getHeight() + 10

    self.OKBtn = ISButton:new(X, Y, BtnWidth, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Booting_PasswordUI.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)

    self.CancelBtn = ISButton:new(X + self.OKBtn:getWidth() + 10, Y, BtnWidth, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_Cancel"), self, S4_Booting_PasswordUI.BtnClick)
    self.CancelBtn.internal = "Cancel"
    self.CancelBtn.textColor = {r=0, g=0, b=0, a=1}
    self.CancelBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.CancelBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.CancelBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.CancelBtn:initialise()
    self:addChild(self.CancelBtn)

    self:FixUISize()
end

function S4_Booting_PasswordUI:render()
    ISPanel.render(self)
    local TitleHeight = S4_UI.FH_S + 2
    -- title
    self:drawRect(2, 2, self:getWidth() - 4, TitleHeight, 1, 0/255, 0/255, 120/255)
    self:drawRect(1, TitleHeight + 3, self:getWidth() - 2, 1, 0.7, 0, 0, 0)
    self:drawRect(1, TitleHeight + 4, self:getWidth() - 2, 5, 1, 169/255, 170/255, 169/255)
    self:drawText(self.TitleName, 10, 2, 1, 1, 1, 1, UIFont.Small)

    if self.HideBox:isSelected(1) then
        if self.PasswordEntry:getText() ~= "" then
            local str = self.PasswordEntry:getText()
            local maskedStr = string.rep("*", #str)
            self:drawRect(self.PasswordEntry:getX(), self.PasswordEntry:getY(), self.PasswordEntry:getWidth(), self.PasswordEntry:getHeight(), 1, 1, 1, 1)
            self:drawRectBorder(self.PasswordEntry:getX(), self.PasswordEntry:getY(), self.PasswordEntry:getWidth(), self.PasswordEntry:getHeight(), 1, 0, 0, 0)
            self:drawText(maskedStr, self.PasswordEntry:getX()+5, self.PasswordEntry:getY() + 2, 0, 0, 0, 1, UIFont.Small)
        end
    end

    -- close button
    if self.C_Btn then
        self:drawRect(self:getWidth() - S4_UI.FH_S - 2, 4, S4_UI.FH_S - 2, S4_UI.FH_S - 2, 1, 169/255, 170/255, 169/255)
    else
        self:drawRect(self:getWidth() - S4_UI.FH_S - 2, 4, S4_UI.FH_S - 2, S4_UI.FH_S - 2, 1, 189/255, 190/255, 189/255)
    end
    self:drawTextureScaled(getTexture("media/textures/S4_Btn/Btn_Close.png"), self:getWidth() - S4_UI.FH_S - 2, 4, S4_UI.FH_S - 2, S4_UI.FH_S - 2, 1)

end

function S4_Booting_PasswordUI:BtnClick(Button)
    local internal = Button.internal
    if self.AddressEntry:getText() == "Administrator" then
        if internal == "Ok" then
            local FixPassword = S4_UI.RemoveTextValid(self.PasswordEntry:getText())
            if FixPassword ~= "" then
                if FixPassword == self.ComUI.ComPassword then
                    local x, y = self.ComUI:getX(), self.ComUI:getY()
                    local OpenUI = S4_Computer_Main:show(self.player, self.ComUI.ComObj, x, y)
                    self.ComUI:close()
                else -- Password does not match
                    self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), getText("IGUI_S4_Msg_Password_Fail"))
                end
            else -- no spaces
                self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), getText("IGUI_S4_Msg_Password_None"))
            end
        end
    else -- ID does not match
        self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), getText("IGUI_S4_Msg_UserName_Fail"))
    end
    if internal == "Cancel" then
        self.ComUI:close()
    end
end

-- window control function
function S4_Booting_PasswordUI:FixUISize()
    local MX = self.MainLabel:getWidth() + 60
    local MY = self.OKBtn:getBottom() + 20
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
function S4_Booting_PasswordUI:onMouseDown(x, y)
    if self.NewMoveWithMouse then
        self.moving = true
        -- Stores the relative offset of the mouse and panel at the start of the drag
        self.dragOffsetX = x
        self.dragOffsetY = y
        self:bringToTop()
    end
    if self:isMouseOver(x, y) and self.C_Btn then
        self.ComUI:close()
    end
end

-- When moving the mouse (while dragging)
function S4_Booting_PasswordUI:onMouseMove(dx, dy)
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
function S4_Booting_PasswordUI:onMouseUp(x, y)
    if self.NewMoveWithMouse then
        self.moving = false
    end
end

function S4_Booting_PasswordUI:onMouseUpOutside(x, y)
    self.moving = false
end

function S4_Booting_PasswordUI:close()
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
