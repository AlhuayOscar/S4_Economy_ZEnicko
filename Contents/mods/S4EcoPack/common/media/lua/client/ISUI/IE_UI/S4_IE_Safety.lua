require "ISUI/Safety_UI/S4_Safety_Scan"

S4_IE_Safety = ISPanel:derive("S4_IE_Safety")

local function s4SafetyChunkKey(cx, cy)
    return tostring(cx) .. ":" .. tostring(cy)
end

local function s4SafetyGetChunkCount(scan, cx, cy)
    if not scan or not scan.counts then
        return 0
    end
    return scan.counts[s4SafetyChunkKey(cx, cy)] or 0
end

local function s4SafetySumRadius(scan, cx, cy, radius)
    if not scan then
        return 0
    end
    local total = 0
    for y = cy - radius, cy + radius do
        for x = cx - radius, cx + radius do
            total = total + s4SafetyGetChunkCount(scan, x, y)
        end
    end
    return total
end

function S4_IE_Safety:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0.05, g = 0.08, b = 0.09, a = 1}
    o.borderColor = {r = 0.18, g = 0.36, b = 0.40, a = 1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.chunkRadiusOptions = {1, 2, 3, 4}
    o.chunkRadius = 2
    o.selectedChunkX = nil
    o.selectedChunkY = nil
    o.lastScan = nil
    return o
end

function S4_IE_Safety:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Safety:createChildren()
    ISPanel.createChildren(self)

    local w = self:getWidth()
    local h = self:getHeight()
    local headerH = 96
    local bodyY = headerH + 10
    local mapW = math.floor(w * 0.64)

    self.HeaderPanel = ISPanel:new(0, 0, w, headerH)
    self.HeaderPanel.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
    self.HeaderPanel.borderColor.a = 0
    self.HeaderPanel.parentSafety = self
    self.HeaderPanel.render = function(panel)
        panel.parentSafety:renderHeaderPanel(panel)
    end
    self:addChild(self.HeaderPanel)

    self.RefreshBtn = ISButton:new(w - 286, 52, 128, 28, "Refresh Scan", self, S4_IE_Safety.onRefresh)
    self.RefreshBtn.backgroundColor = {r = 0.18, g = 0.42, b = 0.26, a = 1}
    self.RefreshBtn.textColor = {r = 0.92, g = 1, b = 0.92, a = 1}
    self.RefreshBtn:initialise()
    self.HeaderPanel:addChild(self.RefreshBtn)

    self.RangeBtn = ISButton:new(w - 148, 52, 132, 28, self:getRangeButtonLabel(), self, S4_IE_Safety.onCycleRange)
    self.RangeBtn.backgroundColor = {r = 0.16, g = 0.22, b = 0.26, a = 1}
    self.RangeBtn.textColor = {r = 0.92, g = 0.96, b = 1, a = 1}
    self.RangeBtn:initialise()
    self.HeaderPanel:addChild(self.RangeBtn)

    self.MapPanel = ISPanel:new(10, bodyY, mapW - 15, h - bodyY - 10)
    self.MapPanel.backgroundColor = {r = 0.03, g = 0.05, b = 0.06, a = 1}
    self.MapPanel.borderColor = {r = 0.18, g = 0.30, b = 0.33, a = 1}
    self.MapPanel.parentSafety = self
    self.MapPanel.render = function(panel)
        panel.parentSafety:renderMapPanel(panel)
    end
    self.MapPanel.onMouseDown = function(panel, x, y)
        return panel.parentSafety:onMapMouseDown(x, y)
    end
    self:addChild(self.MapPanel)

    self.InfoPanel = ISPanel:new(mapW + 5, bodyY, w - mapW - 15, h - bodyY - 10)
    self.InfoPanel.backgroundColor = {r = 0.07, g = 0.10, b = 0.11, a = 1}
    self.InfoPanel.borderColor = {r = 0.18, g = 0.30, b = 0.33, a = 1}
    self.InfoPanel.parentSafety = self
    self.InfoPanel.render = function(panel)
        panel.parentSafety:renderInfoPanel(panel)
    end
    self:addChild(self.InfoPanel)

    self:refreshData()
end

function S4_IE_Safety:getRangeButtonLabel()
    local size = (self.chunkRadius * 2) + 1
    return string.format("Range: %dx%d", size, size)
end

function S4_IE_Safety:getMapMetrics(panel)
    local scan = self.lastScan
    if not scan then
        return nil
    end

    local cols = (scan.radius * 2) + 1
    local padding = 8
    local titleH = 24
    local availW = panel:getWidth() - (padding * 2)
    local availH = panel:getHeight() - titleH - (padding * 2)
    local cellSize = math.floor(math.min(availW / cols, availH / cols))
    if cellSize < 18 then
        cellSize = 18
    end

    local gridW = cellSize * cols
    local gridH = cellSize * cols
    local startX = math.floor((panel:getWidth() - gridW) / 2)
    local startY = titleH + math.floor((panel:getHeight() - titleH - gridH) / 2)

    return {
        cols = cols,
        cellSize = cellSize,
        startX = startX,
        startY = startY
    }
end

function S4_IE_Safety:getChunkColor(count)
    if count <= 0 then
        return 0.12, 0.17, 0.18
    elseif count <= 2 then
        return 0.16, 0.43, 0.24
    elseif count <= 5 then
        return 0.47, 0.58, 0.12
    elseif count <= 10 then
        return 0.74, 0.49, 0.12
    elseif count <= 20 then
        return 0.79, 0.25, 0.14
    end
    return 0.58, 0.07, 0.08
end

function S4_IE_Safety:refreshData()
    self.lastScan = S4_Safety_Scan.scanAroundPlayer(self.player, self.chunkRadius)
    local scan = self.lastScan

    if scan and not scan.error then
        local centerChunkX = scan.centerChunkX
        local centerChunkY = scan.centerChunkY
        local radius = scan.radius
        if not self.selectedChunkX or math.abs(self.selectedChunkX - centerChunkX) > radius or math.abs(self.selectedChunkY - centerChunkY) > radius then
            self.selectedChunkX = centerChunkX
            self.selectedChunkY = centerChunkY
        end
    end

    if self.RangeBtn then
        self.RangeBtn:setTitle(self:getRangeButtonLabel())
    end
end

function S4_IE_Safety:onRefresh()
    self:refreshData()
end

function S4_IE_Safety:onCycleRange()
    local currentIndex = 1
    for i, value in ipairs(self.chunkRadiusOptions) do
        if value == self.chunkRadius then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex + 1
    if currentIndex > #self.chunkRadiusOptions then
        currentIndex = 1
    end
    self.chunkRadius = self.chunkRadiusOptions[currentIndex]
    self:refreshData()
end

function S4_IE_Safety:onMapMouseDown(x, y)
    local scan = self.lastScan
    if not scan or scan.error then
        return false
    end

    local metrics = self:getMapMetrics(self.MapPanel)
    if not metrics then
        return false
    end

    local relX = x - metrics.startX
    local relY = y - metrics.startY
    if relX < 0 or relY < 0 then
        return false
    end

    local col = math.floor(relX / metrics.cellSize)
    local row = math.floor(relY / metrics.cellSize)
    if col < 0 or row < 0 or col >= metrics.cols or row >= metrics.cols then
        return false
    end

    self.selectedChunkX = scan.centerChunkX - scan.radius + col
    self.selectedChunkY = scan.centerChunkY - scan.radius + row
    return true
end

function S4_IE_Safety:renderHeaderPanel(panel)
    local scan = self.lastScan
    local isPrivileged = (self.player and self.player.isAccessLevel and self.player:isAccessLevel("admin")) or getDebug()
    panel:drawRect(0, 0, panel:getWidth(), 44, 1, 0.10, 0.24, 0.22)
    panel:drawRect(0, 44, panel:getWidth(), panel:getHeight() - 44, 1, 0.09, 0.12, 0.13)
    panel:drawRectBorder(0, 0, panel:getWidth(), panel:getHeight(), 1, 0.18, 0.36, 0.40)

    panel:drawText("SAFETY :: Zombie Chunk Map", 16, 10, 0.86, 0.98, 0.90, 1, UIFont.Large)
    panel:drawText("Live debug view grouped by chunk (10x10 tiles). Uses loaded alive zombies from the active cell.", 16, 28, 0.64, 0.82, 0.78, 1, UIFont.Small)
    if isPrivileged then
        panel:drawText("Mode: full visibility (read-only map UI).", 16, 44, 0.84, 0.92, 0.86, 1, UIFont.Small)
    else
        panel:drawText("Mode: read-only access. No spawn, delete or edit actions are available.", 16, 44, 0.92, 0.86, 0.68, 1, UIFont.Small)
    end

    if scan and not scan.error then
        local playerLine = string.format("Player %d,%d,%d  |  Center chunk %d,%d  |  Visible alive %d", scan.playerX, scan.playerY, scan.playerZ, scan.centerChunkX, scan.centerChunkY, scan.visibleAlive)
        panel:drawText(playerLine, 16, 72, 0.94, 0.96, 0.98, 1, UIFont.Small)
    elseif scan and scan.error then
        panel:drawText(scan.error, 16, 72, 1, 0.55, 0.55, 1, UIFont.Small)
    end
end

function S4_IE_Safety:renderMapPanel(panel)
    ISPanel.render(panel)

    panel:drawText("Chunk Heatmap", 10, 6, 0.82, 0.94, 0.98, 1, UIFont.Medium)

    local scan = self.lastScan
    if not scan or scan.error then
        panel:drawTextCentre("No scan data available.", math.floor(panel:getWidth() / 2), math.floor(panel:getHeight() / 2) - 10, 0.9, 0.9, 0.9, 1, UIFont.Medium)
        return
    end

    local metrics = self:getMapMetrics(panel)
    if not metrics then
        return
    end

    for row = 0, metrics.cols - 1 do
        for col = 0, metrics.cols - 1 do
            local chunkX = scan.centerChunkX - scan.radius + col
            local chunkY = scan.centerChunkY - scan.radius + row
            local count = s4SafetyGetChunkCount(scan, chunkX, chunkY)
            local r, g, b = self:getChunkColor(count)
            local drawX = metrics.startX + (col * metrics.cellSize)
            local drawY = metrics.startY + (row * metrics.cellSize)

            panel:drawRect(drawX, drawY, metrics.cellSize - 1, metrics.cellSize - 1, 1, r, g, b)
            panel:drawRectBorder(drawX, drawY, metrics.cellSize - 1, metrics.cellSize - 1, 0.8, 0.06, 0.08, 0.08)

            if chunkX == scan.centerChunkX and chunkY == scan.centerChunkY then
                panel:drawRectBorder(drawX + 1, drawY + 1, metrics.cellSize - 3, metrics.cellSize - 3, 1, 0.18, 0.72, 0.98)
            end

            if chunkX == self.selectedChunkX and chunkY == self.selectedChunkY then
                panel:drawRectBorder(drawX + 3, drawY + 3, metrics.cellSize - 7, metrics.cellSize - 7, 1, 0.96, 0.96, 0.96)
            end

            if metrics.cellSize >= 36 then
                panel:drawTextCentre(tostring(count), drawX + math.floor((metrics.cellSize - 1) / 2), drawY + math.floor(metrics.cellSize / 2) - 8, 1, 1, 1, 1, UIFont.Small)
            end

            if metrics.cellSize >= 56 then
                panel:drawTextCentre(string.format("%d,%d", chunkX, chunkY), drawX + math.floor((metrics.cellSize - 1) / 2), drawY + 5, 0.78, 0.88, 0.88, 1, UIFont.Small)
            end
        end
    end
end

function S4_IE_Safety:renderInfoPanel(panel)
    ISPanel.render(panel)

    local scan = self.lastScan
    panel:drawText("Scan Summary", 12, 8, 0.82, 0.94, 0.98, 1, UIFont.Medium)

    if not scan or scan.error then
        panel:drawText("No data.", 12, 32, 1, 0.55, 0.55, 1, UIFont.Small)
        return
    end

    local leftX = 12
    local rightX = math.floor(panel:getWidth() * 0.54)
    local yLeft = 34
    local yRight = 34
    local line = S4_UI.FH_S + 4
    local selectedX = self.selectedChunkX or scan.centerChunkX
    local selectedY = self.selectedChunkY or scan.centerChunkY
    local selectedCount = S4_Safety_Scan.getChunkCount(scan, selectedX, selectedY)
    local chunkStartX = selectedX * 10
    local chunkStartY = selectedY * 10
    local hotCount = S4_Safety_Scan.getChunkCount(scan, scan.hottestChunkX, scan.hottestChunkY)

    panel:drawText("Area summary", leftX, yLeft, 0.82, 0.94, 0.98, 1, UIFont.Medium)
    yLeft = yLeft + line
    panel:drawText(string.format("Current chunk: %d,%d", scan.centerChunkX, scan.centerChunkY), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("Current chunk zombies: %d", scan.centerCount), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("3x3 around player: %d", scan.chunk3x3), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("5x5 around player: %d", scan.chunk5x5), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("Visible in scan: %d", scan.visibleAlive), leftX, yLeft, 0.82, 0.94, 0.82, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("Loaded alive total: %d", scan.loadedAlive), leftX, yLeft, 0.94, 0.90, 0.70, 1, UIFont.Small)
    yLeft = yLeft + (line + 4)

    panel:drawText("Selected chunk", leftX, yLeft, 0.82, 0.94, 0.98, 1, UIFont.Medium)
    yLeft = yLeft + line
    panel:drawText(string.format("Coords: %d,%d", selectedX, selectedY), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("Bounds X %d-%d", chunkStartX, chunkStartX + 9), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("Bounds Y %d-%d", chunkStartY, chunkStartY + 9), leftX, yLeft, 0.92, 0.96, 0.98, 1, UIFont.Small)
    yLeft = yLeft + line
    panel:drawText(string.format("Alive zombies: %d", selectedCount), leftX, yLeft, 0.96, 0.88, 0.72, 1, UIFont.Small)

    panel:drawText("Hotspot + legend", rightX, yRight, 0.82, 0.94, 0.98, 1, UIFont.Medium)
    yRight = yRight + line
    panel:drawText(string.format("Hottest chunk: %d,%d", scan.hottestChunkX, scan.hottestChunkY), rightX, yRight, 0.96, 0.76, 0.62, 1, UIFont.Small)
    yRight = yRight + line
    panel:drawText(string.format("Zombies there: %d", hotCount), rightX, yRight, 0.96, 0.76, 0.62, 1, UIFont.Small)
    yRight = yRight + (line + 4)
    panel:drawText("0 = clear", rightX, yRight, 0.72, 0.84, 0.86, 1, UIFont.Small)
    yRight = yRight + line
    panel:drawText("1-2 = low", rightX, yRight, 0.62, 0.86, 0.62, 1, UIFont.Small)
    yRight = yRight + line
    panel:drawText("3-5 = medium", rightX, yRight, 0.84, 0.88, 0.42, 1, UIFont.Small)
    yRight = yRight + line
    panel:drawText("6-10 = high", rightX, yRight, 0.92, 0.70, 0.32, 1, UIFont.Small)
    yRight = yRight + line
    panel:drawText("11+ = critical", rightX, yRight, 0.92, 0.40, 0.34, 1, UIFont.Small)
    yRight = yRight + (line + 6)
    panel:drawText("Click any chunk in the map to inspect its exact bounds and count.", rightX, yRight, 0.70, 0.84, 0.88, 1, UIFont.Small)
end

function S4_IE_Safety:render()
    ISPanel.render(self)
end
