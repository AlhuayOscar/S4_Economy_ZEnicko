S4_Pager_System = S4_Pager_System or {}

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
    local objective = point.objective or objectives[ZombRand(1, #objectives + 1)]
    return {
        missionName = point.missionName or objective,
        durationHours = point.durationHours or ZombRand(2, 9),
        objective = objective,
        location = point.location,
        targetX = point.x,
        targetY = point.y,
        targetZ = point.z or 0,
        zombieCount = point.zombieCount or ZombRand(1, 4),
        areaMinX = point.areaMinX,
        areaMaxX = point.areaMaxX,
        areaMinY = point.areaMinY,
        areaMaxY = point.areaMaxY,
        hiddenPadding = point.hiddenPadding
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
    local objective = point.objective or objectives[ZombRand(1, #objectives + 1)]
    return {
        missionName = point.missionName or objective,
        durationHours = point.durationHours or ZombRand(2, 9),
        objective = objective,
        location = point.location,
        targetX = point.x,
        targetY = point.y,
        targetZ = point.z or 0,
        zombieCount = point.zombieCount or ZombRand(1, 4),
        areaMinX = point.areaMinX,
        areaMaxX = point.areaMaxX,
        areaMinY = point.areaMinY,
        areaMaxY = point.areaMaxY,
        hiddenPadding = point.hiddenPadding
    }
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
        return px >= mission.areaMinX and px <= mission.areaMaxX and py >= mission.areaMinY and py <= mission.areaMaxY
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
    if padding < 12 then
        padding = 12
    elseif padding > 20 then
        padding = 20
    end

    if mission.areaMinX and mission.areaMaxX and mission.areaMinY and mission.areaMaxY then
        local minX = mission.areaMinX - padding
        local maxX = mission.areaMaxX + padding
        local minY = mission.areaMinY - padding
        local maxY = mission.areaMaxY + padding
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
    return
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
    local entry = missionPhotoLore and missionPhotoLore[ZombRand(1, #missionPhotoLore + 1)] or nil
    local code = S4_Pager_System.randomWorkObjectCode()
    if entry and photo.setName then
        photo:setName(string.format("Objeto de Trabajo: %s | %s", code, entry.title))
    end
    if entry and photo.setTooltip then
        photo:setTooltip(string.format("Objeto de Trabajo: %s\n%s", code, entry.note))
    end
    if photo.getModData then
        local md = photo:getModData()
        md.S4WorkObject = true
        md.S4WorkCode = code
        if entry then
            md.S4WorkLoreTitle = entry.title
            md.S4WorkLoreNote = entry.note
        end
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

    local entry = missionPhotoLore and missionPhotoLore[ZombRand(1, #missionPhotoLore + 1)] or nil
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
        if entry then
            md.S4WorkLoreTitle = entry.title
            md.S4WorkLoreNote = entry.note
        end
    end
    if entry and item.setName then
        item:setName(string.format("Objeto de Trabajo: %s | %s", code, entry.title))
    end
    if entry and item.setTooltip then
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
    local entry = missionPhotoLore and missionPhotoLore[ZombRand(1, #missionPhotoLore + 1)] or nil
    local code = S4_Pager_System.randomWorkObjectCode()
    if photo.getModData then
        local md = photo:getModData()
        md.S4WorkObject = true
        md.S4WorkCode = code
        md.S4WorkSource = sourceLabel or "Camera"
        if entry then
            md.S4WorkLoreTitle = entry.title
            md.S4WorkLoreNote = entry.note
        end
    end
    if entry and photo.setName then
        photo:setName(string.format("Objeto de Trabajo: %s | %s", code, entry.title))
    end
    if entry and photo.setTooltip then
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
            player:setHaloNote("No se pudo colocar Objeto de Trabajo en el suelo", 230, 110, 70, 280)
        end
    end
    local nowWorldHoursFn = opts.nowWorldHoursFn or S4_Pager_System.nowWorldHours
    pData.S4PagerLastCompletedMission = {
        targetX = mission.targetX,
        targetY = mission.targetY,
        targetZ = mission.targetZ,
        location = mission.location,
        completedWorldHours = nowWorldHoursFn()
    }
    mission.status = "completed"
    pData.S4PagerMission = nil
    if player.setHaloNote then
        player:setHaloNote(opts.reasonText or "Pager mission complete", opts.r or 80, opts.g or 220, opts.b or 80, 300)
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
        return
    end

    local remaining = math.max(0, (mission.killGoal or 1) - (mission.killsDone or 0))
    if remaining > 0 and (opts.isPlayerNearMissionFn and opts.isPlayerNearMissionFn(player, mission, 120)) then
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
                player:setHaloNote("Objeto destruido, deberas dar explicaciones al Cliente", 230, 110, 70, 360)
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
            player:setHaloNote("Debes acercarte al objetivo para tomar la foto", 230, 110, 70, 260)
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
                player:setHaloNote("Se recupero evidencia de mision completada", 245, 225, 140, 260)
            else
                player:setHaloNote("Se encontro algo... parece valioso", 245, 225, 140, 260)
            end
        end
    elseif player.setHaloNote then
        player:setHaloNote("No se pudo crear la foto de evidencia", 230, 110, 70, 260)
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
        tt.description = "Acercate a 10 celdas del objetivo para tomar la foto."
        option.toolTip = tt
    end
end
