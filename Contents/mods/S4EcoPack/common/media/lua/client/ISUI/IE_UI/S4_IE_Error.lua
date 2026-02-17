S4_IE_Error = ISPanel:derive("S4_IE_Error")

function S4_IE_Error:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=1, g=1, b=1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI -- Save parent UI reference
    o.ComUI = IEUI.ComUI -- computer ui
    o.player = IEUI.player
    o.Moving = true
    return o
end

function S4_IE_Error:initialise()
    ISPanel.initialise(self)

end

function S4_IE_Error:createChildren()
    ISPanel.createChildren(self)

    local TextList = {
        "The page cannot be displayed",
        --
        "The page you ar looking for is currently unavailable. The Website might",
        "be experiecing technical difficulties, or you may need to adjust",
        "your browser settings.",
        --
        "Pleses try the following :",
        --
        "* Try to Refresh page, or try angain later.",
        "* Try to reboot your computer.",
        "* Please make sure that the satellite antenna and computer are connected.",
        "* Check the contract with the network contractor to see the status of the network.",
        --
        "Cannot find server or DNS Error",
        "Internet Exploere",
    }

    local x = 10
    local y = 20
    local IconSize = S4_UI.FH_M * 2

    self.IconImage = ISImage:new(x, y, IconSize, IconSize, getTexture("media/textures/S4_Icon/Icon_64_IEError.png"))
    self.IconImage.autoScale = true
    self.IconImage:initialise()
    self.IconImage:instantiate()
    self:addChild(self.IconImage)

    local LabelX = x + IconSize + 10
    local LabelY = y
    for i = 1, 11 do
        local Text = TextList[i]
        local TextFont = UIFont.Small
        if i == 1 then 
            TextFont = UIFont.Medium 
            LabelY = y + 10
        end
        self["Lable"..i] = ISLabel:new(LabelX, LabelY, S4_UI.FH_S, Text, 0, 0, 0, 1, TextFont, true)
        self:addChild(self["Lable"..i])
        if i == 1 then
            LabelX = x + 10
            LabelY = LabelY + IconSize + 10
        elseif i == 4 then
            LabelY = LabelY + S4_UI.FH_S + 10
        elseif i == 5 then
            LabelX = x + IconSize
            LabelY = LabelY + S4_UI.FH_S + 10
        elseif i == 9 then
            LabelX = x + 10
            LabelY = LabelY + S4_UI.FH_S + 10
        else
            LabelY = LabelY + S4_UI.FH_S
        end
    end
    LabelY = LabelY + 20

    local WidthMax = 0
    for i = 1, 11 do
        if self["Lable"..i] then
            WidthMax = math.max(WidthMax, self["Lable"..i]:getRight() + 20)
        end
    end
    
    if self.Reload then
        self.IEUI:ReloadFixUISize(WidthMax, LabelY)
    else
        self.IEUI:FixUISize(WidthMax, LabelY)
    end
end

function S4_IE_Error:render()
    ISPanel.render(self)

end

-- Functions related to moving and exiting UI
function S4_IE_Error:onMouseDown(x, y)
    if not self.Moving then return end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_Error:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.IEUI.moving = false
end

function S4_IE_Error:onChangeComboBox()
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

function S4_IE_Error:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
