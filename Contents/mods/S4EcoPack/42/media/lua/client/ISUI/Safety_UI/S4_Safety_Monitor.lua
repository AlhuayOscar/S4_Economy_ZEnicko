require "ISUI/ISPanel"
require "ISUI/Safety_UI/S4_Safety_Scan"

S4_Safety_Monitor = ISPanel:derive("S4_Safety_Monitor")
S4_Safety_Monitor.instance = nil

S4_Safety_Monitor.DEFAULT_WIDTH = 430
S4_Safety_Monitor.DEFAULT_HEIGHT = 300
S4_Safety_Monitor.COLLAPSED_HEIGHT = 30
S4_Safety_Monitor.TITLE_HEIGHT = 28
S4_Safety_Monitor.AUTO_COLLAPSE_DELAY_MS = 5000

function S4_Safety_Monitor:showForPlayer(player)
    if not player then
        return
    end

    if not S4_Safety_Monitor.instance then
        local md = player:getModData()
        local w = S4_Safety_Monitor.DEFAULT_WIDTH
        local h = S4_Safety_Monitor.DEFAULT_HEIGHT
        local x = md.S4SafetyMonitorX or (getCore():getScreenWidth() - w - 36)
        local y = md.S4SafetyMonitorY or 90
        S4_Safety_Monitor.instance = S4_Safety_Monitor:new(player, x, y, w, h)
        S4_Safety_Monitor.instance:initialise()
        S4_Safety_Monitor.instance:instantiate()
        S4_Safety_Monitor.instance.autoCollapseEnabled = md.S4SafetyMonitorAutoCollapse == true
        S4_Safety_Monitor.instance.collapsed = md.S4SafetyMonitorCollapsed == true
        S4_Safety_Monitor.instance:applyCollapsedState(false)
    end

    S4_Safety_Monitor.instance.player = player
    S4_Safety_Monitor.instance:addToUIManager()
    S4_Safety_Monitor.instance:setVisible(true)
    S4_Safety_Monitor.instance:bumpExpandedVisibility()
    S4_Safety_Monitor.instance:refreshData(true)
    return S4_Safety_Monitor.instance
end

function S4_Safety_Monitor:toggleForPlayer(player)
    if S4_Safety_Monitor.instance and S4_Safety_Monitor.instance:isVisible() then
        S4_Safety_Monitor.instance:close()
        return
    end
    S4_Safety_Monitor:showForPlayer(player)
end

