S4_IE_ZomBank = ISPanel:derive("S4_IE_ZomBank")

function S4_IE_ZomBank:new(IEUI, x, y)
    local width = IEUI.ComUI:getWidth() - 12
    local TaskH = IEUI.ComUI:getHeight() - IEUI.ComUI.TaskBarY
    local height = IEUI.ComUI:getHeight() - ((S4_UI.FH_S * 2) + 23 + TaskH)

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=88/255, g=14/255, b=145/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI -- Save parent UI reference
    o.ComUI = IEUI.ComUI -- computer ui
    o.player = IEUI.player
    o.Moving = true
    o.CardList = {}
    return o
end

function S4_IE_ZomBank:initialise()
    ISPanel.initialise(self)
    local W, H, Count = S4_UI.getGoodShopSizeZ(self.ComUI)
    self.IEUI:FixUISize(817, H)

    self:LoadCardData()
end

function S4_IE_ZomBank:LoadCardData()
    local PlayerName = self.player:getUsername()
    local CardModData = ModData.get("S4_CardData")
    if CardModData then
        for CardNumber, Data in pairs(CardModData) do
            if Data.Master and Data.Master == PlayerName then
                if not self.CardList[CardNumber] then
                    self.CardList[CardNumber] = Data
                end
            end
        end
    end
end

