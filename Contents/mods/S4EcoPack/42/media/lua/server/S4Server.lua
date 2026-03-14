-- Function initialization
S4Server = {}

function S4Server.DayEvent()
    if SandboxVars and SandboxVars.S4SandBox and not SandboxVars.S4SandBox.SinglePlay and isClient() then
        return
    end

    local UpdatModData = ModData.get("S4_CardLog")
    if UpdatModData then
        local NeedUpdata = false
        for CardNumber, CardData in pairs(UpdatModData) do
            for _, Data in pairs(CardData) do
                if Data.Type and Data.Type == "Diposit" then
                    Data.Type = "Deposit"
                    NeedUpdata = true
                end
                if Data.Type and Data.Type == "New" then
                    Data.Type = "Deposit"
                    NeedUpdata = true
                end
                if Data.Type and Data.Type == "Payment" then
                    Data.Type = "Withdraw"
                    NeedUpdata = true
                end
                if Data.Sender and Data.Sender == "BlackJeck" then
                    Data.Sender = "BlackJack"
                    NeedUpdata = true
                end
                if Data.Receiver and Data.Receiver == "BlackJeck" then
                    Data.Receiver = "BlackJack"
                    NeedUpdata = true
                end
            end
        end
        if NeedUpdata then
            ModData.transmit("S4_CardLog")
        end
    end

    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end

    -- Daily Recommended Items (Hot Items) Rotation
    local ShopModData = ModData.get("S4_ShopData")
    if ShopModData then
        local allKeys = {}
        for k, Data in pairs(ShopModData) do
            Data.HotItem = 0
            Data.Discount = 0
            table.insert(allKeys, k)
        end

        local totalItems = #allKeys
        if totalItems > 0 then
            -- Pick between 5 and 15 random items to be "Hot"
            local numHot = ZombRand(5, 16)
            if numHot > totalItems then numHot = totalItems end

            for i = 1, numHot do
                local randIdx = ZombRand(1, totalItems + 1)
                local key = allKeys[randIdx]
                local item = ShopModData[key]
                if item then
                    item.HotItem = 1
                    item.Discount = ZombRand(5, 31) -- 5% to 30% discount
                end
            end
        end
        ModData.transmit("S4_ShopData")
    end

    ModData.transmit("S4_ServerData")
end
Events.EveryDays.Add(S4Server.DayEvent)

function S4Server.HourEvent()
    if SandboxVars and SandboxVars.S4SandBox and not SandboxVars.S4SandBox.SinglePlay and isClient() then
        return
    end

    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end

    local RestockHours = 168
    if SandboxVars and SandboxVars.S4SandBox then
        RestockHours = SandboxVars.S4SandBox.RestockHours
        if not RestockHours and SandboxVars.S4SandBox.RestcokDate then
            RestockHours = SandboxVars.S4SandBox.RestcokDate * 24
        end
    end
    if not RestockHours or RestockHours < 1 then
        return
    end

    if not ServerModData.ShopHourCount then
        if ServerModData.ShopDayCount then
            ServerModData.ShopHourCount = ServerModData.ShopDayCount * 24
            ServerModData.ShopDayCount = nil
        else
            ServerModData.ShopHourCount = 0
        end
    end

    ServerModData.ShopHourCount = ServerModData.ShopHourCount + 1
    if ServerModData.ShopHourCount >= RestockHours then
        local ShopModData = ModData.get("S4_ShopData")
        if not ShopModData then
            return
        end
        for _, Data in pairs(ShopModData) do
            if Data.Restock > 0 then
                Data.Stock = Data.Stock + Data.Restock
            end
        end
        ServerModData.ShopHourCount = 0
        ModData.transmit("S4_ShopData")
    end

    ModData.transmit("S4_ServerData")
end
Events.EveryHours.Add(S4Server.HourEvent)

function S4Server.DayAirDrop(PointX, PointY)
    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end

    ServerModData.TodayAirDrop = {
        X = PointX,
        Y = PointY
    }
    ModData.transmit("S4_ServerData")
end

