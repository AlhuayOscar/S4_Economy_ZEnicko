S4_IE_Twitboid = ISPanel:derive("S4_IE_Twitboid")

function S4_IE_Twitboid:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=15/255, g=20/255, b=25/255, a=1} -- Dark mode 
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.posts = {}
    return o
end

function S4_IE_Twitboid:initialise()
    ISPanel.initialise(self)
    self:syncFeed()
end

-- Genera un feed basado en estado del juego
function S4_IE_Twitboid:syncFeed()
    self.posts = {}
    
    local isHeliActive = getSoundManager():isListenerInRange(0,0,0) -- placeholder check 
    
    table.insert(self.posts, {user="@KnoxGov", name="Knox Response", text="Stay inside your homes. Do not attempt to breach\nthe exclusion zone. Our military personnel have\nthe situation under control.", time="12h", verified=true})
    table.insert(self.posts, {user="@RadioFreeKnox", name="Radio Free Knox", text="They're biting! If someone gets bitten,\nthey don't get sick... they turn!\nDon't listen to the broadcasts!", time="5h", verified=false})
    table.insert(self.posts, {user="@Spiffo_Corp", name="Spiffo's Official", text="We are experiencing supply chain issues.\nStay calm, grab a Spiffo Burger to wait it out!", time="2h", verified=true})
    
    -- Dependiendo del Karma
    local stats = S4_PlayerStats.getStats(self.player)
    if stats.Karma > 30 then
        table.insert(self.posts, {user="@WestPointSurv", name="WP Safehouse", text="There's a good person out there helping\npeople. Gives me hope.", time="30m", verified=false})
    elseif stats.Karma < -30 then
        table.insert(self.posts, {user="@TraderUnion", name="Trader Union Alert", text="WARNING: Dangerous scavenger in the area.\nShoot on sight.", time="15m", verified=true})
    end
    
    -- Posts de la comunidad (ModData)
    local twitData = ModData.getOrCreate("S4_TwitboidGlobal")
    if twitData.posts then
        for i, p in ipairs(twitData.posts) do
            table.insert(self.posts, 1, p) -- Add at top
        end
    end
end

