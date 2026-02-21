S4_Utils = {}
S4_Utils.ItemCashe = {}

local function shouldSkipItemInstance(itemName)
    if not getScriptManager then
        return false
    end

    local okManager, scriptManager = pcall(getScriptManager)
    if not okManager or not scriptManager then
        return false
    end

    local okFind, scriptItem = pcall(function()
        return scriptManager:FindItem(itemName)
    end)
    if not okFind or not scriptItem then
        return false
    end

    if scriptItem.getTypeString then
        local okType, typeString = pcall(function()
            return scriptItem:getTypeString()
        end)
        if okType and typeString == "WeaponPart" then
            return true
        end
    end

    return false
end

-- Object mode data storage function
function S4_Utils.SnycObject(Object)
    if SandboxVars and SandboxVars.S4SandBox and not SandboxVars.S4SandBox.SinglePlay and isClient() then
        Object:transmitModData()
    end
end

-- Tile empty space check function
function S4_Utils.getAdjacent(player, Obj, Px, Py)
    if not Obj then return false end

    local x, y, z = Obj:getX(), Obj:getY(), Obj:getZ()
    local square = getCell():getGridSquare(x+Px, y+Py, z)
    if not square then return false end

    -- Check if the tile can be moved (no obstacles, vehicles, etc.)
    if not square:isFreeOrMidair(false) then return false end
    -- Returns false if the tile overlaps a vehicle or does not meet certain conditions
    if square:isVehicleIntersecting() then return false end
    
    return square
end

-- Player inventory item search, quantity, item information
function S4_Utils.getPlayerItems(player)
    local ItemsTable = {}
    local pInv = player:getInventory()
    local InvItems = pInv:getItems()
    for i = 0, InvItems:size() - 1 do
        local item = InvItems:get(i)
        if instanceof(item, "InventoryContainer") then
            local Container = item:getInventory()
            local ContainerItems = Container:getItems()
            if ContainerItems:size() > 0 then
                for i = 0, ContainerItems:size() - 1 do
                    local Containeritem = ContainerItems:get(i)
                    if S4_Utils.ItemCheck(Containeritem) then
                        local FType = Containeritem:getFullType()
                        if not ItemsTable[FType] then
                            ItemsTable[FType] = {}
                            ItemsTable[FType].items = {}
                            ItemsTable[FType].Amount = 1
                            table.insert(ItemsTable[FType].items, Containeritem)
                        else
                            ItemsTable[FType].Amount = ItemsTable[FType].Amount + 1
                            table.insert(ItemsTable[FType].items, Containeritem)
                        end
                    end
                end
            else
                if S4_Utils.ItemCheck(item) then
                    local FType = item:getFullType()
                    if not ItemsTable[FType] then
                        ItemsTable[FType] = {}
                        ItemsTable[FType].items = {}
                        ItemsTable[FType].Amount = 1
                        table.insert(ItemsTable[FType].items, item)
                    else
                        ItemsTable[FType].Amount = ItemsTable[FType].Amount + 1
                        table.insert(ItemsTable[FType].items, item)
                    end
                end
            end
        else
            if S4_Utils.ItemCheck(item) then
                local FType = item:getFullType()
                if not ItemsTable[FType] then
                    ItemsTable[FType] = {}
                    ItemsTable[FType].items = {}
                    ItemsTable[FType].Amount = 1
                    table.insert(ItemsTable[FType].items, item)
                else
                    ItemsTable[FType].Amount = ItemsTable[FType].Amount + 1
                    table.insert(ItemsTable[FType].items, item)
                end
            end
        end
    end
    return ItemsTable
end

