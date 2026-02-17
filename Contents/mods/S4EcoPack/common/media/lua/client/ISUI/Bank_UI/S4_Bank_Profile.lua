S4_Bank_Profile = ISPanel:derive("S4_Bank_Profile")

function S4_Bank_Profile:new(BankUI, x, y, width, height)
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

function S4_Bank_Profile:initialise()
    ISPanel.initialise(self)
    self:setData()
end

function S4_Bank_Profile:setData()
    local PlayerName = self.player:getUsername()
    local CardModData = ModData.get("S4_CardData")
    if not CardModData then return end
    self.MyCards = {}
    for CardNum, OriginalData in pairs(CardModData) do
        local Data = copyTable(OriginalData)
        if Data.Master == PlayerName then
            Data.CardNumber = CardNum
            self.MyCards[CardNum] = Data
        end
    end
end

function S4_Bank_Profile:createChildren()
    ISPanel.createChildren(self)

    local x, y = 10, 10
    self.TextLabel1 = ISLabel:new(x, y, S4_UI.FH_M, getText("IGUI_S4_Bank_MyProfile"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.TextLabel1)

    local Cx = self.TextLabel1:getRight() + 10
    self.MyCardBox = ISComboBox:new(Cx, y, 100, S4_UI.FH_M, self)
    self.MyCardBox.backgroundColor = {r=88/255, g=14/255, b=145/255, a=1}
    self.MyCardBox.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.MyCardBox.onChange = S4_Bank_Profile.onChangeMyCard
    self:addChild(self.MyCardBox)
    if self.MyCards then
        for CardNumber, Data in pairs(self.MyCards) do
            local DisplayName = getText("IGUI_S4_Label_CardNumber") .. CardNumber
            self.MyCardBox:addOptionWithData(DisplayName, Data)
        end
    end
    y = y + S4_UI.FH_M + 10
    local InfoW = ((self:getWidth() - 30) / 3) * 2
    local InfoH = self:getHeight() - y - 10
    self.InfoPanel = ISPanel:new(x, y, InfoW, InfoH)
    self.InfoPanel.ProfileUI = self
    self.InfoPanel.createChildren = S4_Bank_Profile.InfoChildren
    self.InfoPanel.backgroundColor.a = 0
    self.InfoPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.InfoPanel:initialise()
    self.InfoPanel:instantiate()
    self:addChild(self.InfoPanel)
    x = x + InfoW + 10

    local ControlY = 10
    local ControlW = (self:getWidth() - 30) / 3
    local ControlH = self:getHeight() - 20
    self.ControlPanel = ISPanel:new(x, ControlY, ControlW, ControlH)
    self.ControlPanel.ProfileUI = self
    self.ControlPanel.createChildren = S4_Bank_Profile.ControlChildren
    self.ControlPanel.backgroundColor.a = 0
    self.ControlPanel.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.ControlPanel:initialise()
    self.ControlPanel:instantiate()
    self:addChild(self.ControlPanel)

    self:onChangeMyCard()
end

function S4_Bank_Profile:ControlChildren()
    ISPanel.createChildren(self)
    local x, y = 10, 10
    local BtnW = self:getWidth() - 20
    local BtnH = S4_UI.FH_M

    self.RemoveBtn = ISButton:new(x, y, BtnW, BtnH, getText("IGUI_S4_Bank_Btn_RemoveCard"), self, S4_Bank_Profile.BtnClick)
    self.RemoveBtn.internal = "Remove"
    self.RemoveBtn.font = UIFont.Medium
    self.RemoveBtn.backgroundColorMouseOver.a = 0.7
    self.RemoveBtn.backgroundColor.a = 0
    self.RemoveBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.RemoveBtn.textColor.a = 0.9
    self.RemoveBtn:initialise()
    self:addChild(self.RemoveBtn)
    y = y + BtnH + 10

    self.ReplacementBtn = ISButton:new(x, y, BtnW, BtnH, getText("IGUI_S4_Bank_Btn_ReplacementCard"), self, S4_Bank_Profile.BtnClick)
    self.ReplacementBtn.internal = "Replacement"
    self.ReplacementBtn.font = UIFont.Medium
    self.ReplacementBtn.backgroundColorMouseOver.a = 0.7
    self.ReplacementBtn.backgroundColor.a = 0
    self.ReplacementBtn.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.ReplacementBtn.textColor.a = 0.9
    self.ReplacementBtn:initialise()
    self:addChild(self.ReplacementBtn)
end

function S4_Bank_Profile:InfoChildren()
    ISPanel.createChildren(self)
    local x, y = 10, 10
    self.NumberLabel = ISLabel:new(x, y, S4_UI.FH_M, "", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.NumberLabel)
    y = y + S4_UI.FH_M

    self.MasterLabel = ISLabel:new(x, y, S4_UI.FH_M, "", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.MasterLabel)
    y = y + S4_UI.FH_M

    self.BalanceLabel = ISLabel:new(x, y, S4_UI.FH_M, "", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.BalanceLabel)
    y = y + S4_UI.FH_M
end

function S4_Bank_Profile:onChangeMyCard()
    if self.MyCardBox and self.MyCardBox:getSelected() then
        local Select = self.MyCardBox:getSelected()
        local SelectCardData = self.MyCardBox:getOptionData(Select)
        if Select and SelectCardData and SelectCardData.CardNumber then
            self.InfoPanel.NumberLabel:setName(getText("IGUI_S4_Label_CardNumber")..SelectCardData.CardNumber)
            self.InfoPanel.MasterLabel:setName(getText("IGUI_S4_Label_CardMaster")..SelectCardData.Master)
            local BalanceText = getText("IGUI_S4_Label_CardBalance").."$ ".. S4_UI.getNumCommas(SelectCardData.Money)
            self.InfoPanel.BalanceLabel:setName(BalanceText)
            if SelectCardData.Money < 0 then
                self.InfoPanel.BalanceLabel:setColor(1, 0, 0)
            else
                self.InfoPanel.BalanceLabel:setColor(1, 1, 1)
            end
        end
    end
end

function S4_Bank_Profile:BtnClick(Button)
    local function AddMsgBox(ComUI, ProfileUI, CheckType, CardNum, MsgTitle, IconImg, Text1, Text2, Text3)
        if ComUI.BankMsgBox then ComUI.BankMsgBox:close() end
        ComUI.BankMsgBox = S4_System:new(ComUI)
        ComUI.BankMsgBox.TitleName = MsgTitle
        ComUI.BankMsgBox.PageType = "BankMsgBox"
        ComUI.BankMsgBox.CheckType = CheckType
        ComUI.BankMsgBox.MsgText1 = Text1
        ComUI.BankMsgBox.pUI = ProfileUI
        ComUI.BankMsgBox.CardNumber = CardNum
        if IconImg then
            ComUI.BankMsgBox.IconImg = IconImg
        end
        if Text2 then
            ComUI.BankMsgBox.MsgText2 = Text2
        end
        if Text3 then
            ComUI.BankMsgBox.MsgText3 = Text3
        end
        ComUI.BankMsgBox:initialise()
        ComUI:addChild(ComUI.BankMsgBox)
        ComUI:AddTaskBar(ComUI.BankMsgBox)
    end
    local ProfileUI = self.ProfileUI
    local ComUI = self.ProfileUI.ComUI
    local Select = ProfileUI.MyCardBox:getSelected()
    local SelectCardData = ProfileUI.MyCardBox:getOptionData(Select)
    if Select and SelectCardData and SelectCardData.CardNumber then
        local CardNum = SelectCardData.CardNumber
        local internal = Button.internal

        -- Check the card password?
        if internal == "Remove" then
            AddMsgBox(ComUI, ProfileUI, "Remove", CardNum, getText("IGUI_S4_ShopAdminMsgBox"), false, getText("IGUI_S4_Bank_Msg_Remove1"), getText("IGUI_S4_Bank_Msg_Remove2"), getText("IGUI_S4_Bank_Msg_Remove3"))
        elseif internal == "Replacement" then
            AddMsgBox(ComUI, ProfileUI, "Replacement", CardNum, getText("IGUI_S4_ShopAdminMsgBox"), false, getText("IGUI_S4_Bank_Msg_Replacement1"), getText("IGUI_S4_Bank_Msg_Replacement2"), getText("IGUI_S4_Bank_Msg_Replacement3"))
        end
    end
end

function S4_Bank_Profile:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Bank_Profile:onMouseDown(x, y)
    if self.BankUI.moveWithMouse then
        self.BankUI.moving = true
        self.BankUI.dragOffsetX = x
        self.BankUI.dragOffsetY = y
        self.BankUI:bringToTop()
    end
end