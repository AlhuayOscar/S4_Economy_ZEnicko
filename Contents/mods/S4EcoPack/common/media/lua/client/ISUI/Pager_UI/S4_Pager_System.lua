S4_Pager_System = S4_Pager_System or {}

local function asText(value, fallback)
    if value == nil then
        return fallback or ""
    end
    local t = tostring(value)
    if t == "" then
        return fallback or ""
    end
    return t
end

local function safeLoreEntry(missionPhotoLore)
    if not missionPhotoLore or #missionPhotoLore == 0 then
        return {title = "Work Evidence", note = "Marked evidence tied to this contract."}
    end
    local entry = missionPhotoLore[ZombRand(1, #missionPhotoLore + 1)] or {}
    return {
        title = asText(entry.title, "Work Evidence"),
        note = asText(entry.note, "Marked evidence tied to this contract.")
    }
end

function S4_Pager_System.nowWorldHours()
    local gt = GameTime and GameTime:getInstance() or nil
    if gt and gt.getWorldAgeHours then
        return gt:getWorldAgeHours()
    end
    return 0
end

function S4_Pager_System.randomWorkObjectCode()
    return string.format("%03d-%03d", ZombRand(0, 1000), ZombRand(0, 1000))
end

function S4_Pager_System.resolvePhotoItemType()
    local candidates = {"Base.Photograph", "Base.Photo", "Base.Polaroid", "Base.Picture", "Base.Notepad", "Base.Note",
                        "Base.Notebook", "Base.SheetPaper2", "Base.SheetPaper"}
    local sm = getScriptManager and getScriptManager() or nil
    if sm and sm.FindItem then
        for i = 1, #candidates do
            local t = candidates[i]
            local ok, item = pcall(function()
                return sm:FindItem(t)
            end)
            if ok and item then
                return t
            end
        end
    end
    return "Base.Photograph"
end

function S4_Pager_System.isWithinMissionPhotoRange(player, mission, range)
    if not player or not mission then
        return false
    end
    local px = player:getX()
    local py = player:getY()
    local tx = mission.targetX or 0
    local ty = mission.targetY or 0
    local dx = px - tx
    local dy = py - ty
    local rr = range or 10
    return (dx * dx + dy * dy) <= (rr * rr)
end

function S4_Pager_System.randomMissionPoint(points)
    return points[ZombRand(1, #points + 1)]
end

function S4_Pager_System.buildMission(points, objectives)
    local point = S4_Pager_System.randomMissionPoint(points)
    local objective = asText(point.objective or objectives[ZombRand(1, #objectives + 1)], "Eliminate targets")
    local zombieCount = nil
    if point.zombieCount ~= nil then
        zombieCount = math.max(0, math.floor(point.zombieCount))
    else
        zombieCount = ZombRand(1, 4)
    end
    return {
        missionName = asText(point.missionName or objective, "Contract"),
        durationHours = point.durationHours or ZombRand(2, 9),
        objective = objective,
        location = asText(point.location, "Unknown Location"),
        targetX = point.x,
        targetY = point.y,
        targetZ = point.z or 0,
        zombieCount = zombieCount,
        areaMinX = point.areaMinX,
        areaMaxX = point.areaMaxX,
        areaMinY = point.areaMinY,
        areaMaxY = point.areaMaxY,
        hiddenPadding = point.hiddenPadding,
        requireMask = point.requireMask,
        requireBulletVest = point.requireBulletVest,
        nonCompliantPenaltyPct = point.nonCompliantPenaltyPct,
        missionMode = point.missionMode,
        missionGroup = point.missionGroup,
        missionPart = point.missionPart,
        missionPartTotal = point.missionPartTotal,
        requiredBag = point.requiredBag,
        requiredItemType = point.requiredItemType,
        requiredItemCount = point.requiredItemCount,
        escapeFromX = point.escapeFromX,
        escapeFromY = point.escapeFromY,
        escapeMinDistance = point.escapeMinDistance
    }
end

function S4_Pager_System.buildMissionByIndex(points, objectives, index)
    if not points or #points == 0 then
        return nil
    end
    local i = math.floor(index or 1)
    if i < 1 then
        i = 1
    end
    i = ((i - 1) % #points) + 1
    local point = points[i]
    local objective = asText(point.objective or objectives[ZombRand(1, #objectives + 1)], "Eliminate targets")
    local zombieCount = nil
    if point.zombieCount ~= nil then
        zombieCount = math.max(0, math.floor(point.zombieCount))
    else
        zombieCount = ZombRand(1, 4)
    end
    return {
        missionName = asText(point.missionName or objective, "Contract"),
        durationHours = point.durationHours or ZombRand(2, 9),
        objective = objective,
        location = asText(point.location, "Unknown Location"),
        targetX = point.x,
        targetY = point.y,
        targetZ = point.z or 0,
        zombieCount = zombieCount,
        areaMinX = point.areaMinX,
        areaMaxX = point.areaMaxX,
        areaMinY = point.areaMinY,
        areaMaxY = point.areaMaxY,
        hiddenPadding = point.hiddenPadding,
        requireMask = point.requireMask,
        requireBulletVest = point.requireBulletVest,
        nonCompliantPenaltyPct = point.nonCompliantPenaltyPct,
        missionMode = point.missionMode,
        missionGroup = point.missionGroup,
        missionPart = point.missionPart,
        missionPartTotal = point.missionPartTotal,
        requiredBag = point.requiredBag,
        requiredItemType = point.requiredItemType,
        requiredItemCount = point.requiredItemCount,
        escapeFromX = point.escapeFromX,
        escapeFromY = point.escapeFromY,
        escapeMinDistance = point.escapeMinDistance
    }
end

local function missionAreaBounds(mission)
    if not mission then
        return nil
    end
    local minX = mission.areaMinX and mission.areaMaxX and math.min(mission.areaMinX, mission.areaMaxX) or nil
    local maxX = mission.areaMinX and mission.areaMaxX and math.max(mission.areaMinX, mission.areaMaxX) or nil
    local minY = mission.areaMinY and mission.areaMaxY and math.min(mission.areaMinY, mission.areaMaxY) or nil
    local maxY = mission.areaMinY and mission.areaMaxY and math.max(mission.areaMinY, mission.areaMaxY) or nil
    return minX, maxX, minY, maxY
end

local function isDuffelBagItem(item)
    if not item or not item.getFullType then
        return false
    end
    local ft = tostring(item:getFullType() or "")
    local dn = (item.getDisplayName and tostring(item:getDisplayName() or ""):lower()) or ""
    return ft:find("DuffelBag", 1, true) or ft:find("Duffelbag", 1, true) or dn:find("duffel", 1, true) or
               dn:find("lona", 1, true)
end

local function findDuffelBagItem(player)
    if not player then
        return nil
    end
    local inv = player:getInventory()
    if not inv then
        return nil
    end
    local items = inv:getItems()
    if not items then
        return nil
    end
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if isDuffelBagItem(it) then
            return it
        end
    end
    return nil
end

local function hasDuffelBagAndBundles(player, requiredCount)
    if not player then
        return false, 0, false
    end
    local inv = player:getInventory()
    if not inv then
        return false, 0, false
    end
    local items = inv:getItems()
    if not items then
        return false, 0, false
    end

    local bundles = 0
    local hasDuffel = false
    local duffelItem = nil
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it.getFullType then
            local ft = tostring(it:getFullType() or "")
            if ft == "Base.MoneyBundle" then
                bundles = bundles + 1
            end
            if isDuffelBagItem(it) then
                hasDuffel = true
                duffelItem = duffelItem or it
            end
        end
    end
    local need = math.max(1, math.floor(requiredCount or 10))
    return hasDuffel and bundles >= need, bundles, hasDuffel, duffelItem
end

local function consumeMoneyBundles(player, count)
    if not player then
        return 0
    end
    local inv = player:getInventory()
    if not inv then
        return 0
    end
    local items = inv:getItems()
    if not items then
        return 0
    end
    local removed = 0
    local need = math.max(1, math.floor(count or 10))
    for i = items:size() - 1, 0, -1 do
        if removed >= need then
            break
        end
        local it = items:get(i)
        if it and it.getFullType and tostring(it:getFullType() or "") == "Base.MoneyBundle" then
            inv:Remove(it)
            removed = removed + 1
        end
    end
    return removed
end

local function consumeOneDuffelBag(player)
    local inv = player and player:getInventory() or nil
    if not inv then
        return false
    end
    local bag = findDuffelBagItem(player)
    if bag then
        inv:Remove(bag)
        return true
    end
    return false
end

local function pickRandomContainerInMissionArea(mission)
    local minX, maxX, minY, maxY = missionAreaBounds(mission)
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    local z = math.floor(mission.targetZ or 0)
    if not minX or not maxX or not minY or not maxY or not cell then
        return nil
    end

    for _ = 1, 220 do
        local x = ZombRand(minX, maxX + 1)
        local y = ZombRand(minY, maxY + 1)
        local sq = cell:getGridSquare(x, y, z)
        if sq then
            local objs = sq:getObjects()
            if objs then
                for i = 0, objs:size() - 1 do
                    local obj = objs:get(i)
                    if obj and obj.getContainer and obj:getContainer() then
                        return {x = x, y = y, z = z, obj = obj}
                    end
                end
            end
        end
    end
    return nil
end

local function setContainerHighlight(obj, on)
    if not obj then
        return
    end
    pcall(function()
        if obj.setHighlighted then
            obj:setHighlighted(on and true or false)
        end
    end)
    pcall(function()
        if obj.setOutlineHighlight then
            obj:setOutlineHighlight(on and true or false)
        end
    end)
    pcall(function()
        if obj.setOutlineColor then
            obj:setOutlineColor(1, 1, 0, 1)
        end
    end)
end

local function pickRandomContainerInBounds(minX, maxX, minY, maxY, z)
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    z = math.floor(z or 0)
    if not minX or not maxX or not minY or not maxY or not cell then
        return nil
    end
    for _ = 1, 260 do
        local x = ZombRand(minX, maxX + 1)
        local y = ZombRand(minY, maxY + 1)
        local sq = cell:getGridSquare(x, y, z)
        if sq then
            local objs = sq:getObjects()
            if objs then
                for i = 0, objs:size() - 1 do
                    local obj = objs:get(i)
                    if obj and obj.getContainer and obj:getContainer() then
                        return obj:getContainer(), sq
                    end
                end
            end
        end
    end
    return nil, nil
end

local function addItemsToContainer(container, itemType, count)
    if not container then
        return 0
    end
    local added = 0
    local c = math.max(1, math.floor(count or 1))
    for _ = 1, c do
        local it = container:AddItem(itemType)
        if it then
            added = added + 1
        end
    end
    return added
end

-- Forward-safe helpers for dirty money flow (must be declared before stash supply spawn)
local function _markDirtyMoneyItem(item, mission)
    if not item then
        return
    end
    local dirtyText = "This money... It's dirty... I should not keep it."
    if item.setTooltip then
        pcall(function()
            item:setTooltip(dirtyText)
        end)
    end
    if item.getModData then
        local md = item:getModData()
        md.S4DirtyMoney = true
        md.S4DirtyMoneyGroup = asText(mission and mission.missionGroup, "DirtyMoney")
    end
end

local function _dropDirtyMoneyOnGroundInBounds(minX, maxX, minY, maxY, z, itemType, count, mission)
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    z = math.floor(z or 0)
    if not cell then
        return 0
    end
    local added = 0
    local c = math.max(1, math.floor(count or 1))
    for _ = 1, c do
        local x = ZombRand(minX, maxX + 1)
        local y = ZombRand(minY, maxY + 1)
        local sq = cell:getGridSquare(x, y, z)
        if sq then
            local ok, it = pcall(function()
                return sq:AddWorldInventoryItem(itemType, ZombRand(2, 9) / 10, ZombRand(2, 9) / 10, 0)
            end)
            if ok and it then
                _markDirtyMoneyItem(it, mission)
                added = added + 1
            end
        end
    end
    return added
end

local function _dropDirtyMoneyAroundPoint(x, y, z, itemType, count, mission)
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    if not cell then
        return 0
    end
    x = math.floor(x or 0)
    y = math.floor(y or 0)
    z = math.floor(z or 0)
    local offsets = {{0, 0}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {-1, 1}, {1, -1}, {-1, -1}, {2, 0},
                     {-2, 0}, {0, 2}, {0, -2}, {2, 1}, {-2, -1}}
    local c = math.max(1, math.floor(count or 1))
    local added = 0
    for i = 1, c do
        local o = offsets[((i - 1) % #offsets) + 1]
        local sq = cell:getGridSquare(x + o[1], y + o[2], z)
        if sq then
            local ok, it = pcall(function()
                return sq:AddWorldInventoryItem(itemType, 0.5, 0.5, 0)
            end)
            if ok and it then
                _markDirtyMoneyItem(it, mission)
                added = added + 1
            end
        end
    end
    return added
end

local function _countDirtyMoneyInPlayerInv(player, mission)
    if not player then
        return 0
    end
    local inv = player:getInventory()
    if not inv then
        return 0
    end
    local items = inv:getItems()
    if not items then
        return 0
    end
    local group = asText(mission and mission.missionGroup, "DirtyMoney")
    local n = 0
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it.getModData then
            local md = it:getModData()
            if md and md.S4DirtyMoney and asText(md.S4DirtyMoneyGroup, "DirtyMoney") == group then
                n = n + 1
            end
        end
    end
    return n
end

local function _purgeDirtyMoneyInPlayerInv(player, mission)
    if not player then
        return 0
    end
    local inv = player:getInventory()
    if not inv then
        return 0
    end
    local items = inv:getItems()
    if not items then
        return 0
    end
    local group = asText(mission and mission.missionGroup, "DirtyMoney")
    local removed = 0
    for i = items:size() - 1, 0, -1 do
        local it = items:get(i)
        if it and it.getModData then
            local md = it:getModData()
            if md and md.S4DirtyMoney and asText(md.S4DirtyMoneyGroup, "DirtyMoney") == group then
                inv:Remove(it)
                removed = removed + 1
            end
        end
    end
    return removed
end

local function resolveDuffelSpawnType()
    local candidates = {"Base.Bag_DuffelBag", "Base.Bag_Duffelbag", "Base.Bag_DuffelBagTINT"}
    local sm = getScriptManager and getScriptManager() or nil
    if sm and sm.FindItem then
        for i = 1, #candidates do
            local t = candidates[i]
            local ok, item = pcall(function()
                return sm:FindItem(t)
            end)
            if ok and item then
                return t
            end
        end
    end
    return "Base.Bag_DuffelBag"
end

function S4_Pager_System.getDropTargetNearState(player, mission, maxCells)
    if not player or not mission or not mission.dropTargetX then
        return false
    end
    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())
    local tx = math.floor(mission.dropTargetX or 0)
    local ty = math.floor(mission.dropTargetY or 0)
    local tz = math.floor(mission.dropTargetZ or mission.targetZ or 0)
    if pz ~= tz then
        return false
    end
    local d = math.abs(px - tx) + math.abs(py - ty)
    return d <= (maxCells or 3)
end

function S4_Pager_System.getEscapeDistanceState(player, mission)
    if not player or not mission then
        return 0, tonumber(mission and mission.escapeMinDistance) or 350
    end
    local fromX = tonumber(mission.escapeFromX) or tonumber(mission.targetX) or 0
    local fromY = tonumber(mission.escapeFromY) or tonumber(mission.targetY) or 0
    local need = tonumber(mission.escapeMinDistance) or 350
    if need < 1 then
        need = 1
    end
    local dx = player:getX() - fromX
    local dy = player:getY() - fromY
    local dist = math.floor(math.sqrt(dx * dx + dy * dy))
    return dist, need
end

function S4_Pager_System.spawnStashMoneyMissionSupplies(player, mission)
    if not player or not mission then
        return false
    end
    local pData = player:getModData()
    if mission.suppliesSpawned or (pData and pData.S4KnoxPart2SuppliesSpawned) then
        return true
    end

    local z = math.floor(mission.targetZ or 0)
    local minX = mission.sourceAreaMinX and math.min(mission.sourceAreaMinX, mission.sourceAreaMaxX) or
                     math.min(mission.areaMinX or 0, mission.areaMaxX or 0)
    local maxX = mission.sourceAreaMaxX and math.max(mission.sourceAreaMinX, mission.sourceAreaMaxX) or
                     math.max(mission.areaMinX or 0, mission.areaMaxX or 0)
    local minY = mission.sourceAreaMinY and math.min(mission.sourceAreaMinY, mission.sourceAreaMaxY) or
                     math.min(mission.areaMinY or 0, mission.areaMaxY or 0)
    local maxY = mission.sourceAreaMaxY and math.max(mission.sourceAreaMinY, mission.sourceAreaMaxY) or
                     math.max(mission.areaMinY or 0, mission.areaMaxY or 0)

    local needBundles = tonumber(mission.requiredItemCount) or 10
    local itemType = asText(mission.requiredItemType, "Base.MoneyBundle")
    local dropX = tonumber(mission.moneyDropX)
    local dropY = tonumber(mission.moneyDropY)
    local addedBundles = 0
    if dropX and dropY then
        addedBundles = _dropDirtyMoneyAroundPoint(dropX, dropY, z, itemType, needBundles + 1, mission)
    end
    if addedBundles <= 0 then
        addedBundles = _dropDirtyMoneyOnGroundInBounds(minX, maxX, minY, maxY, z, itemType, needBundles + 1, mission)
    end

    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    local sx = math.floor(mission.duffelSpawnX or 8078)
    local sy = math.floor(mission.duffelSpawnY or 11602)
    local sz = math.floor(mission.duffelSpawnZ or z)
    local square = cell and cell:getGridSquare(sx, sy, sz) or nil
    if not square and player.getSquare then
        square = player:getSquare()
    end

    local bagType = resolveDuffelSpawnType()
    local bagSpawned = false
    if square then
        local okBag, bag = pcall(function()
            return square:AddWorldInventoryItem(bagType, 0.5, 0.5, 0)
        end)
        bagSpawned = okBag and bag ~= nil
    end

    mission.suppliesSpawned = true
    if pData then
        pData.S4KnoxPart2SuppliesSpawned = true
    end
    mission.suppliesBundlesPlaced = addedBundles
    mission.suppliesBagPlaced = bagSpawned
    if player.setHaloNote then
        if addedBundles > 0 then
            player:setHaloNote(string.format("Dirty money prepared: %d MoneyBundle", addedBundles), 80, 220, 80, 300)
        else
            player:setHaloNote("Could not prepare hidden dirty money", 220, 110, 90, 280)
        end
        if bagSpawned then
            player:setHaloNote(string.format("Duffelbag dejado en %d,%d", sx, sy), 230, 210, 120, 280)
        end
    end
    return addedBundles > 0
end

function S4_Pager_System.isPlayerOnMissionSpot(player, mission)
    if not player or not mission then
        return false
    end
    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())
    local mz = math.floor(mission.targetZ or 0)
    if pz ~= mz then
        return false
    end

    if mission.areaMinX and mission.areaMaxX and mission.areaMinY and mission.areaMaxY then
        local minX = math.min(mission.areaMinX, mission.areaMaxX)
        local maxX = math.max(mission.areaMinX, mission.areaMaxX)
        local minY = math.min(mission.areaMinY, mission.areaMaxY)
        local maxY = math.max(mission.areaMinY, mission.areaMaxY)
        return px >= minX and px <= maxX and py >= minY and py <= maxY
    end

    local tx = mission.targetX or 0
    local ty = mission.targetY or 0
    local dx = px - tx
    local dy = py - ty
    return (dx * dx + dy * dy) <= 4
end

function S4_Pager_System.getMissionSpotState(player, mission)
    if not player or not mission then
        return "far"
    end

    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())
    local mz = math.floor(mission.targetZ or 0)
    if pz ~= mz then
        return "far"
    end

    if S4_Pager_System.isPlayerOnMissionSpot(player, mission) then
        return "on_spot"
    end

    local padding = tonumber(mission.hiddenPadding) or 16
    if padding < 1 then
        padding = 1
    elseif padding > 50 then
        padding = 50
    end

    if mission.areaMinX and mission.areaMaxX and mission.areaMinY and mission.areaMaxY then
        local minX = math.min(mission.areaMinX, mission.areaMaxX) - padding
        local maxX = math.max(mission.areaMinX, mission.areaMaxX) + padding
        local minY = math.min(mission.areaMinY, mission.areaMaxY) - padding
        local maxY = math.max(mission.areaMinY, mission.areaMaxY) + padding
        if px >= minX and px <= maxX and py >= minY and py <= maxY then
            return "near"
        end
        return "far"
    end

    local tx = mission.targetX or 0
    local ty = mission.targetY or 0
    local dx = px - tx
    local dy = py - ty
    local rr = padding
    if (dx * dx + dy * dy) <= (rr * rr) then
        return "near"
    end
    return "far"
end

function S4_Pager_System.randomStartLabel(labels)
    return labels[ZombRand(1, #labels + 1)] or "Start"
end

function S4_Pager_System.ensureMapSymbolDefinition(symbolId)
    if not MapSymbolDefinitions or not MapSymbolDefinitions.getInstance then
        return false
    end
    local ok = pcall(function()
        MapSymbolDefinitions.getInstance():addTexture(symbolId, "media/ui/LootableMaps/map_airdrop.png", "Loot")
    end)
    return ok
end

function S4_Pager_System.getSymbolsApi()
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

function S4_Pager_System.clearMissionMapMarkers()
    local symbolsApi = S4_Pager_System.getSymbolsApi()
    if not symbolsApi then
        return false
    end
    local ok = pcall(function()
        if symbolsApi.clear then
            symbolsApi:clear()
            return
        end
        if symbolsApi.getSymbolCount and symbolsApi.removeSymbolByIndex then
            for i = symbolsApi:getSymbolCount() - 1, 0, -1 do
                symbolsApi:removeSymbolByIndex(i)
            end
        end
    end)
    return ok
end

local function markDirtyMoneyItem(item, mission)
    if not item then
        return
    end
    local dirtyText = "This money... It's dirty... I should not keep it."
    if item.setTooltip then
        pcall(function()
            item:setTooltip(dirtyText)
        end)
    end
    if item.getModData then
        local md = item:getModData()
        md.S4DirtyMoney = true
        md.S4DirtyMoneyGroup = asText(mission and mission.missionGroup, "DirtyMoney")
    end
end

local function dropDirtyMoneyOnGroundInBounds(minX, maxX, minY, maxY, z, itemType, count, mission)
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    z = math.floor(z or 0)
    if not cell then
        return 0
    end
    local added = 0
    local c = math.max(1, math.floor(count or 1))
    for _ = 1, c do
        local x = ZombRand(minX, maxX + 1)
        local y = ZombRand(minY, maxY + 1)
        local sq = cell:getGridSquare(x, y, z)
        if sq then
            local ok, it = pcall(function()
                return sq:AddWorldInventoryItem(itemType, ZombRand(2, 9) / 10, ZombRand(2, 9) / 10, 0)
            end)
            if ok and it then
                markDirtyMoneyItem(it, mission)
                added = added + 1
            end
        end
    end
    return added
end

local function countDirtyMoneyInPlayerInv(player, mission)
    if not player then
        return 0
    end
    local inv = player:getInventory()
    if not inv then
        return 0
    end
    local items = inv:getItems()
    if not items then
        return 0
    end
    local group = asText(mission and mission.missionGroup, "DirtyMoney")
    local n = 0
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it.getModData then
            local md = it:getModData()
            if md and md.S4DirtyMoney and asText(md.S4DirtyMoneyGroup, "DirtyMoney") == group then
                n = n + 1
            end
        end
    end
    return n
end

local function purgeDirtyMoneyInPlayerInv(player, mission)
    if not player then
        return 0
    end
    local inv = player:getInventory()
    if not inv then
        return 0
    end
    local items = inv:getItems()
    if not items then
        return 0
    end
    local group = asText(mission and mission.missionGroup, "DirtyMoney")
    local removed = 0
    for i = items:size() - 1, 0, -1 do
        local it = items:get(i)
        if it and it.getModData then
            local md = it:getModData()
            if md and md.S4DirtyMoney and asText(md.S4DirtyMoneyGroup, "DirtyMoney") == group then
                inv:Remove(it)
                removed = removed + 1
            end
        end
    end
    return removed
end

function S4_Pager_System.addMissionMapMarker(symbolId, x, y)
    if not x or not y then
        return false
    end
    S4_Pager_System.ensureMapSymbolDefinition(symbolId)
    S4_Pager_System.clearMissionMapMarkers()
    local symbolsApi = S4_Pager_System.getSymbolsApi()
    if not symbolsApi then
        return false
    end
    local ok = pcall(function()
        local symbol = symbolsApi:addTexture(symbolId, x, y)
        symbol:setAnchor(0.5, 0.5)
        symbol:setRGBA(1, 0, 0, 1)
    end)
    return ok
end

function S4_Pager_System.spawnMissionZombieAt(x, y, z, count)
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
    return 0
end

function S4_Pager_System.getFixedPointData(player)
    if not player then
        return nil
    end
    local md = player:getModData()
    if not md or not md.S4PagerDebugFixedPointEnabled then
        return nil
    end
    if md.S4PagerDebugFixedX == nil or md.S4PagerDebugFixedY == nil then
        return nil
    end
    return {
        x = math.floor(md.S4PagerDebugFixedX),
        y = math.floor(md.S4PagerDebugFixedY),
        z = math.floor(md.S4PagerDebugFixedZ or 0)
    }
end

function S4_Pager_System.applyFixedPointToPending(player, pendingMission)
    if not player or not pendingMission then
        return pendingMission
    end
    local fixed = S4_Pager_System.getFixedPointData(player)
    if not fixed then
        return pendingMission
    end
    pendingMission.targetX = fixed.x
    pendingMission.targetY = fixed.y
    pendingMission.targetZ = fixed.z
    pendingMission.location = string.format("DEBUG Fixed Point (%d,%d,%d)", fixed.x, fixed.y, fixed.z)
    return pendingMission
end

function S4_Pager_System.isPlayerNearMission(player, mission, range)
    if not player or not mission then
        return false
    end
    local px, py = player:getX(), player:getY()
    local tx, ty = mission.targetX or 0, mission.targetY or 0
    local dx, dy = px - tx, py - ty
    local rr = range or 120
    return (dx * dx + dy * dy) <= (rr * rr)
end

function S4_Pager_System.countAliveZombiesAround(x, y, radius)
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    local zlist = cell and cell:getZombieList() or nil
    if not zlist then
        return 0
    end
    local r2 = radius * radius
    local count = 0
    for i = 0, zlist:size() - 1 do
        local z = zlist:get(i)
        if z and (not z:isDead()) then
            local dx = z:getX() - x
            local dy = z:getY() - y
            if (dx * dx + dy * dy) <= r2 then
                count = count + 1
            end
        end
    end
    return count
end

function S4_Pager_System.findAnyWorkObjectCodeInInventory(player)
    if not player then
        return nil
    end
    local inv = player:getInventory()
    if not inv then
        return nil
    end
    local items = inv:getItems()
    if not items then
        return nil
    end
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it.getModData then
            local md = it:getModData()
            if md and md.S4WorkObject then
                return md.S4WorkCode or "unknown"
            end
        end
    end
    return nil
end

function S4_Pager_System.findAnyNearbyWorkObjectCode(player, radius)
    if not player then
        return nil
    end
    local sq = player:getSquare()
    if not sq then
        return nil
    end
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    if not cell then
        return nil
    end
    local px, py, pz = sq:getX(), sq:getY(), sq:getZ()
    radius = radius or 2
    for dx = -radius, radius do
        for dy = -radius, radius do
            local csq = cell:getGridSquare(px + dx, py + dy, pz)
            if csq then
                local wos = csq:getWorldObjects()
                if wos then
                    for i = 0, wos:size() - 1 do
                        local wo = wos:get(i)
                        if wo and wo.getItem then
                            local it = wo:getItem()
                            if it and it.getModData then
                                local md = it:getModData()
                                if md and md.S4WorkObject then
                                    return md.S4WorkCode or "unknown"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

function S4_Pager_System.removeOneItemFromPlayer(player, item)
    if not player or not item then
        return
    end
    if item:getWorldItem() then
        item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
        ISInventoryPage.dirtyUI()
        return
    end
    if item:getContainer() then
        item:getContainer():Remove(item)
    else
        player:getInventory():Remove(item)
    end
end

function S4_Pager_System.addRandomPhotoToCorpse(zombie, missionPhotoLore)
    if not zombie or not zombie.getInventory then
        return false, nil
    end
    local inv = zombie:getInventory()
    if not inv then
        return false, nil
    end
    local photo = inv:AddItem(S4_Pager_System.resolvePhotoItemType())
    if not photo then
        return false, nil
    end
    local entry = safeLoreEntry(missionPhotoLore)
    local code = S4_Pager_System.randomWorkObjectCode()
    if photo.setName then
        photo:setName(string.format("Objeto de Trabajo: %s | %s", code, entry.title))
    end
    if photo.setTooltip then
        photo:setTooltip(string.format("Objeto de Trabajo: %s\n%s", code, entry.note))
    end
    if photo.getModData then
        local md = photo:getModData()
        md.S4WorkObject = true
        md.S4WorkCode = code
        md.S4WorkLoreTitle = entry.title
        md.S4WorkLoreNote = entry.note
    end
    return true, code
end

function S4_Pager_System.addRandomPhotoOnGroundNearMission(mission, player, missionPhotoLore)
    if not mission then
        return false
    end
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    if not cell then
        return false
    end

    local tx = math.floor(mission.targetX or -1)
    local ty = math.floor(mission.targetY or -1)
    local tz = math.floor(mission.targetZ or 0)
    if tx < 0 or ty < 0 then
        return false
    end

    local square = nil
    local offsets = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {-1, 1}, {1, -1}, {-1, -1}, {0, 0}}
    for i = 1, #offsets do
        local ox = offsets[i][1]
        local oy = offsets[i][2]
        local s = cell:getGridSquare(tx + ox, ty + oy, tz)
        if s then
            square = s
            break
        end
    end
    if not square and player then
        square = player:getSquare()
    end
    if not square then
        return false
    end

    local entry = safeLoreEntry(missionPhotoLore)
    local code = S4_Pager_System.randomWorkObjectCode()
    local photoType = S4_Pager_System.resolvePhotoItemType()

    local item = nil
    local okAdd, added = pcall(function()
        return square:AddWorldInventoryItem(photoType, 0.5, 0.5, 0)
    end)
    if okAdd and added then
        item = added
    end
    if not item and player and player.getSquare then
        local ps = player:getSquare()
        if ps then
            local okAddP, addedP = pcall(function()
                return ps:AddWorldInventoryItem(photoType, 0.5, 0.5, 0)
            end)
            if okAddP and addedP then
                item = addedP
                square = ps
            end
        end
    end
    if not item and player and player.getInventory then
        local inv = player:getInventory()
        if inv then
            local invItem = inv:AddItem(photoType)
            if invItem then
                item = invItem
            end
        end
    end
    if not item then
        return false
    end

    if item.getModData then
        local md = item:getModData()
        md.S4WorkObject = true
        md.S4WorkCode = code
        md.S4WorkLoreTitle = entry.title
        md.S4WorkLoreNote = entry.note
    end
    if item.setName then
        item:setName(string.format("Objeto de Trabajo: %s | %s", code, entry.title))
    end
    if item.setTooltip then
        item:setTooltip(string.format("Objeto de Trabajo: %s\n%s", code, entry.note))
    end
    if S4_Utils and S4_Utils.SnycObject then
        pcall(function()
            S4_Utils.SnycObject(item)
        end)
    end

    mission.photoCode = code
    local sq = square
    if not sq and player and player.getSquare then
        sq = player:getSquare()
    end
    mission.photoX = sq and sq:getX() or tx
    mission.photoY = sq and sq:getY() or ty
    mission.photoZ = sq and sq:getZ() or tz
    mission.photoDestroyedWarned = false

    if player and player.setHaloNote then
        player:setHaloNote(string.format("Foto de trabajo en %d,%d", mission.photoX or tx, mission.photoY or ty), 245,
            225, 140, 320)
    end
    return true
end

function S4_Pager_System.hasMissionPhotoOnGround(mission)
    if not mission or not mission.photoCode then
        return false
    end
    local world = getWorld and getWorld() or nil
    local cell = world and world:getCell() or nil
    if not cell then
        return false
    end
    local cx = math.floor(mission.photoX or mission.targetX or -1)
    local cy = math.floor(mission.photoY or mission.targetY or -1)
    local cz = math.floor(mission.photoZ or mission.targetZ or 0)
    if cx < 0 or cy < 0 then
        return false
    end
    for dx = -2, 2 do
        for dy = -2, 2 do
            local square = cell:getGridSquare(cx + dx, cy + dy, cz)
            if square then
                local wos = square:getWorldObjects()
                if wos then
                    for i = 0, wos:size() - 1 do
                        local wo = wos:get(i)
                        if wo and wo.getItem then
                            local it = wo:getItem()
                            if it and it.getModData then
                                local md = it:getModData()
                                if md and md.S4WorkObject and md.S4WorkCode == mission.photoCode then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

function S4_Pager_System.playerHasMissionPhoto(player, mission)
    if not player or not mission or not mission.photoCode then
        return false
    end
    local inv = player:getInventory()
    if not inv then
        return false
    end
    local items = inv:getItems()
    if not items then
        return false
    end
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it and it.getModData then
            local md = it:getModData()
            if md and md.S4WorkObject and md.S4WorkCode == mission.photoCode then
                return true
            end
        end
    end
    return false
end

function S4_Pager_System.getCameraPhotoTarget(player)
    if not player then
        return nil, nil
    end
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if mission and mission.status == "active" then
        return mission, "active"
    end
    local completed = pData and pData.S4PagerLastCompletedMission or nil
    if completed and completed.targetX and completed.targetY then
        return completed, "completed"
    end
    return nil, nil
end

function S4_Pager_System.createValuablePhotoInInventory(player, mission, sourceLabel, missionPhotoLore)
    if not player then
        return false
    end
    local inv = player:getInventory()
    if not inv then
        return false
    end
    local photoType = S4_Pager_System.resolvePhotoItemType()
    local photo = inv:AddItem(photoType)
    if not photo then
        return false
    end
    local entry = safeLoreEntry(missionPhotoLore)
    local code = S4_Pager_System.randomWorkObjectCode()
    if photo.getModData then
        local md = photo:getModData()
        md.S4WorkObject = true
        md.S4WorkCode = code
        md.S4WorkSource = asText(sourceLabel, "Camera")
        md.S4WorkLoreTitle = entry.title
        md.S4WorkLoreNote = entry.note
    end
    if photo.setName then
        photo:setName(string.format("Objeto de Trabajo: %s | %s", code, entry.title))
    end
    if photo.setTooltip then
        photo:setTooltip(string.format("Objeto de Trabajo: %s\n%s", code, entry.note))
    end
    if S4_Utils and S4_Utils.SnycObject then
        pcall(function()
            S4_Utils.SnycObject(photo)
        end)
    end
    if mission then
        mission.photoCode = mission.photoCode or code
    end
    return true
end

local function getItemTextLower(item)
    if not item then
        return ""
    end
    local parts = {}
    if item.getFullType then
        parts[#parts + 1] = tostring(item:getFullType() or "")
    end
    if item.getType then
        parts[#parts + 1] = tostring(item:getType() or "")
    end
    if item.getDisplayCategory then
        parts[#parts + 1] = tostring(item:getDisplayCategory() or "")
    end
    if item.getDisplayName then
        parts[#parts + 1] = tostring(item:getDisplayName() or "")
    end
    return table.concat(parts, " "):lower()
end

local function checkMissionGearRequirements(player, mission)
    if not player then
        return true, true
    end

    local needMask = mission and mission.requireMask
    local needVest = mission and mission.requireBulletVest
    if not needMask and not needVest then
        return true, true
    end

    local hasMask = not needMask
    local hasVest = not needVest
    local hasHalloweenMask = false
    local worn = player.getWornItems and player:getWornItems() or nil
    if not worn or not worn.size then
        return hasMask, hasVest
    end

    for i = 0, worn:size() - 1 do
        local entry = nil
        if worn.get then
            entry = worn:get(i)
        end
        if not entry and worn.getItemByIndex then
            entry = worn:getItemByIndex(i)
        end

        local item = entry
        local location = ""
        if entry and entry.getItem then
            item = entry:getItem()
        end
        if entry and entry.getLocation then
            location = tostring(entry:getLocation() or ""):lower()
        end
        if item then
            local t = getItemTextLower(item)

            if needMask and not hasMask then
                if t:find("mask", 1, true) or location:find("mask", 1, true) then
                    hasMask = true
                elseif item.hasTag and (item:hasTag("Mask") or item:hasTag("GasMask")) then
                    hasMask = true
                end
            end

            if not hasHalloweenMask then
                local fullType = item.getFullType and tostring(item:getFullType() or "") or ""
                if fullType:sub(1, #"Base.Hat_HalloweenMask") == "Base.Hat_HalloweenMask" then
                    hasHalloweenMask = true
                end
            end

            if needVest and not hasVest then
                local bulletVestByName = (t:find("bullet", 1, true) and t:find("vest", 1, true)) or
                                             t:find("bulletproof", 1, true) or t:find("armor vest", 1, true)
                local bulletVestByTag = item.hasTag and (item:hasTag("BulletProof") or item:hasTag("BulletproofVest"))
                if bulletVestByName or bulletVestByTag then
                    hasVest = true
                end
            end
        end

        if hasMask and hasVest and hasHalloweenMask then
            break
        end
    end

    return hasMask, hasVest, hasHalloweenMask
end

function S4_Pager_System.completeMission(player, opts)
    if not player then
        return false
    end
    opts = opts or {}
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        return false
    end
    -- If evidence already dropped on a mission zombie corpse, don't duplicate on ground.
    if (not mission.photoDropped) and (not mission.zombieInventoryDropDone) then
        local addPhotoFn = opts.addPhotoOnGroundFn
        if addPhotoFn and addPhotoFn(mission, player) then
            mission.photoDropped = true
        elseif player and player.setHaloNote then
            player:setHaloNote("Could not place Work Object on the ground", 230, 110, 70, 280)
        end
    end
    local nowWorldHoursFn = opts.nowWorldHoursFn or S4_Pager_System.nowWorldHours
    pData.S4PagerLastCompletedMission = {
        targetX = mission.targetX,
        targetY = mission.targetY,
        targetZ = mission.targetZ,
        location = asText(mission.location, "Unknown Location"),
        completedWorldHours = nowWorldHoursFn()
    }
    S4_Pager_System.stopMissionPersistentAudio(player)

    if asText(mission.missionGroup, "") == "RosewoodKnoxBankHeist" and tonumber(mission.missionPart) == 1 then
        mission.requiredItemType = mission.requiredItemType or "Base.MoneyBundle"
        mission.requiredItemCount = mission.requiredItemCount or 10
        mission.sourceAreaMinX = mission.sourceAreaMinX or mission.areaMinX
        mission.sourceAreaMaxX = mission.sourceAreaMaxX or mission.areaMaxX
        mission.sourceAreaMinY = mission.sourceAreaMinY or mission.areaMinY
        mission.sourceAreaMaxY = mission.sourceAreaMaxY or mission.areaMaxY
        mission.duffelSpawnX = mission.duffelSpawnX or 8078
        mission.duffelSpawnY = mission.duffelSpawnY or 11602
        mission.duffelSpawnZ = mission.duffelSpawnZ or 0
        mission.moneyDropX = mission.moneyDropX or 8089
        mission.moneyDropY = mission.moneyDropY or 11599
        pcall(function()
            S4_Pager_System.spawnStashMoneyMissionSupplies(player, mission)
        end)
    end

    local rewardAmount = ZombRand(200, 501)
    local finalReward = rewardAmount
    local penaltyPct = tonumber(mission.nonCompliantPenaltyPct) or 50
    if penaltyPct < 0 then
        penaltyPct = 0
    elseif penaltyPct > 100 then
        penaltyPct = 100
    end
    local hasMask, hasVest, hasHalloweenMask = checkMissionGearRequirements(player, mission)
    local penaltyApplied = false
    if (mission.requireMask or mission.requireBulletVest) and not (hasMask and hasVest) then
        finalReward = math.floor(rewardAmount * (100 - penaltyPct) / 100)
        penaltyApplied = true
    end

    local halloweenBonusPct = 45
    local halloweenBonusApplied = false
    if hasHalloweenMask then
        finalReward = math.floor(finalReward * (100 + halloweenBonusPct) / 100)
        halloweenBonusApplied = true
    end

    local rewardLogTime = (S4_Utils and S4_Utils.getLogTime) and S4_Utils.getLogTime() or nil
    if sendClientCommand then
        pcall(function()
            sendClientCommand("S4ED", "AddMissionReward", {finalReward, rewardLogTime})
        end)
    end

    mission.status = "completed"
    pData.S4PagerMission = nil
    if player.setHaloNote then
        player:setHaloNote(opts.reasonText or "Pager mission complete", opts.r or 80, opts.g or 220, opts.b or 80, 300)
        if penaltyApplied then
            player:setHaloNote(string.format("Penalizacion -%d%% por equipo incompleto", penaltyPct), 220, 90, 90, 300)
        end
        if halloweenBonusApplied then
            player:setHaloNote(string.format("Bonus +%d%% por Halloween Mask", halloweenBonusPct), 80, 220, 80, 300)
        end
        player:setHaloNote(string.format("Mission reward +$%d (Main Card)", finalReward), 80, 220, 80, 260)
    end
    return true
end

function S4_Pager_System.updateMissionState(player, opts)
    if not player then
        return
    end
    opts = opts or {}
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        S4_Pager_System.stopMissionPersistentAudio(player)
        return
    end

    if mission.missionMode == "stash_money" then
        local dirtyInvCount = _countDirtyMoneyInPlayerInv(player, mission)
        mission.dirtyMoneyMaxSeen = math.max(tonumber(mission.dirtyMoneyMaxSeen) or 0, dirtyInvCount)
        if (mission.dirtyMoneyMaxSeen or 0) > 0 and dirtyInvCount < (mission.dirtyMoneyMaxSeen or 0) then
            _purgeDirtyMoneyInPlayerInv(player, mission)
            if mission.dropTargetObj then
                setContainerHighlight(mission.dropTargetObj, false)
            end
            pData.S4PagerMission = nil
            if opts.clearMissionMapMarkersFn then
                opts.clearMissionMapMarkersFn()
            end
            if player.setHaloNote then
                player:setHaloNote("Mission failed: dirty money was used or lost", 220, 80, 80, 360)
            end
            if opts.onRefreshUiFn then
                opts.onRefreshUiFn(player)
            end
            return
        end

        if not mission.dropTargetX then
            local state = opts.getMissionSpotStateFn and opts.getMissionSpotStateFn(player, mission) or "far"
            if state == "on_spot" then
                local drop = pickRandomContainerInMissionArea(mission)
                if drop then
                    if opts.clearMissionMapMarkersFn then
                        opts.clearMissionMapMarkersFn()
                    end
                    mission.dropTargetX = drop.x
                    mission.dropTargetY = drop.y
                    mission.dropTargetZ = drop.z
                    mission.dropTargetObj = drop.obj
                    mission.runtimeObjective = "Money drop location"
                    if opts.addMissionMapMarkerFn then
                        opts.addMissionMapMarkerFn(drop.x, drop.y)
                    end
                    if drop.obj then
                        setContainerHighlight(drop.obj, true)
                    end
                    if player.setHaloNote then
                        player:setHaloNote("Money drop location marked", 230, 210, 120, 320)
                    end
                else
                    if player.setHaloNote then
                        player:setHaloNote("No se encontro contenedor, reintentando...", 220, 120, 80, 260)
                    end
                end
            end
        else
            local px = math.floor(player:getX())
            local py = math.floor(player:getY())
            local pz = math.floor(player:getZ())
            local tx = math.floor(mission.dropTargetX or 0)
            local ty = math.floor(mission.dropTargetY or 0)
            local tz = math.floor(mission.dropTargetZ or mission.targetZ or 0)
            local nearDrop = (pz == tz) and ((math.abs(px - tx) + math.abs(py - ty)) <= 1)
            if nearDrop then
                local requiredCount = tonumber(mission.requiredItemCount) or 10
                local canDrop, bundles, hasDuffel = hasDuffelBagAndBundles(player, requiredCount)
                if canDrop then
                    consumeMoneyBundles(player, requiredCount)
                    consumeOneDuffelBag(player)
                    if mission.dropTargetObj then
                        setContainerHighlight(mission.dropTargetObj, false)
                    end
                    if opts.completeMissionFn then
                        opts.completeMissionFn(player, "Money secured successfully", 80, 220, 80)
                    end
                    return
                else
                    if player.setHaloNote then
                        if not hasDuffel then
                            player:setHaloNote("You need a duffel bag", 220, 110, 90, 260)
                        else
                            player:setHaloNote(string.format("Faltan Money Bundle: %d/%d", bundles, requiredCount), 220,
                                110, 90, 260)
                        end
                    end
                end
            end
        end
    end

    if mission.missionMode == "escape_bank" then
        local dist, need = S4_Pager_System.getEscapeDistanceState(player, mission)
        mission.escapeDistanceNow = dist
        mission.runtimeObjective = string.format("Escape distance: %d/%d", dist, need)
        if dist >= need then
            if opts.completeMissionFn then
                opts.completeMissionFn(player, "Escape successful. Heat lost.", 80, 220, 80)
            end
            return
        end
    end

    local remaining = math.max(0, (mission.killGoal or 1) - (mission.killsDone or 0))
    if mission.missionMode ~= "stash_money" and mission.missionMode ~= "escape_bank" and remaining > 0 and
        (opts.isPlayerNearMissionFn and opts.isPlayerNearMissionFn(player, mission, 120)) then
        local alive = opts.countAliveZombiesAroundFn and
                          opts.countAliveZombiesAroundFn(mission.targetX or 0, mission.targetY or 0,
                opts.missionRadius or 20) or 0
        if alive <= 0 then
            if opts.completeMissionFn then
                opts.completeMissionFn(player, "Pager mission resolved (targets removed)", 80, 220, 80)
            end
            return
        end
    end

    local nowWorldHoursFn = opts.nowWorldHoursFn or S4_Pager_System.nowWorldHours
    if nowWorldHoursFn() >= mission.endWorldHours then
        S4_Pager_System.stopMissionPersistentAudio(player)
        if mission.dropTargetObj then
            setContainerHighlight(mission.dropTargetObj, false)
        end
        _purgeDirtyMoneyInPlayerInv(player, mission)
        pData.S4PagerMission = nil
        if opts.clearMissionMapMarkersFn then
            opts.clearMissionMapMarkersFn()
        end
        if player.setHaloNote then
            player:setHaloNote("Pager mission failed: out of time", 220, 80, 80, 300)
        end
        if opts.onRefreshUiFn then
            opts.onRefreshUiFn(player)
        end
        return
    end

    if mission.photoDropped and (not mission.photoDestroyedWarned) and mission.photoCode then
        local existsOnGround = opts.hasMissionPhotoOnGroundFn and opts.hasMissionPhotoOnGroundFn(mission)
        local inPlayerInv = opts.playerHasMissionPhotoFn and opts.playerHasMissionPhotoFn(player, mission)
        if (not existsOnGround) and (not inPlayerInv) then
            mission.photoDestroyedWarned = true
            if player.setHaloNote then
                player:setHaloNote("Object destroyed. You will have to explain it to the client", 230, 110, 70, 360)
            end
        end
    end
end

function S4_Pager_System.onZombieDead(zombie, player, opts)
    if not player or not zombie then
        return
    end
    opts = opts or {}
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        return
    end
    if mission.missionMode == "stash_money" then
        return
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local tx = mission.targetX or 0
    local ty = mission.targetY or 0
    local dx = zx - tx
    local dy = zy - ty
    local missionRadius = opts.missionRadius or 20
    local inMissionArea = (dx * dx + dy * dy) <= (missionRadius * missionRadius)
    if not inMissionArea then
        return
    end

    if not mission.zombieInventoryDropDone and opts.addRandomPhotoToCorpseFn then
        local okDrop, code = opts.addRandomPhotoToCorpseFn(zombie)
        if okDrop then
            mission.zombieInventoryDropDone = true
            mission.zombieInventoryDropCode = code
            if player.setHaloNote then
                player:setHaloNote("Se encontro algo... parece valioso", 245, 225, 140, 260)
            end
        end
    end

    mission.killsDone = math.min((mission.killsDone or 0) + 1, mission.killGoal or 1)
    if player.setHaloNote then
        player:setHaloNote(string.format("Targets: %d/%d", mission.killsDone, mission.killGoal or 1), 80, 220, 80, 180)
    end

    if mission.killsDone >= (mission.killGoal or 1) then
        if opts.completeMissionFn then
            opts.completeMissionFn(player, "Pager mission complete", 80, 220, 80)
        end
    elseif opts.onRefreshUiFn then
        opts.onRefreshUiFn(player)
    end
end

function S4_Pager_System.onPlayerUpdateValuableHalo(player, opts)
    if not player then
        return
    end
    opts = opts or {}
    local md = player:getModData()
    local nowMs = getTimestampMs and getTimestampMs() or 0
    local nextMs = md.S4WorkValuableHaloNextMs or 0
    if nowMs > 0 and nowMs < nextMs then
        return
    end
    md.S4WorkValuableHaloNextMs = nowMs + 2000

    local code = opts.findAnyWorkObjectCodeInInventoryFn and opts.findAnyWorkObjectCodeInInventoryFn(player) or nil
    if not code then
        code = opts.findAnyNearbyWorkObjectCodeFn and opts.findAnyNearbyWorkObjectCodeFn(player, 2) or nil
    end
    if not code then
        return
    end

    md.S4WorkValuableSeen = md.S4WorkValuableSeen or {}
    if md.S4WorkValuableSeen[code] then
        return
    end
    md.S4WorkValuableSeen[code] = true
    if player.setHaloNote then
        player:setHaloNote("Se encontro algo... parece valioso", 245, 225, 140, 260)
    end
end

local function isFirearmOrLoudWeapon(weapon)
    if not weapon then
        return false
    end

    local isRanged = false
    if weapon.isRanged then
        local ok, v = pcall(function()
            return weapon:isRanged()
        end)
        if ok and v then
            isRanged = true
        end
    end
    if isRanged then
        return true
    end

    local soundRadius = 0
    if weapon.getSoundRadius then
        local ok, v = pcall(function()
            return weapon:getSoundRadius()
        end)
        if ok and v then
            soundRadius = tonumber(v) or 0
        end
    end
    return soundRadius >= 30
end

local ROBBERY_SHOUT_LINES = {"Everybody to the floor!!!", "Don't make me repeat it!",
                             "Suckers, you'll gonna learn now...", "This isn't your mama, Get the F* Down", "Get Down!"}

local function sayRobberyLine(player)
    if not player then
        return
    end
    local line = ROBBERY_SHOUT_LINES[ZombRand(1, #ROBBERY_SHOUT_LINES + 1)]
    if not line then
        return
    end
    if player.Say then
        pcall(function()
            player:Say(line)
        end)
    elseif player.setHaloNote then
        player:setHaloNote(line, 230, 230, 230, 180)
    end
end

local function startMissionPersistentAudio(player, mission)
    if not player or not mission or mission.razormindStarted then
        return
    end
    local emitter = player.getEmitter and player:getEmitter() or nil
    local ok, sid = false, nil
    if emitter and emitter.playSound then
        ok, sid = pcall(function()
            return emitter:playSound("RazormindTest")
        end)
    end
    if (not ok or not sid) and player.playSound then
        ok, sid = pcall(function()
            return player:playSound("RazormindTest")
        end)
    end
    if ok and sid then
        mission.razormindStarted = true
        local md = player:getModData()
        md.S4PagerRazormindSoundId = sid
    end
end

local function stopMissionPersistentAudio(player)
    if not player then
        return
    end
    local md = player:getModData()
    local emitter = player.getEmitter and player:getEmitter() or nil
    if emitter and md.S4PagerRazormindSoundId and emitter.stopSound then
        pcall(function()
            emitter:stopSound(md.S4PagerRazormindSoundId)
        end)
    end
    md.S4PagerRazormindSoundId = nil
    md.S4PagerRobberyIntroPending = nil
    md.S4PagerRobberyIntroSoundId = nil
    md.S4PagerRobberyIntroStartMs = nil
    md.S4PagerRobberyIntroEndHours = nil
end

function S4_Pager_System.stopMissionPersistentAudio(player)
    stopMissionPersistentAudio(player)
end

function S4_Pager_System.triggerRobberyAlarm(player, mission)
    if not player or not mission then
        return false
    end
    local md = player:getModData()
    local nowMs = getTimestampMs and getTimestampMs() or 0
    local alarmEnd = md.S4PagerAlarmEndMs or 0
    local nextAllowed = md.S4PagerAlarmNextAllowedMs or 0

    if alarmEnd > nowMs then
        return false
    end
    if nowMs < nextAllowed then
        return false
    end

    local endMs = nowMs + 10000
    local cooldownMs = ZombRand(20000, 30001)
    md.S4PagerAlarmEndMs = endMs
    md.S4PagerAlarmNextAllowedMs = endMs + cooldownMs

    local emitter = player.getEmitter and player:getEmitter() or nil
    if not emitter then
        return false
    end

    if emitter.playSound then
        if not mission.robberyIntroPlayed then
            local okIntro, introSid = pcall(function()
                return emitter:playSound("ThisisARobbery")
            end)
            if okIntro and introSid then
                md.S4PagerRobberyIntroSoundId = introSid
            end
            md.S4PagerRobberyIntroStartMs = nowMs
            md.S4PagerRobberyIntroEndHours = S4_Pager_System.nowWorldHours() + (4 / 3600)
            md.S4PagerRobberyIntroPending = true
            mission.robberyIntroPlayed = true
        end
        local ok, sid = pcall(function()
            return emitter:playSound("AlarmGoesBoom")
        end)
        if ok and sid then
            md.S4PagerAlarmSoundId = sid
        end
    end

    return true
end

function S4_Pager_System.stopRobberyAlarm(player)
    if not player then
        return
    end
    local md = player:getModData()
    local emitter = player.getEmitter and player:getEmitter() or nil
    if emitter and md.S4PagerAlarmSoundId and emitter.stopSound then
        pcall(function()
            emitter:stopSound(md.S4PagerAlarmSoundId)
        end)
    end
    md.S4PagerAlarmSoundId = nil
    md.S4PagerAlarmEndMs = nil
end

function S4_Pager_System.onWeaponNoise(player, weapon, opts)
    if not player then
        return
    end
    opts = opts or {}
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        return
    end
    local spotState = opts.getMissionSpotStateFn and opts.getMissionSpotStateFn(player, mission) or "far"
    if spotState ~= "on_spot" then
        return
    end
    if isFirearmOrLoudWeapon(weapon) then
        S4_Pager_System.triggerRobberyAlarm(player, mission)
    end
end

function S4_Pager_System.updateRobberyAlarm(player, opts)
    if not player then
        return
    end
    opts = opts or {}
    local md = player:getModData()
    local nowMs = getTimestampMs and getTimestampMs() or 0

    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    local shoutNow = false
    if player.isShouting then
        local ok, v = pcall(function()
            return player:isShouting()
        end)
        shoutNow = ok and v or false
    end

    if mission and mission.status == "active" and opts.getMissionSpotStateFn then
        local spotState = opts.getMissionSpotStateFn(player, mission)
        if spotState == "on_spot" and shoutNow and not md.S4PagerShoutingPrev then
            sayRobberyLine(player)
            S4_Pager_System.triggerRobberyAlarm(player, mission)
        end
    end
    md.S4PagerShoutingPrev = shoutNow

    if mission and mission.status == "active" and mission.robberyIntroPlayed and (not mission.razormindStarted) then
        local introFinished = false
        if md.S4PagerRobberyIntroPending then
            introFinished = true
            local emitter = player.getEmitter and player:getEmitter() or nil
            if emitter and md.S4PagerRobberyIntroSoundId and emitter.isPlaying then
                local okPlaying, isPlaying = pcall(function()
                    return emitter:isPlaying(md.S4PagerRobberyIntroSoundId)
                end)
                if okPlaying and isPlaying then
                    introFinished = false
                end
            elseif md.S4PagerRobberyIntroStartMs and nowMs > 0 and (nowMs < (md.S4PagerRobberyIntroStartMs + 4000)) then
                introFinished = false
            elseif md.S4PagerRobberyIntroEndHours and (S4_Pager_System.nowWorldHours() < md.S4PagerRobberyIntroEndHours) then
                introFinished = false
            end
        end

        if introFinished then
            startMissionPersistentAudio(player, mission)
            md.S4PagerRobberyIntroPending = nil
            md.S4PagerRobberyIntroSoundId = nil
            md.S4PagerRobberyIntroStartMs = nil
            md.S4PagerRobberyIntroEndHours = nil
        end
    end

    if md.S4PagerAlarmEndMs and nowMs > (md.S4PagerAlarmEndMs or 0) then
        S4_Pager_System.stopRobberyAlarm(player)
    end
end

function S4_Pager_System.cameraMissionPhoto(player, cameraItem, opts)
    if not player or not cameraItem then
        return
    end
    opts = opts or {}
    local mission, mode = nil, nil
    if opts.getCameraPhotoTargetFn then
        mission, mode = opts.getCameraPhotoTargetFn(player)
    end
    if not mission then
        return
    end
    local inRange = opts.isWithinMissionPhotoRangeFn and opts.isWithinMissionPhotoRangeFn(player, mission, 10)
    if not inRange then
        if player.setHaloNote then
            player:setHaloNote("You must get closer to the objective to take the photo", 230, 110, 70, 260)
        end
        return
    end
    local created = opts.createValuablePhotoInInventoryFn and
                        opts.createValuablePhotoInInventoryFn(player, mission, "CameraDisposable")
    if created then
        if opts.removeOneItemFromPlayerFn then
            opts.removeOneItemFromPlayerFn(player, cameraItem)
        end
        if player.setHaloNote then
            if mode == "completed" then
                player:setHaloNote("Recovered evidence from completed mission", 245, 225, 140, 260)
            else
                player:setHaloNote("Se encontro algo... parece valioso", 245, 225, 140, 260)
            end
        end
    elseif player.setHaloNote then
        player:setHaloNote("Could not create evidence photo", 230, 110, 70, 260)
    end
end

function S4_Pager_System.inventoryCameraMenu(playerNum, context, items, opts)
    local player = getSpecificPlayer(playerNum)
    if not player then
        return
    end
    local pData = player:getModData()
    local mission = pData and pData.S4PagerMission or nil
    if not mission or mission.status ~= "active" then
        return
    end
    opts = opts or {}

    items = ISInventoryPane.getActualItems(items)
    if not items then
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

    local item = nil
    for i = 1, #list do
        local it = list[i]
        if it and it.getFullType then
            local ft = it:getFullType()
            if ft == "Base.CameraDisposable" or ft == "Base.DisposableCamera" or ft == "Base.Camera" then
                item = it
                break
            end
        end
    end
    if not item then
        return
    end

    local label = "Take Mission Photo"
    local option = context:addOption(label, player, opts.cameraMissionPhotoFn, item)
    local inRange = opts.isWithinMissionPhotoRangeFn and opts.isWithinMissionPhotoRangeFn(player, mission, 10)
    if not inRange then
        option.notAvailable = true
        option.onSelect = nil
        local tt = ISToolTip:new()
        tt.description = "Get within 10 tiles of the objective to take the photo."
        option.toolTip = tt
    end
end
