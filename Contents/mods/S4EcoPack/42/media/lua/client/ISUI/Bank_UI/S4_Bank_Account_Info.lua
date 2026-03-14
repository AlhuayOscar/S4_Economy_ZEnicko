S4_Bank_Account_Info = ISPanel:derive("S4_Bank_Account_Info")

function S4_Bank_Account_Info:new(BankUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=0}
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=0}
    o.BankUI = BankUI
    o.ComUI = BankUI.ComUI
    o.player = BankUI.player
    return o
end

function S4_Bank_Account_Info:initialise()
    ISPanel.initialise(self)

end

function S4_Bank_Account_Info:createChildren()
    ISPanel.createChildren(self)

end


function S4_Bank_Account_Info:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Bank_Account_Info:onMouseDown(x, y)
    if self.BankUI.moveWithMouse then
        self.BankUI.moving = true
        self.BankUI.dragOffsetX = x
        self.BankUI.dragOffsetY = y
        self.BankUI:bringToTop()
    end
end