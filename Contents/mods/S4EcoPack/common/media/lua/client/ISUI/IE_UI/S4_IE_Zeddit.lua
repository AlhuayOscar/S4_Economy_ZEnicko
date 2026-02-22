S4_IE_Zeddit = ISPanel:derive("S4_IE_Zeddit")

function S4_IE_Zeddit:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=1, g=1, b=1, a=1} -- White background (Reddit light mode) 
    o.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    
    o.currentSub = "z/All"
    o.currentMode = "Feed" -- "Feed" or "Thread"
    o.activeThread = nil
    
    o.baseColor = {r=1, g=69/255, b=0, a=1} -- Orange/Red (Reddit accent color)
    return o
end

function S4_IE_Zeddit:initialise()
    ISPanel.initialise(self)
    self:initDatabase()
end

function S4_IE_Zeddit:initDatabase()
    -- Mock database of threads
    self.threads = {
        {
            id = 1,
            sub = "z/Survival",
            author = "u/Infected_22",
            title = "I got scratched. Am I going to turn?",
            upvotes = 23,
            time = "5h ago",
            body = "A crawler got my leg near the gas station. It's just a scratch but I feel nauseous.",
            comments = {
                { author = "u/Dr_K", text = "Scratch is low chance, laceration higher. If it was a bite, game over. Drink bleach.", time = "4h ago", votes = -15 },
                { author = "u/Hopeful", text = "Just disinfect it and bandage it. Keep your food intake high.", time = "3h ago", votes = 30 }
            }
        },
        {
            id = 2,
            sub = "z/Crafting",
            author = "u/BobTheBuilder",
            title = "PSA: How to make a rain collector barrel",
            upvotes = 512,
            time = "1d ago",
            body = "Since the water shutoff is coming, you need to be prepared. To build a basic Rain Collector Barrel, you need:\n\n- Carpentry skill level 4.\n- 4 Planks\n- 4 Nails\n- 4 Garbage Bags (to line the inside)\n- A Hammer.\n\nDon't forget to boil the water before drinking!",
            comments = {
                { author = "u/Woody", text = "Can I use trash bags instead of garbage bags?", time = "20h ago", votes = 5 },
                { author = "u/BobTheBuilder", text = "They are the same thing. Just make sure they are empty.", time = "19h ago", votes = 12 }
            }
        },
        {
            id = 3,
            sub = "z/Crafting",
            author = "u/PyroManiac",
            title = "[Recipe] The Molotov Cocktail",
            upvotes = 340,
            time = "12h ago",
            body = "Want to clear out a horde quickly? (Warning: you might burn your own house down).\n\nRecipe:\n- Empty Glass Bottle\n- Gas Can (or Bourbon)\n- Ripped Sheets\n\nEquip a lighter in your secondary hand, and the Molotov in primary. Throw it and run!",
            comments = {
                { author = "u/Lumberjack", text = "I tried this and my entire base in Muldraugh burned down. 1/10 would not recommend.", time = "10h ago", votes = 200 },
                { author = "u/PyroManiac", text = "User error.", time = "9h ago", votes = 145 }
            }
        },
        {
            id = 4,
            sub = "z/News",
            author = "u/Watchtower",
            title = "Military helicopters spotted heading South",
            upvotes = 89,
            time = "2h ago",
            body = "Did anyone else hear that? Sounds like heavy choppers flying towards Louisville. Are we getting evacuated?",
            comments = {
                { author = "u/Skeptic", text = "They're not evacuating us. They're trying to contain it. Stay hidden.", time = "1h ago", votes = 42 },
                { author = "u/NoobSurv", text = "They drew a massive horde directly to my safehouse! Thanks a lot, Army!", time = "30m ago", votes = 76 }
            }
        },
        {
            id = 5,
            sub = "z/Trading",
            author = "u/ScavengerX",
            title = "[WTS] Spiked Baseball Bat",
            upvotes = 12,
            time = "3h ago",
            body = "Classic Lucille. Baseball bat + Nails. Excellent condition. Looking for antibiotics or shotgun shells. Meet at the Rosewood gas station.",
            comments = {
                { author = "u/TrustworthyGuy", text = "I have shells. Come alone.", time = "2h ago", votes = 2 },
                { author = "u/ScavengerX", text = "Yeah right. I'm bringing backup.", time = "1h ago", votes = 15 }
            }
        }
    }
