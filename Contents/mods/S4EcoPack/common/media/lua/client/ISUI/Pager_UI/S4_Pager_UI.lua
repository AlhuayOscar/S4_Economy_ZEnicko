require "ISUI/ISPanel"
require "ISUI/Pager_UI/S4_Jobs_Lore"
require "ISUI/Pager_UI/S4_Pager_System"

S4_Pager_UI = ISPanel:derive("S4_Pager_UI")
S4_Pager_UI.instance = nil
S4_Pager_UI.MAP_SYMBOL_ID = "S4PagerMission"
S4_Pager_UI.MISSION_RADIUS = 20

local function ensureMapSymbolDefinition()
    return S4_Pager_System.ensureMapSymbolDefinition(S4_Pager_UI.MAP_SYMBOL_ID)
end

local nowWorldHours = S4_Pager_System.nowWorldHours
local MISSION_POINTS = S4_Jobs_Lore.MISSION_POINTS or {}
local MISSION_OBJECTIVES = S4_Jobs_Lore.MISSION_OBJECTIVES or {}
local START_BUTTON_LABELS = S4_Jobs_Lore.START_BUTTON_LABELS or {"Start"}
local MISSION_PHOTO_LORE = S4_Jobs_Lore.MISSION_PHOTO_LORE or {}

local function randomMissionPoint()
    return S4_Pager_System.randomMissionPoint(MISSION_POINTS)
end

local function buildMission()
    return S4_Pager_System.buildMission(MISSION_POINTS, MISSION_OBJECTIVES)
end

local function buildMissionByIndex(index)
    return S4_Pager_System.buildMissionByIndex(MISSION_POINTS, MISSION_OBJECTIVES, index)
end

local function randomStartLabel()
    return S4_Pager_System.randomStartLabel(START_BUTTON_LABELS)
end

local function getSymbolsApi()
    return S4_Pager_System.getSymbolsApi()
end

local function clearMissionMapMarkers()
    return S4_Pager_System.clearMissionMapMarkers()
end

local function addMissionMapMarker(x, y)
    return S4_Pager_System.addMissionMapMarker(S4_Pager_UI.MAP_SYMBOL_ID, x, y)
end

local function spawnMissionZombieAt(x, y, z, count)
    return S4_Pager_System.spawnMissionZombieAt(x, y, z, count)
end

local function completeMission(player, reasonText, r, g, b)
    local refreshed = S4_Pager_System.completeMission(player, {
        reasonText = reasonText,
        r = r,
        g = g,
        b = b,
        nowWorldHoursFn = nowWorldHours,
        addPhotoOnGroundFn = function(mission, p)
            return S4_Pager_System.addRandomPhotoOnGroundNearMission(mission, p, MISSION_PHOTO_LORE)
        end
    })
    if refreshed then
        clearMissionMapMarkers()
        if S4_Pager_UI.instance and S4_Pager_UI.instance.player == player then
            S4_Pager_UI.instance:refreshData()
        end
    end
end

local function addRandomPhotoToCorpse(zombie)
    return S4_Pager_System.addRandomPhotoToCorpse(zombie, MISSION_PHOTO_LORE)
end

local function hasMissionPhotoOnGround(mission)
    return S4_Pager_System.hasMissionPhotoOnGround(mission)
end

local function playerHasMissionPhoto(player, mission)
    return S4_Pager_System.playerHasMissionPhoto(player, mission)
end

local function findAnyWorkObjectCodeInInventory(player)
    return S4_Pager_System.findAnyWorkObjectCodeInInventory(player)
end

local function findAnyNearbyWorkObjectCode(player, radius)
    return S4_Pager_System.findAnyNearbyWorkObjectCode(player, radius)
end

local function getFixedPointData(player)
    return S4_Pager_System.getFixedPointData(player)
end

local function applyFixedPointToPending(self)
    if not self then
        return
    end
    self.pendingMission = S4_Pager_System.applyFixedPointToPending(self.player, self.pendingMission)
end

local function isPlayerNearMission(player, mission, range)
    return S4_Pager_System.isPlayerNearMission(player, mission, range)
