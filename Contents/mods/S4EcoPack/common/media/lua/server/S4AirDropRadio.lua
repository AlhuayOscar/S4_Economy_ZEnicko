require "radio/ISDynamicRadio"

local AirDropChannel = {
    name = "HIND Emergency Broadcast System",
    freq = 777000, -- number for static frequency, or table for random: {min, max};
    category = "Emergency", -- Emergency type
    uuid = "ARDP-007007", -- must remain fixed.
    register = true,  -- if existing channel dont register, existing channel must match the uuid found in radiodata.xml
    airCounterMultiplier = 1.0, -- optional, change time text displays.
}
table.insert(DynamicRadio.channels, AirDropChannel)

AirDropRadio = {}  -- Create an object for a new radio channel
AirDropRadio.channelUUID = "ARDP-007007"
-- AirDropRadio.debugTestAll = false

local function comp(_str)
    return _str
end

ISDebugUtils = ISDebugUtils or {}
function ISDebugUtils.roundNum(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function roundstring(_val)
    return tostring(ISDebugUtils.roundNum(_val,2))
end

local function roundstring100(_val)
    return tostring(ISDebugUtils.roundNum(_val,0))
end

function AirDropRadio.Init()
    return
end

function AirDropRadio.OnLoadRadioScripts()
    AirDropRadio.Init()
    table.insert(DynamicRadio.scripts, AirDropRadio)
end

function AirDropRadio.OnEveryHour(_channel, _gametime, _radio)
    local hour = _gametime:getHour()

    if hour<120 then
        local bc = AirDropRadio.CreateBroadcast(_gametime)
        _channel:setAiringBroadcast(bc)
    end
end
Events.OnLoadRadioScripts.Add(AirDropRadio.OnLoadRadioScripts)

function AirDropRadio.CreateBroadcast(_gametime)
    local bc = RadioBroadCast.new("GEN-"..tostring(ZombRand(100000,999999)),-1,-1)

    AirDropRadio.FillBroadcast(_gametime, bc)
    return bc
end

function AirDropRadio.FillBroadcast(_gametime, _bc)
    local hour = _gametime:getHour()
    local c = { r=1.0, g=1.0, b=1.0 }
    -- print("Hour: "..tostring(hour))
    -- Need to add sendbox option verification code
    local AirDropOption = SandboxVars.S4SandBox.AirDrop
    if AirDropOption then
        if hour == 23 then
            S4Server.RemoveDayAirDrop()
        elseif hour == 22 then
            AirDropRadio.AddFuzz(c, _bc)

            _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Intro1")), c.r, c.g, c.b) )
            _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Intro2")), c.r, c.g, c.b) )
            local SetDropChane = SandboxVars.S4SandBox.AirDropChance
            if ZombRand(1, 101) <= SetDropChane then
                AirDropRadio.Add_AirDrop(c, _bc)
            else
                AirDropRadio.Add_NotAirDrop(c, _bc)
            end
            AirDropRadio.AddFuzz(c, _bc)
        end
    end
end

function AirDropRadio.AddFuzz(_c, _bc, _chance)
    local rand = ZombRand(1,_chance or 12)

    if rand==1 or rand==2 then
        _bc:AddRadioLine( RadioLine.new("<bzzt>", _c.r, _c.g, _c.b) )
    elseif rand==3 or rand==4 then
        _bc:AddRadioLine( RadioLine.new("<fzzt>", _c.r, _c.g, _c.b) )
    elseif rand==5 or rand==6 then
        _bc:AddRadioLine( RadioLine.new("<wzzt>", _c.r, _c.g, _c.b) )
    end
end

function AirDropRadio.Add_NotAirDrop(c, _bc)
    _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_AirDrop_NotDrop1")), c.r, c.g, c.b) )
    _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_AirDrop_NotDrop2")), c.r, c.g, c.b) )
end

function AirDropRadio.Add_AirDrop(c, _bc)
    local AreaChance = ZombRand(1, #S4_AirdropData.AreaType + 1)
    local AreaType = S4_AirdropData.AreaType[AreaChance] -- Supply area settings
    local AreaCount = AirDropRadio.AreaCount(AreaType)
    if AreaCount > 0 then -- Specify supply drop location
        AreaCount = AreaCount + 1
        local Point = ZombRand(1, AreaCount)
        local DropPoint = S4_AirdropData[AreaType][Point]
        local DropPointX = ZombRand(DropPoint.MinX, DropPoint.MaxX + 1)
        local DropPointY = ZombRand(DropPoint.MinY, DropPoint.MaxY + 1)
        local DropTypeChance = ZombRand(1, #S4_AirdropData.DropType + 1) -- Supply list
        local DropType = S4_AirdropData.DropType[DropTypeChance]
        S4Server.DayAirDrop(DropPointX, DropPointY)
        S4Server.setAirDropList(DropPointX, DropPointY, DropType)
        
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_AirDrop_TodayDrop")), c.r, c.g, c.b) )

        local DropPointText = string.format(getRadioText("HIND_Area_XYZ"), DropPointX, DropPointY)
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Area_"..AreaType)), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(DropPointText), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_DropType")), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_DropType_"..DropType)), c.r, c.g, c.b) )
        
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Area_ReXYZ")), c.r, c.g, c.b) )

        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Area_"..AreaType)), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(DropPointText), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_DropType")), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_DropType_"..DropType)), c.r, c.g, c.b))
    else
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Area_Fail1")), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Area_Fail2")), c.r, c.g, c.b) )
        _bc:AddRadioLine( RadioLine.new(comp(getRadioText("HIND_Area_Fail3")), c.r, c.g, c.b) )
    end
end

function AirDropRadio.AreaCount(AreaType)
    local AreaCount = 0
    if AreaType == "Muldraugh" then
        AreaCount = 23
    elseif AreaType == "WestPoint" then
        AreaCount = 11
    elseif AreaType == "Rosewood" then
        AreaCount = 9
    elseif AreaType == "Riverside" then
        AreaCount = 8
    elseif AreaType == "Brandenburg" then
        AreaCount = 12
    elseif AreaType == "Ekron" then
        AreaCount = 10
    elseif AreaType == "Irvington" then
        AreaCount = 10
    elseif AreaType == "MarchRidge" then
        AreaCount = 8
    elseif AreaType == "FallasLake" then
        AreaCount = 9
    elseif AreaType == "EchoCreek" then
        AreaCount = 8
    elseif AreaType == "Louisville" then
        AreaCount = 21
    end
    return AreaCount
end

