require "ISUI/ISPanel"

S4_Pager_UI = ISPanel:derive("S4_Pager_UI")
S4_Pager_UI.instance = nil

local function nowWorldHours()
    local gt = GameTime and GameTime:getInstance() or nil
    if gt and gt.getWorldAgeHours then
        return gt:getWorldAgeHours()
    end
    return 0
end

local function buildMission()
    local objectives = {"Clean the warehouse office", "Dispose of suspicious trash bags",
                        "Disinfect a small clinic room", "Sanitize the motel hallway",
                        "Clean blood traces in a storage unit", "Deep-clean a private garage"}
    local locations = {"Muldraugh - Warehouse", "West Point - Gas Station", "Riverside - Motel", "Rosewood - Clinic",
                       "Louisville Outskirts - Storage", "March Ridge - Apartments"}

    return {
        durationHours = ZombRand(2, 9), -- 2..8
        objective = objectives[ZombRand(1, #objectives + 1)],
        location = locations[ZombRand(1, #locations + 1)]
    }
end

local START_BUTTON_LABELS = {"Start", "Get that man", "Take their stuff", "You can do it."}

local function randomStartLabel()
    return START_BUTTON_LABELS[ZombRand(1, #START_BUTTON_LABELS + 1)] or "Start"
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
        location = self.pendingMission.location
    }
    self.player:getModData().S4PagerMission = m
    if self.player.setHaloNote then
        self.player:setHaloNote("Pager mission started", 80, 220, 80, 300)
    end
    self:refreshData()
end

function S4_Pager_UI:onDebugComplete()
    local pData = self.player:getModData()
    local mission = pData.S4PagerMission
    if mission and mission.status == "active" then
        pData.S4PagerMission = nil
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
        if self.player.setHaloNote then
            self.player:setHaloNote("Pager mission failed (DEBUG)", 220, 80, 80, 300)
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
        self:drawText("Duration: " .. string.format("%.1f", self.activeMission.durationHours) .. "h", 20, 82, 1, 1, 1,
            1, UIFont.Small)
        self:drawText("Time left: " .. string.format("%.1f", left) .. "h", 20, 104, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Objective: " .. tostring(self.activeMission.objective), 20, 126, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Location: " .. tostring(self.activeMission.location), 20, 148, 1, 1, 1, 1, UIFont.Small)
    elseif self.pendingMission then
        self:drawText("Duration: " .. tostring(self.pendingMission.durationHours) .. "h", 20, 82, 1, 1, 1, 1,
            UIFont.Small)
        self:drawText("Objective: " .. tostring(self.pendingMission.objective), 20, 104, 1, 1, 1, 1, UIFont.Small)
        self:drawText("Location: " .. tostring(self.pendingMission.location), 20, 126, 1, 1, 1, 1, UIFont.Small)
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
        mission.status = "completed"
        pData.S4PagerMission = nil
        if player.setHaloNote then
            player:setHaloNote("Pager mission complete", 80, 220, 80, 300)
        end
    end
end
Events.EveryOneMinute.Add(S4_Pager_UI.UpdateMissionState)