end

function S4_IE_Zeddit:createChildren()
    ISPanel.createChildren(self)
    self:rebuildUI()
end

function S4_IE_Zeddit:rebuildUI()
    local children = self:getChildren()
    if children then
        for i=#children, 1, -1 do
            self:removeChild(children[i])
        end
    end
    
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- Banner Top
    self.Banner = ISPanel:new(0, 0, w, 40)
    self.Banner.backgroundColor = {r=1, g=1, b=1, a=1}
    self.Banner.borderColor = {r=0.9, g=0.9, b=0.9, a=1}
    self:addChild(self.Banner)
    
    local logoBtn = ISButton:new(10, 5, 80, 30, " Zeddit", self, S4_IE_Zeddit.onLogoClick)
    logoBtn.backgroundColor = {r=1, g=1, b=1, a=1}
    logoBtn.textColor = self.baseColor
    logoBtn.borderColor = {r=1, g=1, b=1, a=1}
    self.Banner:addChild(logoBtn)
    
    self.Banner:addChild(ISLabel:new(100, 10, S4_UI.FH_M, "The Front Page of Knox", 0.6, 0.6, 0.6, 1, UIFont.Medium, true))

    -- Left Menu (SubZeddits)
    self.Sidebar = ISPanel:new(0, 40, 150, h - 40)
    self.Sidebar.backgroundColor = {r=0.97, g=0.97, b=0.97, a=1}
    self.Sidebar.borderColor = {r=0.9, g=0.9, b=0.9, a=1}
    self:addChild(self.Sidebar)
    
    self.Sidebar:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "FEEDS", 0.5, 0.5, 0.5, 1, UIFont.Medium, true))
    
    local subs = {"z/All", "z/Survival", "z/Crafting", "z/News", "z/Trading"}
    local sy = 40
    for _, s in ipairs(subs) do
        local btn = ISButton:new(10, sy, 130, 25, s, self, S4_IE_Zeddit.onSubClick)
        btn.internal = s
        if self.currentSub == s then
            btn.backgroundColor = {r=0.9, g=0.9, b=0.9, a=1}
            btn.textColor = self.baseColor
        else
            btn.backgroundColor = {r=0.97, g=0.97, b=0.97, a=1}
            btn.textColor = {r=0.2, g=0.2, b=0.2, a=1}
        end
        btn.borderColor = {r=0, g=0, b=0, a=0}
        self.Sidebar:addChild(btn)
        sy = sy + 30
    end

    -- Main Content Area
    self.Content = ISPanel:new(151, 40, w - 151, h - 40)
    self.Content.backgroundColor = {r=0.9, g=0.92, b=0.95, a=1}
    self.Content.borderColor = {r=0.9, g=0.9, b=0.9, a=1}
    self:addChild(self.Content)
    
    if self.currentMode == "Feed" then
        self:renderFeed()
    else
        self:renderThread()
    end
end