-- Save item cache
function S4_Utils.setItemCashe(itemName)
    if not S4_Cashe then
        S4_Cashe = {}
    end
    if itemName == nil or itemName == "" then
        return nil
    end
    if S4_Cashe[itemName] == false then
        return nil
    end
    if not S4_Cashe[itemName] then
        if shouldSkipItemInstance(itemName) then
            S4_Cashe[itemName] = false
            return nil
        end
        local ok, ItemData = pcall(instanceItem, itemName)
        if ok and ItemData then
            S4_Cashe[itemName] = ItemData
        else
            -- Some third-party item scripts can throw on instance creation (e.g. invalid mountOn data).
            -- Cache as invalid to avoid repeating the same failing call.
            S4_Cashe[itemName] = false
            return nil
        end
    end
    if S4_Cashe[itemName] == false then
        return nil
    end
    return S4_Cashe[itemName]
end

-- Check the status of the item / whether it is being installed, whether it is a favorite, whether it is damaged, whether it is used
function S4_Utils.ItemCheck(item)
    if not item or item:isEquipped() or item:isFavorite() or item:isBroken() then
        return false
    end
    -- return not (instanceof(item, "DrainableComboItem") and item:getUsedDelta() < 1)
    return not (instanceof(item, "DrainableComboItem") and item:getCurrentUsesFloat() < 0.9)
end

-- Contract expiration confirmation function
function S4_Utils.getTimeOver(InputTime)
    local CurrentGameTime = GameTime.getInstance()
    local CurrentTime = {
        CurrentGameTime:getYear(),
        CurrentGameTime:getMonth() + 1,
        CurrentGameTime:getDay(),
        CurrentGameTime:getHour(),
        CurrentGameTime:getMinutes()
    }
    local ExpYear, ExpMonth, ExpDay, ExpHour, ExpMin = InputTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
    if not ExpYear then return false end
    local ExpirationTime = {
        tonumber(ExpYear),
        tonumber(ExpMonth),
        tonumber(ExpDay),
        tonumber(ExpHour),
        tonumber(ExpMin)
    }
    for i = 1, 5 do
        if CurrentTime[i] < ExpirationTime[i] then
            return true  -- Current time is before expiration, so IT IS VALID
        elseif CurrentTime[i] > ExpirationTime[i] then
            return false  -- Current time has passed expiration, so IT IS EXPIRED
        end
    end
    return false  -- Exact same minute, also consider it expired/over
end

-- Current time text function (year, month, day, hour, minute)
function S4_Utils.getDateTimeText()
    local gameTime = GameTime.getInstance()
    local Year = gameTime:getYear()
    local Month = gameTime:getMonth() + 1
    local Day = gameTime:getDay()
    local Hour = gameTime:getHour()
    local Min = gameTime:getMinutes()

    local DateTime = string.format("%04d-%02d-%02d %02d:%02d", Year, Month, Day, Hour, Min)
    return DateTime
end

-- Add time function
function S4_Utils.setAddTime(OldTime, AddTime)
    -- leap year check
    local function isLeapYear(year)
        return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
    end

    local year, month, day, hour, minutes = OldTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
    local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    hour = tonumber(hour)
    minutes = tonumber(minutes)

    if isLeapYear(year) then
        daysInMonth[2] = 29
    end

    -- add time
    hour = hour + AddTime
    while hour >= 24 do
        hour = hour - 24
        day = day + 1
        if day > daysInMonth[month] then
            day = day - daysInMonth[month]
            month = month + 1
            if month > 12 then
                month = 1
                year = year + 1
                if isLeapYear(year) then
                    daysInMonth[2] = 29
                else
                    daysInMonth[2] = 28
                end
            end
        end
    end

    return string.format("%04d-%02d-%02d %02d:%02d", year, month, day, hour, minutes)
end

-- Transaction Time Function
function S4_Utils.getLogTime()
    local gameTime = GameTime.getInstance()
    local year = gameTime:getYear()
    local month = gameTime:getMonth() + 1
    local day = gameTime:getDay()
    local hour = gameTime:getHour()
    local minutes = gameTime:getMinutes()
    local seconds = gameTime:getTimeOfDay() * 3600 % 60
    seconds = math.floor(seconds)

    local LogTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minutes, seconds)
    return LogTime