function S4_Safety_Monitor:new(player, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.moveWithMouse = true
    o.backgroundColor = {r = 0.05, g = 0.08, b = 0.09, a = 0.94}
    o.borderColor = {r = 0.18, g = 0.36, b = 0.40, a = 1}
    o.chunkRadiusOptions = {1, 2, 3}
    o.chunkRadius = 2
    o.collapsed = false
    o.lastScan = nil
    o.selectedChunkX = nil
    o.selectedChunkY = nil
    o.lastRefreshMs = 0
    o.lastCenterChunkX = nil
    o.lastCenterChunkY = nil
    o.autoCollapseEnabled = false
    o.expandedUntilMs = 0
    o:setWantKeyEvents(true)
    return o
end

function S4_Safety_Monitor:initialise()
    ISPanel.initialise(self)
end

function S4_Safety_Monitor:createChildren()
    ISPanel.createChildren(self)

    self.RangeBtn = ISButton:new(8, 4, 92, 20, self:getRangeButtonLabel(), self, S4_Safety_Monitor.onCycleRange)
    self.RangeBtn.backgroundColor = {r = 0.14, g = 0.22, b = 0.24, a = 1}
    self.RangeBtn.textColor = {r = 0.92, g = 0.96, b = 1, a = 1}
    self.RangeBtn:initialise()
    self:addChild(self.RangeBtn)

    self.CollapseBtn = ISButton:new(self:getWidth() - 50, 4, 20, 20, "A", self, S4_Safety_Monitor.onToggleAutoCollapse)
    self.CollapseBtn.backgroundColor = {r = 0.16, g = 0.18, b = 0.20, a = 1}
    self.CollapseBtn.textColor = {r = 1, g = 1, b = 1, a = 1}
    self.CollapseBtn:initialise()
    self:addChild(self.CollapseBtn)

    self.CloseBtn = ISButton:new(self:getWidth() - 26, 4, 20, 20, "X", self, S4_Safety_Monitor.onCloseUI)
    self.CloseBtn.backgroundColor = {r = 0.38, g = 0.16, b = 0.16, a = 1}
    self.CloseBtn.textColor = {r = 1, g = 1, b = 1, a = 1}
    self.CloseBtn:initialise()
    self:addChild(self.CloseBtn)

    self.MapPanel = ISPanel:new(8, S4_Safety_Monitor.TITLE_HEIGHT + 8, math.floor(self:getWidth() * 0.62), self:getHeight() - S4_Safety_Monitor.TITLE_HEIGHT - 16)
    self.MapPanel.backgroundColor = {r = 0.03, g = 0.05, b = 0.06, a = 1}
    self.MapPanel.borderColor = {r = 0.18, g = 0.30, b = 0.33, a = 1}
    self.MapPanel.parentMonitor = self
    self.MapPanel.render = function(panel)
        panel.parentMonitor:renderMapPanel(panel)
    end
    self.MapPanel.onMouseDown = function(panel, x, y)
        return panel.parentMonitor:onMapMouseDown(x, y)
    end
    self:addChild(self.MapPanel)

    self.InfoPanel = ISPanel:new(self.MapPanel:getRight() + 8, self.MapPanel:getY(), self:getWidth() - self.MapPanel:getWidth() - 24, self.MapPanel:getHeight())
    self.InfoPanel.backgroundColor = {r = 0.07, g = 0.10, b = 0.11, a = 1}
    self.InfoPanel.borderColor = {r = 0.18, g = 0.30, b = 0.33, a = 1}
    self.InfoPanel.parentMonitor = self
    self.InfoPanel.render = function(panel)
        panel.parentMonitor:renderInfoPanel(panel)
    end
    self:addChild(self.InfoPanel)

    self:bumpExpandedVisibility()
    self:applyCollapsedState(false)
    self:refreshData(true)
end

function S4_Safety_Monitor:getNowMs()
    return getTimestampMs and getTimestampMs() or 0
end

function S4_Safety_Monitor:bumpExpandedVisibility()
    local nowMs = self:getNowMs()
    if nowMs > 0 then
        self.expandedUntilMs = nowMs + S4_Safety_Monitor.AUTO_COLLAPSE_DELAY_MS
    else
        self.expandedUntilMs = S4_Safety_Monitor.AUTO_COLLAPSE_DELAY_MS
    end
end

function S4_Safety_Monitor:updateAutoCollapseState()
    if not self.autoCollapseEnabled then
        if self.collapsed then
            self.collapsed = false
            self:applyCollapsedState(false)
        end
        return
    end

    if self:isMouseOver() then
        self:bumpExpandedVisibility()
        if self.collapsed then
            self.collapsed = false
            self:applyCollapsedState(false)
        end
        return
    end

    local nowMs = self:getNowMs()
    if nowMs > 0 and nowMs > (self.expandedUntilMs or 0) and not self.collapsed then
        self.collapsed = true
        self:applyCollapsedState(false)
    end
end

function S4_Safety_Monitor:getRangeButtonLabel()
    local size = (self.chunkRadius * 2) + 1
    return string.format("Range %dx%d", size, size)
end

function S4_Safety_Monitor:getMapMetrics(panel)
    local scan = self.lastScan
    if not scan then
        return nil
    end
    local cols = (scan.radius * 2) + 1
    local padding = 8
    local titleH = 18
    local availW = panel:getWidth() - (padding * 2)
    local availH = panel:getHeight() - titleH - (padding * 2)
    local cellSize = math.floor(math.min(availW / cols, availH / cols))
    if cellSize < 18 then
        cellSize = 18
    end
    local gridW = cellSize * cols
    local gridH = cellSize * cols
    return {
        cols = cols,
        cellSize = cellSize,
        startX = math.floor((panel:getWidth() - gridW) / 2),
        startY = titleH + math.floor((panel:getHeight() - titleH - gridH) / 2)
    }
end

function S4_Safety_Monitor:getChunkColor(count)
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

function S4_Safety_Monitor:saveLayout()
    local player = self.player
    if not player then
        return
    end
    local md = player:getModData()
    md.S4SafetyMonitorX = math.floor(self:getX())
    md.S4SafetyMonitorY = math.floor(self:getY())
    md.S4SafetyMonitorCollapsed = self.collapsed == true
    md.S4SafetyMonitorAutoCollapse = self.autoCollapseEnabled == true
end

function S4_Safety_Monitor:applyCollapsedState(shouldSave)
    local collapsed = self.collapsed == true
    local targetHeight = collapsed and S4_Safety_Monitor.COLLAPSED_HEIGHT or S4_Safety_Monitor.DEFAULT_HEIGHT
    self:setHeight(targetHeight)
    self.CollapseBtn:setTitle(self.autoCollapseEnabled and "A" or "P")
    self.RangeBtn:setVisible(not collapsed)
    self.MapPanel:setVisible(not collapsed)
    self.InfoPanel:setVisible(not collapsed)
    self.CollapseBtn:setX(self:getWidth() - 50)
    self.CloseBtn:setX(self:getWidth() - 26)
    if shouldSave ~= false then
        self:saveLayout()
    end
end

function S4_Safety_Monitor:refreshData(force)
    local hasKit = S4_Safety_Scan.playerHasSafetyMonitorKit(self.player)
    if not hasKit then
        self.lastScan = {
            error = "Signal lost. Carry a Pager and a Walkie Talkie to keep the monitor online."
        }
        self.lastRefreshMs = getTimestampMs and getTimestampMs() or 0
        return
    end

    self.lastScan = S4_Safety_Scan.scanAroundPlayer(self.player, self.chunkRadius)
    local scan = self.lastScan
    if scan and not scan.error then
        self.lastCenterChunkX = scan.centerChunkX
        self.lastCenterChunkY = scan.centerChunkY
        if force or not self.selectedChunkX or math.abs(self.selectedChunkX - scan.centerChunkX) > scan.radius or math.abs(self.selectedChunkY - scan.centerChunkY) > scan.radius then
            self.selectedChunkX = scan.centerChunkX
            self.selectedChunkY = scan.centerChunkY
        end
    end
    if self.RangeBtn then
        self.RangeBtn:setTitle(self:getRangeButtonLabel())
    end
    self.lastRefreshMs = getTimestampMs and getTimestampMs() or 0
end

function S4_Safety_Monitor:updateLive(player)
    if not self:isVisible() then
        return
    end
    self.player = player or self.player
    local nowMs = getTimestampMs and getTimestampMs() or 0
    local shouldRefresh = false

    if not self.lastRefreshMs or (nowMs > 0 and nowMs - self.lastRefreshMs > 600) then
        shouldRefresh = true
    end

    local square = self.player and self.player:getSquare() or nil
    if square then
        local chunkX = math.floor(square:getX() / 10)
        local chunkY = math.floor(square:getY() / 10)
        if chunkX ~= self.lastCenterChunkX or chunkY ~= self.lastCenterChunkY then
            shouldRefresh = true
        end
    end

    if shouldRefresh then
        self:refreshData(false)
    end
    self:updateAutoCollapseState()
end

function S4_Safety_Monitor:onCycleRange()
    local idx = 1
    for i, value in ipairs(self.chunkRadiusOptions) do
        if value == self.chunkRadius then
            idx = i
            break
        end
    end
    idx = idx + 1
    if idx > #self.chunkRadiusOptions then
        idx = 1
    end
    self.chunkRadius = self.chunkRadiusOptions[idx]
    self:refreshData(true)
end

function S4_Safety_Monitor:onToggleAutoCollapse()
    self.autoCollapseEnabled = not self.autoCollapseEnabled
    if self.autoCollapseEnabled then
        self:bumpExpandedVisibility()
    else
        self.collapsed = false
    end
    self:applyCollapsedState(true)
end

function S4_Safety_Monitor:onCloseUI()
    self:close()
end

function S4_Safety_Monitor:onMapMouseDown(x, y)
    local scan = self.lastScan
    if not scan or scan.error or self.collapsed then
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

function S4_Safety_Monitor:render()
    ISPanel.render(self)
    self:updateAutoCollapseState()
    local online = self.lastScan and not self.lastScan.error
    self:drawRect(0, 0, self:getWidth(), S4_Safety_Monitor.TITLE_HEIGHT, 1, 0.09, 0.20, 0.22)
    self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 1, 0.18, 0.36, 0.40)
    self:drawText("Pager + Walkie :: Chunk Heatmap", 110, 6, 0.90, 0.98, 0.92, 1, UIFont.Small)
    self:drawText(online and "ONLINE" or "OFFLINE", self:getWidth() - 118, 6, online and 0.68 or 0.96, online and 0.94 or 0.50, online and 0.74 or 0.50, 1, UIFont.Small)

    if self.collapsed then
        local status = self.lastScan and not self.lastScan.error and string.format("Chunk %d,%d | %d visible", self.lastScan.centerChunkX, self.lastScan.centerChunkY, self.lastScan.visibleAlive) or "Carry Pager + Walkie Talkie to restore signal"
        self:drawText(status, 110, 16, 0.80, 0.88, 0.90, 1, UIFont.Small)
    elseif self.autoCollapseEnabled then
        self:drawText("AUTO", 74, 6, 0.90, 0.82, 0.52, 1, UIFont.Small)
    end
