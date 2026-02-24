require "ISUI/IE_UI/S4_MNS_Database"
S4_IE_MNS = ISPanel:derive("S4_IE_MNS")

function S4_IE_MNS:new(IEUI, x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=240/255, g=245/255, b=255/255, a=1}
    o.borderColor = {r=0.2, g=0.5, b=0.8, a=1}
    o.IEUI = IEUI
    o.ComUI = IEUI.ComUI
    o.player = IEUI.player
    o.selectedContact = nil
    o.contacts = {}
    return o
end

function S4_IE_MNS:initialise()
    ISPanel.initialise(self)
    self:syncContacts()
end

function S4_IE_MNS:syncContacts()
    self.contacts = {}
    
    -- Default "System" Bot
    table.insert(self.contacts, {
        id = "mns_bot",
        name = "MNS Guide",
        status = "Online",
        avatar = "media/textures/Item_Paper.png",
        mood = "Welcome to MNS Messenger!",
        messages = {
            {from="Bot", text="Hello! I'm your MNS assistant."},
            {from="Bot", text="You can find new contacts by browsing Twitboid or Zeddit."},
            {from="Bot", text="Traders and Quest givers will appear here once you interact with them."}
        }
    })

    -- Pull unlocked contacts from ModData
    local pData = self.player:getModData()
    if pData.S4_MNS_Contacts then
        for _, savedContact in ipairs(pData.S4_MNS_Contacts) do
            -- Find full data from database to ensure up-to-date mood/lore
            local dbUser = nil
            if S4_MNS_Database and S4_MNS_Database.Users then
                for _, u in ipairs(S4_MNS_Database.Users) do
                    if u.id == savedContact.id then
                        dbUser = u
                        break
                    end
                end
            end

            if dbUser then
                local c = {
                    id = dbUser.id,
                    name = dbUser.name,
                    status = dbUser.status,
                    mood = dbUser.mood,
                    messages = savedContact.messages or {}
                }
                table.insert(self.contacts, c)
            else
                -- Legacy or custom contact support
                table.insert(self.contacts, savedContact)
            end
        end
    end
end

function S4_IE_MNS:createChildren()
    ISPanel.createChildren(self)
    
    local sidebarW = 180
    
    -- Messenger Header
    self.Header = ISPanel:new(0, 0, self:getWidth(), 50)
    self.Header.backgroundColor = {r=0.2, g=0.6, b=0.9, a=1}
    self:addChild(self.Header)
    
    local title = ISLabel:new(15, 10, 30, "MNS Messenger (Beta)", 1, 1, 1, 1, UIFont.Medium, true)
    self.Header:addChild(title)

    -- Sidebar (Contact List)
    self.ContactList = ISPanel:new(0, 50, sidebarW, self:getHeight() - 50)
    self.ContactList.backgroundColor = {r=1, g=1, b=1, a=1}
    self.ContactList.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
    self:addChild(self.ContactList)
    
    -- Chat Area
    self.ChatArea = ISPanel:new(sidebarW + 1, 50, self:getWidth() - sidebarW - 1, self:getHeight() - 50)
    self.ChatArea.backgroundColor = {r=245/255, g=250/255, b=255/255, a=1}
    self:addChild(self.ChatArea)
    
    self:renderContacts()
end

function S4_IE_MNS:renderContacts()
    self.ContactList:clearChildren()
    local y = 10
    for i, contact in ipairs(self.contacts) do
        local entry = ISButton:new(5, y, self.ContactList:getWidth() - 10, 40, contact.name, self, self.onSelectContact)
        entry.internal = i
        entry.backgroundColor = {r=0.95, g=0.95, b=1, a=1}
        entry.borderColor = {r=0.8, g=0.8, b=0.9, a=1}
        if self.selectedContact == i then
            entry.backgroundColor = {r=0.2, g=0.5, b=0.8, a=0.3}
        end
        entry:initialise()
        self.ContactList:addChild(entry)
        
        local statusLabel = ISLabel:new(10, 22, 12, "(" .. contact.status .. ")", 0.4, 0.7, 0.4, 1, UIFont.Small, true)
        entry:addChild(statusLabel)
        
        y = y + 45
    end
