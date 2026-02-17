S4_Bank_Loans = ISPanel:derive("S4_Bank_Loans")

local LENDERS = {
    { id = "Zombank", name = "ZomBank Official", baseRate = 0.20, deadline = 14 },
    { id = "Blacky", name = "Blacky's Quick Cash", baseRate = 0.025, deadline = 3 },
    { id = "FinancialKnox", name = "Financial Knox Corp", baseRate = 0.067, deadline = 30 },
    { id = "SP660", name = "SP660 Investments", baseRate = 0.10, deadline = 21 },
}

function S4_Bank_Loans:new(BankUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=0}
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    o.BankUI = BankUI
    o.ComUI = BankUI.ComUI
    o.player = BankUI.player
    o.loans = {}
    return o
end

function S4_Bank_Loans:initialise()
    ISPanel.initialise(self)
    self:refreshLoans()
end

function S4_Bank_Loans:refreshLoans()
    local LoanModData = ModData.get("S4_LoanData")
    local UserName = self.player:getUsername()
    self.loans = {}
    if LoanModData and LoanModData[UserName] then
        self.loans = LoanModData[UserName]
    end
end

function S4_Bank_Loans:getCurrentRate(baseRate)
    local rate = baseRate
    local newsModData = ModData.getOrCreate("S4_KnoxNews")
    local event = newsModData.CurrentEventID

    if event == "STOCK_RISE" then
        rate = rate - 0.05
    elseif event == "STOCK_CRASH" then
        rate = rate + 0.15
    elseif event == "GUERRILLAS" then
        rate = rate + 0.05
    elseif event == "FUEL_SHORTAGE" then
        rate = rate + 0.03
    end

    -- Clamp rate between 2.5% and 45%
    return math.max(0.025, math.min(0.45, rate))
end

