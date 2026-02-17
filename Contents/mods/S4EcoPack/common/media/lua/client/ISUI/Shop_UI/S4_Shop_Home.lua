S4_Shop_Home = ISPanel:derive("S4_Shop_Home")

function S4_Shop_Home:new(ParentsUI, x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.76, g=0.76, b=0.76, a=0.1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.ParentsUI = ParentsUI
    o.IEUI = ParentsUI.IEUI
    o.ComUI = ParentsUI.ComUI
    o.player = ParentsUI.player
    return o
end

function S4_Shop_Home:initialise()
    ISPanel.initialise(self)
end

function S4_Shop_Home:createChildren()
    ISPanel.createChildren(self)
    local RecipeCheck = true 
    if self.player:getKnownRecipes():contains("CraftS4Signal") then RecipeCheck = false end
    
    local LabelX = 30
    local LabelY = 20
    self.Label1 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, string.format(getText("IGUI_S4_Shop_Home1"), self.player:getUsername()), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.Label1)
    LabelY = LabelY + S4_UI.FH_M

    self.Label2 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, getText("IGUI_S4_Shop_Home2"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.Label2)
    LabelY = LabelY + S4_UI.FH_M
    self.Label3 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, getText("IGUI_S4_Shop_Home3"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.Label3)
    LabelY = LabelY + S4_UI.FH_M
    self.Label4 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, getText("IGUI_S4_Shop_Home4"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.Label4)
    LabelY = LabelY + S4_UI.FH_M
    self.Label5 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, getText("IGUI_S4_Shop_Home5"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.Label5)
    LabelY = LabelY + S4_UI.FH_M
    if RecipeCheck then
        self.Label6 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, getText("IGUI_S4_Shop_Home6"), 1, 1, 1, 0.8, UIFont.Medium, true)
        self:addChild(self.Label6)
        LabelY = LabelY + S4_UI.FH_M
    end
    self.Label7 = ISLabel:new(LabelX, LabelY, S4_UI.FH_M, getText("IGUI_S4_Shop_Home7"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.Label7)
    LabelY = LabelY + S4_UI.FH_M + 10

    if RecipeCheck then
        self.RecipeBtn = ISButton:new(LabelX, LabelY, 200, S4_UI.FH_M, getText("IGUI_S4_Shop_RecipeBtn"), self, S4_Shop_Home.BtnClick)
        self.RecipeBtn.internal = "Recipe"
        self.RecipeBtn.backgroundColor.a = 0.4
        self.RecipeBtn.borderColor.a = 1
        self.RecipeBtn:initialise()
        self:addChild(self.RecipeBtn)
    end
end

function S4_Shop_Home:BtnClick(Button)
    local internal = Button.internal
    if internal == "Close" then
        self:close()
    elseif internal == "Recipe" then
        self.player:getKnownRecipes():add("CraftS4Signal")
    end
end

function S4_Shop_Home:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
