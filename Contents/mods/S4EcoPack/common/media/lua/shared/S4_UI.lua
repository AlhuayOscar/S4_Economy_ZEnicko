S4_UI = {}
S4_UI.FH_S = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
S4_UI.FH_M = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
S4_UI.FH_L = getTextManager():getFontFromEnum(UIFont.Large):getLineHeight()

-- Get computer main screen size
function S4_UI.getScreenSize()
    local Sw, Sh = getCore():getScreenWidth(), getCore():getScreenHeight()
    local width, height = 0, 0
    if Sw <= 1280 or Sh <= 720 then
        width = 720
        height = 480
    elseif Sw <= 1920 or Sh <= 1080 then -- FHD or lower
        width = 1280
        height = 720
    elseif Sw <= 2560 or Sh <= 1440 then -- QHD
        width = 1920
        height = 1080
    else -- 4K or higher 3840 2160
        width = 2560
        height = 1440
    end
    local x, y = (Sw / 2) - (width / 2), (Sh / 2) - (height / 2)
    return width, height, x, y
end

-- Get IE size
function S4_UI.getScreenSizeIE(ComUI)
    local Cw, Ch = ComUI:getWidth(), ComUI:getHeight()
    local UI_Font = S4_UI.getFontType(2)
    local Th = getTextManager():getFontFromEnum(UI_Font):getLineHeight() + 10
    local Ty = Ch - Th
    local width, height = Cw - 2, Ty
    return width, height
    -- if Cw == 1280 and Ch == 720 then
    --     width, height = 1280, 720
    -- elseif Cw == 1920 and Ch == 1080 then
    --     width, height = 1920, 1080
    -- elseif Cw == 2560 and Ch == 1440 then
    --     width, height = 2560, 1440
    -- end
end

-- ATM size
function S4_UI.getScreenSizeATM()
    local Sw, Sh = getCore():getScreenWidth(), getCore():getScreenHeight()
    local width, height = 0, 0
    if Sw <= 1280 or Sh <= 720 then
        width = 600
        height = 350
    elseif Sw <= 1920 or Sh <= 1080 then -- FHD or lower
        width = 850
        height = 500
    elseif Sw <= 2560 or Sh <= 1440 then -- QHD
        width = 1250
        height = 700
    else -- 4K or higher 3840 2160
        width = 1900
        height = 1050
    end
    local x, y = (Sw / 2) - (width / 2), (Sh / 2) - (height / 2)
    return width, height, x, y
end

-- GoodShop Size
function S4_UI.getGoodShopSize(ComUI)
    local width = ComUI:getWidth()
    local height = ComUI:getHeight()
    width = math.min(width, 1280)
    height = math.min(height, 720)
    width = width - 12
    height = height - ((S4_UI.FH_S * 2) + 22) - (height - ComUI.TaskBarY + 1)

    local Mx = (((S4_UI.FH_L * 3) + 20) * 2) + 20
    local My = (S4_UI.FH_S * 2) + 40
    local ListInfoH = S4_UI.FH_L + 40
    local Lw = width - Mx
    local Lh = height - My - ListInfoH
    local Bx, By = 10, 10
    local Bs = (S4_UI.FH_L * 3) + 10
    local SetW, SetH, Ic = 0, 0, 0
    for i = 1, 100 do
        if Bx + Bs + 10 > Lw then
            SetW = Bx + Mx
            Bx = 20 + Bs 
            By = By + Bs + 10
        else
            Bx = Bx + Bs + 10
        end
        if By + Bs + 10 > Lh then
            SetH = By + My + ListInfoH
            Ic = i - 1
            break
        end
    end
    return SetW, SetH, Ic
end

