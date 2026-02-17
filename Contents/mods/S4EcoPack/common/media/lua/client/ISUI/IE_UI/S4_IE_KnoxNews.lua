S4_IE_KnoxNews = ISPanel:derive("S4_IE_KnoxNews")

local KNOX_NEWS_TEXTURES = {"media/textures/S4_KnoxNews/Bradenburg disaster funds coming.png",
                            "media/textures/S4_KnoxNews/Independence_day.PNG",
                            "media/textures/S4_KnoxNews/newspaper-covering-knox-infection-in-the-uk-personal-lore-v0-qrd30uocd8de1.PNG",
                            "media/textures/S4_KnoxNews/No danger to public crash plane.png",
                            "media/textures/S4_KnoxNews/Telephone_outages.png"}

local KNOX_NEWS_ROTATION = {
    order = nil,
    index = 0,
    lastPath = nil
}

local KNOX_NEWS_EVENTS = {"Estado: Sin evento mayor reportado", "Evento: Casos febriles en aumento en Knox",
                          "Evento: Cortes intermitentes de telefonia", "Evento: Restricciones temporales de viaje",
                          "Evento: Cierre preventivo de comercios", "Evento: Evacuacion recomendada en zonas criticas"}

local KNOX_NEWS_EVENT_STATE = {
    index = 1
}

local function copyList(source)
    local out = {}
    for i = 1, #source do
        out[i] = source[i]
    end
    return out
end

local function shuffleList(source)
    local list = copyList(source)
    for i = #list, 2, -1 do
        local swapIndex = ZombRand(i) + 1
        list[i], list[swapIndex] = list[swapIndex], list[i]
    end
    return list
end

local function getNextNewsTexturePath()
    if not KNOX_NEWS_ROTATION.order or KNOX_NEWS_ROTATION.index >= #KNOX_NEWS_ROTATION.order then
        KNOX_NEWS_ROTATION.order = shuffleList(KNOX_NEWS_TEXTURES)
        KNOX_NEWS_ROTATION.index = 0
        if KNOX_NEWS_ROTATION.lastPath and #KNOX_NEWS_ROTATION.order > 1 and KNOX_NEWS_ROTATION.order[1] ==
            KNOX_NEWS_ROTATION.lastPath then
            KNOX_NEWS_ROTATION.order[1], KNOX_NEWS_ROTATION.order[2] = KNOX_NEWS_ROTATION.order[2],
                KNOX_NEWS_ROTATION.order[1]
        end
    end

    KNOX_NEWS_ROTATION.index = KNOX_NEWS_ROTATION.index + 1
    local nextPath = KNOX_NEWS_ROTATION.order[KNOX_NEWS_ROTATION.index]
    KNOX_NEWS_ROTATION.lastPath = nextPath
    return nextPath
end

local function getCurrentAlertEventText()
    if #KNOX_NEWS_EVENTS == 0 then
        return "Status: No major event reported"
    end
    if KNOX_NEWS_EVENT_STATE.index < 1 or KNOX_NEWS_EVENT_STATE.index > #KNOX_NEWS_EVENTS then
        KNOX_NEWS_EVENT_STATE.index = 1
    end
    return KNOX_NEWS_EVENTS[KNOX_NEWS_EVENT_STATE.index]
end

local function getNextAlertEventText()
    if #KNOX_NEWS_EVENTS == 0 then
        return "Status: No major event reported"
    end
    KNOX_NEWS_EVENT_STATE.index = KNOX_NEWS_EVENT_STATE.index + 1
    if KNOX_NEWS_EVENT_STATE.index > #KNOX_NEWS_EVENTS then
        KNOX_NEWS_EVENT_STATE.index = 1
    end
    return KNOX_NEWS_EVENTS[KNOX_NEWS_EVENT_STATE.index]
end

function S4_IE_KnoxNews:new(IEUI, x, y)
    local width = IEUI.ComUI:getWidth() - 12
    local TaskH = IEUI.ComUI:getHeight() - IEUI.ComUI.TaskBarY
    local height = IEUI.ComUI:getHeight() - ((S4_UI.FH_S * 2) + 23 + TaskH)

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 24 / 255,
        g = 24 / 255,
        b = 24 / 255,
        a = 1
    }
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    }
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.Moving = true
    o.NewsTexturePath = nil
    o.NewsTexture = nil
    o.AlertEventText = getCurrentAlertEventText()
    o.ChangeBtnW = 220
    o.ChangeBtnH = S4_UI.FH_S + 10
    o.ChangeBtnX = 0
    o.ChangeBtnY = 0
    o.ChangeBtnText = "Change Image and Event"
    return o
end

function S4_IE_KnoxNews:initialise()
    ISPanel.initialise(self)
    local _, H, _ = S4_UI.getGoodShopSizeZ(self.ComUI)
    self.IEUI:FixUISize(817, H)
    self.NewsTexturePath = getNextNewsTexturePath()
    self.NewsTexture = self.NewsTexturePath and getTexture(self.NewsTexturePath) or nil
