S4_IE_KarmaAdmin = ISPanel:derive("S4_IE_KarmaAdmin")

function S4_IE_KarmaAdmin:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.IEUI = IEUI
    o.player = IEUI.player
    return o
end

function S4_IE_KarmaAdmin:initialise()
    ISPanel.initialise(self)
end

function S4_IE_KarmaAdmin:createChildren()
    ISPanel.createChildren(self)
    self:rebuildUI()
end

function S4_IE_KarmaAdmin:rebuildUI()
    if self.ContentList then
        self:removeChild(self.ContentList)
    end
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.ContentList = ISPanel:new(0, 0, w, h)
    self.ContentList.backgroundColor = {r=0.1, g=0.1, b=0.1, a=1}
    self:addChild(self.ContentList)
    
    self.ContentList:addChild(ISLabel:new(10, 10, S4_UI.FH_L, "S4 Economy - Karma & Stats Admin Tool", 1, 1, 1, 1, UIFont.Large, true))
    self.ContentList:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "WARNING: This tool edits live ModData directly.", 1, 0.2, 0.2, 1, UIFont.Small, true))
    
    local stats = S4_PlayerStats.getStats(self.player)
    
    local y = 80
    
    -- KARMA SEC
    self.ContentList:addChild(ISLabel:new(10, y, S4_UI.FH_M, "Current Karma: " .. stats.Karma, 0.8, 0.8, 1, 1, UIFont.Medium, true))
    
    local bKarmaPlus10 = ISButton:new(200, y - 5, 80, 30, "+10", self, S4_IE_KarmaAdmin.onKPlus)
    bKarmaPlus10:initialise()
    bKarmaPlus10:initialise(); self.ContentList:addChild(bKarmaPlus10)
    
    local bKarmaMinus10 = ISButton:new(290, y - 5, 80, 30, "-10", self, S4_IE_KarmaAdmin.onKMinus)
    bKarmaMinus10:initialise()
    bKarmaMinus10:initialise(); self.ContentList:addChild(bKarmaMinus10)
    
    local bKarmaReset = ISButton:new(380, y - 5, 80, 30, "Reset (0)", self, S4_IE_KarmaAdmin.onKReset)
    bKarmaReset:initialise()
    bKarmaReset:initialise(); self.ContentList:addChild(bKarmaReset)
    
    y = y + 50
    self.ContentList:addChild(ISLabel:new(10, y, S4_UI.FH_M, "Faction Reputations", 0.8, 0.8, 1, 1, UIFont.Medium, true))
    y = y + 40
    
    for faction, rep in pairs(stats.Factions) do
        self.ContentList:addChild(ISLabel:new(20, y, S4_UI.FH_S, faction .. ": " .. rep, 1, 1, 1, 1, UIFont.Small, true))
        
        local bFPlus = ISButton:new(200, y - 5, 60, 25, "+10", self, S4_IE_KarmaAdmin.onFPlus)
        bFPlus:initialise()
        bFPlus.internal = faction; bFPlus:initialise(); self.ContentList:addChild(bFPlus)

        local bFMinus = ISButton:new(270, y - 5, 60, 25, "-10", self, S4_IE_KarmaAdmin.onFMinus)
        bFMinus:initialise()
        bFMinus.internal = faction; bFMinus:initialise(); self.ContentList:addChild(bFMinus)
        
        y = y + 40
    end
    
    y = y + 20
    self.ContentList:addChild(ISLabel:new(10, y, S4_UI.FH_M, "Test Scenarios / Decisions", 0.8, 0.8, 1, 1, UIFont.Medium, true))
    y = y + 40
    
    local bDecA = ISButton:new(10, y, 200, 30, "Trigger 'Fled Ambush'", self, S4_IE_KarmaAdmin.onDec1)
    bDecA:initialise()
    bDecA:initialise(); self.ContentList:addChild(bDecA)
    
    local bDecB = ISButton:new(220, y, 200, 30, "Trigger 'Saved Trader'", self, S4_IE_KarmaAdmin.onDec2)
    bDecB:initialise()
    bDecB:initialise(); self.ContentList:addChild(bDecB)
    
    y = y + 40
    self.ContentList:addChild(ISLabel:new(10, y, S4_UI.FH_M, "Logistics & Commerce Tests", 0.8, 0.8, 1, 1, UIFont.Medium, true))
    y = y + 40
    
    local bSpawnWH = ISButton:new(10, y, 200, 30, "Spawn Test Warehouse", self, S4_IE_KarmaAdmin.onSpawnWH)
    bSpawnWH:initialise()
    bSpawnWH:initialise(); self.ContentList:addChild(bSpawnWH)
    
    local bAddStock = ISButton:new(220, y, 200, 30, "Add 10 SPIFF Stocks", self, S4_IE_KarmaAdmin.onAddStock)
    bAddStock:initialise()
    bAddStock:initialise(); self.ContentList:addChild(bAddStock)
    
    local bRemStock = ISButton:new(430, y, 200, 30, "Remove 10 SPIFF Stocks", self, S4_IE_KarmaAdmin.onRemStock)
    bRemStock:initialise()
    bRemStock:initialise(); self.ContentList:addChild(bRemStock)