function S4_IE_ZomBank:createChildren()
    ISPanel.createChildren(self)

    local Lx = (self:getWidth() / 2) - (getTextManager():MeasureStringX(UIFont.Large, "ZomBank") / 2)
    local Ly = 20 + (S4_UI.FH_L / 2)
    self.LogoLabel1 = ISLabel:new(Lx, Ly, S4_UI.FH_L, "ZomBank", 1, 1, 1, 1, UIFont.Large, true)
    self:addChild(self.LogoLabel1)
    
    local x = 10
    local y = 10
    local InfoW = (self:getWidth() - 30)/3
    local LogoH = (S4_UI.FH_L * 2) + 10
    local LogoW = self:getWidth() - InfoW - 30
    self.LogoPanel = ISPanel:new(x, y, LogoW, LogoH)
    self.LogoPanel.BankUI = self
    self.LogoPanel.createChildren = S4_IE_ZomBank.LogoChildren
    self.LogoPanel.backgroundColor.a = 0
    self.LogoPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=0}
    self.LogoPanel:initialise()
    self.LogoPanel:setVisible(false)
    self:addChild(self.LogoPanel)

    local InfoX = x + LogoW + 10 
    self.InfoPanel = ISPanel:new(InfoX, y, InfoW, LogoH)
    self.InfoPanel.BankUI = self
    self.InfoPanel.backgroundColor.a = 0
    self.InfoPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.InfoPanel:initialise()
    self:addChild(self.InfoPanel)

    local InfoLY = 5
    self.BalanceLabel = ISLabel:new(10, InfoLY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self.InfoPanel:addChild(self.BalanceLabel)
    InfoLY = InfoLY + S4_UI.FH_M
    self.DebtLabel = ISLabel:new(10, InfoLY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self.InfoPanel:addChild(self.DebtLabel)

    y = y + LogoH + 10

    local MenuH = S4_UI.FH_L + 10
    self.MenuPanel = ISPanel:new(x, y, self:getWidth() - 20, MenuH)
    self.MenuPanel.BankUI = self
    self.MenuPanel.createChildren = S4_IE_ZomBank.MenuChildren
    self.MenuPanel.backgroundColor.a = 0
    self.MenuPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.MenuPanel:initialise()
    self:addChild(self.MenuPanel)
    y = y + MenuH + 10

    local PanelY = y + S4_UI.FH_M + 10
    local PanelH = math.floor(S4_UI.FH_M + 4)
    for i = 1, 20 do
        if i == 1 then
            PanelY = PanelY + PanelH - 1
        else
            if PanelY + PanelH + 9 > self:getHeight() then
                self.IEUI:FixUISize(817, PanelY+ 11)
                break
            else
                PanelY = PanelY + PanelH - 1
            end
        end
    end

    self.MainX = x
    self.MainY = y
    self.MainW = self:getWidth() - 20
    self.MainH = self:getHeight() - LogoH - MenuH - 40
    self.MainPanel = S4_Bank_Home:new(self, self.MainX, self.MainY, self.MainW, self.MainH)
    self.MainPanel:initialise()
    self:addChild(self.MainPanel)
end

function S4_IE_ZomBank:LogoChildren()
    ISPanel.createChildren(self)
    local Lx = (self:getWidth() / 2) - (getTextManager():MeasureStringX(UIFont.Large, "ZomBank") / 2)
    local Ly = (self:getHeight() / 2) - (S4_UI.FH_L / 2)
    self.LogoLabel1 = ISLabel:new(Lx, Ly, S4_UI.FH_L, "ZomBank", 1, 1, 1, 1, UIFont.Large, true)
    self:addChild(self.LogoLabel1)
end

function S4_IE_ZomBank:MenuChildren()
    ISPanel.createChildren(self)
    local x, y = 0, 0
    local BtnW = self:getWidth() / 5

    self.HomeBtn= ISButton:new(x, y, BtnW, self:getHeight(), getText("IGUI_S4_Bank_Home"), self, S4_IE_ZomBank.MenuBtnClick)
    self.HomeBtn.internal = "Home"
    self.HomeBtn.font = UIFont.Large
    self.HomeBtn.backgroundColorMouseOver.a = 0.7
    self.HomeBtn.backgroundColor.a = 0
    self.HomeBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.HomeBtn.textColor.a = 0.9
    self.HomeBtn:initialise()
    self:addChild(self.HomeBtn)
    x = x + BtnW - 1

    self.TransferBtn= ISButton:new(x, y, BtnW, self:getHeight(), getText("IGUI_S4_Bank_Transfer"), self, S4_IE_ZomBank.MenuBtnClick)
    self.TransferBtn.internal = "Transfer"
    self.TransferBtn.font = UIFont.Large
    self.TransferBtn.backgroundColorMouseOver.a = 0.7
    self.TransferBtn.backgroundColor.a = 0
    self.TransferBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.TransferBtn.textColor.a = 0.9
    self.TransferBtn:initialise()
    self:addChild(self.TransferBtn)
    x = x + BtnW - 1

    self.AccountBtn= ISButton:new(x, y, BtnW, self:getHeight(), getText("IGUI_S4_Bank_AccountActivity"), self, S4_IE_ZomBank.MenuBtnClick)
    self.AccountBtn.internal = "Account"
    self.AccountBtn.font = UIFont.Large
    self.AccountBtn.backgroundColorMouseOver.a = 0.7
    self.AccountBtn.backgroundColor.a = 0
    self.AccountBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.AccountBtn.textColor.a = 0.9
    self.AccountBtn:initialise()
    self:addChild(self.AccountBtn)
    x = x + BtnW - 1

    self.ProfileBtn= ISButton:new(x, y, BtnW, self:getHeight(), getText("IGUI_S4_Bank_MyProfile"), self, S4_IE_ZomBank.MenuBtnClick)
    self.ProfileBtn.internal = "Profile"
    self.ProfileBtn.font = UIFont.Large
    self.ProfileBtn.backgroundColorMouseOver.a = 0.7
    self.ProfileBtn.backgroundColor.a = 0
    self.ProfileBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.ProfileBtn.textColor.a = 0.9
    self.ProfileBtn:initialise()
    self:addChild(self.ProfileBtn)
    x = x + BtnW - 1

    self.LoanBtn= ISButton:new(x, y, BtnW, self:getHeight(), getText("IGUI_S4_Bank_Loans"), self, S4_IE_ZomBank.MenuBtnClick)
    self.LoanBtn.internal = "Loans"
    self.LoanBtn.font = UIFont.Large
    self.LoanBtn.backgroundColorMouseOver.a = 0.7
    self.LoanBtn.backgroundColor.a = 0
    self.LoanBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.LoanBtn.textColor.a = 0.9
    self.LoanBtn:initialise()
    self:addChild(self.LoanBtn)
end

function S4_IE_ZomBank:render()
    ISPanel.render(self)
    local CardNumber = self.ComUI.CardNumber
    local UserName = self.player:getUsername()
    local BalanceText = getText("IGUI_S4_Label_CardBalance") .. getText("IGUI_S4_Network_UnKnown")
    local DebtText = getText("IGUI_S4_Label_TotalDebt") .. getText("IGUI_S4_Network_UnKnown")
    local balanceColor = {r=1, g=1, b=1}
    local debtColor = {r=1, g=1, b=1}

    if CardNumber then
        local CardModData = ModData.get("S4_CardData")
        local LoanModData = ModData.get("S4_LoanData")
        
        if CardModData and CardModData[CardNumber] then
            local money = CardModData[CardNumber].Money
            BalanceText = getText("IGUI_S4_Label_CardBalance") .. "$ " .. S4_UI.getNumCommas(money)
            if money < 0 then
                balanceColor = {r=1, g=0, b=0}
            end

            -- Calculate net debt (Loans - Balance)
            local totalLoanDebt = 0
            if LoanModData and LoanModData[UserName] then
                for _, loan in pairs(LoanModData[UserName]) do
                    if loan.Status == "Active" then
                        totalLoanDebt = totalLoanDebt + (loan.TotalToPay - (loan.Repaid or 0))
                    end
                end
            end

            local uncoveredDebt = totalLoanDebt - money

            if uncoveredDebt > 0 then
                DebtText = getText("IGUI_S4_Label_TotalDebt") .. "$ " .. S4_UI.getNumCommas(uncoveredDebt)
                debtColor = {r=1, g=0, b=0}
            else
                DebtText = getText("IGUI_S4_DebtFree")
                debtColor = {r=0, g=1, b=0}
            end
        end
    end
    
    self.BalanceLabel:setName(BalanceText)
    self.BalanceLabel.r = balanceColor.r
    self.BalanceLabel.g = balanceColor.g
    self.BalanceLabel.b = balanceColor.b
    
    self.DebtLabel:setName(DebtText)
    self.DebtLabel.r = debtColor.r
    self.DebtLabel.g = debtColor.g
    self.DebtLabel.b = debtColor.b
end

-- button click
function S4_IE_ZomBank:BtnClick(Button)
    local internal = Button.internal
    if not internal then return end

end

function S4_IE_ZomBank:MenuBtnClick(Button)
    local internal = Button.internal
    if not internal then return end
    self.BankUI:setMain(internal)
end

function S4_IE_ZomBank:setMain(MainType)
    if self.MainPanel then
        self.MainPanel:close()
    end
    -- self.MainX, self.MainY, self.MainW, self.MainH
    if MainType == "Home" then
        self.MainPanel = S4_Bank_Home:new(self, self.MainX, self.MainY, self.MainW, self.MainH)
    elseif MainType == "Transfer" then
        self.MainPanel = S4_Bank_Transfer:new(self, self.MainX, self.MainY, self.MainW, self.MainH)
    elseif MainType == "Account" then
        self.MainPanel = S4_Bank_Account:new(self, self.MainX, self.MainY, self.MainW, self.MainH)
    elseif MainType == "Profile" then
        self.MainPanel = S4_Bank_Profile:new(self, self.MainX, self.MainY, self.MainW, self.MainH)
    elseif MainType == "Loans" then
        self.MainPanel = S4_Bank_Loans:new(self, self.MainX, self.MainY, self.MainW, self.MainH)
    end
    if self.MainPanel then
        self.MainPanel:initialise()
        self:addChild(self.MainPanel)
    end
end

-- Functions related to moving and exiting UI
function S4_IE_ZomBank:onMouseDown(x, y)
    if not self.Moving then return end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_ZomBank:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.IEUI.moving = false
end

function S4_IE_ZomBank:close()
    self:setVisible(false)
    self:removeFromUIManager()
end