end

function S4_IE_KnoxNews:createChildren()
    ISPanel.createChildren(self)
end

function S4_IE_KnoxNews:render()
    ISPanel.render(self)

    local x = 10
    local y = 10
    local w = self:getWidth() - 20
    local h = self:getHeight() - 20
    local alertH = 34
    local newsH = h - alertH - 6
    local newsY = y
    local alertY = y + newsH + 6
    local btnX = math.floor(x + (w / 2) - (self.ChangeBtnW / 2))
    local btnY = math.floor(newsY + (newsH / 2) - (self.ChangeBtnH / 2))

    self:drawRect(x, y, w, h, 0.95, 12 / 255, 12 / 255, 12 / 255)
    self:drawRectBorder(x, y, w, h, 1, 0.7, 0.7, 0.7)

    if self.NewsTexture then
        self:drawTextureScaled(self.NewsTexture, x + 1, newsY + 1, w - 2, newsH - 2, 1)
    else
        self:drawRect(x + 1, newsY + 1, w - 2, newsH - 2, 1, 26 / 255, 26 / 255, 26 / 255)
        local missing = "Missing Knox News background"
        local missingW = getTextManager():MeasureStringX(UIFont.Medium, missing)
        self:drawText(missing, x + (w / 2) - (missingW / 2), newsY + (newsH / 2) - (S4_UI.FH_M / 2), 1, 1, 1, 0.8,
            UIFont.Medium)
    end

    self:drawRect(x, alertY, w, alertH, 1, 92 / 255, 92 / 255, 92 / 255)
    self:drawRectBorder(x, alertY, w, alertH, 1, 0.2, 0.2, 0.2)

    local lineText = "ALERTA  ALERTA  ALERTA"
    local lineFont = UIFont.Small
    local lineY = alertY + ((alertH - S4_UI.FH_S) / 2)
    self:drawText(lineText, x + 8, lineY, 211 / 255, 190 / 255, 0, 1, lineFont)
    local lineW = getTextManager():MeasureStringX(lineFont, lineText)
    self:drawText(lineText, x + w - lineW - 8, lineY, 211 / 255, 190 / 255, 0, 1, lineFont)

    local centerText = self.AlertEventText or "Status: Unknown"
    local centerFont = UIFont.Medium
    local centerW = getTextManager():MeasureStringX(centerFont, centerText)
    local centerPad = 14
    local centerBoxW = centerW + centerPad
    local centerBoxX = x + (w / 2) - (centerBoxW / 2)
    self:drawRect(centerBoxX, alertY + 2, centerBoxW, alertH - 4, 0.95, 65 / 255, 65 / 255, 65 / 255)
    self:drawRectBorder(centerBoxX, alertY + 2, centerBoxW, alertH - 4, 1, 0.15, 0.15, 0.15)
    self:drawText(centerText, x + (w / 2) - (centerW / 2), alertY + ((alertH - S4_UI.FH_M) / 2), 0.95, 0.95, 0.95, 1,
        centerFont)

    local mx = self:getMouseX()
    local my = self:getMouseY()
    local isHover = mx >= btnX and mx <= btnX + self.ChangeBtnW and my >= btnY and my <= btnY + self.ChangeBtnH
    if isHover then
        self:drawRect(btnX, btnY, self.ChangeBtnW, self.ChangeBtnH, 1, 252 / 255, 214 / 255, 40 / 255)
    else
        self:drawRect(btnX, btnY, self.ChangeBtnW, self.ChangeBtnH, 1, 211 / 255, 190 / 255, 0)
    end
    self:drawRectBorder(btnX, btnY, self.ChangeBtnW, self.ChangeBtnH, 1, 0, 0, 0)
    local btnTextW = getTextManager():MeasureStringX(UIFont.Small, self.ChangeBtnText)
    self:drawText(self.ChangeBtnText, btnX + (self.ChangeBtnW / 2) - (btnTextW / 2), btnY + ((self.ChangeBtnH - S4_UI.FH_S) / 2), 0, 0, 0, 1, UIFont.Small)
    self.ChangeBtnX = btnX
    self.ChangeBtnY = btnY
end

function S4_IE_KnoxNews:onMouseDown(x, y)
    if x >= self.ChangeBtnX and x <= self.ChangeBtnX + self.ChangeBtnW and y >= self.ChangeBtnY and y <= self.ChangeBtnY + self.ChangeBtnH then
        self.AlertEventText = getNextAlertEventText()
        self.NewsTexturePath = getNextNewsTexturePath()
        self.NewsTexture = self.NewsTexturePath and getTexture(self.NewsTexturePath) or nil
        return true
    end

    if not self.Moving then
        return
    end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_KnoxNews:onMouseUpOutside(x, y)
    if not self.Moving then
        return
    end
    self.IEUI.moving = false
end

function S4_IE_KnoxNews:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
