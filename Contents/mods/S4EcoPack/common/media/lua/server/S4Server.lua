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
            addZombiesInOutfit(x, y, z, count, "Generic01", nil, false, false, false, false)
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
