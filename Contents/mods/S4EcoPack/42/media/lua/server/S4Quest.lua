-- Do not operate outside of the server during multiplayer
-- if not isServer() then return end

-- Function initialization
S4Quest = {}

-- Generate kill data
function S4Quest.CreateQuestData(player, args)
    local Username = player:getUsername()
    local Account = ModData.get("S4_QuestData")[Username]
    if Account then return end
    ModData.get("S4_QuestData")[Username] = {
        Quest1Type = false,
        Quest2Type = false,
        Quest3Type = false,
        Quest1Kill = 0,
        Quest2Kill = 0,
        Quest3Kill = 0,
    }

    ModData.transmit("S4_QuestData")
end