require "ISUI/ISPanel"

S4_Pager_UI = ISPanel:derive("S4_Pager_UI")
S4_Pager_UI.instance = nil
S4_Pager_UI.MAP_SYMBOL_ID = "S4PagerMission"

local function ensureMapSymbolDefinition()
    if not MapSymbolDefinitions or not MapSymbolDefinitions.getInstance then
        return
    end
    local ok = pcall(function()
        MapSymbolDefinitions.getInstance():addTexture(S4_Pager_UI.MAP_SYMBOL_ID,
            "media/ui/LootableMaps/map_airdrop.png", "Loot")
    end)
    return ok
end

local function nowWorldHours()
    local gt = GameTime and GameTime:getInstance() or nil
    if gt and gt.getWorldAgeHours then
        return gt:getWorldAgeHours()
    end
    return 0
end

local MISSION_POINTS = {{
    x = 10625,
    y = 9795,
    z = 0,
    location = "Muldraugh - Warehouse"
}, {
    x = 11978,
    y = 6915,
    z = 0,
    location = "West Point - Gas Station"
}, {
    x = 6360,
    y = 5240,
    z = 0,
    location = "Riverside - Motel"
}, {
    x = 8105,
    y = 11528,
    z = 0,
    location = "Rosewood - Clinic"
}, {
    x = 12530,
    y = 1470,
    z = 0,
    location = "Louisville - Storage"
}, {
    x = 10020,
    y = 12740,
    z = 0,
    location = "March Ridge - Apartments"
}}

