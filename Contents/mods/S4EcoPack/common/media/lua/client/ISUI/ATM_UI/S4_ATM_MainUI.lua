S4_ATM_MainUI = ISPanel:derive("S4_ATM_MainUI")
S4_ATM_MainUI.instance = nil

function S4_ATM_MainUI:show(player, Obj)
    local square = player:getSquare()
    posX = square:getX()
    posY = square:getY()
    if S4_ATM_MainUI.instance == nil then
        S4_ATM_MainUI.instance = S4_ATM_MainUI:new(player, Obj)
        S4_ATM_MainUI.instance:initialise()
        S4_ATM_MainUI.instance:instantiate()
    end
    S4_ATM_MainUI.instance:addToUIManager()
    S4_ATM_MainUI.instance:setVisible(true)
    return S4_ATM_MainUI.instance
end

function S4_ATM_MainUI:new(player, Obj)
    local o = {}
    local width, height, x, y = S4_UI.getScreenSizeATM()
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player 
    o.Obj = Obj
    o.backgroundColor = {r=11/255, g=58/255, b=151/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.moveWithMouse = true
    o.posX = player:getSquare():getX()
    o.posY = player:getSquare():getY()
    o:setWantKeyEvents(true)
    return o
end

function S4_ATM_MainUI:initialise()
    ISPanel.initialise(self)
    local AtmModData = self.Obj:getModData()
    if AtmModData.S4CardNumber then
        self.CardNumber = AtmModData.S4CardNumber
        local CardModData = ModData.get("S4_CardData")[self.CardNumber]
        if CardModData then
            self.CardPassword = CardModData.Password
        end
    end
end

function S4_ATM_MainUI:createChildren()
    ISPanel.createChildren(self)

    self.InfoPanel = S4_ATM_Info:new(self, 20, 20, self:getWidth() - 40, self:getHeight()/6)
    self.InfoPanel:initialise()
    self:addChild(self.InfoPanel)

    local BtnW = ((self:getWidth() - 40) / 5) - 20
    local BtnH = ((self:getHeight() - self.InfoPanel:getHeight() - 40) / 3) - 20
    local BtnX = 20
    local BtnY = self.InfoPanel:getBottom() + 20

    self.MenuBtn1 = ISButton:new(BtnX, BtnY, BtnW, BtnH, getText("IGUI_S4_ATM_Transfer"), self, S4_ATM_MainUI.BtnAction)
    self.MenuBtn1.internal = "Transfer"
    BtnY = BtnY + BtnH + 20
    self.MenuBtn2 = ISButton:new(BtnX, BtnY, BtnW, BtnH, getText("IGUI_S4_ATM_Deposit"), self, S4_ATM_MainUI.BtnAction)
    self.MenuBtn2.internal = "Deposit"
    BtnY = BtnY + BtnH + 20
    self.MenuBtn3 = ISButton:new(BtnX, BtnY, BtnW, BtnH, getText("IGUI_S4_ATM_Withdraw"), self, S4_ATM_MainUI.BtnAction)
    self.MenuBtn3.internal = "Withdraw"

    BtnX = BtnX + ((BtnW + 20) * 4) + 20
    BtnY = self.InfoPanel:getBottom() + 20

    self.MenuBtn4 = ISButton:new(BtnX, BtnY, BtnW, BtnH, getText("IGUI_S4_ATM_Balance"), self, S4_ATM_MainUI.BtnAction)
    self.MenuBtn4.internal = "Balance"
    BtnY = BtnY + BtnH + 20
    self.MenuBtn5 = ISButton:new(BtnX, BtnY, BtnW, BtnH, getText("IGUI_S4_ATM_Setting"), self, S4_ATM_MainUI.BtnAction)
    self.MenuBtn5.internal = "Setting"
    BtnY = BtnY + BtnH + 20
    self.MenuBtn6 = ISButton:new(BtnX, BtnY, BtnW, BtnH, getText("IGUI_S4_ATM_Exit"), self, S4_ATM_MainUI.BtnAction)
    self.MenuBtn6.internal = "Exit"
    BtnY = BtnY + BtnH + 20

    for i = 1, 6 do
        self["MenuBtn"..i].font = UIFont.Medium
        self["MenuBtn"..i].textColor = {r=0, g=0, b=0, a=1}
        self["MenuBtn"..i].backgroundColor = {r=1/255, g=180/255, b=245/255, a=1}
        self["MenuBtn"..i].borderColor = {r=1, g=1, b=1, a=1}
        self["MenuBtn"..i]:initialise()
        self["MenuBtn"..i]:instantiate()
        
        self:addChild(self["MenuBtn"..i])
        if self.CardNumber and self.CardNumber ~= "Null" and self.isPassword then
            self["MenuBtn"..i]:setVisible(true)
        else
            if i == 1 or i == 6 then
                self["MenuBtn"..i]:setVisible(true)
            elseif i == 5 and self.CardNumber then
                self["MenuBtn"..i]:setVisible(true)
            else
                self["MenuBtn"..i]:setVisible(false)
            end
        end
    end

    local HomeW = ((self:getWidth() - 40) / 5) * 3
    local HomeH = self:getHeight() - self.InfoPanel:getHeight() - 60
    local HomeX = BtnW + 40
    local HomeY = self.InfoPanel:getBottom() + 20
    -- self.HomePanel = S4_ATM_Home:new(self, HomeX, HomeY, HomeW, HomeH)
    if self.CardPassword then
        self.HomePanel = S4_ATM_Password:new(self, HomeX, HomeY, HomeW, HomeH)
        self.HomePanel.OnlyCheck = true
    else
        self.HomePanel = S4_ATM_Home:new(self, HomeX, HomeY, HomeW, HomeH)
    end
    self.HomePanel:initialise()
    self:addChild(self.HomePanel)
end

function S4_ATM_MainUI:render()
    ISPanel.render(self)

    -- Close UI when moving when not in ATM action
    if not self.EventAction then 
        local NewPosX, NewPoxY = self.player:getX(), self.player:getY()
        if self.posX ~= NewPosX or self.posY ~= NewPoxY then
            local posX, posY = math.floor(self.posX), math.floor(self.posY)
            NewPosX, NewPoxY = math.floor(self.player:getX()), math.floor(self.player:getY())
            if posX ~= NewPosX or posY ~= NewPoxY then
                self:close()
            end
        end
    end
end

function S4_ATM_MainUI:setMain(CompleteMsg)
    self.MenuBtn1.internal = "Transfer"
    self.MenuBtn1:setTitle(getText("IGUI_S4_ATM_Transfer"))
    self.MenuBtn2.internal = "Deposit"
    self.MenuBtn2:setTitle(getText("IGUI_S4_ATM_Deposit"))
    self.MenuBtn3.internal = "Withdraw"
    self.MenuBtn3:setTitle(getText("IGUI_S4_ATM_Withdraw"))
    self.MenuBtn4.internal = "Balance"
    self.MenuBtn4:setTitle(getText("IGUI_S4_ATM_Balance"))
    self.MenuBtn5.internal = "Setting"
    self.MenuBtn5:setTitle(getText("IGUI_S4_ATM_Setting"))
    self.MenuBtn6.internal = "Exit"
    self.MenuBtn6:setTitle(getText("IGUI_S4_ATM_Exit"))
    if self.CardNumber and self.CardNumber ~= "Null" and self.isPassword then
        for i = 1, 6 do
            self["MenuBtn"..i]:setVisible(true)
        end
    else
        for i = 1, 6 do
            if i == 1 or i == 6 then
                self["MenuBtn"..i]:setVisible(true)
            elseif i == 5 and self.CardNumber then
                self["MenuBtn"..i]:setVisible(true)
            else
                self["MenuBtn"..i]:setVisible(false)
            end
        end
    end
    if CompleteMsg then
        self:setHomeMsgPanel(CompleteMsg)
    else
        self:setHomePanel("Home")
    end
end

function S4_ATM_MainUI:BtnAction(Button)
    if self.EventAction then return end
    local internal = Button.internal
    if internal == "Transfer" then
        if self.CardNumber and self.CardNumber ~= "Null" then -- When there is card information, settings screen
            self:setHomePanel("Transfer_Card")
        else
            self:setHomePanel("Transfer_Cash")
        end
    elseif internal == "Transfer_Card" then
        self:setHomePanel("Transfer_Card")
    elseif internal == "Transfer_Cash" then
        self:setHomePanel("Transfer_Cash")
    elseif internal == "Deposit" then
        self:setHomePanel("Deposit")
    elseif internal == "Withdraw" then
        self:setHomePanel("Withdraw")
    elseif internal == "Balance" then
        self:setHomePanel("Balance")
    elseif internal == "Setting" then
        if self.CardNumber ~= "Null" then -- When there is card information, settings screen
            self:setHomePanel("Setting")
        else -- When using a new card, set a new password
            self:setHomePanel("PasswordChange")
        end
    elseif internal == "Exit" then
        self:close()
    elseif internal == "Undo" then
        self:setMain(false)
    -- Password setting related
    elseif internal == "Password_Clear" then
        self.HomePanel.DumpPassword = ""
        self.HomePanel:setMasked()
    elseif internal == "Password_OK" then
        self.HomePanel:PasswordAction()
    elseif internal == "PasswordChange" then
        self:setHomePanel("PasswordChange")
    elseif internal == "MainCard" then
        self:setHomePanel("MainCard")
    elseif internal == "setMainCard" then
        self.HomePanel:setMainCard()
    elseif internal == "Deposit_Ok" then
        self.HomePanel:ActionDeposit()
    elseif internal == "Withdraw_Ok" then
        self.HomePanel:ActionWithdraw()
    elseif internal == "Transfer_Ok" then
        self.HomePanel:AtcionTransfer()
    end
end

function S4_ATM_MainUI:setHomePanel(HomeType)
    if not HomeType then return end
    if self.HomePanel then self.HomePanel:close() end
    local HomeW = ((self:getWidth() - 40) / 5) * 3
    local HomeH = self:getHeight() - self.InfoPanel:getHeight() - 60
    local HomeX = ((self:getWidth() - 40) / 5) + 20
    local HomeY = self.InfoPanel:getBottom() + 20
    if HomeType == "Home" then
        self.HomePanel = S4_ATM_Home:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "Setting" then
        self.HomePanel = S4_ATM_Setting:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "PasswordChange" then
        self.HomePanel = S4_ATM_Password:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "PasswordCheck" then
        self.HomePanel = S4_ATM_Password:new(self, HomeX, HomeY, HomeW, HomeH)
        self.HomePanel.OnlyCheck = true
    elseif HomeType == "MainCard" then
        self.HomePanel = S4_ATM_MainCard:new(self, HomeX, HomeY, HomeW, HomeH)
    -- elseif HomeType == "Transfer" then
    --     self.HomePanel = S4_ATM_Transfer:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "Transfer_Card" then
        self.HomePanel = S4_ATM_Transfer_Card:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "Transfer_Cash" then
        self.HomePanel = S4_ATM_Transfer_Cash:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "Deposit" then
        self.HomePanel = S4_ATM_Deposit:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "Withdraw" then
        self.HomePanel = S4_ATM_Withdraw:new(self, HomeX, HomeY, HomeW, HomeH)
    elseif HomeType == "Balance" then
        self.HomePanel = S4_ATM_Balance:new(self, HomeX, HomeY, HomeW, HomeH)
    end
    self.HomePanel:initialise()
    self:addChild(self.HomePanel)
end

function S4_ATM_MainUI:setHomeMsgPanel(Msg)
    self.HomePanel:close()
    local HomeW = ((self:getWidth() - 40) / 5) * 3
    local HomeH = self:getHeight() - self.InfoPanel:getHeight() - 60
    local HomeX = ((self:getWidth() - 40) / 5) + 20
    local HomeY = self.InfoPanel:getBottom() + 20

    self.HomePanel = S4_ATM_Home:new(self, HomeX, HomeY, HomeW, HomeH)
    self.HomePanel.CompleteMsg = Msg
    self.HomePanel:initialise()
    self:addChild(self.HomePanel)
end

function S4_ATM_MainUI:isKeyConsumed(key)
    local KeyBlcok = {  
        [79] = true, [2] = true, [80] = true, [3] = true, [81] = true, [4] = true, [75] = true, [5] = true, [76] = true, [6] = true, 
        [77] = true, [7] = true, [71] = true, [8] = true, [72] = true, [9] = true, [73] = true, [10] = true, [82] = true, [11] = true,
        [156] = true, [28] = true, [14] = true
    }
    return KeyBlcok[key] or key == Keyboard.KEY_ESCAPE
end

function S4_ATM_MainUI:onKeyRelease(key)
    if self.EventAction then return end
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
    if self.HomePanel and self.HomePanel.NumberPad then
        local NumSet = false
        local ActSet = false

        local numKeyMap = {
            [79] = 1, [2] = 1, [80] = 2, [3] = 2, [81] = 3, [4] = 3, [75] = 4, [5] = 4, [76] = 5, [6] = 5, 
            [77] = 6, [7] = 6, [71] = 7, [8] = 7, [72] = 8, [9] = 8, [73] = 9, [10] = 9, [82] = 0, [11] = 0
        }
        local actKeyMap = { [156] = "Enter", [28] = "Enter", [14] = "Reset" }
        if numKeyMap[key] then
            NumSet = numKeyMap[key]
            if #self.HomePanel.DumpPassword < 4 then
                self.HomePanel.DumpPassword = self.HomePanel.DumpPassword .. NumSet
                self.HomePanel:setMasked()
            else
                self.HomePanel:setMsg(getText("IGUI_S4_ATM_Msg_Password_Max"))
            end
        elseif actKeyMap[key] then
            ActSet = actKeyMap[key]
            if ActSet == "Enter" then
                self.HomePanel:PasswordAction()
            elseif ActSet == "Reset" then
                self.HomePanel.DumpPassword = ""
                self.HomePanel:setMasked()
            end
        end
    end
end

function S4_ATM_MainUI:close()
    if self.CardNumber then
        self.InfoPanel:ReturnCard(self.CardNumber)
    end
    S4_ATM_MainUI.instance = nil
    ISPanel.close(self)
    self:removeFromUIManager()
end
