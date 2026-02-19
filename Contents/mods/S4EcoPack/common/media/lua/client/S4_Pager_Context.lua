S4_Pager_Context = {}
require "ISUI/Pager_UI/S4_Pager_UI"

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

Events.OnPreFillInventoryObjectContextMenu.Add(S4_Pager_Context.InventoryMenu)