function S4_Bank_Loans:createChildren()
    ISPanel.createChildren(self)

    local x, y = 10, 10
    local w = self:getWidth() - 20
    
    -- Title
    self.titleLabel = ISLabel:new(x, y, S4_UI.FH_M, "Credit & Loan Management", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.titleLabel)
    y = y + S4_UI.FH_M + 10

    -- Left Side: Request Loan UI
    local leftW = (w / 2) - 10
    self.requestPanel = ISPanel:new(x, y, leftW, self:getHeight() - y - 10)
    self.requestPanel.backgroundColor.a = 0
    self.requestPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    self:addChild(self.requestPanel)

    local rx, ry = 10, 10
    local label = ISLabel:new(rx, ry, S4_UI.FH_S, "1. Select Lender:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.requestPanel:addChild(label)
    ry = ry + S4_UI.FH_S + 5

    self.lenderBox = ISComboBox:new(rx, ry, leftW - 20, S4_UI.FH_S + 4, self, self.onLenderChange)
    self.lenderBox:initialise()
    for _, lender in ipairs(LENDERS) do
        local rate = self:getCurrentRate(lender.baseRate)
        local display = string.format("%s (%.1f%% interest)", lender.name, rate * 100)
        self.lenderBox:addOptionWithData(display, lender)
    end
    self.requestPanel:addChild(self.lenderBox)
    ry = ry + S4_UI.FH_S + 15

    label = ISLabel:new(rx, ry, S4_UI.FH_S, "2. Loan Amount ($):", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.requestPanel:addChild(label)
    ry = ry + S4_UI.FH_S + 5

    self.amountEntry = ISTextEntryBox:new("1000", rx, ry, leftW - 20, S4_UI.FH_S + 4)
    self.amountEntry:initialise()
    self.amountEntry:instantiate()
    self.amountEntry:setOnlyNumbers(true)
    self.amountEntry.onTextChange = function() self:updateCalculation() end
    self.requestPanel:addChild(self.amountEntry)
    ry = ry + S4_UI.FH_S + 20

    -- Calculation Display
    self.calcLabel = ISRichTextPanel:new(rx, ry, leftW - 20, 100)
    self.calcLabel:initialise()
    self.calcLabel.backgroundColor.a = 0
    self.requestPanel:addChild(self.calcLabel)
    ry = ry + 110

    self.acceptBtn = ISButton:new(rx, ry, leftW - 20, S4_UI.FH_M, "Request Loan", self, self.onAcceptLoan)
    self.acceptBtn:initialise()
    self.acceptBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=0.8}
    self.requestPanel:addChild(self.acceptBtn)

    -- Right Side: Active Loans List
    local rightX = x + leftW + 20
    self.activeLabel = ISLabel:new(rightX, y, S4_UI.FH_S, "Active Loans:", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self:addChild(self.activeLabel)
    
    self.loanList = ISScrollingListBox:new(rightX, y + 20, leftW, self:getHeight() - y - 30)
    self.loanList:initialise()
    self.loanList:instantiate()
    self.loanList.itemheight = S4_UI.FH_S * 3 + 10
    self.loanList.doDrawItem = self.drawLoanItem
    self:addChild(self.loanList)

    self:updateCalculation()
    self:updateLoanList()
end

function S4_Bank_Loans:updateCalculation()
    local lender = self.lenderBox:getOptionData(self.lenderBox.selected)
    local amount = tonumber(self.amountEntry:getText()) or 0
    if not lender or amount <= 0 then 
        self.calcLabel.text = "Enter a valid amount."
        self.calcLabel:paginate()
        return 
    end

    local rate = self:getCurrentRate(lender.baseRate)
    local total = math.floor(amount * (1 + rate))
    
    self.calcLabel.text = string.format(" <RGB:0.8,0.8,0.8> Interest Rate: <RGB:1,1,0> %.1f%% <LINE> <RGB:0.8,0.8,0.8> Total to Repay: <RGB:1,0,0> $ %s <LINE> <RGB:0.8,0.8,0.8> Deadline: <RGB:0,1,1> %d Days", 
        rate * 100, S4_UI.getNumCommas(total), lender.deadline)
    self.calcLabel:paginate()
end

function S4_Bank_Loans:onLenderChange()
    self:updateCalculation()
end

function S4_Bank_Loans:onAcceptLoan()
    local lender = self.lenderBox:getOptionData(self.lenderBox.selected)
    local amount = tonumber(self.amountEntry:getText()) or 0
    
    if amount <= 0 then return end
    if amount > 500000 then 
        self.ComUI:AddMsgBox("Loan Rejected", nil, "Lenders will not approve loans over $500,000 for this profile.")
        return
    end

    -- Selection of card
    local cardNum = self.BankUI.IEUI.ComUI.CardNumber
    if not cardNum then
        self.ComUI:AddMsgBox("No Card", nil, "Please insert a card to receive the funds.")
        return
    end

    local rate = self:getCurrentRate(lender.baseRate)
    local total = math.floor(amount * (1 + rate))
    local timestamp = S4_Utils.getLogTime()
    local displayTime = S4_Utils.getLogTimeMin(timestamp)

    sendClientCommand("S4ED", "RequestLoan", {
        cardNum, lender.name, amount, rate, total, lender.deadline, timestamp, displayTime
    })

    self.ComUI:AddMsgBox("Loan Approved", nil, string.format("$ %s has been deposited into card %s.", S4_UI.getNumCommas(amount), cardNum))
    
    -- Schedule refresh
    self.refreshTimer = 30
end

function S4_Bank_Loans:update()
    if self.refreshTimer and self.refreshTimer > 0 then
        self.refreshTimer = self.refreshTimer - 1
        if self.refreshTimer == 0 then
            self:refreshLoans()
            self:updateLoanList()
        end
    end
end

function S4_Bank_Loans:updateLoanList()
    self.loanList:clear()
    for i, loan in ipairs(self.loans) do
        if loan.Status == "Active" then
            self.loanList:addItem(loan.Lender, {index = i, loan = loan})
        end
    end
end

function S4_Bank_Loans:drawLoanItem(y, item, alt)
    local loan = item.itemData.loan
    local isMouseOver = self.mouseovercol == item.index
    
    if isMouseOver then
        self:drawRect(0, y, self:getWidth(), item.height, 0.2, 1, 1, 1)
    end
    
    local tx, ty = 10, y + 5
    self:drawText(loan.Lender, tx, ty, 1, 1, 1, 1, UIFont.Small)
    ty = ty + S4_UI.FH_S
    
    local status = string.format("Repaid: $ %s / $ %s", S4_UI.getNumCommas(loan.Repaid or 0), S4_UI.getNumCommas(loan.TotalToPay))
    self:drawText(status, tx, ty, 0.8, 0.8, 0.8, 1, UIFont.Small)
    ty = ty + S4_UI.FH_S
    
    self:drawText("Card: " .. loan.CardNum, tx, ty, 0.6, 0.6, 0.6, 1, UIFont.Small)
    
    -- Repay Button
    local btnW = 80
    local btnH = S4_UI.FH_S + 4
    local btnX = self:getWidth() - btnW - 10
    local btnY = y + (item.height / 2) - (btnH / 2)
    
    if self:drawButton(btnX, btnY, btnW, btnH, "Repay", 0.7) then
        -- Repay Logic
        self:onRepayLoan(item.itemData.index, loan)
    end

    return y + item.height
end

function S4_Bank_Loans:drawButton(x, y, w, h, text, alpha)
    local mouseX, mouseY = self:getMouseX(), self:getMouseY()
    local over = mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
    
    self:drawRect(x, y, w, h, alpha, 0.2, 0.2, 0.2)
    self:drawRectBorder(x, y, w, h, 1, 1, 1, 1)
    local textW = getTextManager():MeasureStringX(UIFont.Small, text)
    self:drawText(text, x + (w/2) - (textW/2), y + 2, 1, 1, 1, 1, UIFont.Small)
    
    return over and isMouseButtonDown(0)
end

function S4_Bank_Loans:onRepayLoan(index, loan)
    local cardNum = self.BankUI.IEUI.ComUI.CardNumber
    if not cardNum then return end
    
    local amountToRepay = loan.TotalToPay - (loan.Repaid or 0)
    local timestamp = S4_Utils.getLogTime()
    local displayTime = S4_Utils.getLogTimeMin(timestamp)

    sendClientCommand("S4ED", "RepayLoan", {
        cardNum, index, amountToRepay, timestamp, displayTime
    })

    self.refreshTimer = 30
end
