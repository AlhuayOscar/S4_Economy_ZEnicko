S4_Sys_CardPassword = ISPanel:derive("S4_Sys_CardPassword")

function S4_Sys_CardPassword:new(SysUI, Px, Py, Pw, Ph)
    local o = ISPanel:new(Px, Py, Pw, Ph)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=189/255, g=190/255, b=189/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
    o.SysUI = SysUI -- Sys UI Reference (Parent UI)
    o.ComUI = SysUI.ComUI -- Com UI Reference
    o.player = SysUI.player
    o.Moving = true
    return o
end

function S4_Sys_CardPassword:initialise()
    ISPanel.initialise(self)
    
end

function S4_Sys_CardPassword:createChildren()
    ISPanel.createChildren(self)

    local Tx = 40
    local Ty = 20
    if self.SysUI.IconImg then
        Tx = Tx + 40 + 64
    end
    local TextMaxX = 0
    -- card number
    local CardNumberText = getText("IGUI_S4_CardReader_UnInsert")
    if self.ComUI.CardNumber then
        CardNumberText = self.ComUI.CardNumber
    end
    CardNumberText = getText("IGUI_S4_Label_CardNumber") .. CardNumberText
    self.CardNumberLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, CardNumberText, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.CardNumberLabel)
    TextMaxX = math.max(TextMaxX, self.CardNumberLabel:getWidth())
    Ty = Ty + S4_UI.FH_S

    -- Card Password:
    self.CardPasswordLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, getText("IGUI_S4_Label_CardPassword"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.CardPasswordLabel)
    TextMaxX = math.max(TextMaxX, self.CardPasswordLabel:getWidth())
    Ty = Ty + S4_UI.FH_S + 2

    local EntryWidth = math.max(self.CardPasswordLabel:getWidth(), 200)
    self.PasswordEntry = ISTextEntryBox:new("", Tx, Ty, EntryWidth, S4_UI.FH_S)
    self.PasswordEntry.font = UIFont.Small
    self.PasswordEntry.backgroundColor = {r=1, g=1, b=1, a=1}
    self.PasswordEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.PasswordEntry:initialise()
    self.PasswordEntry:instantiate()
    self.PasswordEntry:setTextRGBA(0, 0, 0, 1)
    self.PasswordEntry:setOnlyNumbers(true)
    self:addChild(self.PasswordEntry)
    TextMaxX = math.max(TextMaxX, self.PasswordEntry:getWidth())
    Ty = Ty + self.PasswordEntry:getHeight() + 3

    self.HidePasswordBox = ISTickBox:new(Tx, Ty, S4_UI.FH_S, S4_UI.FH_S, "", self)
    self.HidePasswordBox.borderColor = {r=0, g=0, b=0, a=1}
    -- self.HidePasswordBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.HidePasswordBox.choicesColor = {r=0, g=0, b=0, a=1}
    self.HidePasswordBox:initialise()
    self.HidePasswordBox:instantiate()
    self.HidePasswordBox:addOption(getText("IGUI_S4_Hide_Password"))
    self:addChild(self.HidePasswordBox)
    self.HidePasswordBox:forceClick() 
    Ty = Ty + self.HidePasswordBox:getHeight() + S4_UI.FH_S

    TextMaxX = Tx + TextMaxX + 40

    local BtnX = TextMaxX - 110
    self.OKBtn = ISButton:new(BtnX, Ty, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_Cancel"), self, S4_Sys_CardPassword.BtnClick)
    self.OKBtn.internal = "Cancel"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    BtnX = BtnX - 110

    self.OKBtn = ISButton:new(BtnX, Ty, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_CardPassword.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    Ty = Ty + self.OKBtn:getHeight() + 10

    
    self.SysUI:FixUISize(TextMaxX, Ty)
end

function S4_Sys_CardPassword:render()
    ISPanel.render(self)

    if self.HidePasswordBox:isSelected(1) and self.PasswordEntry:getText() ~= "" then
        local str = self.PasswordEntry:getText()
        local maskedStr = string.rep("*", #str)
        self:drawRect(self.PasswordEntry:getX(), self.PasswordEntry:getY(), self.PasswordEntry:getWidth(), self.PasswordEntry:getHeight(), 1, 1, 1, 1)
        self:drawRectBorder(self.PasswordEntry:getX(), self.PasswordEntry:getY(), self.PasswordEntry:getWidth(), self.PasswordEntry:getHeight(), 1, 0, 0, 0)
        self:drawText(maskedStr, self.PasswordEntry:getX()+3, self.PasswordEntry:getY() + 4, 0, 0, 0, 1, UIFont.Small)
    end
end

function S4_Sys_CardPassword:BtnClick(Button)
    local internal = Button.internal
    if internal == "Cancel" then
        self.SysUI:close()
    elseif internal == "Ok" then
        if self.ComUI.CardNumber and self.ComUI.CardPassword then
            local Password = self.ComUI.CardPassword
            local PasswordText = self.PasswordEntry:getText()
            local PasswordFix = S4_UI.getFixPasswordNum(PasswordText)
            self.PasswordEntry:setText(PasswordFix)
            if Password == PasswordFix then
                self.ComUI.isCardPassword = true
                self.SysUI:close()
            else
                self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Password_Fail"), false, false)
                -- self.SysUI:close()
            end
        end

    end
end
-- Functions related to moving and exiting UI
function S4_Sys_CardPassword:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_CardPassword:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end


function S4_Sys_CardPassword:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