function S4_UI.getGoodShopSizeZ(ComUI)
    -- width = 1900
    -- height = 1050
    local width = ComUI:getWidth()
    local height = ComUI:getHeight()
    local TaskH = (height - ComUI.TaskBarY + 1)
    width = math.min(width, 1500)
    height = math.min(height, 1000)
    width = width - 12
    height = height - ((S4_UI.FH_S * 2) + 22) - TaskH
    local x = 70 + (S4_UI.FH_L * 6)
    local y = (S4_UI.FH_S * 2) + S4_UI.FH_L + 90
    local Bs = (S4_UI.FH_L * 3) + 20
    local Rx, Ry, Rc = 0, 0, 0
    for i = 1, 100 do
        if x + Bs + 10 > width then
            Rx = x - 10
            x = (S4_UI.FH_L * 6) + Bs + 90
            y = y + Bs + 10
        else
            x = x + Bs + 10
        end
        if y + Bs + 10 > height then
            Rc = i - 1
            Ry = y
            break
        end
    end
    return Rx, Ry, Rc
end

-- Import fonts
function S4_UI.getFontType(FontType)
    local ScreenWidth, ScreenHeight = getCore():getScreenWidth(), getCore():getScreenHeight()
    local FontS, FontM, FontL = S4_UI.FH_S, S4_UI.FH_M, S4_UI.FH_L
    local FontSetting = UIFont.Small
    local OverSize = false
    local MaxSize

    if ScreenWidth <= 1280 and ScreenHeight <= 720 then
        if FontType == 1 then
            MaxSize = 16
        elseif FontType == 2 then
            MaxSize = 26
        elseif FontType == 3 then
            MaxSize = 33
        end
    elseif ScreenWidth <= 1920 and ScreenHeight <= 1080 then -- FHD or lower
        if FontType == 1 then
            MaxSize = 26
        elseif FontType == 2 then
            MaxSize = 38
        elseif FontType == 3 then
            MaxSize = 45
        end
    elseif ScreenWidth <= 2560 and ScreenHeight <= 1440 then -- QHD
        if FontType == 1 then
            MaxSize = 33
        elseif FontType == 2 then
            MaxSize = 38
        elseif FontType == 3 then
            MaxSize = 45
        end
    else -- 4K and above
        if FontType == 1 then
            MaxSize = 38
        elseif FontType == 2 then
            MaxSize = 45
        elseif FontType == 3 then
            MaxSize = 45
        end
    end

    if FontL <= MaxSize then
        FontSetting = UIFont.Large
    elseif FontM <= MaxSize then
        FontSetting = UIFont.Medium
    elseif FontS <= MaxSize then
        FontSetting = UIFont.Small
    else
        FontSetting = UIFont.Small
        OverSize = true
    end

    return FontSetting, OverSize
end

-- string splitting
function S4_UI.SplitText(Text, MaxLength, Font)
    local textManager = getTextManager()
    local result = {}
    local currentLine = ""
    if not Font then
        Font = UIFont.Small
    end
    -- Separate text by space
    for word in Text:gmatch("%S+") do -- Measure word length with MeasureStringX
        local wordLength = textManager:MeasureStringX(Font, word)
        local FixWord = currentLine .. " " .. word
        if textManager:MeasureStringX(Font, FixWord) <= MaxLength then -- When adding a word to the current line, if it does not exceed the maximum length, it is added as is.
            if currentLine == "" then -- Add to first text face line
                currentLine = word
            else
                currentLine = currentLine .. " " .. word
            end
        else -- If the maximum length is exceeded, the previous line is appended to the result and the current line starts with the new word.
            
            table.insert(result, currentLine)
            currentLine = word
        end
    end
    
    if currentLine ~= "" then -- Add the last remaining lines
        table.insert(result, currentLine)
    end
    return result
end

-- String length limit
function S4_UI.TextLimit(Text, MaxString, Font)
    if not Font then Font = UIFont.Small end
    local TM = getTextManager()
    local NormalString = TM:MeasureStringX(Font, "...")

    local OutputText = ""
    if TM:MeasureStringX(Font, Text) <= MaxString then -- If the original text is less than the maximum length
        OutputText = Text
    else -- When text length is exceeded
        local FixWord = ""
        for CutWord in Text:gmatch("%S+") do -- Cut string by spacing
            if FixWord == "" then -- The first word is the same
                FixWord = CutWord
            else -- From the next word, add a space key and then add the word.
                FixWord = FixWord .. " " .. CutWord
            end

            if TM:MeasureStringX(Font, FixWord) + NormalString <= MaxString then -- After comparing the length of the string, if it is less than the length, the string is stored in the output value.
                OutputText = FixWord
            else -- When the length is exceeded, add ... to the previous Output value and end the function for statement.
                OutputText = OutputText .. "..."
                break
            end
        end
    end
    return OutputText