end

function S4_IE_MNS:onSelectContact(btn)
    self.selectedContact = btn.internal
    self:renderContacts()
    self:renderChat()
end

function S4_IE_MNS:renderChat()
    self.ChatArea:clearChildren()
    
    local contact = self.contacts[self.selectedContact]
    if not contact then
        local msg = ISLabel:new(20, 20, 20, "Select a contact to start chatting", 0.5, 0.5, 0.5, 1, UIFont.Medium, true)
        self.ChatArea:addChild(msg)
        return
    end
    
    -- Chat Header
    local chatHeader = ISPanel:new(0, 0, self.ChatArea:getWidth(), 40)
    chatHeader.backgroundColor = {r=0.9, g=0.9, b=0.95, a=1}
    self.ChatArea:addChild(chatHeader)
    
    local name = ISLabel:new(15, 10, 20, contact.name .. " <" .. contact.mood .. ">", 0, 0, 0, 1, UIFont.Medium, true)
    chatHeader:addChild(name)
    
    -- Messages Container
    local msgContainer = ISPanel:new(10, 50, self.ChatArea:getWidth() - 20, self.ChatArea:getHeight() - 120)
    msgContainer.backgroundColor = {r=1, g=1, b=1, a=1}
    msgContainer.borderColor = {r=0.8, g=0.8, b=0.8, a=1}
    msgContainer:addScrollBars()
    self.ChatArea:addChild(msgContainer)
    
    local my = 10
    for _, m in ipairs(contact.messages or {}) do
        local col = {r=0.2, g=0.2, b=0.6, a=1}
        if m.from == "Bot" or m.from ~= self.player:getUsername() then
            col = {r=0.1, g=0.4, b=0.1, a=1}
        end
        
        local mLabel = ISLabel:new(10, my, 15, m.from .. " says:", col.r, col.g, col.b, 1, UIFont.Small, true)
        msgContainer:addChild(mLabel)
        
        local textLabel = ISLabel:new(20, my + 15, 15, m.text, 0, 0, 0, 1, UIFont.Small, true)
        msgContainer:addChild(textLabel)
        
        my = my + 40
    end
    msgContainer:setScrollHeight(my + 20)

    -- Input Area
    local input = ISTextEntryBox:new("", 10, self.ChatArea:getHeight() - 60, self.ChatArea:getWidth() - 100, 25)
    input:initialise()
    input:instantiate()
    self.ChatArea:addChild(input)
    self.ChatInput = input
    
    local btnSend = ISButton:new(self.ChatArea:getWidth() - 85, self.ChatArea:getHeight() - 60, 75, 25, "Send", self, self.onSendMessage)
    btnSend.backgroundColor = {r=0.1, g=0.5, b=0.1, a=1}
    btnSend.textColor = {r=1, g=1, b=1, a=1}
    btnSend:initialise()
    self.ChatArea:addChild(btnSend)
end

function S4_IE_MNS:onSendMessage(btn)
    local text = self.ChatInput:getText()
    if not text or text == "" then return end
    
    local contact = self.contacts[self.selectedContact]
    if not contact then return end
    
    table.insert(contact.messages, {from=self.player:getUsername(), text=text})
    self.ChatInput:setText("")
    self:renderChat()
    
    -- Basic response logic for the bot
    if contact.id == "mns_bot" then
        if string.find(string.lower(text), "hello") or string.find(string.lower(text), "hi") then
            table.insert(contact.messages, {from="Bot", text="Hello there! Feeling nostalgic today?"})
        else
            table.insert(contact.messages, {from="Bot", text="I am just a simple guide. Search for real traders!"})
        end
        self:renderChat()
    end
end

function S4_IE_MNS:render()
    ISPanel.render(self)
end
