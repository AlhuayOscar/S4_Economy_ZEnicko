S4_Sys_UserSettings = ISPanel:derive("S4_Sys_UserSettings")

function S4_Sys_UserSettings:new(SysUI, Px, Py, Pw, Ph)
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

function S4_Sys_UserSettings:initialise()
    ISPanel.initialise(self)
    
end

function S4_Sys_UserSettings:createChildren()
    ISPanel.createChildren(self)

    local TextMaxX = 0
    local Tx = 40
    local Ty = 30
    local IconNextY = 20
    if self.SysUI.IconImg then
        Tx = Tx + 64 + 20
        IconNextY = IconNextY + 84
    end

    local InfoText1 = getText("IGUI_S4_UserSettings_Info")
    local InfoTextW1 = getTextManager():MeasureStringX(UIFont.Small, InfoText1)
    self.InfoLabel1 = ISLabel:new(Tx, Ty, S4_UI.FH_S, InfoText1, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel1)
    TextMaxX = math.max(TextMaxX, Tx + InfoTextW1 + 40)
    Ty = Ty + S4_UI.FH_S
    local InfoText2 = getText("IGUI_S4_UserSettings_Info2")
    local InfoTextW2 = getTextManager():MeasureStringX(UIFont.Small, InfoText2)
    self.InfoLabel2 = ISLabel:new(Tx, Ty, S4_UI.FH_S, InfoText2, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel2)
    TextMaxX = math.max(TextMaxX, Tx + InfoTextW2 + 40)
    Ty = Ty + S4_UI.FH_S

    local SetupX = 40
    local SetupY = math.max(104, Ty)
    self.AddressLabel = ISLabel:new(SetupX, SetupY, S4_UI.FH_S, getText("IGUI_S4_Label_Username"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.AddressLabel)
    SetupY = SetupY + self.AddressLabel:getHeight()

    local EntryWidth = TextMaxX - 80
    self.AddressEntry = ISTextEntryBox:new("Administrator", SetupX, SetupY, EntryWidth, S4_UI.FH_S)
    self.AddressEntry.font = UIFont.Small
    self.AddressEntry.backgroundColor = {r=1, g=1, b=1, a=1}
    self.AddressEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.AddressEntry:initialise()
    self.AddressEntry:instantiate()
    self.AddressEntry:setTextRGBA(0, 0, 0, 1)
    self:addChild(self.AddressEntry)
    SetupY = SetupY + self.AddressEntry:getHeight() + 5

    local ChangeText = getText("IGUI_S4_Label_NewPasswordCheck")
    local ChangeCheckText = getText("IGUI_S4_Label_NewPasswordCheck")

    if self.ComUI.ComPassword then
        ChangeText = getText("IGUI_S4_Label_ChangePassword")
        ChangeCheckText = getText("IGUI_S4_Label_ChangePasswordChenk")

        self.OldPasswordLabel = ISLabel:new(SetupX, SetupY, S4_UI.FH_S, getText("IGUI_S4_Label_OldPassword"), 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.OldPasswordLabel)
        SetupY = SetupY + self.OldPasswordLabel:getHeight()

        self.OldPasswordEntry = ISTextEntryBox:new("", SetupX, SetupY, EntryWidth, S4_UI.FH_S)
        self.OldPasswordEntry.font = UIFont.Small
        self.OldPasswordEntry.backgroundColor = {r=1, g=1, b=1, a=1}
        self.OldPasswordEntry.borderColor = {r=0, g=0, b=0, a=1}
        self.OldPasswordEntry:initialise()
        self.OldPasswordEntry:instantiate()
        self.OldPasswordEntry:setTextRGBA(0, 0, 0, 1)
        self:addChild(self.OldPasswordEntry)
        SetupY = SetupY + self.OldPasswordEntry:getHeight() + 5
    end

    self.ChangePasswordLabel = ISLabel:new(SetupX, SetupY, S4_UI.FH_S, ChangeText, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ChangePasswordLabel)
    SetupY = SetupY + self.ChangePasswordLabel:getHeight()

    self.ChangePasswordEntry = ISTextEntryBox:new("", SetupX, SetupY, EntryWidth, S4_UI.FH_S)
    self.ChangePasswordEntry.font = UIFont.Small
    self.ChangePasswordEntry.backgroundColor = {r=1, g=1, b=1, a=1}
    self.ChangePasswordEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.ChangePasswordEntry:initialise()
    self.ChangePasswordEntry:instantiate()
    self.ChangePasswordEntry:setTextRGBA(0, 0, 0, 1)
    self:addChild(self.ChangePasswordEntry)
    SetupY = SetupY + self.ChangePasswordEntry:getHeight() + 5

    self.ChangeCheckPasswordLabel = ISLabel:new(SetupX, SetupY, S4_UI.FH_S, ChangeCheckText, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.ChangeCheckPasswordLabel)
    SetupY = SetupY + self.ChangeCheckPasswordLabel:getHeight()

    self.ChangeCheckPasswordEntry = ISTextEntryBox:new("", SetupX, SetupY, EntryWidth, S4_UI.FH_S)
    self.ChangeCheckPasswordEntry.font = UIFont.Small
    self.ChangeCheckPasswordEntry.backgroundColor = {r=1, g=1, b=1, a=1}
    self.ChangeCheckPasswordEntry.borderColor = {r=0, g=0, b=0, a=1}
    self.ChangeCheckPasswordEntry:initialise()
    self.ChangeCheckPasswordEntry:instantiate()
    self.ChangeCheckPasswordEntry:setTextRGBA(0, 0, 0, 1)
    self:addChild(self.ChangeCheckPasswordEntry)
    SetupY = SetupY + self.ChangeCheckPasswordEntry:getHeight() + 5

    self.HideBox = ISTickBox:new(SetupX, SetupY, S4_UI.FH_S, S4_UI.FH_S, "", self)
    self.HideBox.borderColor = {r=0, g=0, b=0, a=1}
    self.HideBox.choicesColor = {r=0, g=0, b=0, a=1}
    self.HideBox.tooltip = getText("Tooltip_S4_Hide_Password")
    self.HideBox:initialise()
    self.HideBox:instantiate()
    self.HideBox:addOption(getText("IGUI_S4_Hide_Password"))
    self:addChild(self.HideBox)
    self.HideBox.joypadIndex = 1
    self.HideBox:forceClick() 
    SetupY = SetupY + self.HideBox:getHeight() + 10

    local BtnX = TextMaxX - 110
    self.CancelBtn = ISButton:new(BtnX, SetupY, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_Cancel"), self, S4_Sys_UserSettings.BtnClick)
    self.CancelBtn.internal = "Cancel"
    self.CancelBtn.textColor = {r=0, g=0, b=0, a=1}
    self.CancelBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.CancelBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.CancelBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.CancelBtn:initialise()
    self:addChild(self.CancelBtn)

    BtnX = BtnX - 110
    self.OKBtn = ISButton:new(BtnX, SetupY, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_UserSettings.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    SetupY = SetupY + self.OKBtn:getHeight() + 10

    if self.Reload then
        self.SysUI:ReloadFixUISize(TextMaxX, SetupY)
    else
        self.SysUI:FixUISize(TextMaxX, SetupY)
    end
end

function S4_Sys_UserSettings:render()
    if self.HideBox:isSelected(1) then
        if self.OldPasswordEntry and self.OldPasswordEntry:getText() ~= "" then
            local str = self.OldPasswordEntry:getText()
            local maskedStr = string.rep("*", #str)
            self:drawRect(self.OldPasswordEntry:getX(), self.OldPasswordEntry:getY(), self.OldPasswordEntry:getWidth(), self.OldPasswordEntry:getHeight(), 1, 1, 1, 1)
            self:drawRectBorder(self.OldPasswordEntry:getX(), self.OldPasswordEntry:getY(), self.OldPasswordEntry:getWidth(), self.OldPasswordEntry:getHeight(), 1, 0, 0, 0)
            self:drawText(maskedStr, self.OldPasswordEntry:getX()+5, self.OldPasswordEntry:getY() + 2, 0, 0, 0, 1, UIFont.Small)
        end
        if self.ChangePasswordEntry:getText() ~= "" then
            local str = self.ChangePasswordEntry:getText()
            local maskedStr = string.rep("*", #str)
            self:drawRect(self.ChangePasswordEntry:getX(), self.ChangePasswordEntry:getY(), self.ChangePasswordEntry:getWidth(), self.ChangePasswordEntry:getHeight(), 1, 1, 1, 1)
            self:drawRectBorder(self.ChangePasswordEntry:getX(), self.ChangePasswordEntry:getY(), self.ChangePasswordEntry:getWidth(), self.ChangePasswordEntry:getHeight(), 1, 0, 0, 0)
            self:drawText(maskedStr, self.ChangePasswordEntry:getX()+5, self.ChangePasswordEntry:getY() + 2, 0, 0, 0, 1, UIFont.Small)
        end
        if self.ChangeCheckPasswordEntry:getText() ~= "" then
            local str = self.ChangeCheckPasswordEntry:getText()
            local maskedStr = string.rep("*", #str)
            self:drawRect(self.ChangeCheckPasswordEntry:getX(), self.ChangeCheckPasswordEntry:getY(), self.ChangeCheckPasswordEntry:getWidth(), self.ChangeCheckPasswordEntry:getHeight(), 1, 1, 1, 1)
            self:drawRectBorder(self.ChangeCheckPasswordEntry:getX(), self.ChangeCheckPasswordEntry:getY(), self.ChangeCheckPasswordEntry:getWidth(), self.ChangeCheckPasswordEntry:getHeight(), 1, 0, 0, 0)
            self:drawText(maskedStr, self.ChangeCheckPasswordEntry:getX()+5, self.ChangeCheckPasswordEntry:getY() + 2, 0, 0, 0, 1, UIFont.Small)
        end
    end
end

function S4_Sys_UserSettings:BtnClick(Button)
    local internal = Button.internal
    local ComModData = self.ComUI.ComObj:getModData()
    if internal == "Ok" then
        if self.AddressEntry:getText() == "Administrator" then
            local ChangePassword = self.ChangePasswordEntry:getText()
            local ChangeCheckPassword = self.ChangeCheckPasswordEntry:getText()
            if self.ComUI.ComPassword then
                local OldPassword = self.OldPasswordEntry:getText()
                if S4_UI.getTextValid({OldPassword, ChangePassword, ChangeCheckPassword}) then
                    if self.ComUI.ComPassword == OldPassword then
                        if ChangePassword == ChangeCheckPassword then
                            local FixPassword = S4_UI.RemoveTextValid(ChangePassword)
                            self.ComUI.ComPassword = FixPassword
                            ComModData.ComPassword = FixPassword
                            S4_Utils.SnycObject(self.ComUI.ComObj)

                            self.SysUI:close()
                        else -- MsgBox Change password does not match
                            self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Password_Chnage_Fail"), false, false)
                        end
                    else -- MsgBox Current password does not match
                        self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Password_Fail"), false, false)
                    end
                else -- No spaces in MsgBox password
                    self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Password_None"), false, false)
                end
            else
                if S4_UI.getTextValid({ChangePassword, ChangeCheckPassword}) then
                    if ChangePassword == ChangeCheckPassword then
                        local FixPassword = S4_UI.RemoveTextValid(ChangePassword)
                        self.ComUI.ComPassword = FixPassword
                        ComModData.ComPassword = FixPassword
                        S4_Utils.SnycObject(self.ComUI.ComObj)
                        
                        self.SysUI:close()
                    else -- MsgBox The new password does not match.
                        self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Password_NewChnage_Fail"), false, false)
                    end
                else -- No spaces in MsgBox password
                    self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Password_None"), false, false)
                end
            end
        else -- Username does not match
            self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_UserName_Fail"), false, false)
        end
    elseif internal == "Cancel" then
        self.SysUI:close()
    end
end


-- Functions related to moving and exiting UI
function S4_Sys_UserSettings:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_UserSettings:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end

function S4_Sys_UserSettings:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
