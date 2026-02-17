S4_ATM_Setting = ISPanel:derive("S4_ATM_Setting")

function S4_ATM_Setting:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Setting:initialise()
    ISPanel.initialise(self)
    self.NumberPad = true

    self.DumpPassword = "" --Enter password (temporary value)

    self.AtmUI.MenuBtn4.internal = "Password_OK"
    self.AtmUI.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Ok"))
    self.AtmUI.MenuBtn5.internal = "Password_Clear"
    self.AtmUI.MenuBtn5:setTitle(getText("IGUI_S4_ATM_Clear"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn1:setVisible(false)
    self.AtmUI.MenuBtn2:setVisible(false)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(true)
    self.AtmUI.MenuBtn5:setVisible(true)
    self.AtmUI.MenuBtn6:setVisible(true)
end

function S4_ATM_Setting:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_Password_Check")
    local InfoText = getText("IGUI_S4_ATM_Info_Check")
    local MsgText = ""

    local TitleW = getTextManager():MeasureStringX(UIFont.Medium, TitleText)
    local TitleX = (self:getWidth() / 2) - (TitleW / 2)
    local TextY = 10
    self.TitleLabel = ISLabel:new(TitleX, TextY, S4_UI.FH_M, TitleText, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.TitleLabel)
    TextY = TextY + S4_UI.FH_M

    local InfoW = getTextManager():MeasureStringX(UIFont.Small, InfoText)
    local InfoX = (self:getWidth() / 2) - (InfoW / 2)
    self.InfoLabel = ISLabel:new(InfoX, TextY, S4_UI.FH_S, InfoText, 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel)
    TextY = TextY + S4_UI.FH_S

    local MsgW = getTextManager():MeasureStringX(UIFont.Small, MsgText)
    local MsgX = (self:getWidth() / 2) - (MsgW / 2)
    self.MsgLabel = ISLabel:new(MsgX, TextY, S4_UI.FH_S, MsgText, 1, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel)
    self.MsgLabel:setVisible(false)
    TextY = TextY + S4_UI.FH_S


    local BtnY = TextY + 10
    local BtnSize = ((self:getHeight() - BtnY) / 4) - 10
    local BtnX = (self:getWidth()/2) - ((BtnSize) * 3)/2 - 10
    for i = 1, 10 do 
        local Number = "1"
        if i == 4 or i == 7 then
            BtnX = (self:getWidth()/2) - ((BtnSize) * 3)/2 - 10
            BtnY = BtnY + BtnSize + 10
            Number = "" .. i
        elseif i == 10 then
            BtnX = (self:getWidth()/2) - ((BtnSize) * 3)/2 + BtnSize
            BtnY = BtnY + BtnSize + 10
            Number = "0"
        elseif i ~= 1 then
            BtnX = BtnX + BtnSize + 10
            Number = "" .. i
        end
        self["NumBtn"..i] = ISButton:new(BtnX, BtnY, BtnSize, BtnSize, Number, self, S4_ATM_Setting.BtnAction)
        self["NumBtn"..i].internal = Number
        self["NumBtn"..i].font = UIFont.Medium
        self["NumBtn"..i]:initialise()
        self["NumBtn"..i]:instantiate()
        self:addChild(self["NumBtn"..i])
    end
end

function S4_ATM_Setting:render()
    ISPanel.initialise(self)

end

function S4_ATM_Setting:BtnAction(Button)
    local internal = Button.internal
    if internal:match("^%d$") then
        self:NumberAction(internal)
    end
end

function S4_ATM_Setting:NumberAction(Num)
    -- print("Number: "..Num)
    if #self.DumpPassword < 4 then
        local Number = tonumber(Num)
        self.DumpPassword = self.DumpPassword .. Number
        self:setMasked()
    else
        self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Max"))
    end
end

function S4_ATM_Setting:PasswordAction()
    if #self.DumpPassword == 4 then -- When password is entered correctly
        if self.DumpPassword == self.AtmUI.CardPassword then
            self:setScreen()
        else
            self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Fail"))
        end
    else -- If the password is less than 4 characters, an error message is returned.
        self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Min"))
    end
end

function S4_ATM_Setting:setScreen()
    self.NumberPad = false
    self.MsgLabel:setVisible(false)
    for i = 1, 10 do 
        self["NumBtn"..i]:setVisible(false)
    end
    self.AtmUI.MenuBtn1.internal = "PasswordChange"
    self.AtmUI.MenuBtn1:setTitle(getText("IGUI_S4_ATM_PasswordChange"))
    self.AtmUI.MenuBtn1:setVisible(true)
    self.AtmUI.MenuBtn2.internal = "MainCard"
    self.AtmUI.MenuBtn2:setTitle(getText("IGUI_S4_ATM_MainCard"))
    self.AtmUI.MenuBtn2:setVisible(true)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(false)
    self.AtmUI.MenuBtn5:setVisible(false)

    self:setTitleInfo(getText("IGUI_S4_ATM_Setting"), getText("IGUI_S4_ATM_Info_Home"))
end

function S4_ATM_Setting:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Setting:setTitleInfo(Title, Info)
    self.TitleLabel:setName(Title)
    local TitleString = getTextManager():MeasureStringX(UIFont.Medium, Title)
    local TitleX = (self:getWidth() / 2) - (TitleString / 2)
    self.TitleLabel:setX(TitleX)

    self.InfoLabel:setName(Info)
    local InfoString = getTextManager():MeasureStringX(UIFont.Small, Info)
    local InfoX = (self:getWidth() / 2) - (InfoString / 2)
    self.InfoLabel:setX(InfoX)

    self.MsgLabel:setVisible(false)
end

function S4_ATM_Setting:setMasked()
    local MaskedStr = string.rep("*", #self.DumpPassword)
    local MaskedString = getTextManager():MeasureStringX(UIFont.Small, MaskedStr)
    local MaskedX = (self:getWidth() / 2) - (MaskedString / 2)
    self.InfoLabel:setName(MaskedStr)
    self.InfoLabel:setX(MaskedX)
    self.MsgLabel:setVisible(false)
end

function S4_ATM_Setting:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Setting:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end