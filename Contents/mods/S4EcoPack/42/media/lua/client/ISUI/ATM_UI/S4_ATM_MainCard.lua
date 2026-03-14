S4_ATM_MainCard = ISPanel:derive("S4_ATM_MainCard")

function S4_ATM_MainCard:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_MainCard:initialise()
    ISPanel.initialise(self)

    self.AtmUI.MenuBtn4.internal = "setMainCard"
    self.AtmUI.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Ok"))
    self.AtmUI.MenuBtn5.internal = "Undo"
    self.AtmUI.MenuBtn5:setTitle(getText("IGUI_S4_ATM_Cancel"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn1:setVisible(false)
    self.AtmUI.MenuBtn2:setVisible(false)
    self.AtmUI.MenuBtn3:setVisible(false)
    self.AtmUI.MenuBtn4:setVisible(true)
    self.AtmUI.MenuBtn5:setVisible(true)
    self.AtmUI.MenuBtn6:setVisible(true)
end

function S4_ATM_MainCard:createChildren()
    ISPanel.createChildren(self)

    local TitleText = getText("IGUI_S4_ATM_MainCard")
    local InfoText = getText("IGUI_S4_ATM_Info_MainCard")
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

end

function S4_ATM_MainCard:setMainCard()
    local CardNumber = self.AtmUI.CardNumber
    local CardData = ModData.get("S4_CardData")
    if CardData[CardNumber] then
        local UserName = self.player:getUsername()
        if UserName == CardData[CardNumber].Master then
            local PlayerModData = ModData.get("S4_PlayerData")
            if PlayerModData[UserName] then
                sendClientCommand("S4PD", "setMainCard", {CardNumber})
            else
                self:setMsg(getText("IGUI_S4_ATM_Msg_Error").."Not found player ModData")
            end
            self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_MainCard"))
        else
            self:setMsg(getText("IGUI_S4_ATM_Msg_MainCard_Master"))
        end
    end
end

function S4_ATM_MainCard:render()
    ISPanel.initialise(self)

end

function S4_ATM_MainCard:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_MainCard:setTitleInfo(Title, Info)
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

function S4_ATM_MainCard:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_MainCard:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end