end
-- Remove trading time seconds
function S4_Utils.getLogTimeMin(LogTime)
    local year, month, day, hour, minute, seconds = LogTime:match("(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)")
    local LogTimeMin = year.."-"..month.."-"..day.." "..hour..":"..minute
    return LogTimeMin
end

-- Mouse movement, item table
function S4_Utils.getMoveItemTable(items)
    local itemTable = {}
    local itemSet = {}

    local function addItem(item) -- Add items after checking for duplicates
        if not itemSet[item] then
            itemSet[item] = true
            table.insert(itemTable, item)
        end
    end

    local function processItemData(ItemData) -- Process data recursively
        if type(ItemData) == "table" then
            if ItemData.items then
                -- If you have an items field
                for _, item in pairs(ItemData.items) do
                    addItem(item)
                end
            else -- Treated as a regular table
                for _, item in pairs(ItemData) do
                    if item then
                        addItem(item)
                    end
                end
            end
        else -- Single item processing
            addItem(ItemData)
        end
    end
    if type(items) == "table" then -- main processing loop
        for _, ItemData in pairs(items) do
            processItemData(ItemData)
        end
    end

    return #itemTable > 0 and itemTable or nil
end

-- Initial card funds random function
function S4_Utils.getNewCardMoney()
    local Money = 100
    local Rand = ZombRand(1000)
    if Rand < 1 then -- 0.1%
        Money = ZombRand(100000, 300000)
    elseif Rand < 10 then -- 0.9%
        Money = ZombRand(50000, 100000)
    elseif Rand < 60 then -- 5%
        Money = ZombRand(10000, 20000)
    elseif Rand < 200 then -- 14%
        Money = ZombRand(1000, 10000)
    elseif Rand < 500 then -- 30%
        Money = ZombRand(500, 5000)
    else -- 50%
        Money = ZombRand(100, 300)
    end
    return Money
end

-- Withdrawal cash payment function
function S4_Utils.giveWithdrawMoney(player, Value)
    local value10000 = math.floor(Value / 10000)  -- Values ​​greater than 10000
    local value100 = math.floor((Value % 10000) / 100)  -- Values ​​less than 10000 and more than 100 digits
    local value1 = Value % 100  -- Value less than 100 but more than 1 digit

    if value10000 > 0 then
        player:getInventory():AddItems("S4Item.Money10000", value10000)
    end
    if value100 > 0 then
        player:getInventory():AddItems("S4Item.Money100", value100)
    end
    if value1 > 0 then
        player:getInventory():AddItems("S4Item.Money1", value1)
    end
end

-- Satellite antenna distance check
function S4_Utils.DistanceSatelliteDish(ComObj)
    local Range = 14
    local RangeZ = 3

    for x = ComObj:getX() - Range, ComObj:getX() + Range do
        for y = ComObj:getY() - Range, ComObj:getY() + Range do
            for z = ComObj:getZ() - RangeZ, ComObj:getZ() + RangeZ do
                if z >= 0 then
                    local square = getCell():getGridSquare(x, y, z)
                    if square then
                        for i = 0, square:getObjects():size() - 1 do
                            local Obj = square:getObjects():get(i)
                            if Obj:getSprite() == getSprite("appliances_com_01_20") or Obj:getSprite() == getSprite("appliances_com_01_21") then
                                if Obj:getSquare():isOutside() then
                                    local dx = math.abs(Obj:getX() - ComObj:getX())
                                    local dy = math.abs(Obj:getY() - ComObj:getY())
                                    local dz = math.abs(Obj:getZ() - ComObj:getZ())
                                    local distance = dx + dy + dz  -- 3D distance calculation (including Manhattan distance)
                                    local XYZ = "X"..Obj:getX().."Y"..Obj:getY().."Z"..Obj:getZ()
                                    return distance, XYZ  -- Returns the distance to the nearest object
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return 0, false  -- Returns false if no object meets the condition.
end

