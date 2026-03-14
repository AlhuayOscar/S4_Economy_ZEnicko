S4_ATM_Home = ISPanel:derive("S4_ATM_Home")

function S4_ATM_Home:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Home:initialise()
    ISPanel.initialise(self)

end

function S4_ATM_Home:createChildren()
    ISPanel.createChildren(self)

    local TitleW = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_ATM_Home"))
    local TitleX = (self:getWidth() / 2) - (TitleW / 2)
    local TextY = 10
    self.TitleLabel = ISLabel:new(TitleX, TextY, S4_UI.FH_M, getText("IGUI_S4_ATM_Home"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.TitleLabel)
    TextY = TextY + S4_UI.FH_M

    local InfoW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_ATM_Info_Home"))
    local InfoX = (self:getWidth() / 2) - (InfoW / 2)
    self.InfoLabel = ISLabel:new(InfoX, TextY, S4_UI.FH_S, getText("IGUI_S4_ATM_Info_Home"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel)
    TextY = TextY + S4_UI.FH_S

    local MsgW = getTextManager():MeasureStringX(UIFont.Small, getText(""))
    local MsgX = (self:getWidth() / 2) - (MsgW / 2)
    self.MsgLabel = ISLabel:new(MsgX, TextY, S4_UI.FH_S, getText(""), 1, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel)
    self.MsgY = TextY + S4_UI.FH_S * 3

end

function S4_ATM_Home:render()
    ISPanel.initialise(self)

    if self.CompleteMsg then
        local MsgW = getTextManager():MeasureStringX(UIFont.Medium, self.CompleteMsg)
        local MsgX = (self:getWidth() / 2) - (MsgW / 2)
        self:drawText(self.CompleteMsg, MsgX, self.MsgY, 0, 0.8, 0, 1, UIFont.Medium)
    end
end

function S4_ATM_Home:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Home:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end