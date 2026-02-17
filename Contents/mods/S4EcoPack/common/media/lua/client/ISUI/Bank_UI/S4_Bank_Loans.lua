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
    o.lastViewedRate = 0
    o.refreshTimer = 0
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
        for _, loan in ipairs(LoanModData[UserName]) do
            if loan.Status == "Active" then
                table.insert(self.loans, loan)
            end
        end
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
    self.requestPanel.borderColor.a = 0
    self:addChild(self.requestPanel)

    local rx, ry = 10, 10
    local label = ISLabel:new(rx, ry, S4_UI.FH_S, "1. Select Lender:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.requestPanel:addChild(label)
    ry = ry + S4_UI.FH_S + 5

    self.lenderBox = ISComboBox:new(rx, ry, leftW - 20, S4_UI.FH_S + 4, self, self.onLenderChange)
    self.lenderBox:initialise()
    for _, lender in ipairs(LENDERS) do
        local rate = self:getCurrentRate(lender.baseRate)
        local display = string.format("%s (%.1f%%)", lender.name, rate * 100)
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
    self.calcLabel:instantiate()
    self.calcLabel.backgroundColor.a = 0
    self.requestPanel:addChild(self.calcLabel)
    ry = ry + 110

    self.acceptBtn = ISButton:new(rx, ry, leftW - 20, S4_UI.FH_M, "Request Loan", self, self.onAcceptLoan)
    self.acceptBtn:initialise()
    self.acceptBtn.backgroundColor = {r=0.2, g=0.5, b=0.2, a=0.8}
    self.requestPanel:addChild(self.acceptBtn)

    -- Debug Buttons (Lower Left)
    if getDebug() then
        local dbgW = (leftW - 30) / 3
        local dbgY = self.requestPanel:getHeight() - 30
        
        self.debugDeadlineBtn = ISButton:new(10, dbgY, dbgW, 20, "Days+", self, self.onDebugDeadline)
        self.debugDeadlineBtn:initialise()
        self.requestPanel:addChild(self.debugDeadlineBtn)

        self.debugPayBtn = ISButton:new(15 + dbgW, dbgY, dbgW, 20, "Force Pay", self, self.onDebugRepay)
        self.debugPayBtn:initialise()
        self.requestPanel:addChild(self.debugPayBtn)

        self.debugEventBtn = ISButton:new(20 + (dbgW*2), dbgY, dbgW, 20, "Rand Event", self, self.onDebugEvent)
        self.debugEventBtn:initialise()
        self.requestPanel:addChild(self.debugEventBtn)
    end

    -- Right Side: Active Loans List (Manual approach, no ScrollingListBox)
    local rightX = x + leftW + 20
    self.activeLabel = ISLabel:new(rightX, y, S4_UI.FH_S, "Active Loans:", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self:addChild(self.activeLabel)
    
    self.listPanel = ISPanel:new(rightX, y + 25, leftW, self:getHeight() - y - 35)
    self.listPanel.backgroundColor.a = 0
    self.listPanel.borderColor.a = 0.3
    self.listPanel:initialise()
    self:addChild(self.listPanel)

    self:onLenderChange()
    self:updateLoanListUI()
end

function S4_Bank_Loans:updateLoanListUI()
    if not self.listPanel then return end
    
    -- Clear previous items
    self.listPanel:clearChildren()
    
    local py = 5
    local itemH = 65
    local UserName = self.player:getUsername()
    local LoanModData = ModData.get("S4_LoanData")
    
    if LoanModData and LoanModData[UserName] then
        for i, loan in ipairs(LoanModData[UserName]) do
            if loan.Status == "Active" then
                local item = ISPanel:new(5, py, self.listPanel:getWidth() - 10, itemH)
                item.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.4}
                item.borderColor = {r=0.5, g=0.5, b=0.5, a=0.5}
                item:initialise()
                self.listPanel:addChild(item)
                
                local lx = 5
                local ly = 5
                local label = ISLabel:new(lx, ly, 14, loan.Lender, 1, 1, 1, 1, UIFont.Small, true)
                item:addChild(label)
                ly = ly + 16
                
                local status = string.format("Repaid: $ %s / $ %s", S4_UI.getNumCommas(loan.Repaid or 0), S4_UI.getNumCommas(loan.TotalToPay))
                label = ISLabel:new(lx, ly, 14, status, 0.8, 0.8, 0.8, 1, UIFont.Small, true)
                item:addChild(label)
                ly = ly + 16
                
                label = ISLabel:new(lx, ly, 14, "Card: " .. loan.CardNum, 0.6, 0.6, 0.6, 1, UIFont.Small, true)
                item:addChild(label)
                
                local btnW = 70
                local btnH = 20
                local repayBtn = ISButton:new(item:getWidth() - btnW - 5, (itemH / 2) - (btnH / 2), btnW, btnH, "Repay", self, function() self:onRepayLoan(i, loan) end)
                repayBtn:initialise()
                repayBtn.backgroundColor = {r=0.4, g=0.2, b=0.2, a=0.8}
                item:addChild(repayBtn)
                
                py = py + itemH + 5
                if py + itemH > self.listPanel:getHeight() then break end -- Limit view to visible area
            end
        end
    end
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
    self.lastViewedRate = rate
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
    
    local cardNum = self.BankUI.IEUI.ComUI.CardNumber
    if not cardNum then
        self.ComUI:AddMsgBox("No Card", nil, "Please insert a card to receive the funds.")
        return
    end

    local rate = self:getCurrentRate(lender.baseRate)
    if self.lastViewedRate ~= rate then
        self.ComUI:AddMsgBox("Rate Changed", nil, "Disculpa las molestias, Los valores cambiaron.")
        self:updateCalculation()
        return
    end

    local total = math.floor(amount * (1 + rate))
    local timestamp = S4_Utils.getLogTime()
    local displayTime = S4_Utils.getLogTimeMin(timestamp)

    sendClientCommand("S4ED", "RequestLoan", {
        cardNum, lender.name, amount, rate, total, lender.deadline, timestamp, displayTime
    })

    self.ComUI:AddMsgBox("Loan Approved", nil, string.format("$ %s has been deposited into card %s.", S4_UI.getNumCommas(amount), cardNum))
    self.refreshTimer = 30
end

function S4_Bank_Loans:update()
    ISPanel.update(self)
    if self.refreshTimer and self.refreshTimer > 0 then
        self.refreshTimer = self.refreshTimer - 1
        if self.refreshTimer == 0 then
            self:updateLoanListUI()
        end
    end
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

function S4_Bank_Loans:onDebugDeadline()
    local gt = getGameTime()
    gt:setDay(gt:getDay() + 2)
    self.ComUI:AddMsgBox("Debug", nil, "Advanced time by 2 days.")
end

function S4_Bank_Loans:onDebugRepay()
    local LoanModData = ModData.get("S4_LoanData")
    local UserName = self.player:getUsername()
    if LoanModData and LoanModData[UserName] then
        for i, loan in ipairs(LoanModData[UserName]) do
            if loan.Status == "Active" then
                self:onRepayLoan(i, loan)
                break
            end
        end
    end
end

function S4_Bank_Loans:onDebugEvent()
    local modData = ModData.getOrCreate("S4_KnoxNews")
    local events = {"STOCK_RISE", "STOCK_CRASH", "GUERRILLAS", "FUEL_SHORTAGE"}
    modData.CurrentEventID = events[ZombRand(#events) + 1]
    self.ComUI:AddMsgBox("Debug", nil, "Event Changed: " .. modData.CurrentEventID)
    self:updateCalculation()
end