local function randomMissionPoint()
    return MISSION_POINTS[ZombRand(1, #MISSION_POINTS + 1)]
end

local function buildMission()
    local objectives = {"Clean the warehouse office", "Dispose of suspicious trash bags",
                        "Disinfect a small clinic room", "Sanitize the motel hallway",
                        "Clean blood traces in a storage unit", "Deep-clean a private garage"}
    local point = randomMissionPoint()

    return {
        durationHours = ZombRand(2, 9), -- 2..8
        objective = objectives[ZombRand(1, #objectives + 1)],
        location = point.location,
        targetX = point.x,
        targetY = point.y,
        targetZ = point.z or 0,
        zombieCount = ZombRand(1, 4) -- 1..3
    }
end

local START_BUTTON_LABELS = {"Start", "Get that man", "Take their stuff", "You can do it."}

local function randomStartLabel()
    return START_BUTTON_LABELS[ZombRand(1, #START_BUTTON_LABELS + 1)] or "Start"
end

local function getSymbolsApi()
    if not ISWorldMap_instance then
        ISWorldMap.ShowWorldMap(0)
        if ISWorldMap_instance and ISWorldMap_instance.close then
            ISWorldMap_instance:close()
        end
    end
    if not ISWorldMap_instance or not ISWorldMap_instance.javaObject then
        return nil
    end
    local mapApi = ISWorldMap_instance.javaObject:getAPIv1()
    if not mapApi then
        return nil
    end
    return mapApi:getSymbolsAPI()
end

local function clearMissionMapMarkers()
    -- Build compatibility: some map symbol APIs aren't available in all game versions.
    -- Keep this as a safe no-op to avoid runtime errors.
    return
end

local function addMissionMapMarker(x, y)
    if not x or not y then
        return false
    end
    ensureMapSymbolDefinition()
    clearMissionMapMarkers()
    local symbolsApi = getSymbolsApi()
    if not symbolsApi then
        return false
    end
    local ok = pcall(function()
        local symbol = symbolsApi:addTexture(S4_Pager_UI.MAP_SYMBOL_ID, x, y)
        symbol:setAnchor(0.5, 0.5)
        symbol:setRGBA(1, 0, 0, 1)
    end)
    return ok
end

local function spawnMissionZombieAt(x, y, z, count)
    if not x or not y then
        return 0
    end
    x = math.floor(x)
    y = math.floor(y)
    z = math.floor(z or 0)
    count = math.max(1, math.floor(count or 1))

    local spawnedCount = 0

    if addZombie then
        for i = 1, count do
            local sx = x + ZombRand(-2, 3)
            local sy = y + ZombRand(-2, 3)
            local ok1 = pcall(function()
                addZombie(sx, sy, z, nil)
            end)
            if ok1 then
                spawnedCount = spawnedCount + 1
            else
                local ok2 = pcall(function()
                    addZombie(sx, sy, z, 0)
                end)
                if ok2 then
                    spawnedCount = spawnedCount + 1
                end
            end
        end
    end

    if spawnedCount > 0 then
        return spawnedCount
    end

    if createHordeFromTo then
        local okHorde = pcall(function()
            createHordeFromTo(x, y, x, y, count)
        end)
        if okHorde then
            return count
        end
    end

    if sendClientCommand then
        pcall(function()
            sendClientCommand("S4SMD", "SpawnMissionZombie", {
                x = x,
                y = y,
                z = z,
                count = count
            })
        end)
        return count
    end

    if isDebugEnabled and isDebugEnabled() then
        print(string.format("[S4_Pager] Failed local zombie spawn at %d,%d,%d", x, y, z))
    end
    return 0
end

local function completeMission(player, reasonText, r, g, b)
    if not player then
        return
    end
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        return
    end
    mission.status = "completed"
    pData.S4PagerMission = nil
    clearMissionMapMarkers()
    if player.setHaloNote then
        player:setHaloNote(reasonText or "Pager mission complete", r or 80, g or 220, b or 80, 300)
    end
    if S4_Pager_UI.instance and S4_Pager_UI.instance.player == player then
        S4_Pager_UI.instance:refreshData()
    end
end

function S4_Pager_UI:showForPlayer(player)
    if not player then
        return
    end
    if not S4_Pager_UI.instance then
        local w = 480
        local h = 280
        local x = (getCore():getScreenWidth() - w) / 2
        local y = (getCore():getScreenHeight() - h) / 2
        S4_Pager_UI.instance = S4_Pager_UI:new(player, x, y, w, h)
        S4_Pager_UI.instance:initialise()
        S4_Pager_UI.instance:instantiate()
    end
    S4_Pager_UI.instance.player = player
    S4_Pager_UI.instance:refreshData()
    S4_Pager_UI.instance:addToUIManager()
    S4_Pager_UI.instance:setVisible(true)
end

function S4_Pager_UI:new(player, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.moveWithMouse = true
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o.borderColor = {
        r = 0.8,
        g = 0.8,
        b = 0.8,
        a = 1
    }
    o:setWantKeyEvents(true)
    o.texture = getTexture("media/textures/PagerUI.png")
    if not o.texture then
        o.texture = getTexture("media/textures/PagerUI.PNG")
    end
    o.pendingMission = nil
    return o
end

function S4_Pager_UI:initialise()
    ISPanel.initialise(self)
end

function S4_Pager_UI:createChildren()
    ISPanel.createChildren(self)

    self.startBtn = ISButton:new(20, self.height - 44, 100, 28, randomStartLabel(), self, S4_Pager_UI.onStartMission)
    self.startBtn:initialise()
    self:addChild(self.startBtn)

    self.rollBtn = ISButton:new(126, self.height - 44, 140, 28, "DEBUG: New Contract", self, S4_Pager_UI.onRollMission)
    self.rollBtn:initialise()
    self:addChild(self.rollBtn)

    self.completeBtn = ISButton:new(20, self.height - 74, 100, 24, "DEBUG: Complete", self, S4_Pager_UI.onDebugComplete)
    self.completeBtn:initialise()
    self:addChild(self.completeBtn)

    self.failBtn = ISButton:new(126, self.height - 74, 140, 24, "DEBUG: Fail", self, S4_Pager_UI.onDebugFail)
    self.failBtn:initialise()
    self:addChild(self.failBtn)

    self.setPointBtn = ISButton:new(20, self.height - 104, 246, 24, "DEBUG: Set Point Here", self,
        S4_Pager_UI.onDebugSetPointHere)
    self.setPointBtn:initialise()
    self:addChild(self.setPointBtn)

    self.closeBtn = ISButton:new(self.width - 74, self.height - 44, 54, 28, "Close", self, S4_Pager_UI.onCloseUI)
    self.closeBtn:initialise()
    self:addChild(self.closeBtn)
end

function S4_Pager_UI:refreshData()
    local pData = self.player:getModData()
    local mission = pData.S4PagerMission
    if mission and mission.status == "active" then
        local left = mission.endWorldHours - nowWorldHours()
        if left < 0 then
            left = 0
        end
        self.activeMission = mission
        self.pendingMission = nil
        self.startBtn:setEnable(false)
        self.startBtn:setTitle("Start")
        self.rollBtn:setEnable(true)
        self.completeBtn:setEnable(true)
        self.failBtn:setEnable(true)
        self.setPointBtn:setEnable(false)
        self.statusText = string.format("Active mission: %.1fh left", left)
        return
    end

    self.activeMission = nil
    if not self.pendingMission then
        self.pendingMission = buildMission()
    end
    self.startBtn:setTitle(randomStartLabel())
    self.startBtn:setEnable(true)
    self.rollBtn:setEnable(true)
    self.completeBtn:setEnable(false)
    self.failBtn:setEnable(false)
    self.setPointBtn:setEnable(true)
    self.statusText = "Ready to start mission"
end

function S4_Pager_UI:onRollMission()
    self.pendingMission = buildMission()
end

function S4_Pager_UI:onStartMission()
    if not self.pendingMission then
        return
    end
    local startAt = nowWorldHours()
    local m = {
        status = "active",
        startWorldHours = startAt,
        endWorldHours = startAt + self.pendingMission.durationHours,
        durationHours = self.pendingMission.durationHours,
        objective = self.pendingMission.objective,
        location = self.pendingMission.location,
        targetX = self.pendingMission.targetX,
        targetY = self.pendingMission.targetY,
        targetZ = self.pendingMission.targetZ,
        killGoal = math.max(1, math.floor(self.pendingMission.zombieCount or 1)),
        killsDone = 0
    }
    self.player:getModData().S4PagerMission = m

    local markerOk = addMissionMapMarker(m.targetX, m.targetY)
    local spawnedCount = spawnMissionZombieAt(m.targetX, m.targetY, m.targetZ, m.killGoal)
    local zombieOk = spawnedCount > 0

    if self.player.setHaloNote then
        if markerOk and zombieOk then
            self.player:setHaloNote(string.format("Mission started: %d targets", m.killGoal), 80, 220, 80, 300)
        elseif markerOk then
            self.player:setHaloNote("Pager mission started: marca en mapa creada", 80, 220, 80, 300)
        else
            self.player:setHaloNote("Pager mission started", 80, 220, 80, 300)
        end
    end
    self:refreshData()
end

function S4_Pager_UI:onDebugComplete()
    local pData = self.player:getModData()
    local mission = pData.S4PagerMission
    if mission and mission.status == "active" then
        pData.S4PagerMission = nil
        clearMissionMapMarkers()
        if self.player.setHaloNote then
            self.player:setHaloNote("Pager mission complete (DEBUG)", 80, 220, 80, 300)
        end
    end
    self:refreshData()
end

function S4_Pager_UI:onDebugFail()
    local pData = self.player:getModData()
    local mission = pData.S4PagerMission
    if mission and mission.status == "active" then
        pData.S4PagerMission = nil
        clearMissionMapMarkers()
        if self.player.setHaloNote then
            self.player:setHaloNote("Pager mission failed (DEBUG)", 220, 80, 80, 300)
        end
    end
    self:refreshData()
end

function S4_Pager_UI:onDebugSetPointHere()
    if self.activeMission then
        if self.player and self.player.setHaloNote then
            self.player:setHaloNote("DEBUG: Finish current mission first", 220, 180, 80, 240)
        end
        return
    end
    if not self.pendingMission then
        self.pendingMission = buildMission()
    end
    local p = self.player
    if not p then
        return
    end
    local x = math.floor(p:getX())
    local y = math.floor(p:getY())
    local z = math.floor(p:getZ())
    self.pendingMission.targetX = x
    self.pendingMission.targetY = y
    self.pendingMission.targetZ = z
    self.pendingMission.location = string.format("Player Selected Point (%d,%d,%d)", x, y, z)
    addMissionMapMarker(x, y)
    if p.setHaloNote then
        p:setHaloNote("DEBUG: Mission point set to your position", 80, 220, 80, 260)
    end
    self:refreshData()
end

function S4_Pager_UI:onCloseUI()
    self:close()
end

function S4_Pager_UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

function S4_Pager_UI:render()
    ISPanel.render(self)

    if self.texture then
        self:drawTextureScaled(self.texture, 0, 0, self.width, self.height, 0.28)
    end

    self:drawText("Pager Mission Terminal", 20, 12, 1, 1, 1, 1, UIFont.Medium)
    self:drawText(self.statusText or "", 20, 38, 0.9, 0.9, 0.9, 1, UIFont.Small)

    if self.activeMission then
        local left = self.activeMission.endWorldHours - nowWorldHours()
        if left < 0 then
            left = 0
        end
        self:drawText("Duration: " .. string.format("%.1f", self.activeMission.durationHours) .. "h", 20, 82, 1, 1, 1,
            1, UIFont.Small)
        self:drawText("Time left: " .. string.format("%.1f", left) .. "h", 20, 104, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Objective: " .. tostring(self.activeMission.objective), 20, 126, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Location: " .. tostring(self.activeMission.location), 20, 148, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Targets: " .. tostring(self.activeMission.killsDone or 0) .. "/" ..
                          tostring(self.activeMission.killGoal or 1), 20, 170, 1, 0.9, 0.8, 1, UIFont.Small)
        self:drawText("Coords: " .. tostring(self.activeMission.targetX) .. "," .. tostring(self.activeMission.targetY),
            20, 192, 1, 0.7, 0.7, 1, UIFont.Small)
    elseif self.pendingMission then
        self:drawText("Duration: " .. tostring(self.pendingMission.durationHours) .. "h", 20, 82, 1, 1, 1, 1,
            UIFont.Small)
        self:drawText("Objective: " .. tostring(self.pendingMission.objective), 20, 104, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Location: " .. tostring(self.pendingMission.location), 20, 126, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Targets: " .. tostring(self.pendingMission.zombieCount or 1), 20, 148, 1, 0.9, 0.8, 1,
            UIFont.Small)
        self:drawText("Coords: " .. tostring(self.pendingMission.targetX) .. "," ..
                          tostring(self.pendingMission.targetY), 20, 170, 1, 0.7, 0.7, 1, UIFont.Small)
    end
end

function S4_Pager_UI:close()
    ISPanel.close(self)
    self:removeFromUIManager()
    S4_Pager_UI.instance = nil
end

function S4_Pager_UI.UpdateMissionState()
    local player = getSpecificPlayer(0)
    if not player then
        return
    end
    local pData = player:getModData()
    local mission = pData.S4PagerMission
    if not mission or mission.status ~= "active" then
        return
    end
    if nowWorldHours() >= mission.endWorldHours then
        pData.S4PagerMission = nil
        clearMissionMapMarkers()
        if player.setHaloNote then
            player:setHaloNote("Pager mission failed: out of time", 220, 80, 80, 300)
        end
        if S4_Pager_UI.instance and S4_Pager_UI.instance.player == player then
            S4_Pager_UI.instance:refreshData()
        end
    end
end
Events.EveryOneMinute.Add(S4_Pager_UI.UpdateMissionState)

function S4_Pager_UI.OnZombieDead(zombie)
    local player = getSpecificPlayer(0)
    if not player or not zombie then
        return
    end
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        return
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local tx = mission.targetX or 0
    local ty = mission.targetY or 0
    local dx = zx - tx
    local dy = zy - ty
    local inMissionArea = (dx * dx + dy * dy) <= (20 * 20)
    if not inMissionArea then
        return
    end

    mission.killsDone = math.min((mission.killsDone or 0) + 1, mission.killGoal or 1)
    if player.setHaloNote then
        player:setHaloNote(string.format("Targets: %d/%d", mission.killsDone, mission.killGoal or 1), 80, 220, 80, 180)
    end

    if mission.killsDone >= (mission.killGoal or 1) then
        completeMission(player, "Pager mission complete", 80, 220, 80)
    elseif S4_Pager_UI.instance and S4_Pager_UI.instance.player == player then
        S4_Pager_UI.instance:refreshData()
    end
end
Events.OnZombieDead.Add(S4_Pager_UI.OnZombieDead)

local function OnGameStartPagerMissionSymbol()
    ensureMapSymbolDefinition()
end
Events.OnGameStart.Add(OnGameStartPagerMissionSymbol)
