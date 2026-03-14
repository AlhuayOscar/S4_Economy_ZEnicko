S4_Sys_BankMsgBox = ISPanel:derive("S4_Sys_BankMsgBox")

function S4_Sys_BankMsgBox:new(SysUI, Px, Py, Pw, Ph)
    local o = ISPanel:new(Px, Py, Pw, Ph)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=189/255, g=190/255, b=189/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
    o.SysUI = SysUI -- Sys UI Reference (Parent UI)
    o.ComUI = SysUI.ComUI -- Com UI Reference
    o.player = SysUI.player
    o.Moving = true
    return o
end

function S4_Sys_BankMsgBox:initialise()
    ISPanel.initialise(self)
    
end

function S4_Sys_BankMsgBox:createChildren()
    ISPanel.createChildren(self)

    local Tx = 20
    local Ty = 20
    if self.SysUI.IconImg then
        Tx = Tx + 20 + 64
    end
    local TextMaxX = 0
    -- message box
    local MsgText1, MsgText2, MsgText3 = "", "", ""
    if self.SysUI.MsgText1 then
        MsgText1 = self.SysUI.MsgText1
    end

    self.MsgLabel1 = ISLabel:new(Tx, Ty, S4_UI.FH_S, MsgText1, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.MsgLabel1)
    TextMaxX = math.max(TextMaxX, self.MsgLabel1:getWidth())
    Ty = Ty + S4_UI.FH_S

    if self.SysUI.MsgText2 then
        MsgText2 = self.SysUI.MsgText2
        self.MsgLabel2 = ISLabel:new(Tx, Ty, S4_UI.FH_S, MsgText2, 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.MsgLabel2)
        TextMaxX = math.max(TextMaxX, self.MsgLabel2:getWidth())
        Ty = Ty + S4_UI.FH_S
    end
    if self.SysUI.MsgText3 then
        MsgText3 = self.SysUI.MsgText3
        self.MsgLabel3 = ISLabel:new(Tx, Ty, S4_UI.FH_S, MsgText3, 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.MsgLabel3)
        TextMaxX = math.max(TextMaxX, self.MsgLabel3:getWidth())
        Ty = Ty + S4_UI.FH_S
    end
    Ty = Ty + S4_UI.FH_S
    local TitleW = getTextManager():MeasureStringX(UIFont.Small, self.SysUI.TitleName) + (S4_UI.FH_S*3)
    TextMaxX = math.max(TextMaxX, TitleW)
    TextMaxX = math.max(TextMaxX, 200)
    
    TextMaxX = Tx + TextMaxX + 20

    local BtnX = TextMaxX - 110
    self.CancelBtn = ISButton:new(BtnX, Ty, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_Cancel"), self, S4_Sys_BankMsgBox.BtnClick)
    self.CancelBtn.internal = "Cancel"
    self.CancelBtn.textColor = {r=0, g=0, b=0, a=1}
    self.CancelBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.CancelBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.CancelBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.CancelBtn:initialise()
    self:addChild(self.CancelBtn)
    BtnX = BtnX - 110

    self.OKBtn = ISButton:new(BtnX, Ty, 100, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_BankMsgBox.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    Ty = Ty + self.OKBtn:getHeight() + 10
    
    
    self.SysUI:FixUISize(TextMaxX, Ty)
end

function S4_Sys_BankMsgBox:BtnClick(Button)
    local internal = Button.internal
    if internal == "Ok" then
        if self.SysUI.CheckType == "Transfer" then

        elseif self.SysUI.CheckType == "Remove" then
            if self.SysUI.pUI then
                local UI = self.SysUI.pUI
                if self.SysUI.CardNumber then
                    sendClientCommand("S4ED", "RemoveCardData", {self.SysUI.CardNumber})
                    UI.BankUI:setMain("Home")
                    self.SysUI:close()
                end
            end
        elseif self.SysUI.CheckType == "Replacement" then
            local CardModData = ModData.get("S4_CardData")
            local NewCardNumber = 0
            for CardNumberList, _ in pairs(CardModData) do
                NewCardNumber = CardNumberList
            end
            NewCardNumber = NewCardNumber + 1
            local PlayerShopModData = ModData.get("S4_PlayerShopData")
            local DeliveryAdrress = false
            if PlayerShopModData[self.player:getUsername()] and PlayerShopModData[self.player:getUsername()].DeliveryList then
                for XYZCode, Dname in pairs(PlayerShopModData[self.player:getUsername()].DeliveryList) do
                    local CodeX, CodeY, CodeZ = string.match(XYZCode, "X(%d+)Y(%d+)Z(%d+)")
                    local x, y, z = tonumber(CodeX), tonumber(CodeY), tonumber(CodeZ)
                    -- local cell = getCell()
                    local square = getCell():getGridSquare(x, y, z)
                    if square then
                        DeliveryAdrress = XYZCode
                        break
                    end
                end
            end
            if NewCardNumber > 0 and DeliveryAdrress then
                if self.SysUI.pUI then
                    local UI = self.SysUI.pUI
                    if self.SysUI.CardNumber then
                        local LogTime =S4_Utils.getLogTime()
                        local DisplayTime = S4_Utils.getLogTimeMin(LogTime)
                        local DeliveryTime = S4_Utils.setAddTime(DisplayTime, 1)
                        sendClientCommand("S4ED", "ReplacementCardData", {self.SysUI.CardNumber,  NewCardNumber, LogTime, DisplayTime, DeliveryTime, DeliveryAdrress})
                        UI.BankUI:setMain("Home")
                        self.SysUI:close()
                    end
                end
            elseif not DeliveryAdrress then
                self.ComUI:AddMsgBox("Error - ZomBank", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_Bank_Msg_DeliveryFail"), getText("IGUI_S4_Bank_Msg_DeliveryFailTry"))
                self.SysUI:close()
            end
        elseif self.SysUI.CheckType == "CreditBuy" then
            if self.SysUI.onConfirm then
                self.SysUI.onConfirm()
            end
            self.SysUI:close()
        end
    elseif internal == "Cancel" then
        self.SysUI:close()
    end
end
-- Functions related to moving and exiting UI
function S4_Sys_BankMsgBox:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_BankMsgBox:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end


function S4_Sys_BankMsgBox:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