function S4Server.setAirDropList(PointX, PointY, DropType)
    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end
    if not ServerModData.AirDropList then
        ServerModData.AirDropList = {}
    end
    if ServerModData.AirDropList["X" .. PointX .. "Y" .. PointY] then
        return
    end

    ServerModData.AirDropList["X" .. PointX .. "Y" .. PointY] = {}
    ServerModData.AirDropList["X" .. PointX .. "Y" .. PointY].PointX = PointX
    ServerModData.AirDropList["X" .. PointX .. "Y" .. PointY].PointY = PointY
    ServerModData.AirDropList["X" .. PointX .. "Y" .. PointY].Check = false
    ServerModData.AirDropList["X" .. PointX .. "Y" .. PointY].DropType = DropType

    ModData.transmit("S4_ServerData")
end

function S4Server.CheckAirDrop(player, args)
    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end
    if not ServerModData.AirDropList then
        return
    end
    if not ServerModData.AirDropList[args[1]] then
        return
    end
    ServerModData.AirDropList[args[1]].Check = true

    ModData.transmit("S4_ServerData")
end

function S4Server.RemoveDayAirDrop()
    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end
    if not ServerModData.AirDropList then
        return
    end
    for XYCode, Data in pairs(ServerModData.AirDropList) do
        if not Data.Check then
            ServerModData.AirDropList[XYCode] = nil
        end
    end
    ModData.transmit("S4_ServerData")
end

function S4Server.SpawnMissionZombie(player, args)
    if not args then
        return
    end
    local x = math.floor(tonumber(args.x) or -1)
    local y = math.floor(tonumber(args.y) or -1)
    local z = math.floor(tonumber(args.z) or 0)
    local count = math.max(1, math.floor(tonumber(args.count) or 1))
    if x < 0 or y < 0 then
        return
    end

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

    if spawnedCount <= 0 and addZombiesInOutfit then
        local ok3 = pcall(function()
            addZombiesInOutfit(x, y, z, count, "Generic01", nil)
        end)
        if ok3 then
            spawnedCount = count
        end
    end

    if isDebugEnabled and isDebugEnabled() then
        print(string.format("[S4_Pager] SpawnMissionZombie at %d,%d,%d count=%d spawned=%d", x, y, z, count,
            spawnedCount))
    end
end

local function S4_applyPartConditionPercent(part, deltaPct)
    if not part or not deltaPct or not part.getCondition or not part.setCondition then
        return
    end
    local okGet, cur = pcall(function()
        return tonumber(part:getCondition()) or 100
    end)
    if not okGet then
        return
    end
    local newCond = math.floor(cur * (1 + (deltaPct / 100)))
    if newCond < 0 then
        newCond = 0
    elseif newCond > 100 then
        newCond = 100
    end
    pcall(function()
        part:setCondition(newCond)
    end)
end

local function S4_applyVehicleDeliveryMods(vehicle, mods)
    if not vehicle or not mods then
        return
    end
    local seatPct = tonumber(mods.seatDurabilityPct) or 0
    local panelPct = tonumber(mods.bodyPanelDurabilityPct) or 0
    local engineDelta = tonumber(mods.engineHP) or 0
    local partCount = 0
    local okCount, cnt = pcall(function()
        return vehicle:getPartCount()
    end)
    if okCount and cnt then
        partCount = math.max(0, tonumber(cnt) or 0)
    end
    local enginePart = nil
    for i = 0, partCount - 1 do
        local part = nil
        local okPart, p = pcall(function()
            return vehicle:getPartByIndex(i)
        end)
        if okPart then
            part = p
        end
        if part then
            local pid = ""
            if part.getId then
                local okId, id = pcall(function()
                    return tostring(part:getId() or ""):lower()
                end)
                if okId and id then
                    pid = id
                end
            end
            if seatPct ~= 0 and string.find(pid, "seat", 1, true) then
                S4_applyPartConditionPercent(part, seatPct)
            end
            if panelPct ~= 0 and (string.find(pid, "door", 1, true) or string.find(pid, "hood", 1, true) or
                string.find(pid, "trunk", 1, true)) then
                S4_applyPartConditionPercent(part, panelPct)
            end
            if not enginePart and (pid == "engine" or string.find(pid, "engine", 1, true)) then
                enginePart = part
            end
        end
    end

    if engineDelta ~= 0 then
        local applied = false
        if vehicle.getEnginePower and vehicle.setEnginePower then
            local okApply = pcall(function()
                local current = tonumber(vehicle:getEnginePower()) or 0
                vehicle:setEnginePower(math.max(0, current + engineDelta))
            end)
            applied = okApply
        end
        if (not applied) and enginePart then
            local condDeltaPct = 0
            if engineDelta > 0 then
                condDeltaPct = math.min(80, math.floor(engineDelta / 2))
            else
                condDeltaPct = -math.min(80, math.floor(math.abs(engineDelta) / 2))
            end
            S4_applyPartConditionPercent(enginePart, condDeltaPct)
        end
    end

    local md = vehicle:getModData()
    md.S4VehicleOrderMods = {
        seatDurabilityPct = seatPct,
        bodyPanelDurabilityPct = panelPct,
        engineHP = engineDelta
    }
    pcall(function()
        vehicle:transmitModData()
    end)
