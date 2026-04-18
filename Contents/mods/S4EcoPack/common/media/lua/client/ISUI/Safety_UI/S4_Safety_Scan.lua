S4_Safety_Scan = S4_Safety_Scan or {}

local function lowerSafe(value)
    return string.lower(tostring(value or ""))
end

local function itemLooksLikePager(item)
    if not item then
        return false
    end
    local fullType = lowerSafe(item.getFullType and item:getFullType() or "")
    local itemType = lowerSafe(item.getType and item:getType() or "")
    local displayName = lowerSafe(item.getDisplayName and item:getDisplayName() or "")
    return fullType == "base.pager" or itemType == "pager" or string.find(displayName, "pager", 1, true) ~= nil
end

local function itemLooksLikeWalkie(item)
    if not item then
        return false
    end
    local fullType = lowerSafe(item.getFullType and item:getFullType() or "")
    local itemType = lowerSafe(item.getType and item:getType() or "")
    local displayName = lowerSafe(item.getDisplayName and item:getDisplayName() or "")

    if string.find(fullType, "walkietalkie", 1, true) then
        return true
    end
    if string.find(itemType, "walkietalkie", 1, true) then
        return true
    end
    if string.find(displayName, "walkie talkie", 1, true) or string.find(displayName, "walkietalkie", 1, true) then
        return true
    end
    if string.find(displayName, "handy-talkie", 1, true) or string.find(displayName, "two-way radio", 1, true) then
        return true
    end
    return false
end

function S4_Safety_Scan.getChunkKey(cx, cy)
    return tostring(cx) .. ":" .. tostring(cy)
end

function S4_Safety_Scan.getChunkCount(scan, cx, cy)
    if not scan or not scan.counts then
        return 0
    end
    return scan.counts[S4_Safety_Scan.getChunkKey(cx, cy)] or 0
end

function S4_Safety_Scan.sumChunkRadius(scan, cx, cy, radius)
    if not scan then
        return 0
    end
    local total = 0
    for y = cy - radius, cy + radius do
        for x = cx - radius, cx + radius do
            total = total + S4_Safety_Scan.getChunkCount(scan, x, y)
        end
    end
    return total
end

function S4_Safety_Scan.playerHasPager(player)
    if not player then
        return false
    end
    local primary = player.getPrimaryHandItem and player:getPrimaryHandItem() or nil
    local secondary = player.getSecondaryHandItem and player:getSecondaryHandItem() or nil
    if itemLooksLikePager(primary) or itemLooksLikePager(secondary) then
        return true
    end

    local inv = player:getInventory()
    if inv and inv:containsTypeRecurse("Pager") then
        return true
    end

    local items = inv and inv:getItems() or nil
    if not items then
        return false
    end
    for i = 0, items:size() - 1 do
        if itemLooksLikePager(items:get(i)) then
            return true
        end
    end
    return false
end

function S4_Safety_Scan.playerHasWalkieTalkie(player)
    if not player then
        return false
    end
    local primary = player.getPrimaryHandItem and player:getPrimaryHandItem() or nil
    local secondary = player.getSecondaryHandItem and player:getSecondaryHandItem() or nil
    if itemLooksLikeWalkie(primary) or itemLooksLikeWalkie(secondary) then
        return true
    end

    local inv = player:getInventory()
    local items = inv and inv:getItems() or nil
    if not items then
        return false
    end
    for i = 0, items:size() - 1 do
        if itemLooksLikeWalkie(items:get(i)) then
            return true
        end
    end
    return false
end

function S4_Safety_Scan.playerHasSafetyMonitorKit(player)
    return S4_Safety_Scan.playerHasPager(player) and S4_Safety_Scan.playerHasWalkieTalkie(player)
end

function S4_Safety_Scan.isWalkieTalkieItem(item)
    return itemLooksLikeWalkie(item)
end

function S4_Safety_Scan.isPagerItem(item)
    return itemLooksLikePager(item)
end

function S4_Safety_Scan.scanAroundPlayer(player, radius)
    local square = player and player.getSquare and player:getSquare() or nil
    if not square then
        return {
            error = "No se pudo leer la posicion del jugador."
        }
    end

    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or (getCell and getCell() or nil)
    if not cell then
        return {
            error = "No se pudo leer la celda activa."
        }
    end

    local zlist = cell:getZombieList()
    local px = math.floor(square:getX())
    local py = math.floor(square:getY())
    local pz = math.floor(square:getZ())
    local centerChunkX = math.floor(px / 10)
    local centerChunkY = math.floor(py / 10)
    radius = math.max(1, tonumber(radius) or 2)

    local counts = {}
    local visibleAlive = 0
    local loadedAlive = 0
    local maxCount = 0
    local hottestChunkX = centerChunkX
    local hottestChunkY = centerChunkY

    if zlist then
        for i = 0, zlist:size() - 1 do
            local zombie = zlist:get(i)
            if zombie and (not zombie:isDead()) then
                loadedAlive = loadedAlive + 1
                local zcx = math.floor(zombie:getX() / 10)
                local zcy = math.floor(zombie:getY() / 10)
                if math.abs(zcx - centerChunkX) <= radius and math.abs(zcy - centerChunkY) <= radius then
                    local key = S4_Safety_Scan.getChunkKey(zcx, zcy)
                    local newCount = (counts[key] or 0) + 1
                    counts[key] = newCount
                    visibleAlive = visibleAlive + 1
                    if newCount > maxCount then
                        maxCount = newCount
                        hottestChunkX = zcx
                        hottestChunkY = zcy
                    end
                end
            end
        end
    end

    local scan = {
        playerX = px,
        playerY = py,
        playerZ = pz,
        centerChunkX = centerChunkX,
        centerChunkY = centerChunkY,
        radius = radius,
        counts = counts,
        visibleAlive = visibleAlive,
        loadedAlive = loadedAlive,
        maxCount = maxCount,
        hottestChunkX = hottestChunkX,
        hottestChunkY = hottestChunkY
    }
    scan.centerCount = S4_Safety_Scan.getChunkCount(scan, centerChunkX, centerChunkY)
    scan.chunk3x3 = S4_Safety_Scan.sumChunkRadius(scan, centerChunkX, centerChunkY, math.min(1, radius))
    scan.chunk5x5 = S4_Safety_Scan.sumChunkRadius(scan, centerChunkX, centerChunkY, math.min(2, radius))
    return scan
end
