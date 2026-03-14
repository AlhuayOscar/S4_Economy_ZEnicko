S4_IE_MyDoc = ISPanel:derive("S4_IE_MyDoc")

function S4_IE_MyDoc:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    -- Tech/CRT background color
    o.backgroundColor = {r=0.02, g=0.08, b=0.05, a=1}
    o.borderColor = {r=0, g=0.6, b=0.4, a=0.8}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_MyDoc:initialise()
    ISPanel.initialise(self)
end

function S4_IE_MyDoc:createChildren()
    ISPanel.createChildren(self)
    local margin = 20
    local pWidth = self:getWidth()
    local pHeight = self:getHeight()
    self.DocPanel = ISPanel:new(margin, margin, pWidth - (margin * 2), pHeight - (margin * 2))
    self.DocPanel.backgroundColor = {r=0, g=0.05, b=0.02, a=0.8}
    self.DocPanel.borderColor = {r=0.2, g=0.8, b=0.6, a=0.5}
    self:addChild(self.DocPanel)

    self.DocPanel:addChild(ISLabel:new(20, 15, S4_UI.FH_L, "MY DOCUMENTS", 0.5, 1, 0.8, 1, UIFont.Large, true))
    self.DocPanel:addChild(ISLabel:new(20, 60, S4_UI.FH_M, "Personal Files", 0.8, 0.9, 0.8, 1, UIFont.Medium, true))
    self.DocPanel:addChild(ISLabel:new(35, 100, S4_UI.FH_S, "- Notes.txt", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    self.DocPanel:addChild(ISLabel:new(35, 125, S4_UI.FH_S, "- Contacts.txt", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    self.DocPanel:addChild(ISLabel:new(35, 150, S4_UI.FH_S, "- Delivery Addresses.txt", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    self.DocPanel:addChild(ISLabel:new(35, 175, S4_UI.FH_S, "- Bank Records.txt", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    self.DocPanel:addChild(ISLabel:new(20, 230, S4_UI.FH_S, "No shared reputation or karma data is displayed on this page.", 0.6, 0.8, 1, 1, UIFont.Small, true))
end

function S4_IE_MyDoc:render()
    ISPanel.render(self)
    
    -- CRT scanlines effect (simple alternating rows or overlay block)
    -- This makes it look like Zomdows 88
    local w = self:getWidth()
    local h = self:getHeight()
    
    local numLines = math.floor(h / 4)
    for i=0, numLines do
        self:drawRect(0, i*4, w, 1, 0.05, 0, 0, 0)
    end
end