-- Check satellite antenna
function S4_Utils.CheckSatelliteDish(ComObj)
    local ComModData = ComObj:getModData()
    if ComModData.ComSatelliteXYZ then
        local Sx, Sy, Sz = string.match(ComModData.ComSatelliteXYZ, "X(%d+)Y(%d+)Z(%d+)")
        local x, y, z = tonumber(Sx), tonumber(Sy), tonumber(Sz)
        local square = getCell():getGridSquare(x, y, z)
        if square then
            for i=0,square:getObjects():size()-1 do
                local Obj = square:getObjects():get(i)
                if Obj:getSprite() == getSprite("appliances_com_01_20") or Obj:getSprite() == getSprite("appliances_com_01_21") then
                    if Obj:getSquare():isOutside() then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Fee calculation
function S4_Utils.CheckCommission(SellAmount)
    local Commission = 0
    if not SandboxVars or not SandboxVars.S4Authority then
        -- Return default values if SandboxVars is missing
        local defaults = {20, 15, 10, 5, 1, 0}
        return defaults[SellAmount + 1] or 0
    end

    if SellAmount == 0 then
        Commission = SandboxVars.S4Authority.SellCommissionBronze or 20
    elseif SellAmount == 1 then
        Commission = SandboxVars.S4Authority.SellCommissionSilver or 15
    elseif SellAmount == 2 then
        Commission = SandboxVars.S4Authority.SellCommissionGold or 10
    elseif SellAmount == 3 then
        Commission = SandboxVars.S4Authority.SellCommissionPlatinum or 5
    elseif SellAmount == 4 then
        Commission = SandboxVars.S4Authority.SellCommissionDiamond or 1
    elseif SellAmount == 5 then
        Commission = SandboxVars.S4Authority.SellCommissionVIP or 0
    end
    return Commission
end

-- money change probability
function S4_Utils.CheckInvCash(player, item)
    local playerInv = player:getInventory()
    if not item then return end

    local isDirty = false
    if item:hasModData() and item:getModData().S4DirtyMoney then
        isDirty = true
    else
        local dn = string.lower(item:getName() or "")
        local dnn = string.lower(item:getDisplayName() or "")
        if string.find(dn, "dirty") or string.find(dnn, "dirty") or string.find(dn, "suci") or string.find(dnn, "suci") then
            isDirty = true
        end
    end

    if isDirty then
        if player.setHaloNote then
            player:setHaloNote("They can't be used... Taxes are no joke", 255, 60, 60, 300)
        end
        if item:getWorldItem() then
            item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
            ISInventoryPage.dirtyUI()
        else
            if item:getContainer() then
                item:getContainer():Remove(item)
            else
                playerInv:Remove(item)
            end
        end
        return
    end

    if item:getFullType() == "Base.Money" then
        local BRand = ZombRand(10001)
        if BRand == 1234 then
            local zRand = ZombRand(30)
            playerInv:AddItems("S4Item.Money10000", 2)
            playerInv:AddItems("S4Item.Money1", zRand)
        elseif BRand >= 9900 then
            local mRand = ZombRand(11)
            playerInv:AddItems("S4Item.Money100", mRand)
            local zRand = ZombRand(30)
            playerInv:AddItems("S4Item.Money1", zRand)
        else
            local zRand = ZombRand(100)
            playerInv:AddItems("S4Item.Money1", zRand)
        end
    elseif item:getFullType() == "Base.MoneyBundle" then
        local BRand = ZombRand(10001)
        if BRand == 5678 then
            playerInv:AddItems("S4Item.Money10000x100", 1)
        elseif BRand >= 9000 then
            playerInv:AddItems("S4Item.Money100x100", 1)
        else
            playerInv:AddItems("S4Item.Money1x100", 1)
        end
    end

    if item:getWorldItem() then
        item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem())
        ISInventoryPage.dirtyUI()
    else
        if item:getContainer() then
            item:getContainer():Remove(item)
        else
            playerInv:Remove(item)
        end
    end

end
