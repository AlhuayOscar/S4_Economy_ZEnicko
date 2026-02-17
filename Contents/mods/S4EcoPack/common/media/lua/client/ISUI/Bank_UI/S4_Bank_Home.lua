S4_Bank_Home = ISPanel:derive("S4_Bank_Home")

function S4_Bank_Home:new(BankUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=0}
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    o.BankUI = BankUI
    o.ComUI = BankUI.ComUI
    o.player = BankUI.player
    return o
end

function S4_Bank_Home:initialise()
    ISPanel.initialise(self)
end

function S4_Bank_Home:createChildren()
    ISPanel.createChildren(self)

    local x, y = 10, 10
    local UserName = self.player:getUsername()
    local Msg1 = string.format(getText("IGUI_S4_Bank_Msg_Home1"), UserName)
    self.MsgLabel1 = ISLabel:new(x, y, S4_UI.FH_M, Msg1, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.MsgLabel1)
    y = y + S4_UI.FH_M
    self.MsgLabel2 = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Bank_Msg_Home2"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel2)
    y = y + S4_UI.FH_M
    self.MsgLabel3 = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Bank_Msg_Home3"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel3)
    y = y + S4_UI.FH_M
    self.MsgLabel4 = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Bank_Msg_Home4"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel4)
    y = y + S4_UI.FH_M

    -- local Py = self:getHeight() - (S4_UI.FH_M * 3) - 20
    -- self.ZomPricePanel = ISPanel:new(x, Py, self:getWidth() - 20, (S4_UI.FH_M * 3) + 10)
    -- self.ZomPricePanel.backgroundColor.a = 0
    -- self.ZomPricePanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    -- self.ZomPricePanel:initialise()
    -- self.ZomPricePanel:instantiate()
    -- self:addChild(self.ZomPricePanel)
end

function S4_Bank_Home:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Bank_Home:onMouseDown(x, y)
    if self.BankUI.moveWithMouse then
        self.BankUI.moving = true
        self.BankUI.dragOffsetX = x
        self.BankUI.dragOffsetY = y
        self.BankUI:bringToTop()
    end
end