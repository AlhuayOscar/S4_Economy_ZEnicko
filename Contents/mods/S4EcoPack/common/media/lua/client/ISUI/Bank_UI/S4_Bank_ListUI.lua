S4_Bank_ListUI = ISPanel:derive("S4_Bank_ListUI")

function S4_Bank_ListUI:new(BankUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=0}
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    o.BankUI = BankUI
    o.ComUI = BankUI.ComUI
    o.player = BankUI.player
    o.MyCards = {}
    return o
end

function S4_Bank_ListUI:initialise()
    ISPanel.initialise(self)
    self:setData()
end

function S4_Bank_ListUI:setData()
    local PlayerName = self.player:getUsername()
    local CardModData = ModData.get("S4_CardData")
    if not CardModData then return end
    for CardNum, Data in pairs(CardModData) do
        if Data.Master == PlayerName then
            self.MyCards[CardNum] = Data
        end
    end
end

function S4_Bank_ListUI:createChildren()
    ISPanel.createChildren(self)

    -- local x, y = 10, 5
    -- self.TextLabel = ISLabel:new(x, y, S4_UI.FH_M, getText("Account"), 1, 1, 1, 1, UIFont.Medium, true)
    -- self:addChild(self.TextLabel)

    -- local TW1 = getTextManager():MeasureStringX(UIFont.Small, getText("All View"))
    -- local TW2 = getTextManager():MeasureStringX(UIFont.Small, getText("Withdraw View"))
    -- local TW3 = getTextManager():MeasureStringX(UIFont.Small, getText("Deposit View"))
    -- local BtnW = math.max(TW1, TW2, TW3) + 20
    -- local BtnX = self.TextLabel:getRight() + 10
    -- local BtnY = y + ((S4_UI.FH_M - S4_UI.FH_S) / 2)
    -- self.AllBtn= ISButton:new(BtnX, BtnY, BtnW, S4_UI.FH_S, "All View", self, S4_Bank_ListUI.BtnClick)
    -- self.AllBtn.backgroundColorMouseOver.a = 0.7
    -- self.AllBtn.backgroundColor.a = 0
    -- self.AllBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    -- self.AllBtn.textColor.a = 0.9
    -- -- self.AllBtn.font = UIFont.Medium
    -- self.AllBtn:initialise()
    -- self:addChild(self.AllBtn)
    -- BtnX = BtnX + BtnW + 10
    -- self.WithdrawBtn= ISButton:new(BtnX, BtnY, BtnW, S4_UI.FH_S, "Withdraw View", self, S4_Bank_ListUI.BtnClick)
    -- self.WithdrawBtn.backgroundColorMouseOver.a = 0.7
    -- self.WithdrawBtn.backgroundColor.a = 0
    -- self.WithdrawBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    -- self.WithdrawBtn.textColor.a = 0.9
    -- -- self.WithdrawBtn.font = UIFont.Medium
    -- self.WithdrawBtn:initialise()
    -- self:addChild(self.WithdrawBtn)
    -- BtnX = BtnX + BtnW + 10
    -- self.DepositBtn= ISButton:new(BtnX, BtnY, BtnW, S4_UI.FH_S, "Deposit View", self, S4_Bank_ListUI.BtnClick)
    -- self.DepositBtn.backgroundColorMouseOver.a = 0.7
    -- self.DepositBtn.backgroundColor.a = 0
    -- self.DepositBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    -- self.DepositBtn.textColor.a = 0.9
    -- -- self.DepositBtn.font = UIFont.Medium
    -- self.DepositBtn:initialise()
    -- self:addChild(self.DepositBtn)

    -- self.Listpanel = ISPanel:new(x, y, width, height)
end

function S4_Bank_ListUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Bank_ListUI:onMouseDown(x, y)
    if self.BankUI.moveWithMouse then
        self.BankUI.moving = true
        self.BankUI.dragOffsetX = x
        self.BankUI.dragOffsetY = y
        self.BankUI:bringToTop()
    end
end