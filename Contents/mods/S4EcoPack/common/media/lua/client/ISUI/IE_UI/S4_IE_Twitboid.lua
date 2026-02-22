S4_IE_Twitboid = ISPanel:derive("S4_IE_Twitboid")

function S4_IE_Twitboid:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=29/255, g=161/255, b=242/255, a=0.1} -- Twitter blue tint
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.posts = {}
    return o
end

function S4_IE_Twitboid:initialise()
    ISPanel.initialise(self)
    self:generateFeed()
end

function S4_IE_Twitboid:generateFeed()
    -- Some static/dynamic posts
    table.insert(self.posts, {user="@Spiffo", text="Don't forget to wash your hands! Safety first!", time="2m"})
    table.insert(self.posts, {user="@Survivr1", text="Anyone seen the helicopter? It's been hovering over Muldraugh for an hour.", time="15m"})
    table.insert(self.posts, {user="@General_Mcgrew", text="Martial law is in effect. Stay indoors. Do not approach the exclusion zone.", time="1h"})
    table.insert(self.posts, {user="@Chef_Louis", text="I found a working stove! Rat stew is back on the menu boys!", time="3h"})
    
    local stats = S4_PlayerStats.getStats(self.player)
    if stats.Karma > 50 then
        table.insert(self.posts, {user="@Civilian_Aid", text="Rumors of a hero in the area... someone is actually helping for once.", time="4h"})
    elseif stats.Karma < -50 then
        table.insert(self.posts, {user="@Survivor_Network", text="WARNING: A dangerous individual has been spotted. Avoid contact at all costs.", time="4h"})
    end
end

function S4_IE_Twitboid:createChildren()
    ISPanel.createChildren(self)
    
    local x = 10
    local y = 10
    
    -- Banner
    self.Banner = ISPanel:new(0, 0, self:getWidth(), 40)
    self.Banner.backgroundColor = {r=29/255, g=161/255, b=242/255, a=1}
    self:addChild(self.Banner)
    
    self.LogoLabel = ISLabel:new(20, 10, S4_UI.FH_M, "Twitboid / Home", 1, 1, 1, 1, UIFont.Medium, true)
    self.Banner:addChild(self.LogoLabel)
    
    y = 50
    -- Feed
    for i, post in ipairs(self.posts) do
        local postPanel = ISPanel:new(10, y, self:getWidth() - 20, 60)
        postPanel.backgroundColor = {r=1, g=1, b=1, a=0.9}
        postPanel.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
        self:addChild(postPanel)
        
        local uLabel = ISLabel:new(10, 5, S4_UI.FH_S, post.user .. " • " .. post.time, 0.1, 0.5, 0.9, 1, UIFont.Small, true)
        postPanel:addChild(uLabel)
        
        local tLabel = ISLabel:new(10, 25, S4_UI.FH_S, post.text, 0, 0, 0, 1, UIFont.Small, false)
        postPanel:addChild(tLabel)
        
        y = y + 70
    end
end

function S4_IE_Twitboid:render()
    ISPanel.render(self)
end
