S4_Sys_CardReader = ISPanel:derive("S4_Sys_CardReader")

function S4_Sys_CardReader:new(SysUI, Px, Py, Pw, Ph)
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

function S4_Sys_CardReader:initialise()
    ISPanel.initialise(self)
end

function S4_Sys_CardReader:createChildren()
    ISPanel.createChildren(self)

    local Tx = 40
    local Ty = 20
    if self.SysUI.IconImg then
        Tx = Tx + 40 + 64
    end
    local TextMaxX = 0

    local SystemText = getText("IGUI_S4_Label_System")
    local CardReaderText = getText("IGUI_S4_CardReader_UnInstall")
    local CardInsertText = getText("IGUI_S4_CardReader_UnInsert")
    local CardInfoText = getText("IGUI_S4_Label_CardInfo")
    local CardNumberText = getText("IGUI_S4_Network_UnKnown")
    local CardMasterText = getText("IGUI_S4_Network_UnKnown")
    if self.ComUI.CardReaderInstall then
        CardReaderText = getText("IGUI_S4_CardReader_Install")
        if self.ComUI.CardNumber then
            CardInsertText = getText("IGUI_S4_CardReader_Insert")
            CardNumberText = self.ComUI.CardNumber
            CardMasterText = self.ComUI.CardMaster
        end
    end
    
    self.SystemLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, SystemText, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.SystemLabel)
    TextMaxX = math.max(TextMaxX, self.SystemLabel:getWidth())
    Ty = Ty + S4_UI.FH_S

    CardReaderText = getText("IGUI_S4_Label_CardReader") .. CardReaderText
    self.CardReaderLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, CardReaderText, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.CardReaderLabel)
    TextMaxX = math.max(TextMaxX, self.CardReaderLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S

    CardInsertText = getText("IGUI_S4_Label_CardInsert") .. CardInsertText
    self.CardInsertLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, CardInsertText, 0, 0, 0, 1, UIFont.Small, true)
    self:addChild(self.CardInsertLabel)
    TextMaxX = math.max(TextMaxX, self.CardInsertLabel:getWidth() + 15)
    Ty = Ty + S4_UI.FH_S * 2
    if self.ComUI.CardReaderInstall then
        self.CardInfoLabel = ISLabel:new(Tx, Ty, S4_UI.FH_S, CardInfoText, 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.CardInfoLabel)
        TextMaxX = math.max(TextMaxX, self.CardInfoLabel:getWidth())
        Ty = Ty + S4_UI.FH_S

        CardNumberText = getText("IGUI_S4_Label_CardNumber") .. CardNumberText
        self.CardNumberLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, CardNumberText, 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.CardNumberLabel)
        TextMaxX = math.max(TextMaxX, self.CardNumberLabel:getWidth() + 15)
        Ty = Ty + S4_UI.FH_S

        CardMasterText = getText("IGUI_S4_Label_CardMaster") .. CardMasterText
        self.CardMasterLabel = ISLabel:new(Tx + 15, Ty, S4_UI.FH_S, CardMasterText, 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.CardMasterLabel)
        TextMaxX = math.max(TextMaxX, self.CardMasterLabel:getWidth() + 15)
        Ty = Ty + S4_UI.FH_S * 2

        self.CardBoxLabel = ISLabel:new(10, Ty, S4_UI.FH_S, getText("IGUI_S4_Label_CardBox"), 0, 0, 0, 1, UIFont.Small, true)
        self:addChild(self.CardBoxLabel)
        TextMaxX = math.max(TextMaxX, self.CardBoxLabel:getWidth() + 15)
        Ty = Ty + S4_UI.FH_S

        local CardBoxW = math.max((Tx + TextMaxX + 40), 400) - 20
        local CardBoxH = ((S4_UI.FH_S + 4) * 4)
        self.CardBox = ISScrollingListBox:new(10, Ty, CardBoxW, CardBoxH)
        self.CardBox:initialise()
        self.CardBox:instantiate()
        self.CardBox.drawBorder = true
        self.CardBox.backgroundColor.a = 0.2
        self.CardBox.ReaderUI = self
        self.CardBox.vscroll:setX(30000)
        self.CardBox.vscroll:setVisible(false)
        self.CardBox.doDrawItem = S4_Sys_CardReader.doDrawItem_CardBox
        self.CardBox.onMouseDown = S4_Sys_CardReader.onMouseDown_CardBox
        self:addChild(self.CardBox)
        Ty = Ty + CardBoxH

        TextMaxX = Tx + TextMaxX + 40
        if TextMaxX < 400 then TextMaxX = 400 end
        self:AddCardItems()
        local BtnH = (TextMaxX - 40) / 3
        if self.ComUI.CardNumber then
            self.ChangeBtn = ISButton:new(10, Ty + S4_UI.FH_S, BtnH, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_CardChnage"), self, S4_Sys_CardReader.BtnClick)
            self.ChangeBtn.internal = "Change"
            self.ChangeBtn.textColor = {r=0, g=0, b=0, a=1}
            self.ChangeBtn.borderColor = {r=0, g=0, b=0, a=1}
            self.ChangeBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
            self.ChangeBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
            self.ChangeBtn:initialise()
            self:addChild(self.ChangeBtn)

            self.ReturnBtn = ISButton:new(20 + BtnH, Ty + S4_UI.FH_S, BtnH, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_CardReturn"), self, S4_Sys_CardReader.BtnClick)
            self.ReturnBtn.internal = "Return"
            self.ReturnBtn.textColor = {r=0, g=0, b=0, a=1}
            self.ReturnBtn.borderColor = {r=0, g=0, b=0, a=1}
            self.ReturnBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
            self.ReturnBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
            self.ReturnBtn:initialise()
            self:addChild(self.ReturnBtn)
        else
            self.InsertBtn = ISButton:new(10, Ty + S4_UI.FH_S, BtnH, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_CardInsert"), self, S4_Sys_CardReader.BtnClick)
            self.InsertBtn.internal = "Insert"
            self.InsertBtn.textColor = {r=0, g=0, b=0, a=1}
            self.InsertBtn.borderColor = {r=0, g=0, b=0, a=1}
            self.InsertBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
            self.InsertBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
            self.InsertBtn:initialise()
            self:addChild(self.InsertBtn)
        end
    else
        TextMaxX = Tx + TextMaxX + 40
        if TextMaxX < 350 then TextMaxX = 350 end
    end
    Ty = Ty + S4_UI.FH_S

    local BtnH = (TextMaxX - 40) / 3
    local BtnX = TextMaxX - BtnH - 10
    self.OKBtn = ISButton:new(BtnX, Ty, BtnH, S4_UI.FH_S, getText("IGUI_S4_Com_Btn_OK"), self, S4_Sys_CardReader.BtnClick)
    self.OKBtn.internal = "Ok"
    self.OKBtn.textColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.borderColor = {r=0, g=0, b=0, a=1}
    self.OKBtn.backgroundColor = {r=179/255, g=180/255, b=179/255, a=1}
    self.OKBtn.backgroundColorMouseOver = {r=0, g=0, b=0, a=0.3}
    self.OKBtn:initialise()
    self:addChild(self.OKBtn)
    Ty = Ty + self.OKBtn:getHeight() + 10
    if self.Reload then
        self.SysUI:ReloadFixUISize(TextMaxX, Ty)
    else
        self.SysUI:FixUISize(TextMaxX, Ty)
    end
    
end

function S4_Sys_CardReader:AddCardItems()
    self.CardBox:clear()
    local playerInv = self.player:getInventory()
    local InvItems = playerInv:getItems()
    local CardModData = ModData.get("S4_CardData")
    for i = 0, InvItems:size() - 1 do
        local item = InvItems:get(i)
        if instanceof(item, "InventoryContainer") then
            local Container = item:getInventory()
            local ContainerItems = Container:getItems()
            if ContainerItems:size() > 0 then
                for i = 0, ContainerItems:size() - 1 do
                    local Containeritem = ContainerItems:get(i)
                    if Containeritem:getFullType() == "Base.CreditCard" and S4_Utils.ItemCheck(Containeritem) then
                        local itemModData = Containeritem:getModData()
                        if itemModData.S4CardNumber and CardModData[itemModData.S4CardNumber] then
                            local Data = {}
                            Data.item = Containeritem
                            Data.Texture = Containeritem:getTex()
                            Data.DisplayName = Containeritem:getDisplayName()
                            Data.CardNumber = itemModData.S4CardNumber
                            Data.CardMaster = CardModData[itemModData.S4CardNumber].Master
                            self.CardBox:addItem(Data.DisplayName, Data)
                        end
                    end
                end
            else -- When the bag is empty, check whether the item is in the bag.
                if item:getFullType() == "Base.CreditCard" and S4_Utils.ItemCheck(item) then
                    local itemModData = item:getModData()
                    if itemModData.S4CardNumber and CardModData[itemModData.S4CardNumber] then
                        local Data = {}
                        Data.item = item
                        Data.Texture = item:getTex()
                        Data.DisplayName = item:getDisplayName()
                        Data.CardNumber = itemModData.S4CardNumber
                        Data.CardMaster = CardModData[itemModData.S4CardNumber].Master
                        self.CardBox:addItem(Data.DisplayName, Data)
                    end
                end
            end
        else
            if item:getFullType() == "Base.CreditCard" and S4_Utils.ItemCheck(item) then
                local itemModData = item:getModData()
                if itemModData.S4CardNumber and CardModData[itemModData.S4CardNumber] then
                    local Data = {}
                    Data.item = item
                    Data.Texture = item:getTex()
                    Data.DisplayName = item:getDisplayName()
                    Data.CardNumber = itemModData.S4CardNumber
                    Data.CardMaster = CardModData[itemModData.S4CardNumber].Master
                    self.CardBox:addItem(Data.DisplayName, Data)
                end
            end
        end
    end
end

function S4_Sys_CardReader:onMouseDown_CardBox(x, y)
    ISScrollingListBox.onMouseDown(self, x, y)
    local list = self
    local ReaderUI = self.ReaderUI
    local rowIndex = list:rowAt(x, y)
    if rowIndex > 0 then
        list.selectedRow = rowIndex 
        list.selectedItem = self.items[rowIndex].item
    end
end

function S4_Sys_CardReader:doDrawItem_CardBox(y, item, alt)
    local yOffset = S4_UI.FH_S + 4
    local Data = item.item
    if self.selectedRow == item.index then
        self:drawRect(0, y, self:getWidth(), yOffset, 0.3, 0, 0, 0)
    end

    self:drawTextureScaledAspect(Data.Texture, 2, y + 2, yOffset - 4, yOffset - 4, 1, 1, 1, 1)
    self:drawText(Data.DisplayName, yOffset, y, 0, 0, 0, 1, UIFont.Small)
    self:drawRectBorder(0, y + yOffset, self:getWidth(), 1, 0.9, 0.4, 0.4, 0.4)
    return y + yOffset
end

-- button function
function S4_Sys_CardReader:BtnClick(Button)
    local internal = Button.internal
    if internal == "Ok" then
        self.SysUI:close()
    elseif internal == "Insert" then
        self:InsertCard()
        self.SysUI:ReloadUI()
    elseif internal == "Change" then
        self:ReturnCard()
        self:InsertCard()
        self.SysUI:ReloadUI()
    elseif internal == "Return" then
        self:ReturnCard()
        self.SysUI:ReloadUI()
    end
end

-- card removal
function S4_Sys_CardReader:ReturnCard()
    if self.ComUI.CardNumber then
        local CardNumber = self.ComUI.CardNumber
        local CardMaster = self.ComUI.CardMaster
        local CardName = string.format(getText("IGUI_S4_Item_CreditCard"), CardMaster) .. string.format(getText("IGUI_S4_Item_CardNumber"), CardNumber)

        local CreateCard = instanceItem("Base.CreditCard")
        local ReturnCarditem = self.player:getInventory():AddItem(CreateCard)
        local CardModData = ReturnCarditem:getModData()
        CardModData.S4CardNumber = CardNumber
        S4_Utils.SnycObject(ReturnCarditem)
        ReturnCarditem:setName(CardName)

        local ComModData = self.ComUI.ComObj:getModData()
        ComModData.S4CardNumber = false
        ComModData.S4CardMaster = false
        S4_Utils.SnycObject(self.ComUI.ComObj)

        self.ComUI.CardNumber = false
        self.ComUI.CardMaster = false
        self.ComUI.CardMoney = false
        self.ComUI.CardPassword = false
    end
end
-- insert card
function S4_Sys_CardReader:InsertCard()
    if self.CardBox.selectedItem then
        local CardNumber = self.CardBox.selectedItem.CardNumber
        local CardMaster = self.CardBox.selectedItem.CardMaster
        local Carditem = self.CardBox.selectedItem.item
        local ComModData = self.ComUI.ComObj:getModData()
        ComModData.S4CardNumber = CardNumber
        ComModData.S4CardMaster = CardMaster
        S4_Utils.SnycObject(self.ComUI.ComObj)
        self.ComUI.CardNumber = CardNumber
        self.ComUI.CardMaster = CardMaster
        self.ComUI.isCardPassword = false

        local CardModData = ModData.get("S4_CardData")
        if CardModData[ComModData.S4CardNumber] then
            self.ComUI.CardMoney = CardModData[ComModData.S4CardNumber].Money
            self.ComUI.CardPassword = CardModData[ComModData.S4CardNumber].Password
        end

        if Carditem:getWorldItem() then 
            Carditem:getWorldItem():getSquare():transmitRemoveItemFromSquare(Carditem:getWorldItem())
            ISInventoryPage.dirtyUI()
        else
            if Carditem:getContainer() then
                Carditem:getContainer():Remove(Carditem)
            else
                self.player:getInventory():Remove(Carditem)
            end
        end
    end
end

-- Functions related to moving and exiting UI
function S4_Sys_CardReader:onMouseDown(x, y)
    if not self.Moving then return end
    self.SysUI.moving = true
    self.SysUI:bringToTop()
    self.ComUI.TopApp = self.SysUI
end

function S4_Sys_CardReader:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.SysUI.moving = false
end

function S4_Sys_CardReader:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
