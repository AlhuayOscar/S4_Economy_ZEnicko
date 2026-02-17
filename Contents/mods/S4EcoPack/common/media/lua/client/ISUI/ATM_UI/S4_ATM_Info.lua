S4_ATM_Info = ISPanel:derive("S4_ATM_Info")

function S4_ATM_Info:new(AtmUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    -- o.backgroundColor = {r=11/255, g=48/255, b=131/255, a=1}
    -- o.borderColor = {r=1, g=1, b=1, a=0.8}
    o.backgroundColor.a = 0
    o.borderColor.a = 0
    o.AtmUI = AtmUI
    o.player = AtmUI.player
    return o
end

function S4_ATM_Info:initialise()
    ISPanel.initialise(self)
    self.ATM_Btn_W = ((self.AtmUI:getWidth() - 40) / 5) - 20
    self.CardX = self.ATM_Btn_W + 20
    self.CardY = 10
    self.CardW = (self.ATM_Btn_W + 20) * 3
    self.CardH = self:getHeight() - 20

    local ReturnString = getTextManager():MeasureStringX(UIFont.Small, "Return Card")
    self.ReturnX = self.CardX + self.CardW - ReturnString - 10
    local CardInsertString = getTextManager():MeasureStringX(UIFont.Medium, "Card Reader Slot")
    self.CardInsertX = self.CardX + (self.CardW / 2) - (CardInsertString / 2)
end

function S4_ATM_Info:createChildren()
    ISPanel.createChildren(self)

    local LogoString1 = getTextManager():MeasureStringX(UIFont.Medium, "ATM")
    local LogoString2 = getTextManager():MeasureStringX(UIFont.Small, "ZomBank")
    local LogoMaxString = self.ATM_Btn_W
    local LogoX1 = LogoMaxString / 2 - LogoString1 / 2
    local LogoX2 = LogoMaxString / 2 - LogoString2 / 2

    local LogoY = (self:getHeight() - (S4_UI.FH_M + S4_UI.FH_S)) / 2
    self.Logo1Label = ISLabel:new(LogoX1, LogoY, S4_UI.FH_M, "ATM", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.Logo1Label)
    LogoY = LogoY + S4_UI.FH_M
    self.Logo2Label = ISLabel:new(LogoX2, LogoY, S4_UI.FH_S, "ZomBank", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.Logo2Label)
end

function S4_ATM_Info:render()
    ISPanel.render(self)

    -- self:drawRect(self.CardX, self.CardY, self.CardW, self.CardH, 1, 0.2, 0.6, 0)
    -- Card Insert Panel
    self:drawRect(self.CardX, self.CardY, self.CardW, self.CardH, 1, 0, 0, 0)
    self:drawRectBorder(self.CardX, self.CardY, self.CardW, self.CardH, 0.8, 1, 1, 1)
    -- Card Insert
    local InsertY = self.CardY + ((self.CardH / 5) * 3)
    self:drawText("Card Reader Slot", self.CardInsertX, self.CardY, 1, 1, 1, 0.8, UIFont.Medium)
    self:drawRectBorder(self.CardX + 10, InsertY, self.CardW - 20, self.CardH / 5, 0.8, 1, 1, 1)
    if self.AtmUI.CardNumber then
        local ReturnA = 0.5
        if self.ReturnBtn then
            ReturnA = 0.8
        end
        self:drawText("Return Card", self.ReturnX, self.CardY, 1, 1, 1, ReturnA, UIFont.Small)
        self:drawRect(self.CardX + 15, InsertY + 5, self.CardW - 30, (self.CardH / 5) - 10, 0.8, 0, 1, 0)
    end
end

function S4_ATM_Info:onMouseUp(x, y)
    ISPanel.onMouseUp(self, x, y)

    if ISMouseDrag.dragging then
        if x >= self.CardX and x <= (self.CardX + self.CardW) then
            if y >= self.CardY and y <= (self.CardY + self.CardH) then
                local items = S4_Utils.getMoveItemTable(ISMouseDrag.dragging)
                local item = items[1]
                if item and item:getFullType() == "Base.CreditCard" then
                    self:InsertCard(item)
                end
            end
        end
    end
    if self.ReturnBtn then
        if self.AtmUI.CardNumber then
            self:ReturnCard(self.AtmUI.CardNumber)

            self.AtmUI:setMain(getText("IGUI_S4_ATM_CompleteMsg_ReturnCard"))
        end
    end
end

function S4_ATM_Info:onMouseMove(dx, dy)
    ISPanel.onMouseMove(dx, dy)
    local Mx, My = self:getMouseX(), self:getMouseY()

    self.ReturnBtn = false
    if Mx >= self.ReturnX and self.ReturnX <= (self.CardX + self.CardW) then
        if My >= self.CardY and My <= (self.CardY + S4_UI.FH_S) then
            self.ReturnBtn = true
        end
    end
end

function S4_ATM_Info:InsertCard(item)
    local itemModData = item:getModData()
    local AtmModData = self.AtmUI.Obj:getModData()
    if itemModData and AtmModData then
        if AtmModData.S4CardNumber then -- If there is a card inserted, return the existing card
            self:ReturnCard(AtmModData.S4CardNumber)
        end
        if itemModData.S4CardNumber then -- When inserting, when there is data on the card
            local CardModData = ModData.get("S4_CardData")
            if CardModData[itemModData.S4CardNumber] then
                -- Set card number and password in UI
                self.AtmUI.CardNumber = itemModData.S4CardNumber
                self.AtmUI.CardPassword = CardModData[itemModData.S4CardNumber].Password
                -- Save card number in ATM Object
                AtmModData.S4CardNumber = itemModData.S4CardNumber 
                S4_Utils.SnycObject(self.AtmUI.Obj)
            end
        else -- When inserting, when there is no data on the card
            self.AtmUI.CardNumber = "Null"
            self.AtmUI.CardPassword = false

            AtmModData.S4CardNumber = "Null" 
            S4_Utils.SnycObject(self.AtmUI.Obj)
        end

        -- Delete item
        if item:getWorldItem() then 
            item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
            ISInventoryPage.dirtyUI()
        else
            if item:getContainer() then
                item:getContainer():Remove(item)
            else
                self.player:getInventory():Remove(item)
            end
        end
        -- Password confirmation/initial setup window
        self.AtmUI:setHomePanel("PasswordCheck")
    end
end

function S4_ATM_Info:ReturnCard(CardNum)
    if CardNum then
        local CreateCard = instanceItem("Base.CreditCard")
        local OldCard = self.player:getInventory():AddItem(CreateCard)
        local UserName = self.player:getUsername()
        local DisplayName = string.format(getText("IGUI_S4_Item_CreditCard"), UserName)
        if CardNum ~= "Null" then
            local NewCardNumber = string.format(getText("IGUI_S4_Item_CardNumber"), CardNum)
            DisplayName = DisplayName .. NewCardNumber
            local OldCardModData = OldCard:getModData()
            OldCardModData.S4CardNumber = CardNum
            S4_Utils.SnycObject(OldCard)
        else
            DisplayName = DisplayName .. getText("IGUI_S4_Item_Unused")
        end
        OldCard:setName(DisplayName)

        local AtmModdata = self.AtmUI.Obj:getModData()
        if not AtmModdata then return end
        AtmModdata.S4CardNumber = false
        self.AtmUI.CardNumber = false
        self.AtmUI.CardPassword = false
        self.AtmUI.isPassword = false
        S4_Utils.SnycObject(self.AtmUI.Obj)
    end
end

function S4_ATM_Info:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_ATM_Info:onMouseDown(x, y)
    if self.AtmUI.moveWithMouse then
        self.AtmUI.moving = true
        self.AtmUI.dragOffsetX = x
        self.AtmUI.dragOffsetY = y
        self.AtmUI:bringToTop()
    end
end