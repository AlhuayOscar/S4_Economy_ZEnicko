local function S4_AddWalletContext(playerNum, context, items)
    items = ISInventoryPane.getActualItems(items)
    local item = items[1]
    if not item then return end
    
    local player = getSpecificPlayer(playerNum)
    local fullType = item:getFullType()
    
    if fullType == "Base.Wallet" then
        context:addOption("Pocket and Hook ($)", item, function(item, player)
            ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, item:getContainer(), player:getInventory()))
            
            -- Timed action to simulate hooking the wallet
            local Action = ISBaseTimedAction:new(player)
            Action.maxTime = 50
            function Action:perform()
                local inv = self.character:getInventory()
                inv:Remove(item)
                local newWallet = inv:AddItem("S4Item.S4Wallet")
                if self.character.setHaloNote then
                    self.character:setHaloNote("Wallet hooked to pocket", 255, 255, 255, 300)
                end
                ISBaseTimedAction.perform(self)
            end
            ISTimedActionQueue.add(Action)
        end, player)
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(S4_AddWalletContext)
