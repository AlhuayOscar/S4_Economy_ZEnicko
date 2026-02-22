S4_IE_Community = ISPanel:derive("S4_IE_Community")

function S4_IE_Community:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.9, g=0.9, b=0.85, a=1} -- Public board beige
    o.borderColor = {r=0.4, g=0.3, b=0.2, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Community:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Community:createChildren()
    ISPanel.createChildren(self)
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    self.Banner = ISPanel:new(0, 0, w, 60)
    self.Banner.backgroundColor = {r=0.6, g=0.2, b=0.2, a=1}
    self.Banner.borderColor = {r=0.4, g=0.1, b=0.1, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "KNOX COMMUNITY BOARD", 1, 1, 1, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Find jobs, trade rumors, and connect with survivors.", 0.8, 0.8, 0.8, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.95, g=0.95, b=0.92, a=1}
    self:addChild(self.ContentArea)
    
    -- Notices
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Recent Public Notices:", 0.2, 0.2, 0.2, 1, UIFont.Medium, true))
    y = y + 30
    
    local notices = {
        "[Looking for Group] Anyone alive in Riverside? Need medical supplies.",
        "[Warning] Huge horde spotted migrating near West Point bridge.",
        "[Trade] Will trade 5 boxes of 9mm for a working generator."
    }
    
    for _, txt in ipairs(notices) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 40)
        pnl.backgroundColor = {r=1, g=1, b=1, a=1}
        pnl.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_S, txt, 0.3, 0.3, 0.3, 1, UIFont.Small, true))
        
        local replyBtn = ISButton:new(pnl:getWidth() - 80, 5, 70, 30, "Reply", self, S4_IE_Community.onDebug)
        pnl:addChild(replyBtn)
        
        y = y + 50
    end
    
    local postBtn = ISButton:new(20, y + 20, 200, 30, "Post New Notice ($50)", self, S4_IE_Community.onDebug)
    self.ContentArea:addChild(postBtn)
end

function S4_IE_Community:onDebug(btn)
    self.ComUI:AddMsgBox("Network Notice", false, "[DEBUG] Community functionality triggered.", false, false)
end

function S4_IE_Community:render()
    ISPanel.render(self)
end