function S4_IE_Twitboid:createChildren()
    ISPanel.createChildren(self)
    
    local x = 0
    local y = 0
    
    -- Left Sidebar (Menu)
    self.Sidebar = ISPanel:new(x, y, 120, self:getHeight())
    self.Sidebar.backgroundColor = {r=15/255, g=20/255, b=25/255, a=1}
    self.Sidebar.borderColor = {r=0.2, g=0.2, b=0.2, a=1}
    self:addChild(self.Sidebar)
    
    local logo = ISLabel:new(10, 10, S4_UI.FH_L, "Twitboid", 0.1, 0.6, 0.9, 1, UIFont.Large, true)
    self.Sidebar:addChild(logo)
    
    local menuHome = ISLabel:new(10, 50, S4_UI.FH_M, "# Home", 1, 1, 1, 1, UIFont.Medium, true)
    self.Sidebar:addChild(menuHome)
    
    local menuFollow = ISLabel:new(10, 80, S4_UI.FH_M, "@ Following", 0.6, 0.6, 0.6, 1, UIFont.Medium, true)
    self.Sidebar:addChild(menuFollow)

    local menuNotif = ISLabel:new(10, 110, S4_UI.FH_M, "! Notifications", 0.6, 0.6, 0.6, 1, UIFont.Medium, true)
    self.Sidebar:addChild(menuNotif)
    
    local menuProfile = ISLabel:new(10, 140, S4_UI.FH_M, "$ Profile", 0.6, 0.6, 0.6, 1, UIFont.Medium, true)
    self.Sidebar:addChild(menuProfile)

    -- Trending (Sidebar Right)
    self.Rightbar = ISPanel:new(self:getWidth() - 150, y, 150, self:getHeight())
    self.Rightbar.backgroundColor = {r=15/255, g=20/255, b=25/255, a=1}
    self.Rightbar.borderColor = {r=0.2, g=0.2, b=0.2, a=1}
    self:addChild(self.Rightbar)

    local trendTitle = ISLabel:new(10, 10, S4_UI.FH_M, "Trends for you", 1, 1, 1, 1, UIFont.Medium, true)
    self.Rightbar:addChild(trendTitle)
    self.Rightbar:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "1. #Quarantine", 0.1, 0.6, 0.9, 1, UIFont.Small, true))
    self.Rightbar:addChild(ISLabel:new(10, 60, S4_UI.FH_S, "2. #Muldraugh", 0.1, 0.6, 0.9, 1, UIFont.Small, true))
    self.Rightbar:addChild(ISLabel:new(10, 80, S4_UI.FH_S, "3. Where is Army?", 0.8, 0.8, 0.8, 1, UIFont.Small, true))
    self.Rightbar:addChild(ISLabel:new(10, 100, S4_UI.FH_S, "4. #Bitten", 0.8, 0.8, 0.8, 1, UIFont.Small, true))

    -- Main Feed Area
    self.FeedArea = ISPanel:new(121, 0, self:getWidth() - 271, self:getHeight())
    self.FeedArea.backgroundColor = {r=0, g=0, b=0, a=1}
    self:addChild(self.FeedArea)
    
    -- Compositor / Postear
    self.PostInput = ISTextEntryBox:new("What is happening?", 10, 10, self.FeedArea:getWidth() - 100, S4_UI.FH_M)
    self.PostInput.font = UIFont.Medium
    self.PostInput:initialise()
    self.PostInput:instantiate()
    self.FeedArea:addChild(self.PostInput)
    
    self.BtnPost = ISButton:new(self.FeedArea:getWidth() - 80, 10, 70, S4_UI.FH_M, "Boid", self, S4_IE_Twitboid.onPost)
    self.BtnPost.backgroundColor = {r=0.1, g=0.6, b=0.9, a=1}
    self.BtnPost.textColor = {r=1, g=1, b=1, a=1}
    self.BtnPost:initialise()
    self.FeedArea:addChild(self.BtnPost)

    -- Rendering posts
    local feedY = 50
    for i, post in ipairs(self.posts) do
        if feedY > self:getHeight() - 60 then break end -- Limit view
        
        local postPanel = ISPanel:new(0, feedY, self.FeedArea:getWidth(), 60)
        postPanel.backgroundColor = {r=15/255, g=20/255, b=25/255, a=1} -- Dark mode tweet
        postPanel.borderColor = {r=0.2, g=0.2, b=0.2, a=1}
        postPanel:initialise()
        postPanel:instantiate()
        self.FeedArea:addChild(postPanel)
        
        local displayName = post.name or "Survivor"
        local headerText = displayName .. " " .. post.user .. " • " .. post.time
        if post.verified then headerText = headerText .. " [V]" end
        
        local hLabel = ISLabel:new(10, 5, S4_UI.FH_S, headerText, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
        postPanel:addChild(hLabel)
        
        local bodyLines = luautils.split(post.text, "\n")
        local ty = 25
        for _, line in ipairs(bodyLines) do
            local tLabel = ISLabel:new(10, ty, S4_UI.FH_S, line, 1, 1, 1, 1, UIFont.Small, true)
            postPanel:addChild(tLabel)
            ty = ty + 15
        end
        
        -- Interactive buttons
        local btnW = 50
        local by = ty + 10
        local bReply = ISButton:new(10, by, btnW, 20, "Reply", self, S4_IE_Twitboid.onAction)
        bReply.internal = "reply"
        bReply.backgroundColor = {r=0, g=0, b=0, a=0}
        bReply.borderColor = {r=0, g=0, b=0, a=0}
        bReply.textColor = {r=0.6, g=0.6, b=0.7, a=1}
        bReply:initialise()
        postPanel:addChild(bReply)
        
        local bReboid = ISButton:new(70, by, btnW + 20, 20, "ReBoid", self, S4_IE_Twitboid.onAction)
        bReboid.internal = "reboid"
        bReboid.backgroundColor = {r=0, g=0, b=0, a=0}
        bReboid.borderColor = {r=0, g=0, b=0, a=0}
        bReboid.textColor = {r=0.6, g=0.8, b=0.6, a=1}
        bReboid:initialise()
        postPanel:addChild(bReboid)
        
        local likes = ZombRand(0, 500)
        local bLike = ISButton:new(150, by, btnW, 20, "<3 " .. likes, self, S4_IE_Twitboid.onAction)
        bLike.internal = "like"
        bLike.backgroundColor = {r=0, g=0, b=0, a=0}
        bLike.borderColor = {r=0, g=0, b=0, a=0}
        bLike.textColor = {r=0.8, g=0.4, b=0.5, a=1}
        bLike:initialise()
        postPanel:addChild(bLike)
        
        postPanel:setHeight(by + 30)
        
        feedY = feedY + postPanel:getHeight() + 10
    end
end

function S4_IE_Twitboid:onAction(btn)
    local act = btn.internal
    if act == "like" then
        btn.textColor = {r=1, g=0.1, b=0.2, a=1}
    else
        self.ComUI:AddMsgBox("Twitboid", false, "Feature locked in offline mode.", false, false)
    end
end

function S4_IE_Twitboid:onPost(button)
    local text = self.PostInput:getText()
    if text and text ~= "" and text ~= "What is happening?" then
        local twitData = ModData.getOrCreate("S4_TwitboidGlobal")
        if not twitData.posts then twitData.posts = {} end
        
        local username = "@" .. self.player:getUsername()
        
        local newPost = {
            user = username,
            name = username,
            text = text,
            time = "Just now",
            verified = false
        }
        
        table.insert(twitData.posts, 1, newPost)
        -- Limpiar historial para evitar lag extremo
        if #twitData.posts > 20 then
            table.remove(twitData.posts, 21)
        end
        
        if isClient() then ModData.transmit("S4_TwitboidGlobal") end
        
        -- Recargar
        self.IEUI:ReloadUI()
    end
end

function S4_IE_Twitboid:render()
    ISPanel.render(self)
end
