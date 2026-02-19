require "ISUI/ISPanel"
require "ISUI/ISButton"

S4_Dev_ResetLua = ISPanel:derive("S4_Dev_ResetLua")
S4_Dev_ResetLua.instance = nil

local function canUseDevButton()
    return true
end

local function tryEngineLuaReset()
    -- Avoid direct engine ResetLua calls from mod scripts.
    -- Some builds expose mismatched signatures and still spam exceptions inside pcall.
    return false, "Engine ResetLua API not used in this build"
end

local function requestS4ModData()
    if not ModData or not ModData.request then
        return false
    end
    local keys = {"S4_CardData", "S4_CardLog", "S4_PlayerData", "S4_QuestData", "S4_ShopData", "S4_PlayerShopData",
                  "S4_PlayerXpData", "S4_ServerData"}
    for i = 1, #keys do
        pcall(function()
            ModData.request(keys[i])
        end)
    end
    return true
end

local function fallbackReloadOpenS4Windows()
    local comUI = S4_Computer_Main and S4_Computer_Main.instance or nil

    local reloaded = false
    if comUI then
        local apps = {comUI.GoodShop, comUI.GoodShopAdmin, comUI.Network, comUI.Settings, comUI.CardReader,
                      comUI.UserSetting}
        for i = 1, #apps do
            local app = apps[i]
            if app and app.isVisible and app:isVisible() and app.ReloadUI then
                pcall(function()
                    app:ReloadUI()
                end)
                reloaded = true
            end
        end
    end

    if S4_Pager_UI and S4_Pager_UI.instance and S4_Pager_UI.instance.refreshData then
        pcall(function()
            S4_Pager_UI.instance.pendingMission = nil
            S4_Pager_UI.instance:refreshData()
        end)
        reloaded = true
    end

    return reloaded
end

function S4_Dev_ResetLua:new(x, y, w, h)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 0.05,
        g = 0.05,
        b = 0.05,
        a = 0.55
    }
    o.borderColor = {
        r = 0.25,
        g = 0.25,
        b = 0.25,
        a = 0.8
    }
    o.moveWithMouse = false
    o:setWantKeyEvents(false)
    return o
end

function S4_Dev_ResetLua:initialise()
    ISPanel.initialise(self)
end

function S4_Dev_ResetLua:createChildren()
    ISPanel.createChildren(self)
    self.resetBtn = ISButton:new(6, 6, self.width - 12, self.height - 12, "Reset S4_Lua", self,
        S4_Dev_ResetLua.onResetClick)
    self.resetBtn:initialise()
    self:addChild(self.resetBtn)
end

function S4_Dev_ResetLua:onResetClick()
    local player = getSpecificPlayer(0)
    local _, _ = tryEngineLuaReset()
    local requested = requestS4ModData()
    local reloaded = fallbackReloadOpenS4Windows()
    local ok = requested or reloaded
    local method = table.concat({requested and "ModData.request" or "ModData n/a",
                                 reloaded and "ReloadUI" or "No open UI"}, " + ")

    if player and player.setHaloNote then
        if ok then
            player:setHaloNote("S4 reload: " .. tostring(method), 80, 220, 80, 220)
        else
            player:setHaloNote("S4 reload failed: " .. tostring(method), 220, 90, 90, 280)
        end
    end
end

function S4_Dev_ResetLua:prerender()
    ISPanel.prerender(self)
    local core = getCore and getCore() or nil
    if not core then
        return
    end
    local newX = core:getScreenWidth() - self.width - 14
    local newY = math.floor(core:getScreenHeight() * 0.45)
    if self.x ~= newX or self.y ~= newY then
        self:setX(newX)
        self:setY(newY)
    end
end

function S4_Dev_ResetLua.ensureVisible()
    if not canUseDevButton() then
        return
    end
    if S4_Dev_ResetLua.instance and S4_Dev_ResetLua.instance.isVisible and S4_Dev_ResetLua.instance:isVisible() then
        return
    end

    local core = getCore and getCore() or nil
    if not core then
        return
    end

    local w = 140
    local h = 34
    local x = core:getScreenWidth() - w - 14
    local y = math.floor(core:getScreenHeight() * 0.45)

    S4_Dev_ResetLua.instance = S4_Dev_ResetLua:new(x, y, w, h)
    S4_Dev_ResetLua.instance:initialise()
    S4_Dev_ResetLua.instance:instantiate()
    S4_Dev_ResetLua.instance:addToUIManager()
    S4_Dev_ResetLua.instance:setVisible(true)
end

function S4_Dev_ResetLua.onGameStart()
    S4_Dev_ResetLua.ensureVisible()
end

function S4_Dev_ResetLua.onResolutionChange()
    S4_Dev_ResetLua.ensureVisible()
end

Events.OnGameStart.Add(S4_Dev_ResetLua.onGameStart)
if Events.OnResolutionChange then
    Events.OnResolutionChange.Add(S4_Dev_ResetLua.onResolutionChange)
end
