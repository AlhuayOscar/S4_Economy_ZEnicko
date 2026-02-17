S4_Booting_Sequence = ISPanel:derive("S4_Booting_Sequence")
S4_Booting_Sequence.instance = nil

local Step1Text = {
    "HINDsoftBIOS 1.0 Release 1.1",
    "Copyright 1986-1999 HINDsoft Technologies Corporation.",
    "All Rights Reserverd",
    "Copyright 1986-1999 Zomtel Corporation.",
    "S4ECOX1.01A.1988.P01",

    "HINDsoft Dimension ZXP Z300",
    "BIOS Version 01A",
    "Zomtel(R) Zomtium(R) II processor 300 MHz",
    "128MB System RAM Passed",
}

function S4_Booting_Sequence:show(player, ComObj)
    local square = player:getSquare()
    posX = square:getX()
    posY = square:getY()
    if S4_Booting_Sequence.instance == nil then
        S4_Booting_Sequence.instance = S4_Booting_Sequence:new(player, ComObj)
        S4_Booting_Sequence.instance:initialise()
        S4_Booting_Sequence.instance:instantiate()
    end
    S4_Booting_Sequence.instance:addToUIManager()
    S4_Booting_Sequence.instance:setVisible(true)
    return S4_Booting_Sequence.instance
end

function S4_Booting_Sequence:new(player, ComObj)
    local o = {}
    local width, height, x, y = S4_UI.getScreenSize()
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player 
    o.ComObj = ComObj
    o.backgroundColor = {r=0/255, g=0/255, b=0/255, a=1}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.moveWithMouse = true
    o:setWantKeyEvents(true)
    return o
end

function S4_Booting_Sequence:initialise()
    ISPanel.initialise(self)
    self:BootingSequence()
end

function S4_Booting_Sequence:createChildren()
    ISPanel.createChildren(self)

end

function S4_Booting_Sequence:render()
    ISPanel.render(self)

    local UI_Font = S4_UI.getFontType(2)
    local UI_Font_Height = getTextManager():getFontFromEnum(UI_Font):getLineHeight()

    local Ew = self:getWidth() - getTextManager():MeasureStringX(UI_Font, "[Esc] Shutdown") - 10
    local Eh = self:getHeight() - UI_Font_Height - 10
    if self.Step1 or self.Step2 then
        self:drawText("[Esc] Shutdown", Ew, Eh, 1, 1, 1, 0.8, UI_Font)
    end

    if self.Step1 then
        local TextY = 0
        for TextNum, Text in ipairs(Step1Text) do
            if TextNum == 1 then
                TextY = TextY + 20
            elseif TextNum == 6 then
                TextY = TextY + UI_Font_Height + 20
            else
                TextY = TextY + UI_Font_Height
            end
            self:drawText(Text, 20, TextY, 1, 1, 1, 1, UI_Font)
        end
        
        if self.Step1n1 then
            TextY = TextY + UI_Font_Height + 20
            self:drawText("Keyboard .......... Detected", 20, TextY, 1, 1, 1, 1, UI_Font)
        end
        if self.Step1n2 then
            TextY = TextY + UI_Font_Height
            self:drawText("Mouse ............. Detected", 20, TextY, 1, 1, 1, 1, UI_Font)
        end
        if self.Step1n3 then
            TextY = TextY + UI_Font_Height + 20
            self:drawText("Fixed Disk 0: WDC ZD100ED-00100G-(PM)", 20, TextY, 1, 1, 1, 1, UI_Font)
        end
    elseif self.Step2 then
        self:drawTextureScaled(getTexture("media/textures/S4_Img/Img_BootingScreen.png"), 0, 0, self:getWidth(), self:getHeight(), 1)
    end
    
end

function S4_Booting_Sequence:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        -- Turn off the computer
        local ComData = self.ComObj:getModData()
        if ComData then
            ComData.ComPower = false
            S4_Utils.SnycObject(self.ComObj)
        end
        self:close()
    end
end

function S4_Booting_Sequence:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function S4_Booting_Sequence:BootingSequence()
    local UpdataCount = 0
    self.UICheck = true
    local ComData = self.ComObj:getModData()
    local function BootingUpdate()
        UpdataCount = UpdataCount + 1
        if not self.UICheck then 
            Events.OnTick.Remove(BootingUpdate)
            return
        end
        local Second = PerformanceSettings.getLockFPS()
        if UpdataCount == Second * 0.5 then
            if ComData and ComData.ComPower then
                self:PasswordCheck()
                Events.OnTick.Remove(BootingUpdate)
            else
                getSoundManager():playUISound("S4_Beep")
                return
            end     
        elseif UpdataCount == Second * 1 then
            self.Step1 = true
            -- Computer power on
            if ComData then
                ComData.ComPower = true
                S4_Utils.SnycObject(self.ComObj)
            end
            return
        elseif UpdataCount == Second * 5 then
            self.Step1n1 = true
            return
        elseif UpdataCount == Second * 6 then
            self.Step1n2 = true
            return
        elseif UpdataCount == Second * 7 then
            self.Step1n3 = true
            return
        elseif UpdataCount == Second * 10 then
            -- Add beep sound
            getSoundManager():playUISound("S4_Beep")
            self.Step1 = false
            return
        elseif UpdataCount == Second * 11 then
            getSoundManager():playUISound("S4_BootingSound")
            self.Step2 = true
            return
        elseif UpdataCount == Second * 20 then
            Events.OnTick.Remove(BootingUpdate)
            self.Step2 = false

            -- Go to computer password confirmation function
            self:PasswordCheck()
        end
    end
    -- if Check computer power else Go to computer password check function
    Events.OnTick.Add(BootingUpdate)
end

function S4_Booting_Sequence:PasswordCheck()
    self.borderColor = { r = 0, g = 0, b = 0, a = 1 }
    self.backgroundColor = {r=0/255, g=128/255, b=128/255, a=1}

    local ComData = self.ComObj:getModData()
    if ComData and ComData.ComLock then
        self.ComPassword = ComData.ComPassword
        self.PasswordUI = S4_Booting_PasswordUI:new(self)
        self.PasswordUI.TitleName = "Welcome to Windows"
        self.PasswordUI:initialise()
        self.PasswordUI:instantiate()
        self:addChild(self.PasswordUI)
    else
        -- Computer main screen show
        local x, y = self:getX(), self:getY()
        local OpenUI = S4_Computer_Main:show(self.player, self.ComObj, x, y)
        self:close()
    end

end

function S4_Booting_Sequence:AddMsgBox(MsgTitle, Msg)
    local MsgBox = S4_Booting_MsgBox:new(self)
    MsgBox.TitleName = MsgTitle
    MsgBox.MsgText = Msg
    MsgBox:initialise()
    MsgBox:instantiate()
    self:addChild(MsgBox)
end

function S4_Booting_Sequence:close()
    S4_Booting_Sequence.instance = nil
    self.UICheck = false
    ISPanel.close(self)
    self:removeFromUIManager()
end
