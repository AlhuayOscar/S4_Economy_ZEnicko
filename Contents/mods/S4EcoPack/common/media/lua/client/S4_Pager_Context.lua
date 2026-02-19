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
    local item = items and items[1] or nil
    if not item then
        return
    end

    local player = getSpecificPlayer(playerNum)
    if not player then
        return
    end

    if item:getFullType() == "Base.Pager" then
        context:addOption("Use Pager", player, S4_Pager_Context.OpenPagerMissionUI)
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

Events.OnPreFillInventoryObjectContextMenu.Add(S4_Pager_Context.InventoryMenu)
Events.OnKeyPressed.Add(S4_Pager_Context.OnKeyTogglePager)
Events.OnPlayerUpdate.Add(S4_Pager_Context.OnPlayerUpdate)
