S4_IE_SNetwork = ISPanel:derive("S4_IE_SNetwork")
local function getCardCreditLimit()
    local maxNegative = 1000
    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.MaxNegativeBalance then
        maxNegative = SandboxVars.S4SandBox.MaxNegativeBalance
    end
    if maxNegative < 0 then
        maxNegative = 0
    end
    return -maxNegative
end

function S4_IE_SNetwork:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.2, g=0.4, b=0.6, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI -- Save parent UI reference
    o.ComUI = IEUI.ComUI -- computer ui
    o.player = IEUI.player
    o.Moving = true
    return o
end

function S4_IE_SNetwork:initialise()
    ISPanel.initialise(self)

end

function S4_IE_SNetwork:createChildren()
    ISPanel.createChildren(self)

    local PlayerName = self.player:getUsername()
    local WidthMax = 0
    -- information maximum length
    local InfoText1 = getText("IGUI_S4_Label_ID") .. PlayerName
    local InfoTextW1 = getTextManager():MeasureStringX(UIFont.Small, InfoText1) + 20
    local InfoText2 = getText("IGUI_S4_Label_CardBalance") .. "$ 000,000,000,000"
    local InfoTextW2 = getTextManager():MeasureStringX(UIFont.Small, InfoText2) + 20
    local InfoText3 = getText("IGUI_S4_Label_ContractState") .. "0000-00-00 00:00"
    local InfoTextW3 = getTextManager():MeasureStringX(UIFont.Small, InfoText3) + 20
    local InfoPanelW = math.max(InfoTextW1, InfoTextW2, InfoTextW3)

    local LogoW = 400
    local LogoInfoW = InfoPanelW + LogoW + 100
    WidthMax = math.max(WidthMax, LogoInfoW)

    local HomeText1 = string.format(getText("IGUI_S4_SNetwork_Text1"), PlayerName)
    local HomeTextW1 = getTextManager():MeasureStringX(UIFont.Small, HomeText1) + 40
    local HomeTextW2 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_SNetwork_Text2")) + 40
    local HomeTextW3 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_SNetwork_Text3")) + 40
    local HomeTextW4 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_SNetwork_Text4")) + 40
    local HomeTextW5 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_SNetwork_Text5")) + 40
    local HomeW = math.max(HomeTextW1, HomeTextW2, HomeTextW3, HomeTextW4, HomeTextW5)
    WidthMax = math.max(WidthMax, HomeW)

    local SelectTextW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_S4_SNetwork_SelectionPack"))
    local SelectPanelW = HomeW - 40
    local SelectBoxW = SelectPanelW - SelectTextW - 30
    local BtnW = SelectPanelW - 20
    WidthMax = math.max(WidthMax, SelectPanelW)

    local InfoPanelX = WidthMax - InfoPanelW - 10
    local InfoPnaelY = 10
    local InfoPanelH = (S4_UI.FH_S * 3) + 10
    self.InfoPanel = ISPanel:new(InfoPanelX, InfoPnaelY, InfoPanelW, InfoPanelH)
    self.InfoPanel.backgroundColor.a = 0
    self.InfoPanel.borderColor = {r=1, g=1, b=1, a=1}
    self:addChild(self.InfoPanel)

    if not self.player:getKnownRecipes():contains("CraftS4CardReader") then
        self.RecipeBtn = ISButton:new(InfoPanelX, self.InfoPanel:getBottom() + 5, InfoPanelW, S4_UI.FH_M, getText("IGUI_S4_SNetwork_RecipBtn"), self, S4_IE_SNetwork.BtnClick)
        self.RecipeBtn.internal = "Recipe"
        self.RecipeBtn.backgroundColor.a = 0.4
        self.RecipeBtn.borderColor.a = 1
        self.RecipeBtn:initialise()
        self:addChild(self.RecipeBtn)
    end

    local LogoX = ((WidthMax - InfoPanelW - 50) / 2) - (LogoW / 2)
    local LogoY = 0
    local LogoH = 90
    self.LogoImg = ISImage:new(LogoX, LogoY, LogoW, LogoH, getTexture("media/textures/S4_Img/Img_Logo_ZomNetwork.png"))
    self:addChild(self.LogoImg)

    -- (ID: playername)
    local InfoLabelText1 = getText("IGUI_S4_Label_ID") .. PlayerName
    local InfoLabelY = InfoPnaelY + 5
    self.InfoLabel1 = ISLabel:new(InfoPanelX + 10, InfoLabelY, S4_UI.FH_S, InfoLabelText1, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel1)
    InfoLabelY = InfoLabelY + S4_UI.FH_S
    -- (Card Balance: $ 0)
    local InfoLabelText2 = getText("IGUI_S4_CardReader_UnInsert") 
    if self.ComUI.CardNumber and self.ComUI.CardMoney then 
        InfoLabelText2 = "$ " .. S4_UI.getNumCommas(self.ComUI.CardMoney)
    end
    InfoLabelText2 = getText("IGUI_S4_Label_CardBalance") .. InfoLabelText2
    self.InfoLabel2 = ISLabel:new(InfoPanelX + 10, InfoLabelY, S4_UI.FH_S, InfoLabelText2, 0, 0, 0, 1, UIFont.Small, true)
    if self.ComUI.CardMoney and self.ComUI.CardMoney < 0 then
        self.InfoLabel2.r = 1
        self.InfoLabel2.g = 0
        self.InfoLabel2.b = 0
    end
    self:addChild(self.InfoLabel2)
    InfoLabelY = InfoLabelY + S4_UI.FH_S
    -- (Network Period: 0000-00-00 00:00)
    local InfoLabelText3 = getText("IGUI_S4_Network_UnAvailable")
    if self.ComUI.NetContract then InfoLabelText3 = self.ComUI.NetPeriod end -- Needs modification
    InfoLabelText3 = getText("IGUI_S4_Label_ContractState") .. InfoLabelText3
    self.InfoLabel3 = ISLabel:new(InfoPanelX + 10, InfoLabelY, S4_UI.FH_S, InfoLabelText3, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.InfoLabel3)
    
    -- %s, welcome to Zom Network. (welcom SNetwerk. #usernaem)
    local HomeY = math.max(self.InfoPanel:getBottom(), self.LogoImg:getBottom()) + S4_UI.FH_S
    local HomeX1 = (WidthMax / 2) - ((HomeTextW1 - 40) / 2)
    local HomeText1 = string.format(getText("IGUI_S4_SNetwork_Text1"), PlayerName)
    self.HomeLabel1 = ISLabel:new(HomeX1, HomeY, S4_UI.FH_S, HomeText1, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.HomeLabel1)
    HomeY = HomeY + S4_UI.FH_S
    -- SNetwerk's services offer the best quality, speed, and data capacity.
    local HomeX2 = (WidthMax / 2) - ((HomeTextW2 - 40) / 2)
    local HomeText2 = getText("IGUI_S4_SNetwork_Text2")
    self.HomeLabel2 = ISLabel:new(HomeX2, HomeY, S4_UI.FH_S, HomeText2, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.HomeLabel2)
    HomeY = HomeY + S4_UI.FH_S
    -- We provide more than just a service, we provide hope to this damn world.
    local HomeX3 = (WidthMax / 2) - ((HomeTextW3 - 40) / 2)
    local HomeText3 = getText("IGUI_S4_SNetwork_Text3")
    self.HomeLabel3 = ISLabel:new(HomeX3, HomeY, S4_UI.FH_S, HomeText3, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.HomeLabel3)
    HomeY = HomeY + S4_UI.FH_S
    -- In fact, it seems like you have no choice other than our service.
    local HomeX4 = (WidthMax / 2) - ((HomeTextW4 - 40) / 2)
    local HomeText4 = getText("IGUI_S4_SNetwork_Text4")
    self.HomeLabel4 = ISLabel:new(HomeX4, HomeY, S4_UI.FH_S, HomeText4, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.HomeLabel4)
    HomeY = HomeY + S4_UI.FH_S
    -- We ask for your interest and support!
    local HomeX5 = (WidthMax / 2) - ((HomeTextW5 - 40) / 2)
    local HomeText5 = getText("IGUI_S4_SNetwork_Text5")
    self.HomeLabel5 = ISLabel:new(HomeX5, HomeY, S4_UI.FH_S, HomeText5, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.HomeLabel5)

    -- selectPanel
    local SelectPanelX = (WidthMax / 2) - (SelectPanelW / 2)
    local SelectPanelY = self.HomeLabel5:getBottom() + S4_UI.FH_S
    local SelectPanelH = 10 + (S4_UI.FH_S * 6) + S4_UI.FH_M
    self.SelectPanel = ISPanel:new(SelectPanelX, SelectPanelY, SelectPanelW, SelectPanelH)
    self.SelectPanel.backgroundColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.SelectPanel)

    local SelectX = SelectPanelX + 10
    local SelectY = SelectPanelY + 5
    self.SelectLabel = ISLabel:new(SelectX, SelectY, S4_UI.FH_S, getText("IGUI_S4_Label_NetPack"), 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SelectLabel)

    self.BuyPakcBox = ISComboBox:new(self.SelectLabel:getRight(), SelectY, SelectBoxW, S4_UI.FH_S, self)
    self.BuyPakcBox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.BuyPakcBox.onChange = S4_IE_SNetwork.onChangeComboBox
    self:addChild(self.BuyPakcBox)
    self.BuyPakcBox:addOptionWithData(getText("IGUI_S4_SNetwork_1Day"), 1)
    self.BuyPakcBox:addOptionWithData(getText("IGUI_S4_SNetwork_7Day"), 7)
    self.BuyPakcBox:addOptionWithData(getText("IGUI_S4_SNetwork_31Day"), 31)
    self.BuyPakcBox:addOptionWithData(getText("IGUI_S4_SNetwork_365Day"), 365)
    SelectY = SelectY + (S4_UI.FH_S * 2)

    self.SelectTextLabel1 = ISLabel:new(SelectX, SelectY, S4_UI.FH_S, "", 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SelectTextLabel1)
    SelectY = SelectY + S4_UI.FH_S
    self.SelectTextLabel2 = ISLabel:new(SelectX, SelectY, S4_UI.FH_S, "", 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SelectTextLabel2)
    SelectY = SelectY + S4_UI.FH_S
    self.SelectTextLabel3 = ISLabel:new(SelectX, SelectY, S4_UI.FH_S, "", 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SelectTextLabel3)
    SelectY = SelectY + (S4_UI.FH_S * 2)

    self.BuyBtn = ISButton:new(SelectX, SelectY, BtnW, S4_UI.FH_M, getText("IGUI_S4_Com_Btn_Buy"), self, S4_IE_SNetwork.BtnClick)
    self.BuyBtn.internal = "Buy"
    self.BuyBtn.backgroundColor.a = 0.4
    self.BuyBtn.borderColor.a = 1
    self.BuyBtn:initialise()
    self:addChild(self.BuyBtn)

    if self.BuyPakcBox and self.BuyPakcBox:getSelected() then
        local SelectNum = self.BuyPakcBox:getSelected()
        local SelectDay = self.BuyPakcBox:getOptionData(SelectNum)
        local Price = SandboxVars.S4SandBox.NetworkOneDayPrice
        local Text1 = string.format(getText("IGUI_S4_SNetwork_DayText1"), SelectDay)
        local Text2 = string.format(getText("IGUI_S4_SNetwork_DayText2"), SelectDay)
        local Text3 = string.format(getText("IGUI_S4_SNetwork_DayText3"), Price)
        self.SelectTextLabel1:setName(Text1)
        self.SelectTextLabel2:setName(Text2)
        self.SelectTextLabel3:setName(Text3)
    end

    local MaxY = self.SelectPanel:getBottom() + 10
    if self.Reload then
        self.IEUI:ReloadFixUISize(WidthMax, MaxY)
    else
        self.IEUI:FixUISize(WidthMax, MaxY)
    end