function S4_IE_Zeddit:renderFeed()
    local cw = self.Content:getWidth()
    local ch = self.Content:getHeight()
    
    local titlePanel = ISPanel:new(20, 20, cw - 40, 40)
    titlePanel.backgroundColor = {r=1, g=1, b=1, a=1}
    titlePanel.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
    self.Content:addChild(titlePanel)
    
    titlePanel:addChild(ISLabel:new(10, 10, S4_UI.FH_M, self.currentSub .. " - Hot Posts", 0.1, 0.1, 0.1, 1, UIFont.Medium, true))
    
    local ty = 70
    for _, th in ipairs(self.threads) do
        if self.currentSub == "z/All" or self.currentSub == th.sub then
            local pnl = ISPanel:new(20, ty, cw - 40, 70)
            pnl.backgroundColor = {r=1, g=1, b=1, a=1}
            pnl.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
            self.Content:addChild(pnl)
            
            -- Upvotes column
            pnl:addChild(ISLabel:new(10, 25, S4_UI.FH_M, "^ " .. th.upvotes, self.baseColor.r, self.baseColor.g, self.baseColor.b, 1, UIFont.Medium, true))
            
            -- Context
            pnl:addChild(ISLabel:new(60, 5, S4_UI.FH_S, th.sub .. " • Posted by " .. th.author .. " " .. th.time, 0.5, 0.5, 0.5, 1, UIFont.Small, true))
            
            -- Title Button
            local tBtn = ISButton:new(55, 25, cw - 120, 20, th.title, self, S4_IE_Zeddit.onThreadClick)
            tBtn.internal = th
            tBtn.backgroundColor = {r=1, g=1, b=1, a=0}
            tBtn.borderColor = {r=0, g=0, b=0, a=0}
            tBtn.textColor = {r=0.1, g=0.1, b=0.1, a=1}
            pnl:addChild(tBtn)
            
            -- Comments count
            pnl:addChild(ISLabel:new(60, 45, S4_UI.FH_S, #th.comments .. " Comments", 0.6, 0.6, 0.6, 1, UIFont.Small, true))
            
            ty = ty + 80
            if ty > ch - 80 then break end
        end
    end
end

function S4_IE_Zeddit:renderThread()
    local cw = self.Content:getWidth()
    local th = self.activeThread
    
    local backBtn = ISButton:new(20, 10, 100, 25, "< Back to Feed", self, S4_IE_Zeddit.onLogoClick)
    self.Content:addChild(backBtn)
    
    -- Main Post
    local pnl = ISPanel:new(20, 45, cw - 40, 120)
    pnl.backgroundColor = {r=1, g=1, b=1, a=1}
    pnl.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
    self.Content:addChild(pnl)
    
    pnl:addChild(ISLabel:new(10, 10, S4_UI.FH_M, "^ " .. th.upvotes, self.baseColor.r, self.baseColor.g, self.baseColor.b, 1, UIFont.Medium, true))
    pnl:addChild(ISLabel:new(60, 10, S4_UI.FH_S, th.sub .. " • Posted by " .. th.author .. " " .. th.time, 0.5, 0.5, 0.5, 1, UIFont.Small, true))
    pnl:addChild(ISLabel:new(60, 30, S4_UI.FH_M, th.title, 0.1, 0.1, 0.1, 1, UIFont.Medium, true))
    
    -- Split body lines for simple text wrapping
    local bodyLines = luautils.split(th.body, "\n")
    local by = 55
    for _, line in ipairs(bodyLines) do
        pnl:addChild(ISLabel:new(60, by, S4_UI.FH_S, line, 0.2, 0.2, 0.2, 1, UIFont.Small, false))
        by = by + 15
    end
    
    -- Comments Section
    self.Content:addChild(ISLabel:new(20, 180, S4_UI.FH_M, "Comments (" .. #th.comments .. ")", 0.3, 0.3, 0.3, 1, UIFont.Medium, true))
    
    local cy = 210
    for _, c in ipairs(th.comments) do
        local cPnl = ISPanel:new(20, cy, cw - 40, 60)
        cPnl.backgroundColor = {r=1, g=1, b=1, a=1}
        cPnl.borderColor = {r=0.9, g=0.9, b=0.9, a=1}
        self.Content:addChild(cPnl)
        
        cPnl:addChild(ISLabel:new(10, 5, S4_UI.FH_S, c.author .. " • " .. c.time, 0.5, 0.5, 0.5, 1, UIFont.Small, true))
        cPnl:addChild(ISLabel:new(10, 25, S4_UI.FH_S, c.text, 0.2, 0.2, 0.2, 1, UIFont.Small, false))
        
        local voteColor = {r=0.5, g=0.5, b=0.5}
        if c.votes > 0 then voteColor = self.baseColor end
        cPnl:addChild(ISLabel:new(10, 40, S4_UI.FH_S, "^ " .. c.votes, voteColor.r, voteColor.g, voteColor.b, 1, UIFont.Small, true))
        
        cy = cy + 70
        if cy > self.Content:getHeight() - 70 then break end
    end
end

function S4_IE_Zeddit:onSubClick(btn)
    self.currentSub = btn.internal
    self.currentMode = "Feed"
    self:rebuildUI()
end

function S4_IE_Zeddit:onLogoClick(btn)
    self.currentMode = "Feed"
    self:rebuildUI()
end

function S4_IE_Zeddit:onThreadClick(btn)
    self.activeThread = btn.internal
    self.currentMode = "Thread"
    self:rebuildUI()
end

function S4_IE_Zeddit:render()
    ISPanel.render(self)
end
