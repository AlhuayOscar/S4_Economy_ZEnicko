S4_IE_Mail = ISPanel:derive("S4_IE_Mail")

function S4_IE_Mail:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=230/255, g=230/255, b=235/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    return o
end

function S4_IE_Mail:initialise()
    ISPanel.initialise(self)
end

function S4_IE_Mail:createChildren()
    ISPanel.createChildren(self)
    
    local padding = 20
    local title = ISLabel:new(padding, padding, 25, "Inbox - S4 Secure Mail", 0.1, 0.1, 0.2, 1, UIFont.Large, true)
    self:addChild(title)
    
    local userName = self.player:getUsername()
    local playerData = ModData.get("S4_PlayerData") and ModData.get("S4_PlayerData")[userName]
    
    local pendingRewards = (playerData and playerData.PendingMissionRewards) or 0
    local pendingCount = (playerData and playerData.PendingMissionCount) or 0
    
    if pendingRewards > 0 then
        -- Mail Container
        local mailW = self:getWidth() - (padding * 2)
        local mailH = 150
        self.MailPanel = ISPanel:new(padding, 60, mailW, mailH)
        self.MailPanel.backgroundColor = {r=1, g=1, b=1, a=1}
        self.MailPanel.borderColor = {r=0.7, g=0.7, b=0.8, a=1}
        self:addChild(self.MailPanel)
        
        local from = ISLabel:new(10, 10, 20, "From: S4 Pager Command", 0.2, 0.2, 0.2, 1, UIFont.Medium, true)
        self.MailPanel:addChild(from)
        
        local subject = ISLabel:new(10, 35, 20, "Subject: Pending Mission Rewards Transfer", 0, 0, 0, 1, UIFont.Medium, true)
        self.MailPanel:addChild(subject)
        
        local body = string.format("Agent %s,\n\nWe have successfully logged %d completed operations.\nDue to the lack of an active bank account during those operations,\nyour rewards have been held in escrow.\n\nTotal Pending Balance: $%d", 
                        userName, pendingCount, pendingRewards)
        
        local bodyLabel = ISLabel:new(10, 65, 20, body, 0.3, 0.3, 0.3, 1, UIFont.Small, true)
        self.MailPanel:addChild(bodyLabel)
        
        self.BtnClaim = ISButton:new(mailW - 130, mailH - 40, 120, 30, "Claim Rewards", self, self.onClaim)
        self.BtnClaim.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
        self.BtnClaim.textColor = {r=1, g=1, b=1, a=1}
        self.MailPanel:addChild(self.BtnClaim)
    else
        local noMail = ISLabel:new(padding, 70, 20, "Your inbox is empty.", 0.5, 0.5, 0.5, 1, UIFont.Medium, true)
        self:addChild(noMail)
    end
end

function S4_IE_Mail:onClaim(btn)
    sendClientCommand("S4ED", "ClaimPendingMissionRewards", {})
    -- Refresh UI after claim
    self:clearChildren()
    self:createChildren()
end

function S4_IE_Mail:render()
    ISPanel.render(self)
end
