S4_Pager_Context = {}
require "ISUI/Pager_UI/S4_Pager_UI"

S4_Pager_Context.TOGGLE_KEY = Keyboard.KEY_6
S4_Pager_Context.HOTBAR_CLOSE_WINDOW_MS = 500

local function isHotbarNumberKey(key)
    return key == Keyboard.KEY_1 or key == Keyboard.KEY_2 or key == Keyboard.KEY_3 or key == Keyboard.KEY_4 or key ==
               Keyboard.KEY_5 or key == Keyboard.KEY_6 or key == Keyboard.KEY_7 or key == Keyboard.KEY_8 or key ==
               Keyboard.KEY_9 or key == Keyboard.KEY_0
end

local function isPagerUiOpen()
    return S4_Pager_UI and S4_Pager_UI.instance and S4_Pager_UI.instance.isVisible and S4_Pager_UI.instance:isVisible()
end

local function playPagerGrabSound()
    if getSoundManager and getSoundManager().playUISound then
        local ok = pcall(function()
            getSoundManager():playUISound("pageGrab")
        end)
        if not ok then
            getSoundManager():playUISound("S4_QoL_ButtonPush")
        end
    end
end

local function closePagerUiIfOpen()
    if isPagerUiOpen() and S4_Pager_UI.instance.close then
        S4_Pager_UI.instance:close()
        return true
    end
    return false
end

local function isPagerInHands(player)
    if not player then
        return false
    end
    local p = player.getPrimaryHandItem and player:getPrimaryHandItem() or nil
    if p and p.getFullType and p:getFullType() == "Base.Pager" then
        return true
    end
    local s = player.getSecondaryHandItem and player:getSecondaryHandItem() or nil
    if s and s.getFullType and s:getFullType() == "Base.Pager" then
        return true
    end
    return false
end

local function playerHasPager(player)
    if not player then
        return false
    end
    local inv = player:getInventory()
    if inv and inv:containsTypeRecurse("Pager") then
        return true
    end
    local p = player.getPrimaryHandItem and player:getPrimaryHandItem() or nil
    if p and p.getFullType and p:getFullType() == "Base.Pager" then
        return true
    end
    local s = player.getSecondaryHandItem and player:getSecondaryHandItem() or nil
    if s and s.getFullType and s:getFullType() == "Base.Pager" then
        return true
    end
    return false
end

function S4_Pager_Context.InventoryMenu(playerNum, context, items)
    items = ISInventoryPane.getActualItems(items)
    if not items then
        return
    end

    local player = getSpecificPlayer(playerNum)
    if not player then
        return
    end

    local list = {}
    if items.size and items.get then
        for i = 0, items:size() - 1 do
            list[#list + 1] = items:get(i)
        end
    else
        list = items
    end
    if not list or #list == 0 then
        return
    end

    local item = list[1]
    if item and item.getFullType and item:getFullType() == "Base.Pager" then
        context:addOption("Use Pager", player, S4_Pager_Context.OpenPagerMissionUI)
    end

    local function isCameraItem(it)
        if not it then
            return false
        end
        local ft = it.getFullType and it:getFullType() or ""
        local ty = it.getType and it:getType() or ""
        local dn = it.getDisplayName and it:getDisplayName() or ""
        ft = string.lower(tostring(ft))
        ty = string.lower(tostring(ty))
        dn = string.lower(tostring(dn))
        if string.find(ft, "camera", 1, true) then
            return true
        end
        if string.find(ty, "camera", 1, true) then
            return true
        end
        if string.find(dn, "camera", 1, true) or string.find(dn, "camara", 1, true) then
            return true
        end
        return false
    end

    local cameraItem = nil
    for i = 1, #list do
        local it = list[i]
        if isCameraItem(it) then
            cameraItem = it
            break
        end
    end
    if not cameraItem then
        return
    end

    local option = context:addOption("Usar Camara Desechable", player, S4_Pager_Context.UseDisposableCamera, cameraItem)

    local mission = nil
    if S4_Pager_UI and S4_Pager_UI.GetCameraPhotoTarget then
        mission = S4_Pager_UI.GetCameraPhotoTarget(player)
    end
    if not mission then
        option.notAvailable = true
        option.onSelect = nil
        local tt = ISToolTip:new()
        tt.description = "Necesitas una mision activa o recien completada del Pager."
        option.toolTip = tt
        return
    end

    local px, py = player:getX(), player:getY()
    local tx, ty = mission.targetX or 0, mission.targetY or 0
    local dx, dy = px - tx, py - ty
    if (dx * dx + dy * dy) > (10 * 10) then
        option.notAvailable = true
        option.onSelect = nil
        local tt = ISToolTip:new()
        tt.description = "Acercate a 10 celdas del objetivo para tomar la foto."
        option.toolTip = tt
    end
end

function S4_Pager_Context.OpenPagerMissionUI(player)
    if not player then
        return
    end
    S4_Pager_UI:showForPlayer(player)
end

function S4_Pager_Context.OnKeyTogglePager(key)
    local player = getSpecificPlayer(0)
    if not player or player:isDead() then
        return
    end
    local md = player:getModData()
    local nowMs = getTimestampMs and getTimestampMs() or 0

    if isHotbarNumberKey(key) then
        md.S4PagerLastHotbarToggleMs = nowMs
    end

    if key == S4_Pager_Context.TOGGLE_KEY then
        if not playerHasPager(player) then
            return
        end
        md.S4PagerLastHotbarToggleMs = nowMs
        if not closePagerUiIfOpen() then
            S4_Pager_UI:showForPlayer(player)
        end
    end
end

function S4_Pager_Context.OnPlayerUpdate(player)
    if not player or player:isDead() then
        return
    end
    local md = player:getModData()
    local nowInHands = isPagerInHands(player)
    local wasInHands = md.S4PagerWasInHands == true

    if nowInHands ~= wasInHands then
        md.S4PagerWasInHands = nowInHands
        playPagerGrabSound()
        if nowInHands then
            S4_Pager_UI:showForPlayer(player)
        else
            -- Only auto-close when pager was removed via hotbar key toggle.
            local nowMs = getTimestampMs and getTimestampMs() or 0
            local lastToggleMs = md.S4PagerLastHotbarToggleMs or 0
            if nowMs > 0 and lastToggleMs > 0 and (nowMs - lastToggleMs) <= S4_Pager_Context.HOTBAR_CLOSE_WINDOW_MS then
                closePagerUiIfOpen()
            end
        end
    end
end

function S4_Pager_Context.UseDisposableCamera(player, cameraItem)
    if not player then
        return
    end
    if S4_Pager_UI and S4_Pager_UI.CameraMissionPhoto then
        S4_Pager_UI.CameraMissionPhoto(player, cameraItem)
    elseif player.setHaloNote then
        player:setHaloNote("No se pudo usar la camara", 230, 110, 70, 220)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(S4_Pager_Context.InventoryMenu)
Events.OnKeyPressed.Add(S4_Pager_Context.OnKeyTogglePager)
Events.OnPlayerUpdate.Add(S4_Pager_Context.OnPlayerUpdate)
