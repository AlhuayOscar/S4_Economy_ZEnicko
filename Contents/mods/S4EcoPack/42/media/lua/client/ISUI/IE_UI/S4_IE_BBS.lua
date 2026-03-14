S4_IE_BBS = ISPanel:derive("S4_IE_BBS")

function S4_IE_BBS:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=1} -- Terminal Black
    o.borderColor = {r=0.2, g=0.8, b=0.2, a=1} -- Terminal Green
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_BBS:initialise()
    ISPanel.initialise(self)
end

function S4_IE_BBS:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- Banner (BBS ANSI Art style)
    self.Banner = ISPanel:new(0, 0, w, 80)
    self.Banner.backgroundColor = {r=0.05, g=0.1, b=0.05, a=1}
    self.Banner.borderColor = {r=0, g=1, b=0, a=0.5}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "=== KNOX TELECOM B.B.S. v4.2 ===", 0, 1, 0, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 40, S4_UI.FH_S, "> CONNECTION ESTABLISHED... 14400 BAUD", 0, 0.8, 0, 1, UIFont.Small, true))
    self.Banner:addChild(ISLabel:new(20, 55, S4_UI.FH_S, "> DOWNLOADING FILE LIST... OK", 0, 0.8, 0, 1, UIFont.Small, true))

    self.ContentArea = ISScrollingListBox:new(10, 90, w - 20, h - 100)
    self.ContentArea.backgroundColor = {r=0, g=0, b=0, a=1}
    self.ContentArea:initialise()
    self.ContentArea:instantiate()
    self:addChild(self.ContentArea)
    
    local y = 10
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "FILE DIRECTORY [SHAREWARE & UTILITIES]:", 0, 1, 0, 1, UIFont.Medium, true))
    y = y + 40
    
    local apps = {
        {file="COMMHUB.EXE", name="Knox Community Hub", size="1.2 MB", desc="Access municipal voting and local ad boards."},
        {file="FARMWTCH.ZIP", name="FarmWatch Agrosystems", size="4.5 MB", desc="Satellite crop monitor (Requires Sub)."},
        {file="RECON_V2.EXE", name="Recon & Survival Mapping", size="8.1 MB", desc="Tactical sweeps for Zed/Loot/Animals."},
        {file="WEATHER.COM", name="Knox Weather Predictor", size="500 KB", desc="7-Day meteorological forecasts."},
        {file="LOGISTIC.DAT", name="S4 Logistics & Commerce", size="3.2 MB", desc="Manage remote cargo and corporate stocks."},
        {file="RECOVER.EXE", name="Body Recovery Service", size="2.0 MB", desc="Hire mercenaries to retrieve your items."}
    }
    
    for _, app in ipairs(apps) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 60)
        pnl.backgroundColor = {r=0.05, g=0.2, b=0.05, a=0.3}
        pnl.borderColor = {r=0, g=0.6, b=0, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_S, "[" .. app.file .. "]", 0.5, 1, 0.5, 1, UIFont.Small, true))
        pnl:addChild(ISLabel:new(130, 8, S4_UI.FH_M, app.name, 0, 1, 0, 1, UIFont.Medium, true))
        pnl:addChild(ISLabel:new(130, 30, S4_UI.FH_S, app.desc, 0, 0.8, 0, 1, UIFont.Small, true))
        
        pnl:addChild(ISLabel:new(pnl:getWidth() - 220, 20, S4_UI.FH_S, "Size: " .. app.size, 0, 0.8, 0, 1, UIFont.Small, true))
        
        local downBtn = ISButton:new(pnl:getWidth() - 130, 15, 120, 30, "DOWNLOAD", self, S4_IE_BBS.onDownload)
        downBtn.backgroundColor = {r=0, g=0.5, b=0, a=1}
        downBtn.textColor = {r=0, g=1, b=0, a=1}
        downBtn:initialise()
        pnl:addChild(downBtn)
        
        y = y + 70
    end
    self.ContentArea:setScrollHeight(y + 20)
end

function S4_IE_BBS:onDownload(btn)
    self.ComUI:AddMsgBox("BBS Transfer", false, "Aviso: Software is already installed on the Local Disk C:/", false, false)
end

function S4_IE_BBS:render()
    ISPanel.render(self)
end
