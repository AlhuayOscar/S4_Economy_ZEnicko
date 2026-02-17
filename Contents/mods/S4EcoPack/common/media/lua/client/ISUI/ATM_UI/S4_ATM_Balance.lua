S4_ATM_Balance = ISPanel:derive("S4_ATM_Balance")

function S4_ATM_Balance:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Balance:initialise()
    ISPanel.initialise(self)

    self.AtmUI.MenuBtn1.internal = "Transfer"
    self.AtmUI.MenuBtn1:setTitle(getText("IGUI_S4_ATM_Transfer"))
    self.AtmUI.MenuBtn2.internal = "Deposit"
    self.AtmUI.MenuBtn2:setTitle(getText("IGUI_S4_ATM_Deposit"))
    self.AtmUI.MenuBtn3.internal = "Withdraw"
    self.AtmUI.MenuBtn3:setTitle(getText("IGUI_S4_ATM_Withdraw"))
    self.AtmUI.MenuBtn6.internal = "Undo"
    self.AtmUI.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Undo"))
    self.AtmUI.MenuBtn1:setVisible(true)
    self.AtmUI.MenuBtn2:setVisible(true)
    self.AtmUI.MenuBtn3:setVisible(true)
    self.AtmUI.MenuBtn4:setVisible(false)
    self.AtmUI.MenuBtn5:setVisible(false)
    self.AtmUI.MenuBtn6:setVisible(true)
end

function S4_ATM_Balance:createChildren()
    ISPanel.createChildren(self)
    local TitleText = getText("IGUI_S4_ATM_Balance")
    local InfoText = ""
    local MsgText = ""
    local Money = 0

    local CardModData = ModData.get("S4_CardData")
    if self.AtmUI.CardNumber and CardModData[self.AtmUI.CardNumber] then
        local CardData = CardModData[self.AtmUI.CardNumber]
        InfoText = string.format(getText("IGUI_S4_ATM_Info_Balance"), CardData.Master, self.AtmUI.CardNumber)
        self.Money = CardData.Money
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

    self.PanelY = TextY + (self:getHeight() - TextY) / 2 - (S4_UI.FH_L + S4_UI.FH_M) / 2

end

function S4_ATM_Balance:render()
    ISPanel.initialise(self)

    local PanelW = self:getWidth() - 40
    local PanelH = S4_UI.FH_L + S4_UI.FH_M

    self:drawRect(20, self.PanelY, PanelW, PanelH, 1, 0, 0, 0)
    self:drawRectBorder(20, self.PanelY, PanelW, PanelH, 0.8, 1, 1, 1)

    local InfoW = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Balance_Info"))
    local InfoX = (self:getWidth() / 2) - (InfoW / 2)
    self:drawText(getText("IGUI_S4_ATM_Balance_Info"), InfoX, self.PanelY, 1, 1, 1, 0.8, UIFont.Medium)

    local FixMoney = S4_UI.getNumCommas(self.Money)
    local MoneyValue = string.format(getText("IGUI_S4_ATM_Money_Value"), FixMoney)
    local ValueW = getTextManager():MeasureStringX(UIFont.Large, MoneyValue)
    local ValueX = (self:getWidth() / 2) - (ValueW / 2)
    self:drawText(MoneyValue, ValueX, self.PanelY + S4_UI.FH_M, 1, 1, 1, 0.8, UIFont.Large)
end

function S4_ATM_Balance:setMsg(Msg)
    self.MsgLabel:setName(Msg)
    local MsgString = getTextManager():MeasureStringX(UIFont.Small, Msg)
    local MsgX = (self:getWidth() / 2) - (MsgString / 2)
    self.MsgLabel:setX(MsgX)
    self.MsgLabel:setVisible(true)
end

function S4_ATM_Balance:setTitleInfo(Title, Info)
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

function S4_ATM_Balance:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Balance:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end