end

local function S4_applyVehicleDeliveryState(vehicle)
    if not vehicle then
        return
    end

    local createdKey = nil
    if vehicle.createVehicleKey then
        local okKey, key = pcall(function()
            return vehicle:createVehicleKey()
        end)
        if okKey then
            createdKey = key
        end
    end
    if (not createdKey) and InventoryItemFactory and InventoryItemFactory.CreateItem then
        local okFallback, item = pcall(function()
            return InventoryItemFactory.CreateItem("Base.CarKey")
        end)
        if okFallback then
            createdKey = item
        end
    end

    local glovePart = nil
    if vehicle.getPartById then
        local okGlove, gp = pcall(function()
            return vehicle:getPartById("GloveBox")
        end)
        if okGlove then
            glovePart = gp
        end
    end
    if glovePart and createdKey then
        local container = nil
        if glovePart.getItemContainer then
            local okC, c = pcall(function()
                return glovePart:getItemContainer()
            end)
            if okC then
                container = c
            end
        end
        if (not container) and glovePart.getContainer then
            local okC2, c2 = pcall(function()
                return glovePart:getContainer()
            end)
            if okC2 then
                container = c2
            end
        end
        if container and container.AddItem then
            pcall(function()
                container:AddItem(createdKey)
            end)
        end
    end

    local partCount = 0
    local okCount, cnt = pcall(function()
        return vehicle:getPartCount()
    end)
    if okCount and cnt then
        partCount = math.max(0, tonumber(cnt) or 0)
    end
    for i = 0, partCount - 1 do
        local part = nil
        local okPart, p = pcall(function()
            return vehicle:getPartByIndex(i)
        end)
        if okPart then
            part = p
        end
        if part and part.getId then
            local pid = ""
            local okId, id = pcall(function()
                return tostring(part:getId() or ""):lower()
            end)
            if okId and id then
                pid = id
            end
            if string.find(pid, "door", 1, true) then
                local door = nil
                if part.getDoor then
                    local okDoor, d = pcall(function()
                        return part:getDoor()
                    end)
                    if okDoor then
                        door = d
                    end
                end

                if door then
                    pcall(function()
                        door:setLocked(false)
                        door:setOpen(true)
                    end)
                elseif part.setOpen then
                    pcall(function()
                        part:setOpen(true)
                    end)
                end

                if vehicle.transmitPartDoor then
                    pcall(function()
                        vehicle:transmitPartDoor(part)
                    end)
                end
            end
        end
    end
end