end

local function isWithinMissionPhotoRange(player, mission, range)
    return S4_Pager_System.isWithinMissionPhotoRange(player, mission, range)
end

local function isPlayerOnMissionSpot(player, mission)
    return S4_Pager_System.isPlayerOnMissionSpot(player, mission)
end

local function getMissionSpotState(player, mission)
    return S4_Pager_System.getMissionSpotState(player, mission)
end

function S4_Pager_UI.GetCameraPhotoTarget(player)
    return S4_Pager_System.getCameraPhotoTarget(player)
end

local function removeOneItemFromPlayer(player, item)
    S4_Pager_System.removeOneItemFromPlayer(player, item)
end

local function createValuablePhotoInInventory(player, mission, sourceLabel)
    return S4_Pager_System.createValuablePhotoInInventory(player, mission, sourceLabel, MISSION_PHOTO_LORE)
end

local function countAliveZombiesAround(x, y, radius)
    return S4_Pager_System.countAliveZombiesAround(x, y, radius)
end

local function getDropTargetNearState(player, mission, maxCells)
    return S4_Pager_System.getDropTargetNearState(player, mission, maxCells)
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
    o.pendingMissionIndex = 1
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

    self.rollBtn = ISButton:new(126, self.height - 44, 140, 28, "Next Contract", self, S4_Pager_UI.onRollMission)
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
        self.pendingMission = buildMissionByIndex(self.pendingMissionIndex) or buildMission()
    end
    applyFixedPointToPending(self)
    self.startBtn:setTitle(randomStartLabel())
    self.isLocked = false
    self.lockReason = nil
    if self.pendingMission and self.pendingMission.missionGroup == "RosewoodKnoxBankHeist" then
        local part = tonumber(self.pendingMission.missionPart) or 1
        local progress = tonumber(pData.S4PagerBankHeistProgress) or 0
        if part > progress + 1 then
            self.isLocked = true
            self.lockReason = "Complete previous part first"
            self.startBtn:setEnable(false)
        end
    end

    if not self.isLocked then
        self.startBtn:setEnable(true)
    end
    self.rollBtn:setEnable(true)
    self.completeBtn:setEnable(false)
    self.failBtn:setEnable(false)
    self.setPointBtn:setEnable(true)
    if getFixedPointData(self.player) then
        self.setPointBtn:setTitle("DEBUG: Fixed Point ON")
    else
        self.setPointBtn:setTitle("DEBUG: Fixed Point OFF")
    end
    self.statusText = self.isLocked and ("LOCKED: " .. self.lockReason) or "Ready to start mission"
end

function S4_Pager_UI:onRollMission()
    local total = #MISSION_POINTS
    if total > 0 then
        self.pendingMissionIndex = (self.pendingMissionIndex or 1) + 1
        if self.pendingMissionIndex > total then
            self.pendingMissionIndex = 1
        end
    end
    self.pendingMission = buildMissionByIndex(self.pendingMissionIndex) or buildMission()
    applyFixedPointToPending(self)
end

