S4_IE_Blackjeck = ISPanel:derive("S4_IE_Blackjeck")
local function getCardCreditLimit()
    local maxNegative = 1000
    if SandboxVars and SandboxVars.S4SandBox and SandboxVars.S4SandBox.MaxNegativeBalance then
        maxNegative = SandboxVars.S4SandBox.MaxNegativeBalance
    end
    if maxNegative < 0 then
        maxNegative = 0
    end
    return -maxNegative
end

function S4_IE_Blackjeck:new(IEUI, x, y)
    local width = IEUI.ComUI:getWidth() - 12
    local TaskH = IEUI.ComUI:getHeight() - IEUI.ComUI.TaskBarY
    local height = IEUI.ComUI:getHeight() - ((S4_UI.FH_S * 2) + 23 + TaskH)

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=30/255, g=121/255, b=30/255, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.IEUI = IEUI -- Save parent UI reference
    o.ComUI = IEUI.ComUI -- computer ui
    o.player = IEUI.player
    o.Moving = true
    return o
end

function S4_IE_Blackjeck:initialise()
    ISPanel.initialise(self)
    local W, H, Count = S4_UI.getGoodShopSizeZ(self.ComUI)
    self.IEUI:FixUISize(W, H)
    self.Game = false

    self.suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
    self.values = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    self.deck = {}
    for _, suit in ipairs(self.suits) do  -- By iterating through the suits array
        for _, value in ipairs(self.values) do  -- By iterating through the values ​​array
            -- Create image file path for each card
            local imageFile = "media/textures/S4_Blackjack/" .. suit .. "_" .. value .. ".png"
            
            -- Create a table of card information (pattern, value, image file path) and add it to the deck
            table.insert(self.deck, {suit = suit, value = value, image = imageFile})
        end
    end
end

function S4_IE_Blackjeck:createChildren()
    ISPanel.createChildren(self)

    local S_BtnX = self:getWidth() - 220
    local S_BtnY = self:getHeight() / 2 - S4_UI.FH_L / 2
    self.StartBtn = ISButton:new(S_BtnX, S_BtnY, 200, S4_UI.FH_L, getText("IGUI_S4_BlackJack_GameStart"), self, S4_IE_Blackjeck.BtnClick)
    self.StartBtn.internal = "Start"
    self.StartBtn:initialise()
    self:addChild(self.StartBtn)

    local EnrtyY = S_BtnY - S4_UI.FH_M - 14
    self.BettingEntry = ISTextEntryBox:new("", S_BtnX, EnrtyY, 200, S4_UI.FH_M + 4)
    self.BettingEntry.font = UIFont.Medium
    self.BettingEntry.render = S4_IE_Blackjeck.EntryRender
    self.BettingEntry.EntryNameTag = getText("IGUI_S4_BlackJack_Betting")
    -- self.BettingEntry.EntryNameTag = "Betting Money"
    self.BettingEntry:initialise()
    self.BettingEntry:instantiate()
    self.BettingEntry:setOnlyNumbers(true)
    self:addChild(self.BettingEntry)

    self.RestartBtn = ISButton:new(S_BtnX, S_BtnY, 200, S4_UI.FH_L, getText("IGUI_S4_BlackJack_GameRestart"), self, S4_IE_Blackjeck.BtnClick)
    self.RestartBtn.internal = "Restart"
    self.RestartBtn:initialise()
    self.RestartBtn:setVisible(false)
    self:addChild(self.RestartBtn)

    local H_BtnX = self:getWidth() / 2
    local H_BtnY = self:getHeight() - S4_UI.FH_L - 10
    self.HitBtn = ISButton:new(H_BtnX - 310, H_BtnY, 200, S4_UI.FH_L, getText("IGUI_S4_BlackJack_Hit"), self, S4_IE_Blackjeck.BtnClick)
    self.HitBtn.internal = "Hit"
    self.HitBtn:initialise()
    self.HitBtn:setVisible(false)
    self:addChild(self.HitBtn)

    self.StandBtn = ISButton:new(H_BtnX - 100, H_BtnY, 200, S4_UI.FH_L, getText("IGUI_S4_BlackJack_Stand"), self, S4_IE_Blackjeck.BtnClick)
    self.StandBtn.internal = "Stand"
    self.StandBtn:initialise()
    self.StandBtn:setVisible(false)
    self:addChild(self.StandBtn)

    self.DoubleBtn = ISButton:new(H_BtnX + 110, H_BtnY, 200, S4_UI.FH_L, getText("IGUI_S4_BlackJack_DoubleDown"), self, S4_IE_Blackjeck.BtnClick)
    self.DoubleBtn.internal = "DoubleDown"
    self.DoubleBtn:initialise()
    self.DoubleBtn:setVisible(false)
    self:addChild(self.DoubleBtn)
    
    local PanelH = S4_UI.FH_M * 6
    local PanelY = S_BtnY + S4_UI.FH_L + 10
    self.InfoPanel = ISPanel:new(S_BtnX, PanelY, 200, PanelH)
    self.InfoPanel.render = S4_IE_Blackjeck.InfoRender
    self.InfoPanel.createChildren = S4_IE_Blackjeck.InfoChildren
    self.InfoPanel:initialise()
    self.InfoPanel.backgroundColor  = {r=0, g=0, b=0, a=1}
    self.InfoPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.InfoPanel:setVisible(false)
    self:addChild(self.InfoPanel)

    self.InfoPanel2 = ISPanel:new(S_BtnX, 10, 200, S4_UI.FH_M * 2)
    self.InfoPanel2.createChildren = S4_IE_Blackjeck.InfoChildren2
    self.InfoPanel2:initialise()
    self.InfoPanel2.backgroundColor  = {r=0, g=0, b=0, a=1}
    self.InfoPanel2.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.InfoPanel2:setVisible(false)
    self:addChild(self.InfoPanel2)