end

function S4_UI.TextLimitOne(Text, MaxString, Font)
    if not Font then Font = UIFont.Small end
    local TM = getTextManager()
    local NormalString = TM:MeasureStringX(Font, "...")

    local OutputText = ""
    if TM:MeasureStringX(Font, Text) <= MaxString then -- If the original text is less than the maximum length
        OutputText = Text
    else -- When text length is exceeded
        local FixWord = ""
        for CutWord in Text:gmatch(".") do -- Cut string by spacing
            if FixWord == "" then -- The first word is the same
                FixWord = CutWord
            else -- From the next word, add a space key and then add the word.
                FixWord = FixWord .. CutWord
            end

            if TM:MeasureStringX(Font, FixWord) + NormalString <= MaxString then -- After comparing the length of the string, if it is less than the length, the string is stored in the output value.
                OutputText = FixWord
            else -- When the length is exceeded, add ... to the previous Output value and end the function for statement.
                OutputText = OutputText .. "..."
                break
            end
        end
    end
    return OutputText
end
-- Numeric string removal function
function S4_UI.getFixPasswordNum(Text)
    if Text == "" then Text = "0" end
    local filteredText = Text:gsub("[^%d]", "")
    if filteredText == "" then filteredText = "0" end
    filteredText = filteredText:gsub("^0+", "")
    if filteredText == "" then filteredText = "0" end
    local Number = tonumber(filteredText)
    return filteredText, Number
end

-- Code to remove text spaces and verify
function S4_UI.getTextValid(TextTable)
    for i, text in ipairs(TextTable) do
        local Clean = text:gsub("%s+", "")
        if Clean == "" then
            return false
        end
    end
    return true
end
-- Space removal function
function S4_UI.RemoveTextValid(Text)
    local FixText = Text:gsub("%s+", "")
    return FixText
end


-- computer time
-- function S4_UI.getComputerTime(Check)
--     local Hour = GameTime.getInstance():getHour()
--     local Minutes = GameTime.getInstance():getMinutes()
--     local DisplayTime = ""
--     if Check then
--         DisplayTime = string.format("%02d:%02d", Hour, Minutes)
--     else
--         local Text = getText("IGUI_S4_COM_AM")
--         if Hour == 12 then
--             Text = getText("IGUI_S4_COM_PM")
--         elseif Hour > 12 then
--             Text = getText("IGUI_S4_COM_PM")
--             Hour = Hour - 12
--         end
--         DisplayTime = Text .. " " .. string.format("%02d:%02d", Hour, Minutes)
--     end
--     return DisplayTime
-- end
function S4_UI.getComputerTime(Check)
    local Hour = GameTime.getInstance():getHour()
    local Minutes = GameTime.getInstance():getMinutes()
    local DisplayTime = ""

    if Check then
        DisplayTime = string.format("%02d:%02d", Hour, Minutes)
    else
        local Text = getText("IGUI_S4_COM_AM")
        
        if Hour == 0 then -- 0 o'clock is 12 o'clock in the morning
            Hour = 12
            Text = getText("IGUI_S4_COM_AM")
        elseif Hour == 12 then -- 12 o'clock is 12 p.m.
            Text = getText("IGUI_S4_COM_PM")
        elseif Hour > 12 then -- 13:00 - 23:00 is PM, minus 12
            Hour = Hour - 12
            Text = getText("IGUI_S4_COM_PM")
        else -- 1 to 11 am
            Text = getText("IGUI_S4_COM_AM")
        end

        DisplayTime = Text .. " " .. string.format("%02d:%02d", Hour, Minutes)
    end

    return DisplayTime
end

-- Function to add a comma to a number
function S4_UI.getNumCommas(number)
    if not number or type(number) ~= "number" then return "0" end
    local isNegative = number < 0
    local numStr = tostring(math.abs(number))  -- Absolute value processing
    local formatted = numStr:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end
    if isNegative then
        formatted = "-" .. formatted
    end
    return formatted
end