function S4Server.SpawnVehicleDelivery(player, args)
    if not args then
        return
    end
    local scriptId = tostring(args.vehicleId or "")
    local x = math.floor(tonumber(args.x) or -1)
    local y = math.floor(tonumber(args.y) or -1)
    local z = math.floor(tonumber(args.z) or 0)
    if scriptId == "" or x < 0 or y < 0 then
        return
    end

    local cell = getCell()
    if not cell then
        return
    end

    -- 1) Find the best square (search nearby if blocked)
    local sq = cell:getGridSquare(x, y, z)
    if (not sq) or (not sq:isFreeOrMidair(false)) or sq:isVehicleIntersecting() then
        local found = false
        for dx = -2, 2 do
            for dy = -2, 2 do
                local s2 = cell:getOrCreateGridSquare(x + dx, y + dy, z)
                if s2 and s2:isFreeOrMidair(false) and not s2:isVehicleIntersecting() then
                    sq = s2
                    x = x + dx
                    y = y + dy
                    found = true
                    break
                end
            end
            if found then
                break
            end
        end
    end
    if not sq then
        sq = cell:getOrCreateGridSquare(x, y, z)
    end

    local vehicle = nil
    local function setIfVehicle(v)
        if v and v.getScriptName then
            vehicle = v
            return true
        end
        return false
    end

    local dir = nil
    if IsoDirections and IsoDirections.N then
        dir = IsoDirections.N
    end

    -- 2) Try spawning methods
    if addVehicleDebug then
        local ok2, v2 = pcall(function()
            return addVehicleDebug(scriptId, dir, nil, sq)
        end)
        if ok2 and setIfVehicle(v2) then
            -- spawned
        end
    end

    if (not vehicle) and addVehicle then
        local ok4, v4 = pcall(function()
            return addVehicle(scriptId, x, y, z)
        end)
        if ok4 and setIfVehicle(v4) then
            -- spawned
        end
    end

    -- 3) Post-spawn configuration and EFFECTS
    if vehicle then
        S4_applyVehicleDeliveryState(vehicle)
        S4_applyVehicleDeliveryMods(vehicle, args.mods or {})

        -- VIBRANT EFFECTS:
        -- Sound: Simulate helicopter/delivery arrival
        addSound(nil, x, y, z, 60, 100)

        -- Visual: Smoke at the drop point
        if IsoFireManager and IsoFireManager.StartSmoke then
            pcall(function()
                IsoFireManager.StartSmoke(sq, 10)
            end)
        end

        -- Notifications to nearby players
        local players = getOnlinePlayers()
        if players then
            for i = 0, players:size() - 1 do
                local p = players:get(i)
                local dist = math.sqrt((p:getX() - x) ^ 2 + (p:getY() - y) ^ 2)
                if dist < 30 then
                    -- Send server command to trigger local effects (sound/halo)
                    sendServerCommand(p, "S4SMD", "PlayVehicleSpawnEffect", {
                        x = x,
                        y = y,
                        z = z,
                        vehicleName = vehicle:getScriptName(),
                        orderId = args.orderId or "Unknown"
                    })
                end
            end
        elseif player then
             -- Singleplayer or fallback
             sendServerCommand(player, "S4SMD", "PlayVehicleSpawnEffect", {
                x = x,
                y = y,
                z = z,
                vehicleName = vehicle:getScriptName(),
                orderId = args.orderId or "Unknown"
            })
        end
    end
end

-- function S4Server.CreateAirDropBox(player, args)
--     local ServerModData = ModData.get("S4_ServerData")
--     if not ServerModData then return end
--     if not ServerModData.AirDropList then return end
--     if not ServerModData.AirDropList[args[1]] then return end
--     ServerModData.AirDropList[args[1]] = nil

--     ModData.transmit("S4_ServerData")
-- end

function S4Server.CreateAirDropBoxMutiTest()
    local ServerModData = ModData.get("S4_ServerData")
    if not ServerModData then
        return
    end
    if not ServerModData.AirDropList then
        return
    end
    for XYCode, Data in pairs(ServerModData.AirDropList) do
        if Data.Check then
            local Ax, Ay, Az = Data.PointX, Data.PointY, 0
            local square = getWorld():getCell():getGridSquare(Ax, Ay, Az)
            if square and square:isOutside() and not square:isWaterSquare() then
                if Data.DropType then
                    square:AddWorldInventoryItem("S4Item.AirDropBox_" .. Data.DropType, 0.5, 0.5, 0)
                end
                -- local AirDropItemModData = AirDropItem:getModData()
                -- AirDropItemModData.S4AirDropType = Data.DropType
                -- S4_Utils.SnycObject(AirDropItem)
                -- Not reflected immediately
                ServerModData.AirDropList[XYCode] = nil
                ModData.transmit("S4_ServerData")
            elseif square and (not square:isOutside() or square:isWaterSquare()) then
                -- Delete Supply
                ServerModData.AirDropList[XYCode] = nil
                ModData.transmit("S4_ServerData")
            end
        end
    end
end
Events.EveryOneMinute.Add(S4Server.CreateAirDropBoxMutiTest)