end

-- function S4_IE_Blackjeck:render()
--     ISPanel.render(self)
-- end
function S4_IE_Blackjeck:InfoChildren2()
    ISPanel.createChildren(self)

    local PanelX = self:getWidth() / 2 - getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_BlackJack_DealerPoint")) / 2
    self.PointLabel = ISLabel:new(PanelX, 0, S4_UI.FH_M, getText("IGUI_S4_BlackJack_DealerPoint"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PointLabel)

    self.PointValue = ISLabel:new(PanelX, S4_UI.FH_M, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PointValue)
end

function S4_IE_Blackjeck:InfoChildren()
    ISPanel.createChildren(self)

    local PanelY = 0
    local PanelX = self:getWidth() / 2 - getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_BlackJack_Betting")) / 2
    self.BettingLabel = ISLabel:new(PanelX, PanelY, S4_UI.FH_M, getText("IGUI_S4_BlackJack_Betting"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.BettingLabel)
    PanelY = PanelY + S4_UI.FH_M
    self.BettingValue = ISLabel:new(PanelX, PanelY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.BettingValue)
    PanelY = PanelY + S4_UI.FH_M

    PanelX = self:getWidth() / 2 - getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_BlackJack_Point")) / 2
    self.PointLabel = ISLabel:new(PanelX, PanelY, S4_UI.FH_M, getText("IGUI_S4_BlackJack_Point"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PointLabel)
    PanelY = PanelY + S4_UI.FH_M
    self.PointValue = ISLabel:new(PanelX, PanelY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.PointValue)
    PanelY = PanelY + S4_UI.FH_M

    PanelX = self:getWidth() / 2 - getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_S4_BlackJack_Total")) / 2
    self.TotalLabel = ISLabel:new(PanelX, PanelY, S4_UI.FH_M, getText("IGUI_S4_BlackJack_Total"), 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalLabel)
    PanelY = PanelY + S4_UI.FH_M
    self.TotalValue = ISLabel:new(PanelX, PanelY, S4_UI.FH_M, "", 1, 1, 1, 0.8, UIFont.Medium, true)
    self:addChild(self.TotalValue)
end

function S4_IE_Blackjeck:InfoRender()
    ISPanel.render(self)
    self:drawRect(0, S4_UI.FH_M * 2, self:getWidth(), 1, 1, 0.4, 0.4, 0.4)
    self:drawRect(0, S4_UI.FH_M * 4, self:getWidth(), 1, 1, 0.4, 0.4, 0.4)
end

-- button click
function S4_IE_Blackjeck:BtnClick(Button)
    local internal = Button.internal
    if internal == "Start" then
        if self.ComUI.CardReaderInstall then
            if self.ComUI.CardNumber then
                if self.ComUI.isCardPassword then
                    local Money = self.BettingEntry:getText()
                    local filteredText = Money:gsub("[^%d]", "")
                    filteredText = filteredText:gsub("^0+", "")
                    if filteredText == "" or filteredText == "0" then filteredText = "1" end
                    self.BettingEntry:setText(filteredText)
                    local BettingMoney = tonumber(filteredText)

                    local CardModData = ModData.get("S4_CardData")
                    if CardModData[self.ComUI.CardNumber] and CardModData[self.ComUI.CardNumber].Money and (CardModData[self.ComUI.CardNumber].Money - BettingMoney) >= getCardCreditLimit() then
                        -- card withdrawal
                        if CardModData[self.ComUI.CardNumber].Money > BettingMoney * 2 then
                            self.DoubleBtn:setVisible(true)
                        end
                        sendClientCommand("S4ED", "RemoveMoney", {self.ComUI.CardNumber, BettingMoney})
                        self.Betting = BettingMoney
                        self:SetInfo("Betting", BettingMoney)
                        self.ComUI.CardMoney = self.ComUI.CardMoney - BettingMoney
                        self.ComUI.BlackJeckTotal = self.ComUI.BlackJeckTotal - BettingMoney
                        self:SetInfo("Total", self.ComUI.BlackJeckTotal)
                        self:GameStart()
                    else -- insufficient balance
                        self.ComUI:AddMsgBox(getText("Error - Black Jack"), false, getText("IGUI_S4_BJ_Msg_Lack_Balance"), getText("IGUI_S4_BJ_Msg_Betting"))
                    end
                else -- Requires entering card password
                    self.ComUI:CardPasswordCheck()
                    self.ComUI:AddMsgBox("Error - Black Jack", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardPassword"), getText("IGUI_S4_ATM_Msg_NotCardPasswordTry"))
                    return
                end
            else -- Card not inserted
                self.ComUI:AddMsgBox("Error - Black Jack", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_BJ_Msg_NotInsertCard"))
                self.IEUI:close()
            end
        else -- Card reader not installed
            self.ComUI:AddMsgBox("Error - Black Jack", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardReaderInstall"))
            self.IEUI:close()
        end
    elseif internal == "DoubleDown" then
        self:GameDoubleDown()
    elseif internal == "Restart" then
        self:clearCards()
        self.Betting = 0
        self.BettingEntry:setVisible(true)
        self.StartBtn:setVisible(true)
        self.RestartBtn:setVisible(false)
        self.InfoPanel:setVisible(false)
        self.InfoPanel2:setVisible(false)
    elseif internal == "Hit" then
        self:GameHit()
    elseif internal == "Stand" then
        self:GameStand()
    end
end
-- InfoSet
function S4_IE_Blackjeck:SetInfo(InfoType, Number)
    self.InfoPanel:setVisible(true)
    self.InfoPanel2:setVisible(true)
    local Text = S4_UI.getNumCommas(Number)
    local x = self.InfoPanel:getWidth() / 2 - getTextManager():MeasureStringX(UIFont.Medium, Text) / 2
    if InfoType == "Betting" then
        self.InfoPanel.BettingValue:setName(Text)
        self.InfoPanel.BettingValue:setX(x)
    elseif InfoType == "Point" then
        self.InfoPanel.PointValue:setName(Text)
        self.InfoPanel.PointValue:setX(x)
    elseif InfoType == "Total" then
        self.InfoPanel.TotalValue:setName(Text)
        self.InfoPanel.TotalValue:setX(x)
    elseif InfoType == "DealerPointOpen" then
        self.InfoPanel2.PointValue:setName(Text)
        self.InfoPanel2.PointValue:setX(x)
    elseif InfoType == "DealerPoint" then
        x = self.InfoPanel2:getWidth() / 2 - getTextManager():MeasureStringX(UIFont.Medium, Text .. "+") / 2
        Text = Text .. "+"
        self.InfoPanel2.PointValue:setName(Text)
        self.InfoPanel2.PointValue:setX(x)
    end
end

-- Game Start
function S4_IE_Blackjeck:GameStart()
    -- Reset and Shuffle Deck
    self:initializeDeck()
    self:Suhffle(self.deck)
    
    -- Change to game start state
    self.Game = true
    self.BettingEntry:setVisible(false)
    self.StartBtn:setVisible(false)
    self.HitBtn:setVisible(true)
    self.StandBtn:setVisible(true)

    -- Hand out two cards to the player and the dealer.
    self.playerHand = {}
    self.dealerHand = {}
    for i = 1, 2 do
        table.insert(self.playerHand, table.remove(self.deck))
        table.insert(self.dealerHand, table.remove(self.deck))
    end

    -- Add card image to panel
    self:displayCards()

    -- Player Score Calculation
    self.playerScore = self:calculateHand(self.playerHand)
    self.dealerScore = self:calculateHand(self.dealerHand)
    self.DealerHideScore = self:DealerCalculateHand(self.dealerHand)
    self:SetInfo("Point", self.playerScore)
    self:SetInfo("DealerPoint", self.DealerHideScore)
end

-- Get more cards (Hit)
function S4_IE_Blackjeck:GameHit()
    if not self.Game then return end

    -- Receive 1 more card from the player
    table.insert(self.playerHand, table.remove(self.deck))

    -- Show card image
    self:displayCards()

    -- Player Score Calculation
    self.playerScore = self:calculateHand(self.playerHand)
    self:SetInfo("Point", self.playerScore)

    -- If you exceed 21, the game is over.
    if self.playerScore > 21 then
        self:gameOver("PlayerBusts")
    end
end

-- Stand
function S4_IE_Blackjeck:GameStand()
    if not self.Game then return end

    -- Dealer's turn begins
    self:dealerTurn()

    self.Game = false
    -- Result processing
    if self.dealerScore > 21 then
        self:gameOver("DealerBusts")
    elseif self.playerScore > self.dealerScore then
        self:gameOver("Win")
    elseif self.playerScore <= self.dealerScore then
        self:gameOver("Lose")
    end
end

-- Double Down
function S4_IE_Blackjeck:GameDoubleDown()
    if not self.Game then return end
    if self.ComUI.CardNumber and self.ComUI.isCardPassword then
        self.ComUI.BlackJeckTotal = self.ComUI.BlackJeckTotal - self.Betting
        self.ComUI.CardMoney = self.ComUI.CardMoney - self.Betting
        self:SetInfo("Total", self.ComUI.BlackJeckTotal)
        sendClientCommand("S4ED", "RemoveMoney", {self.ComUI.CardNumber, self.Betting})
        self.Betting = self.Betting * 2
        self:SetInfo("Betting", self.Betting)

        -- After hitting, if the player card does not exceed 21, the game ends function is executed.
        table.insert(self.playerHand, table.remove(self.deck))
        self:displayCards()
        self.playerScore = self:calculateHand(self.playerHand)
        self:SetInfo("Point", self.playerScore)
        -- If you exceed 21, the game is over.
        if self.playerScore > 21 then
            self:gameOver("PlayerBusts")
        else
            self:GameStand()
        end
    else
        if self.ComUI.CardNumber then
            self.ComUI:CardPasswordCheck()
            self.ComUI:AddMsgBox("Error - Black Jack", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_ATM_Msg_NotCardPassword"), getText("IGUI_S4_ATM_Msg_NotCardPasswordTry"))
            return
        else
            self.ComUI:AddMsgBox("Error - Black Jack", nil, getText("IGUI_S4_ATM_Msg_Error"), getText("IGUI_S4_BJ_Msg_NotInsertCard"))
            self.IEUI:close()
        end
    end
end

-- Function to shuffle a deck of cards
function S4_IE_Blackjeck:Suhffle(Deck)
    -- Shuffle sequentially from the last card of the deck to the second card.
    for i = #self.deck, 2, -1 do  -- #deck is the size of the deck (number of cards), 2 is the remaining cards except the first card
        -- Pick a random number j from the range 1 to i
        local j = ZombRand(i)
        -- Swap the positions of the i-th card and j-th card
        self.deck[i], self.deck[j] = self.deck[j], self.deck[i]
    end
end

-- Function to initialize the card deck
function S4_IE_Blackjeck:initializeDeck()
    self.suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
    self.values = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    self.deck = {}

    -- Create a new deck
    for _, suit in ipairs(self.suits) do
        for _, value in ipairs(self.values) do
            local imageFile = "media/textures/S4_Blackjack/" .. suit .. "_" .. value .. ".png"
            table.insert(self.deck, {suit = suit, value = value, image = imageFile})
        end
    end
end

-- Hand score calculation function
function S4_IE_Blackjeck:calculateHand(hand)
    local total = 0
    local aceCount = 0

    for _, card in ipairs(hand) do
        if card.value == "A" then
            total = total + 11
            aceCount = aceCount + 1
        elseif card.value == "K" or card.value == "Q" or card.value == "J" then
            total = total + 10
        else
            total = total + tonumber(card.value)
        end
    end

    -- If the Ace card is greater than 11, it counts as 1.
    while total > 21 and aceCount > 0 do
        total = total - 10
        aceCount = aceCount - 1
    end

    return total
end

function S4_IE_Blackjeck:DealerCalculateHand(hand)
    local total = 0
    local aceCount = 0

    for i, card in ipairs(hand) do
        if i ~= 1 then
            if card.value == "A" then
                total = total + 11
                aceCount = aceCount + 1
            elseif card.value == "K" or card.value == "Q" or card.value == "J" then
                total = total + 10
            else
                total = total + tonumber(card.value)
            end
        end
    end

    -- If the Ace card is greater than 11, it counts as 1.
    while total > 21 and aceCount > 0 do
        total = total - 10
        aceCount = aceCount - 1
    end

    return total
end

-- Dealer's Turn
function S4_IE_Blackjeck:dealerTurn()
    -- Get a card if the dealer card is less than 17
    while self.dealerScore < 17 do
        table.insert(self.dealerHand, table.remove(self.deck))
        self.dealerScore = self:calculateHand(self.dealerHand)
        self:displayCards()  -- Screen update after adding new card
    end
    self:SetInfo("DealerPointOpen", self.dealerScore)
end

-- Game end handling
function S4_IE_Blackjeck:gameOver(OverType)
    self:displayCards()

    -- Show game over message
    if OverType == "Win" then
        self.ComUI.BlackJeckTotal = self.ComUI.BlackJeckTotal + (self.Betting * 2)
        self.ComUI.CardMoney = self.ComUI.CardMoney + (self.Betting * 2)
        self.ComUI:AddMsgBox("Black Jack - Win", nil, getText("IGUI_S4_BlackJack_PlayerWin"))
        sendClientCommand("S4ED", "AddMoney", {self.ComUI.CardNumber, (self.Betting * 2)})
        -- pay money
    elseif OverType == "DealerBusts" then
        self.ComUI.BlackJeckTotal = self.ComUI.BlackJeckTotal + (self.Betting * 2)
        self.ComUI.CardMoney = self.ComUI.CardMoney + (self.Betting * 2)
        self.ComUI:AddMsgBox("Black Jack - Dealer Busts", nil, getText("IGUI_S4_BlackJack_DealerBusts"))
        sendClientCommand("S4ED", "AddMoney", {self.ComUI.CardNumber, (self.Betting * 2)})
        -- pay money
    elseif OverType == "PlayerBusts" then
        self.ComUI:AddMsgBox("Black Jack - Player Busts", nil, getText("IGUI_S4_BlackJack_PlayerBusts"))
    elseif OverType == "Lose" then
        self.ComUI:AddMsgBox("Black Jack - Lose", nil, getText("IGUI_S4_BlackJack_PlayerLose"))
    end
    -- Reset game buttons
    self:SetInfo("Total", self.ComUI.BlackJeckTotal)
    self.HitBtn:setVisible(false)
    self.StandBtn:setVisible(false)
    self.DoubleBtn:setVisible(false)
    self.RestartBtn:setVisible(true)
end



-- Display card images for player and dealer
function S4_IE_Blackjeck:displayCards()
    -- Delete existing cards from the screen
    self:clearCards()

    local CardW = 150
    local CardH = 210
    local CardX = self:getWidth() / 2

    -- Display player card image
    for i, card in ipairs(self.playerHand) do
        local xPos = 50 + (i - 1) * (CardW + 10)
        local yPos = self:getHeight() - CardH - S4_UI.FH_L - 20
        local ImgFile = getTexture(card.image)
        self["MyCard"..i] = ISImage:new(xPos, yPos, CardW, CardH, ImgFile)
        self["MyCard"..i].autoScale = true
        self["MyCard"..i]:setAnchorLeft(true)
        self["MyCard"..i]:setAnchorTop(true)
        self:addChild(self["MyCard"..i])
    end

    -- Show dealer card image (first card revealed, second card covered)
    for i, card in ipairs(self.dealerHand) do
        local xPos = 50 + (i - 1) * (CardW + 10)
        local yPos = 10
        if i == 1 and self.Game then
            local backImage = getTexture("media/textures/S4_Blackjack/Back.png") -- Card back image
            self["DealerCard"..i] = ISImage:new(xPos, yPos, CardW, CardH, backImage)
            self["DealerCard"..i].autoScale = true
            self["DealerCard"..i]:setAnchorLeft(true)
            self["DealerCard"..i]:setAnchorTop(true)
            self:addChild(self["DealerCard"..i])
        else
            local ImgFile = getTexture(card.image)
            self["DealerCard"..i] = ISImage:new(xPos, yPos, CardW, CardH, ImgFile)
            self["DealerCard"..i].autoScale = true
            self["DealerCard"..i]:setAnchorLeft(true)
            self["DealerCard"..i]:setAnchorTop(true)
            self:addChild(self["DealerCard"..i])
        end
    end
end

-- remove cards
function S4_IE_Blackjeck:clearCards()
    for i = 1, 6 do
        if self["DealerCard"..i] then
            self["DealerCard"..i]:close()
        end
        if self["MyCard"..i] then
            self["MyCard"..i]:close()
        end
    end
end

-- Entry render
function S4_IE_Blackjeck:EntryRender()
    if self.EntryNameTag and not self.javaObject:isFocused() and self:getText() == "" then
        local TextW = getTextManager():MeasureStringX(UIFont.Medium, self.EntryNameTag)
        self:drawText(self.EntryNameTag, 10, 1, 1, 1, 1, 0.5, UIFont.Medium)
    end
end

-- Functions related to moving and exiting UI
function S4_IE_Blackjeck:onMouseDown(x, y)
    if not self.Moving then return end
    self.IEUI.moving = true
    self.IEUI:bringToTop()
    self.ComUI.TopApp = self.IEUI
end

function S4_IE_Blackjeck:onMouseUpOutside(x, y)
    if not self.Moving then return end
    self.IEUI.moving = false
end

function S4_IE_Blackjeck:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