end

function S4_IE_SNetwork:BtnClick(Button)
    local internal = Button.internal
    if internal == "Buy" then
        self:ActionContract()
    elseif internal == "Recipe" then
        self.player:getKnownRecipes():add("CraftS4CardReader")
    end
end

function S4_IE_SNetwork:ActionContract()
    if self.BuyPakcBox and self.BuyPakcBox:getSelected() then
        local SelectNum = self.BuyPakcBox:getSelected()
        local SelectDay = self.BuyPakcBox:getOptionData(SelectNum)
        local Price = SandboxVars.S4SandBox.NetworkOneDayPrice
        if SelectNum ~= 1 then
            local Discount = SandboxVars.S4SandBox["NetPackDiscont"..SelectDay]
            local DiscountPrice = math.floor((Price * SelectDay) * (Discount * 0.01))
            Price = (Price * SelectDay) - DiscountPrice
        end
        local CardModData = ModData.get("S4_CardData")
        if self.ComUI.CardNumber and CardModData[self.ComUI.CardNumber] then
            if self.ComUI.isCardPassword then
                if (CardModData[self.ComUI.CardNumber].Money - Price) >= getCardCreditLimit() then
                    local Period = S4_Utils.getDateTimeText()
                    -- If the contract is still active, add to the existing period.
                    -- If it's already expired (NetContract is false), start from now.
                    if self.ComUI.NetContract and self.ComUI.NetPeriod then 
                        Period = self.ComUI.NetPeriod 
                    end
                    local NewPeriod = S4_Utils.setAddTime(Period, (SelectDay * 24))

                    -- Server transfers and computer data updates
                    local player = self.player
                    sendClientCommand("S4ED", "RemoveMoney", {self.ComUI.CardNumber, Price})
                    local LogTime = S4_Utils.getLogTime()
                    sendClientCommand("S4ED", "AddCardLog", {self.ComUI.CardNumber, LogTime, "Withdraw", Price, player:getUsername(), "Survivor Network"})
                    self.ComUI.CardMoney = self.ComUI.CardMoney - Price
                    local ComModData = self.ComUI.ComObj:getModData()
                    ComModData.ComPeriod = NewPeriod
                    self.ComUI.NetPeriod = NewPeriod
                    self.ComUI.NetContract = true
                    S4_Utils.SnycObject(self.ComUI.ComObj)
                    self.IEUI:ReloadUI()
                else -- MsgBox Insufficient Balance
                    self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Card_UnderBalance"), false, false)
                end 
            else -- Card password Check UI, MsgBox card password input
                self.ComUI:CardPasswordCheck()
                self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Card_CheckPassword"), false, false)
            end
        else -- MsgBox There is no card to use for payment.
            self.ComUI:AddMsgBox(getText("IGUI_S4_Com_Msg_Error"), false, getText("IGUI_S4_Msg_Card_NotInsert"), getText("IGUI_S4_Msg_Card_PlzInsert"), false)
        end
    end
