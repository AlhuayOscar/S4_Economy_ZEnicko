S4_Computer_Start = ISPanel:derive("S4_Computer_Start")

function S4_Computer_Start:new(ComUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=192/255, g=192/255, b=192/255, a=1}
    o.borderColor = {r=0, g=0, b=0, a=1}
    o.ComUI = ComUI
    o.player = ComUI.player
    o.UI_Font = ComUI.UI_Font
    return o
end

function S4_Computer_Start:initialise()
    ISPanel.initialise(self)
end

function S4_Computer_Start:createChildren()
    ISPanel.createChildren(self)
    local FontH = self.FontH + 4
    local BtnW = self:getWidth() - 45
    local BtnY = self:getHeight() - FontH - 5
    self.Shutdown = ISButton:new(40, BtnY, BtnW, FontH, "Shut Down...", self, S4_Computer_Start.BtnClick)
    self.Shutdown.font = self.UI_Font
    self.Shutdown.FontH = self.FontH
    self.Shutdown.Img = getTexture("media/textures/S4_Icon/Icon_64_Shutdown.png")
    self.Shutdown.internal = "Shutdown"
    self.Shutdown.backgroundColor.a = 0
    self.Shutdown.backgroundColorMouseOver = {r=0.1, g=0.1, b=1, a=0.9}
    self.Shutdown.borderColor.a = 0
    self.Shutdown.textColor = {r=0, g=0, b=0, a=0.9}
    self.Shutdown.render = S4_Computer_Start.BtnRender
    self.Shutdown:initialise()
    self:addChild(self.Shutdown)

    BtnY = BtnY - FontH - 5
    self.LogOff = ISButton:new(40, BtnY, BtnW, FontH, "Log Off...", self, S4_Computer_Start.BtnClick)
    self.LogOff.font = self.UI_Font
    self.LogOff.FontH = self.FontH
    self.LogOff.Img = getTexture("media/textures/S4_Icon/Icon_64_LogOff.png")
    self.LogOff.internal = "LogOff"
    self.LogOff.backgroundColor.a = 0
    self.LogOff.backgroundColorMouseOver = {r=0.1, g=0.1, b=1, a=0.9}
    self.LogOff.borderColor.a = 0
    self.LogOff.textColor = {r=0, g=0, b=0, a=0.9}
    self.LogOff.render = S4_Computer_Start.BtnRender
    self.LogOff:initialise()
    self:addChild(self.LogOff)
    BtnY = BtnY - 7

    self.DumpPanel = ISPanel:new(40, BtnY, BtnW, 2)
    self.DumpPanel.backgroundColor = {r=159/255, g=160/255, b=159/255, a=1}
    self.DumpPanel.borderColor.a = 0
    self.DumpPanel:initialise(self)
    self:addChild(self.DumpPanel)
    BtnY = BtnY - FontH - 5

    self.Settings = ISButton:new(40, BtnY, BtnW, FontH, "Settings", self, S4_Computer_Start.BtnClick)
    self.Settings.font = self.UI_Font
    self.Settings.FontH = self.FontH
    self.Settings.Img = getTexture("media/textures/S4_Icon/Icon_64_Setting.png")
    self.Settings.internal = "Settings"
    self.Settings.backgroundColor.a = 0
    self.Settings.backgroundColorMouseOver = {r=0.1, g=0.1, b=1, a=0.9}
    self.Settings.borderColor.a = 0
    self.Settings.textColor = {r=0, g=0, b=0, a=0.9}
    self.Settings.render = S4_Computer_Start.BtnRender
    self.Settings:initialise()
    self:addChild(self.Settings)
    BtnY = BtnY - FontH - 5

    self.IE = ISButton:new(40, BtnY, BtnW, FontH, "Internet Explorer", self, S4_Computer_Start.BtnClick)
    self.IE.font = self.UI_Font
    self.IE.FontH = self.FontH
    self.IE.Img = getTexture("media/textures/S4_Icon/Icon_64_IE.png")
    self.IE.internal = "IE"
    self.IE.backgroundColor.a = 0
    self.IE.backgroundColorMouseOver = {r=0.1, g=0.1, b=1, a=0.9}
    self.IE.borderColor.a = 0
    self.IE.textColor = {r=0, g=0, b=0, a=0.9}
    self.IE.render = S4_Computer_Start.BtnRender
    self.IE:initialise()
    self:addChild(self.IE)
end

function S4_Computer_Start:render()
    ISPanel.initialise(self)
    -- 30 150
    local ImgY = self:getHeight() - 160
    local RectH = self:getHeight() - 6
    self:drawRect(3, 3, 34, RectH, 1, 0/255, 0/255, 128/255)
    self:drawTextureScaled(getTexture("media/textures/S4_Img/StartBar.png"), 5, ImgY, 30, 150, 1)
end

function S4_Computer_Start:BtnClick(Btn)
    local internal = Btn.internal
    if internal == "Shutdown" then
        local ComModData = self.ComUI.ComObj:getModData()
        if ComModData then
            ComModData.ComPower = false
            S4_Utils.SnycObject(self.ComUI.ComObj)
        end
        self.ComUI:close()
    elseif internal == "LogOff" then
        self.ComUI:close()
    elseif internal == "Settings" then
        if self.ComUI.Settings then
            if not self.ComUI.Settings:isVisible() then
                self.ComUI.Settings:setVisible(true)
            end
            self.ComUI.Settings:bringToTop()
        else
            self.ComUI.Settings = S4_System:new(self.ComUI)
            self.ComUI.Settings:initialise()
            self.ComUI.Settings.TitleName = "Settings - System"
            self.ComUI.Settings.PageType = internal
            self.ComUI.Settings.IconImg = getTexture("media/textures/S4_Icon/Icon_64_Setting.png")
            self.ComUI:addChild(self.ComUI.Settings)
            self.ComUI:AddTaskBar(self.ComUI.Settings)
            self.ComUI.StartBtnAction = false
            self:close()
        end
    elseif internal == "IE" then
        if self.ComUI.IE then
            if not self.ComUI.IE:isVisible() then
                self.ComUI.IE:setVisible(true)
            end
            self.ComUI.IE:bringToTop()
        else
            self.ComUI.IE = S4_InternetExplorer:new(self.ComUI)
            self.ComUI.IE:initialise()
            self.ComUI.IE.TitleName = "Servivor Network - Internet Explorer"
            self.ComUI.IE.AddressText = "http://hind.com/ServivorNetwork/home"
            self.ComUI.IE.PageType = internal
            self.ComUI:addChild(self.ComUI.IE)
            self.ComUI:AddTaskBar(self.ComUI.IE)
            self.ComUI.StartBtnAction = false
            self:close()
        end
    end
end

function S4_Computer_Start:close()
    if self.ComUI.StartPanel then
        self.ComUI.StartPanel = nil
    end
    self:setVisible(false)
    self:removeFromUIManager()
end

-- panel move code
function S4_Computer_Start:onMouseDown(x, y)
    -- if self.ComUI.moveWithMouse then
    --     self.ComUI.moving = true
    --     self.ComUI.dragOffsetX = x
    --     self.ComUI.dragOffsetY = y
    --     self.ComUI:bringToTop()
    -- end
end

-- button rendering
function S4_Computer_Start:BtnRender()
    if self.Img then
        self:drawTextureScaled(self.Img, 2, 2, self.FontH, self.FontH, 1)
    end
    if self.title then
        self:drawText(self.title, self.FontH + 4, 2, 0, 0, 0, 1, self.font)
    end
end