end

function S4_IE_KarmaAdmin:onKPlus()
    S4_PlayerStats.addKarma(self.player, 10)
    self:rebuildUI()
end
function S4_IE_KarmaAdmin:onKMinus()
    S4_PlayerStats.addKarma(self.player, -10)
    self:rebuildUI()
end
function S4_IE_KarmaAdmin:onKReset()
    local d = S4_PlayerStats.getStats(self.player)
    d.Karma = 0
    if isClient() then ModData.transmit("S4_Economy_SocialStats") end
    self:rebuildUI()
end

function S4_IE_KarmaAdmin:onFPlus(btn)
    S4_PlayerStats.addFactionRep(self.player, btn.internal, 10)
    self:rebuildUI()
end
function S4_IE_KarmaAdmin:onFMinus(btn)
    S4_PlayerStats.addFactionRep(self.player, btn.internal, -10)
    self:rebuildUI()
end

function S4_IE_KarmaAdmin:onDec1(btn)
    S4_PlayerStats.addDecision(self.player, "Fled Ambush", true)
    self:rebuildUI()
end
function S4_IE_KarmaAdmin:onDec2(btn)
    S4_PlayerStats.addDecision(self.player, "Saved Trader", true)
    S4_PlayerStats.addFactionRep(self.player, "TraderUnion", 15)
    S4_PlayerStats.addKarma(self.player, 10)
    self:rebuildUI()
end

function S4_IE_KarmaAdmin:onSpawnWH(btn)
    local randomId = "testWH_" .. tostring(ZomboidRand(1000, 9999))
    S4_PlayerStats.addWarehouse(self.player, randomId, "Debug Storage Alpha", 1000, "Muldraugh")
    S4_PlayerStats.updateWarehouseUsage(self.player, randomId, ZomboidRand(100, 800))
    self.ComUI:AddMsgBox("Test Data Added", false, "Created debug warehouse in Logistics system.", false, false)
end

function S4_IE_KarmaAdmin:onAddStock(btn)
    S4_PlayerStats.addStock(self.player, "SPIFF", 10)
    self.ComUI:AddMsgBox("Test Data Added", false, "+10 SPIFF added to portfolio.", false, false)
end

function S4_IE_KarmaAdmin:onRemStock(btn)
    S4_PlayerStats.addStock(self.player, "SPIFF", -10)
    self.ComUI:AddMsgBox("Test Data Removed", false, "-10 SPIFF removed from portfolio.", false, false)
end

function S4_IE_KarmaAdmin:render()
    ISPanel.render(self)
end
