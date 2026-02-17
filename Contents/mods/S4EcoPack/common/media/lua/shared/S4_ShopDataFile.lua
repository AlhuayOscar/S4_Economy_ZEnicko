S4_ShopDataFile = S4_ShopDataFile or {}

function S4_ShopDataFile.WriteShopData()

    local path = "S4Economy/S4_Shop_Data.lua"
    local file = getFileWriter(path, true, false)
    if file then
        local ShopModData = ModData.get("S4_ShopData")
        if ShopModData then
            file:write("S4_Shop_Data = S4_Shop_Data or {}\n\n")
            for ItemName, Data in pairs(ShopModData) do
                local line = string.format(
                "S4_Shop_Data[\"%s\"] = {\n" ..
                "    BuyPrice      = %s,\n" ..
                "    SellPrice     = %s,\n" ..
                "    Stock         = %s,\n" ..
                "    Restock       = %s,\n" ..
                "    Category      = \"%s\",\n" ..
                "    BuyAuthority  = %s,\n" ..
                "    SellAuthority = %s,\n" ..
                "    Discount      = %s,\n" ..
                "    HotItem       = %s,\n" ..
                "}\n\n",
                ItemName,
                tostring(Data.BuyPrice),
                tostring(Data.SellPrice),
                tostring(Data.Stock),
                tostring(Data.Restock),
                tostring(Data.Category),
                tostring(Data.BuyAuthority),
                tostring(Data.SellAuthority),
                tostring(Data.Discount),
                tostring(Data.HotItem))

                file:write(line)
            end
        end
        file:close()
    end
end