require "Items/ProceduralDistributions"

local function S4_AddLootDistributions()
    if not ProceduralDistributions or not ProceduralDistributions.list then return end

    local houseContainers = {
        "BedroomDresser",
        "BedroomSideTable",
        "WardrobeShelf"
    }

    local bankContainers = {
        "BankCounter",
        "SafeLoot",
        "KitchenSafe",
        "DeskLow" -- Banks often have many desks
    }

    for _, container in ipairs(houseContainers) do
        if ProceduralDistributions.list[container] then
            table.insert(ProceduralDistributions.list[container].items, "Base.MoneyBundle")
            table.insert(ProceduralDistributions.list[container].items, 5) -- 5% chance
            table.insert(ProceduralDistributions.list[container].items, "S4Item.Wallet")
            table.insert(ProceduralDistributions.list[container].items, 2) -- 2% chance for wallet
        end
    end

    for _, container in ipairs(bankContainers) do
        if ProceduralDistributions.list[container] then
            table.insert(ProceduralDistributions.list[container].items, "Base.MoneyBundle")
            table.insert(ProceduralDistributions.list[container].items, 10) -- 10% chance
        end
    end
end

S4_AddLootDistributions()
