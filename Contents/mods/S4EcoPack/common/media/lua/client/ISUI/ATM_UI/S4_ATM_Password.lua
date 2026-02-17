S4_ATM_Password = ISPanel:derive("S4_ATM_Password")

function S4_ATM_Password:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Password:initialise()
    ISPanel.initialise(self)
    self.NumberPad = true

    self.DumpPassword = "" --Enter password (temporary value)
    self.FirstPassword = "" -- Password input value (saved value)
    self.isPassword = false -- Check existing password
    self.isPasswordNew = false -- Enter new password for the first time
    
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

function S4_ATM_Password:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_Password_New")
    local InfoText = getText("IGUI_S4_ATM_Info_New")
    local MsgText = ""
    if self.AtmUI.CardNumber == "Null" then
        TitleText = getText("IGUI_S4_ATM_Password_First")
        InfoText = getText("IGUI_S4_ATM_Info_First")
    elseif self.OnlyCheck then
        TitleText = getText("IGUI_S4_ATM_Password_Check")
        InfoText = getText("IGUI_S4_ATM_Info_Check")
    end

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
        self["NumBtn"..i] = ISButton:new(BtnX, BtnY, BtnSize, BtnSize, Number, self, S4_ATM_Password.BtnAction)
        self["NumBtn"..i].internal = Number
        self["NumBtn"..i].font = UIFont.Medium
        self["NumBtn"..i]:initialise()
        self["NumBtn"..i]:instantiate()
        self:addChild(self["NumBtn"..i])
    end
end

function S4_ATM_Password:render()
    ISPanel.initialise(self)

end

function S4_ATM_Password:BtnAction(Button)
    local internal = Button.internal
    if internal:match("^%d$") then
        self:NumberAction(internal)
    end
end

function S4_ATM_Password:NumberAction(Num)
    -- print("Number: "..Num)
    if #self.DumpPassword < 4 then
        local Number = tonumber(Num)
        self.DumpPassword = self.DumpPassword .. Number
        self:setMasked()
    else
        self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Max"))
    end
end

function S4_ATM_Password:PasswordAction()
    if #self.DumpPassword == 4 then -- When password is entered correctly
        if self.OnlyCheck and self.AtmUI.CardNumber ~= "Null" and not self.AtmUI.isPassword then -- Confirm password when inserting a card with data
            if self.DumpPassword == self.AtmUI.CardPassword then
                self.AtmUI.isPassword = true
                self.AtmUI:setMain(false)
            else
                self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Fail"))
            end
        else
            if self.AtmUI.CardPassword and self.AtmUI.CardNumber ~= "Null" then -- Change password
                if self.isPassword then -- Set a new password
                    if self.FirstPassword == self.DumpPassword then
                        self.AtmUI.CardPassword = self.FirstPassword
                        -- server transfer
                        local CardNum = self.AtmUI.CardNumber
                        sendClientCommand("S4ED", "setPassword", {CardNum, self.FirstPassword})
                        -- main screen
                        self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_Password_Change"))
                    else
                        self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Sync"))
                    end
                else -- Enter new password for the first time
                    self.FirstPassword = self.DumpPassword
                    self.DumpPassword = ""
                    self:setMasked()
                    self.isPassword = true
                    self:setTitleInfo(getText("IGUI_S4_ATM_Password_NewCheck"), getText("IGUI_S4_ATM_Info_NewCheck"))
                end
            else -- Initial password settings
                if self.isPassword then -- Initial change of password
                    if self.FirstPassword == self.DumpPassword then
                        -- server transfer
                        local CardNum = 1
                        local CardModData = ModData.get("S4_CardData")
                        for i, Data in pairs(CardModData) do
                            CardNum = i + 1
                        end
                        local Money = S4_Utils.getNewCardMoney()
                        local LogTime = S4_Utils.getLogTime()
                        sendClientCommand("S4ED", "CreateCardData", {CardNum, self.FirstPassword, Money, LogTime})
                        -- AtmObj ModData / UI Card Number update
                        self.AtmUI.CardNumber = CardNum
                        self.AtmUI.CardPassword = self.FirstPassword
                        self.AtmUI.isPassword = true
                        local AtmModData = self.AtmUI.Obj:getModData()
                        AtmModData.S4CardNumber = CardNum
                        S4_Utils.SnycObject(self.AtmUI.Obj)
                        -- main screen
                        self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_Password_Setting"))
                    else
                        self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Sync"))
                    end
                else -- first input
                    self.FirstPassword = self.DumpPassword
                    self.DumpPassword = ""
                    self:setMasked()
                    self.isPassword = true
                    self:setTitleInfo(getText("IGUI_S4_ATM_Password_FirstCheck"), getText("IGUI_S4_ATM_Info_FirstCheck"))
                end
            end
        end
    else -- If the password is less than 4 characters, an error message is returned.
        self:setMsg(getText("IGUI_S4_ATM_Msg_Password_Min"))
    end
end

function S4_ATM_Password:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Password:setTitleInfo(Title, Info)
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

function S4_ATM_Password:setMasked()
    local MaskedStr = string.rep("*", #self.DumpPassword)
    local MaskedString = getTextManager():MeasureStringX(UIFont.Small, MaskedStr)
    local MaskedX = (self:getWidth() / 2) - (MaskedString / 2)
    self.InfoLabel:setName(MaskedStr)
    self.InfoLabel:setX(MaskedX)
    self.MsgLabel:setVisible(false)
end

function S4_ATM_Password:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Password:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end