end

function S4_Safety_Monitor:renderMapPanel(panel)
    ISPanel.render(panel)
    panel:drawText("Live chunk map", 8, 4, 0.82, 0.94, 0.98, 1, UIFont.Small)

    local scan = self.lastScan
    if not scan or scan.error then
        panel:drawTextCentre("No live signal.", math.floor(panel:getWidth() / 2), math.floor(panel:getHeight() / 2) - 10, 0.92, 0.62, 0.58, 1, UIFont.Medium)
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
            local count = S4_Safety_Scan.getChunkCount(scan, chunkX, chunkY)
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
            if metrics.cellSize >= 30 then
                panel:drawTextCentre(tostring(count), drawX + math.floor((metrics.cellSize - 1) / 2), drawY + math.floor(metrics.cellSize / 2) - 7, 1, 1, 1, 1, UIFont.Small)
            end
        end
    end
end

function S4_Safety_Monitor:renderInfoPanel(panel)
    ISPanel.render(panel)
    panel:drawText("Telemetry", 8, 6, 0.82, 0.94, 0.98, 1, UIFont.Small)

    local scan = self.lastScan
    if not scan or scan.error then
        panel:drawText(scan and scan.error or "No data.", 8, 28, 0.96, 0.62, 0.58, 1, UIFont.Small)
        return
    end

    local y = 22
    local line = S4_UI.FH_S + 1
    local selectedX = self.selectedChunkX or scan.centerChunkX
    local selectedY = self.selectedChunkY or scan.centerChunkY
    local selectedCount = S4_Safety_Scan.getChunkCount(scan, selectedX, selectedY)
    local hotCount = S4_Safety_Scan.getChunkCount(scan, scan.hottestChunkX, scan.hottestChunkY)

    panel:drawText(string.format("Player: %d,%d,%d", scan.playerX, scan.playerY, scan.playerZ), 8, y, 0.92, 0.96, 0.98, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("Chunk: %d,%d", scan.centerChunkX, scan.centerChunkY), 8, y, 0.92, 0.96, 0.98, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("Current: %d", scan.centerCount), 8, y, 0.92, 0.96, 0.98, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("3x3: %d | 5x5: %d", scan.chunk3x3, scan.chunk5x5), 8, y, 0.82, 0.94, 0.82, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("Visible: %d", scan.visibleAlive), 8, y, 0.82, 0.94, 0.82, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("Loaded total: %d", scan.loadedAlive), 8, y, 0.94, 0.90, 0.70, 1, UIFont.Small)
    y = y + (line + 2)

    panel:drawText("Selection", 8, y, 0.82, 0.94, 0.98, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("%d,%d -> %d zeds", selectedX, selectedY, selectedCount), 8, y, 0.96, 0.88, 0.72, 1, UIFont.Small)
    y = y + (line + 2)

    panel:drawText("Hotspot", 8, y, 0.82, 0.94, 0.98, 1, UIFont.Small)
    y = y + line
    panel:drawText(string.format("%d,%d -> %d zeds", scan.hottestChunkX, scan.hottestChunkY, hotCount), 8, y, 0.96, 0.76, 0.62, 1, UIFont.Small)
    y = y + (line + 2)

    panel:drawText("Legend", 8, y, 0.82, 0.94, 0.98, 1, UIFont.Small)
    y = y + line
    panel:drawText("0 clear | 1-2 low | 3-5 medium", 8, y, 0.72, 0.84, 0.86, 1, UIFont.Small)
    y = y + line
    panel:drawText("6-10 high | 11+ critical", 8, y, 0.92, 0.70, 0.32, 1, UIFont.Small)
end

function S4_Safety_Monitor:onMouseUp(x, y)
    ISPanel.onMouseUp(self, x, y)
    self:bumpExpandedVisibility()
    self:saveLayout()
end

function S4_Safety_Monitor:onMouseDown(x, y)
    ISPanel.onMouseDown(self, x, y)
    self:bumpExpandedVisibility()
end

function S4_Safety_Monitor:onMouseMove(dx, dy)
    ISPanel.onMouseMove(self, dx, dy)
    self:bumpExpandedVisibility()
end

function S4_Safety_Monitor:onMouseMoveOutside(dx, dy)
    ISPanel.onMouseMoveOutside(self, dx, dy)
end

function S4_Safety_Monitor:close()
    self:saveLayout()
    self:setVisible(false)
    self:removeFromUIManager()
end

function S4_Safety_Monitor.OnPlayerUpdate(player)
    if not player or player:isDead() then
        return
    end
    local instance = S4_Safety_Monitor.instance
    if instance and instance:isVisible() and instance.player == player then
        instance:updateLive(player)
    end
end

Events.OnPlayerUpdate.Add(S4_Safety_Monitor.OnPlayerUpdate)