function S4_Pager_UI:onStartMission()
    if not self.pendingMission then
        return
    end
    local startAt = nowWorldHours()
    local m = {
        status = "active",
        missionName = self.pendingMission.missionName,
        startWorldHours = startAt,
        endWorldHours = startAt + self.pendingMission.durationHours,
        durationHours = self.pendingMission.durationHours,
        objective = self.pendingMission.objective,
        location = self.pendingMission.location,
        targetX = self.pendingMission.targetX,
        targetY = self.pendingMission.targetY,
        targetZ = self.pendingMission.targetZ,
        areaMinX = self.pendingMission.areaMinX,
        areaMaxX = self.pendingMission.areaMaxX,
        areaMinY = self.pendingMission.areaMinY,
        areaMaxY = self.pendingMission.areaMaxY,
        hiddenPadding = self.pendingMission.hiddenPadding,
        requireMask = self.pendingMission.requireMask,
        requireBulletVest = self.pendingMission.requireBulletVest,
        nonCompliantPenaltyPct = self.pendingMission.nonCompliantPenaltyPct,
        missionMode = self.pendingMission.missionMode,
        missionGroup = self.pendingMission.missionGroup,
        missionPart = self.pendingMission.missionPart,
        missionPartTotal = self.pendingMission.missionPartTotal,
        requiredBag = self.pendingMission.requiredBag,
        requiredItemType = self.pendingMission.requiredItemType,
        requiredItemCount = self.pendingMission.requiredItemCount,
        escapeFromX = self.pendingMission.escapeFromX,
        escapeFromY = self.pendingMission.escapeFromY,
        escapeMinDistance = self.pendingMission.escapeMinDistance,
        killGoal = (self.pendingMission.missionMode == "stash_money" or self.pendingMission.missionMode == "escape_bank") and 0 or
            math.max(1, math.floor(self.pendingMission.zombieCount or 1)),
        killsDone = 0,
        photoDropped = false
    }
    if m.missionGroup == "RosewoodKnoxBankHeist" and tonumber(m.missionPart) == 1 then
        self.player:getModData().S4KnoxPart2SuppliesSpawned = nil
    end
    self.player:getModData().S4PagerMission = m

    local markerOk = addMissionMapMarker(m.targetX, m.targetY)
    local spawnedCount = 0
    if m.killGoal > 0 then
        spawnedCount = spawnMissionZombieAt(m.targetX, m.targetY, m.targetZ, m.killGoal)
    end
    local zombieOk = spawnedCount > 0

    if self.player.setHaloNote then
        if m.missionMode == "stash_money" then
            self.player:setHaloNote("Mission started: reach area and secure dirty money", 80, 220, 80, 300)
        elseif m.missionMode == "escape_bank" then
            self.player:setHaloNote("Mission started: Escape at least 350 cells from Knox Bank", 80, 220, 80, 300)
        elseif markerOk and zombieOk then
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
        S4_Pager_System.stopMissionPersistentAudio(self.player)
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
        S4_Pager_System.stopMissionPersistentAudio(self.player)
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
    local p = self.player
    if not p then
        return
    end
    local md = p:getModData()
    local enabled = md.S4PagerDebugFixedPointEnabled == true
    if enabled then
        md.S4PagerDebugFixedPointEnabled = false
        md.S4PagerDebugFixedX = nil
        md.S4PagerDebugFixedY = nil
        md.S4PagerDebugFixedZ = nil
        if p.setHaloNote then
            p:setHaloNote("DEBUG: Fixed mission point OFF", 220, 200, 120, 260)
        end
    else
        local x = math.floor(p:getX())
        local y = math.floor(p:getY())
        local z = math.floor(p:getZ())
        md.S4PagerDebugFixedPointEnabled = true
        md.S4PagerDebugFixedX = x
        md.S4PagerDebugFixedY = y
        md.S4PagerDebugFixedZ = z
        addMissionMapMarker(x, y)
        if p.setHaloNote then
            p:setHaloNote("DEBUG: Fixed mission point ON", 80, 220, 80, 260)
        end
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
        local contractTitle = self.activeMission.missionName or self.activeMission.objective or "Mission"
        local coordsText = "Coords: " .. tostring(self.activeMission.targetX) .. "," ..
                               tostring(self.activeMission.targetY)
        local spotState = getMissionSpotState(self.player, self.activeMission)
        self:drawText("Duration: " .. string.format("%.1f", self.activeMission.durationHours) .. "h", 20, 82, 1, 1, 1,
            1, UIFont.Small)
        self:drawText("Time left: " .. string.format("%.1f", left) .. "h", 20, 104, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Contract: " .. tostring(contractTitle), 20, 126, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Objective: " .. tostring(self.activeMission.runtimeObjective or self.activeMission.objective), 20, 148, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Location: " .. tostring(self.activeMission.location), 20, 170, 1, 1, 1, 1, UIFont.Small)
        if (self.activeMission.killGoal or 0) > 0 then
            self:drawText("Targets: " .. tostring(self.activeMission.killsDone or 0) .. "/" ..
                              tostring(self.activeMission.killGoal or 1), 20, 192, 1, 0.9, 0.8, 1, UIFont.Small)
        elseif self.activeMission.missionMode == "stash_money" then
            local need = tonumber(self.activeMission.requiredItemCount) or 10
            self:drawText("Requirement: Duffelbag + " .. tostring(need) .. " Money Bundle", 20, 192, 1, 0.9, 0.8, 1,
                UIFont.Small)
        elseif self.activeMission.missionMode == "escape_bank" then
            local dist, need = S4_Pager_System.getEscapeDistanceState(self.player, self.activeMission)
            self:drawText("Escape: " .. tostring(dist) .. "/" .. tostring(need) .. " cells", 20, 192, 1, 0.9, 0.8, 1,
                UIFont.Small)
        end
        self:drawText(coordsText, 20, 214, 1, 0.7, 0.7, 1, UIFont.Small)
        if spotState == "on_spot" then
            local w = getTextManager():MeasureStringX(UIFont.Small, coordsText)
            self:drawText("On Spot", 26 + w, 214, 0.2, 0.95, 0.2, 1, UIFont.Small)
        elseif spotState == "near" then
            local w = getTextManager():MeasureStringX(UIFont.Small, coordsText)
            self:drawText("You're near", 26 + w, 214, 0.95, 0.85, 0.2, 1, UIFont.Small)
        end
        if self.activeMission and self.activeMission.missionMode == "stash_money" and
            getDropTargetNearState(self.player, self.activeMission, 3) then
            self:drawText("Destination nearby", 20, 228, 0.2, 0.95, 0.2, 1, UIFont.Small)
        end
    elseif self.pendingMission then
        local contractTitle = self.pendingMission.missionName or self.pendingMission.objective or "Mission"
        local coordsText = "Coords: " .. tostring(self.pendingMission.targetX) .. "," ..
                               tostring(self.pendingMission.targetY)
        local spotState = getMissionSpotState(self.player, self.pendingMission)
        self:drawText("Duration: " .. tostring(self.pendingMission.durationHours) .. "h", 20, 82, 1, 1, 1, 1,
            UIFont.Small)
        self:drawText("Contract: " .. tostring(contractTitle), 20, 104, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Objective: " .. tostring(self.pendingMission.objective), 20, 126, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Location: " .. tostring(self.pendingMission.location), 20, 148, 1, 1, 1, 1, UIFont.Small)
        if self.pendingMission.missionMode == "stash_money" then
            local need = tonumber(self.pendingMission.requiredItemCount) or 10
            self:drawText("Requirement: Duffelbag + " .. tostring(need) .. " Money Bundle", 20, 170, 1, 0.9, 0.8, 1,
                UIFont.Small)
        elseif self.pendingMission.missionMode == "escape_bank" then
            local need = tonumber(self.pendingMission.escapeMinDistance) or 350
            self:drawText("Requirement: Move away " .. tostring(need) .. " cells", 20, 170, 1, 0.9, 0.8, 1,
                UIFont.Small)
        else
            self:drawText("Targets: " .. tostring(self.pendingMission.zombieCount or 1), 20, 170, 1, 0.9, 0.8, 1,
                UIFont.Small)
        end
        self:drawText(coordsText, 20, 192, 1, 0.7, 0.7, 1, UIFont.Small)
        if self.isLocked then
            self:drawText(self.lockReason or "Locked", 20, 214, 1, 0.3, 0.3, 1, UIFont.Small)
        end
        if spotState == "on_spot" then
            local w = getTextManager():MeasureStringX(UIFont.Small, coordsText)
            self:drawText("On Spot", 26 + w, 192, 0.2, 0.95, 0.2, 1, UIFont.Small)
        elseif spotState == "near" then
            local w = getTextManager():MeasureStringX(UIFont.Small, coordsText)
            self:drawText("You're near", 26 + w, 192, 0.95, 0.85, 0.2, 1, UIFont.Small)
        end
    end
end

function S4_Pager_UI:close()
    ISPanel.close(self)
    self:removeFromUIManager()
    S4_Pager_UI.instance = nil
end

function S4_Pager_UI.UpdateMissionState()
    local player = getSpecificPlayer(0)
    S4_Pager_System.updateMissionState(player, {
        missionRadius = S4_Pager_UI.MISSION_RADIUS,
        nowWorldHoursFn = nowWorldHours,
        getMissionSpotStateFn = getMissionSpotState,
        isPlayerNearMissionFn = isPlayerNearMission,
        addMissionMapMarkerFn = addMissionMapMarker,
        countAliveZombiesAroundFn = countAliveZombiesAround,
        hasMissionPhotoOnGroundFn = hasMissionPhotoOnGround,
        playerHasMissionPhotoFn = playerHasMissionPhoto,
        clearMissionMapMarkersFn = clearMissionMapMarkers,
        completeMissionFn = completeMission,
        onRefreshUiFn = function(forPlayer)
            if S4_Pager_UI.instance and S4_Pager_UI.instance.player == forPlayer then
                S4_Pager_UI.instance:refreshData()
            end
        end
    })
end
Events.EveryOneMinute.Add(S4_Pager_UI.UpdateMissionState)

function S4_Pager_UI.OnZombieDead(zombie)
    local player = getSpecificPlayer(0)
    S4_Pager_System.onZombieDead(zombie, player, {
        missionRadius = S4_Pager_UI.MISSION_RADIUS,
        addRandomPhotoToCorpseFn = addRandomPhotoToCorpse,
        completeMissionFn = completeMission,
        onRefreshUiFn = function(forPlayer)
            if S4_Pager_UI.instance and S4_Pager_UI.instance.player == forPlayer then
                S4_Pager_UI.instance:refreshData()
            end
        end
    })
end
Events.OnZombieDead.Add(S4_Pager_UI.OnZombieDead)

function S4_Pager_UI.OnPlayerUpdateValuableHalo(player)
    if not player or player ~= getSpecificPlayer(0) then
        return
    end
    S4_Pager_System.updateRobberyAlarm(player, {
        getMissionSpotStateFn = getMissionSpotState
    })
    S4_Pager_System.onPlayerUpdateValuableHalo(player, {
        findAnyWorkObjectCodeInInventoryFn = findAnyWorkObjectCodeInInventory,
        findAnyNearbyWorkObjectCodeFn = findAnyNearbyWorkObjectCode
    })
end
Events.OnPlayerUpdate.Add(S4_Pager_UI.OnPlayerUpdateValuableHalo)

function S4_Pager_UI.OnWeaponSwing(player, weapon)
    if not player or player ~= getSpecificPlayer(0) then
        return
    end
    S4_Pager_System.onWeaponNoise(player, weapon, {
        getMissionSpotStateFn = getMissionSpotState
    })
end
if Events.OnWeaponSwing then
    Events.OnWeaponSwing.Add(S4_Pager_UI.OnWeaponSwing)
end

function S4_Pager_UI.CameraMissionPhoto(player, cameraItem)
    S4_Pager_System.cameraMissionPhoto(player, cameraItem, {
        getCameraPhotoTargetFn = S4_Pager_UI.GetCameraPhotoTarget,
        isWithinMissionPhotoRangeFn = isWithinMissionPhotoRange,
        createValuablePhotoInInventoryFn = createValuablePhotoInInventory,
        removeOneItemFromPlayerFn = removeOneItemFromPlayer
    })
end

function S4_Pager_UI.InventoryCameraMenu(playerNum, context, items)
    S4_Pager_System.inventoryCameraMenu(playerNum, context, items, {
        cameraMissionPhotoFn = S4_Pager_UI.CameraMissionPhoto,
        isWithinMissionPhotoRangeFn = isWithinMissionPhotoRange
    })
end
-- Inventory camera context is registered in S4_Pager_Context to avoid duplicate hooks.

local function OnGameStartPagerMissionSymbol()
    ensureMapSymbolDefinition()
end
Events.OnGameStart.Add(OnGameStartPagerMissionSymbol)
