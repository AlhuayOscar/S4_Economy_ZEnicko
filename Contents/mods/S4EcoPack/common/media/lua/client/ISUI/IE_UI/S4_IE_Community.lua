S4_IE_Community = ISPanel:derive("S4_IE_Community")

function S4_IE_Community:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.9, g=0.9, b=0.88, a=1} -- Gov paper theme
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
    self.Banner.backgroundColor = {r=0.2, g=0.3, b=0.4, a=1}
    self.Banner.borderColor = {r=0.1, g=0.2, b=0.3, a=1}
    self:addChild(self.Banner)
    
    self.Banner:addChild(ISLabel:new(20, 10, S4_UI.FH_L, "KNOX MUNICIPALITY - COMMUNITY HUB", 1, 1, 1, 1, UIFont.Large, true))
    self.Banner:addChild(ISLabel:new(20, 35, S4_UI.FH_S, "Exclusive voting and announcements for active tax-paying citizens.", 0.8, 0.8, 0.9, 1, UIFont.Small, true))

    self.ContentArea = ISPanel:new(10, 70, w - 20, h - 80)
    self.ContentArea.backgroundColor = {r=0.95, g=0.95, b=0.92, a=1}
    self:addChild(self.ContentArea)
    
    local y = 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_L, "Active Government Proposals:", 0.2, 0.2, 0.2, 1, UIFont.Large, true))
    y = y + 40
    
    local proposals = {
        {
            title = "Prop 104: Controlled Demolition of West Point Bridge",
            desc = "Vote to clear the zombie blockade using C4 charges. Will affect regional transit.",
            votesYes = 142, votesNo = 89
        },
        {
            title = "Prop 105: Emergency ZomBank Inflation Adjustment Law",
            desc = "Increase base prices by 15% to stabilize the local Knox currency.",
            votesYes = 210, votesNo = 340
        }
    }
    
    for _, prop in ipairs(proposals) do
        local pnl = ISPanel:new(20, y, self.ContentArea:getWidth() - 40, 80)
        pnl.backgroundColor = {r=1, g=1, b=1, a=1}
        pnl.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
        self.ContentArea:addChild(pnl)
        
        pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, prop.title, 0.1, 0.2, 0.5, 1, UIFont.Medium, true))
        pnl:addChild(ISLabel:new(10, 35, S4_UI.FH_S, prop.desc, 0.3, 0.3, 0.3, 1, UIFont.Small, true))
        
        local stat = ISLabel:new(10, 55, S4_UI.FH_S, "Current Polls: YES ("..prop.votesYes..") | NO ("..prop.votesNo..")", 0.4, 0.4, 0.4, 1, UIFont.Small, true)
        pnl:addChild(stat)
        
        local btnYes = ISButton:new(pnl:getWidth() - 150, 20, 60, 30, "Vote YES", self, S4_IE_Community.onVote)
        btnYes.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
        btnYes.textColor = {r=1, g=1, b=1, a=1}
        pnl:addChild(btnYes)

        local btnNo = ISButton:new(pnl:getWidth() - 80, 20, 60, 30, "Vote NO", self, S4_IE_Community.onVote)
        btnNo.backgroundColor = {r=0.8, g=0.2, b=0.2, a=1}
        btnNo.textColor = {r=1, g=1, b=1, a=1}
        pnl:addChild(btnNo)
        
        y = y + 90
    end
    
    y = y + 20
    self.ContentArea:addChild(ISLabel:new(20, y, S4_UI.FH_M, "Citizen Status: DELINQUENT", 0.8, 0.1, 0.1, 1, UIFont.Medium, true))
    self.ContentArea:addChild(ISLabel:new(20, y + 25, S4_UI.FH_S, "Note: You must pay your taxes inside the Regional Taxes app to cast votes.", 0.4, 0.4, 0.4, 1, UIFont.Small, true))
end

function S4_IE_Community:onVote(btn)
    self.ComUI:AddMsgBox("Authorization Denied", false, "Your taxes are currently unpaid. Voting privileges revoked.", false, false)
end

function S4_IE_Community:render()
    ISPanel.render(self)
end