end

-- Functions related to moving and exiting UI
function S4_IE_SNetwork:onMouseDown(x, y)
    if not self.Moving then return end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_SNetwork:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.IEUI.moving = false
end

function S4_IE_SNetwork:onChangeComboBox()
    -- ISComboBox.onChange(self)
    if self.BuyPakcBox and self.BuyPakcBox:getSelected() then
        local SelectNum = self.BuyPakcBox:getSelected()
        local SelectDay = self.BuyPakcBox:getOptionData(SelectNum)
        local Price = SandboxVars.S4SandBox.NetworkOneDayPrice
        local Text1 = string.format(getText("IGUI_S4_SNetwork_DayText1"), SelectDay)
        local Text2 = string.format(getText("IGUI_S4_SNetwork_DayText2"), SelectDay)
        if SelectNum ~= 1 then
            local Discount = SandboxVars.S4SandBox["NetPackDiscont"..SelectDay]
            local DiscountPrice = math.floor((Price * SelectDay) * (Discount * 0.01))
            Price = (Price * SelectDay) - DiscountPrice
        end
        local Text3 = string.format(getText("IGUI_S4_SNetwork_DayText3"), Price)
        self.SelectTextLabel1:setName(Text1)
        self.SelectTextLabel2:setName(Text2)
        self.SelectTextLabel3:setName(Text3)
    end
end

-- function S4_IE_SNetwork:render()

-- end

function S4_IE_SNetwork:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
