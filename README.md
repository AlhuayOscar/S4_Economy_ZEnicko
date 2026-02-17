# S4_Economy_ZEnicko

S4 Economy (Project Zomboid B42) is a multiplayer economy mod featuring banking, ATMs, cards, transfers, a dynamic shop system, and airdrop events.  
El proyecto esta abierto a contribuciones de codigo, balance, traduccion y QA, manteniendo siempre creditos de autor y colaboradores.

## Features / Caracteristicas

- Banking and card economy (balance, transfer, deposit, withdraw)
- GoodShop dynamic data with server-authoritative sync
- Player shop cart flow (buy/sell) with live refresh
- Airdrop events and world interactions
- Admin tools to update/reset shop data
- UI modules for ATM, bank, computer, network, and system panels

## Repository Layout (Workshop Package)

This repository is a Workshop-ready package layout:

- `workshop.txt`
- `preview.png`
- `Contents/mods/S4EcoPack/42/...`
- `Contents/mods/S4EcoPack/common/...`

## Important Runtime Notes

- Server is the source of truth for shop data (`ModData`).
- Live client updates are applied on `OnReceiveGlobalModData`.
- Shop admin actions:
  - `Update Data` -> `ShopDataAddon` (add missing entries only)
  - `Add Data` -> `OverWriteShopDataAddon` (add + overwrite existing entries)
  - `Erase All` -> `ResetShopData`

## Refresh Data Flow

- `Refresh` button is available in item lists (player shop and admin shop).
- Refresh triggers server command `RefreshShopDataFromLua`.
- Server reloads `S4_Shop_Data.lua` and applies it into runtime `S4_ShopData`.
- Runtime data is transmitted back through `ModData`, then UI reloads item values.

Behavior:
- New entries in `S4_Shop_Data` are added.
- Existing entries are overwritten with file values.
- Entries missing from `S4_Shop_Data` are removed during refresh overwrite mode.

## Useful File References

- Server command router: `Contents/mods/S4EcoPack/common/media/lua/server/S4ServerCommand.lua`
- Shop logic: `Contents/mods/S4EcoPack/common/media/lua/server/S4Shop.lua`
- Client data sync: `Contents/mods/S4EcoPack/common/media/lua/client/S4_Eco_Client.lua`
- Admin shop UI: `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Admin_UI/S4_IE_GoodShopAdmin.lua`
- Shop list UI (Refresh button): `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Shop_UI/UI/S4_ItemListBox.lua`

## Troubleshooting

- If admin actions seem to do nothing, verify server-side execution first.
- Typical runtime log path:
  - `C:\Users\<usuario>\Zomboid\Lua\S4Economy\S4_AdminShop.log`

## Credits

- Server/modpack version: `ZEnicko`
- Base mod author: `Pkoko`
- Base mod: `https://steamcommunity.com/sharedfiles/filedetails/?id=3480405054`
- Author profile: `https://steamcommunity.com/profiles/76561198867336456`

## Contributing

Pull requests are welcome for:

- Bug fixes
- Performance and stability
- Translation updates
- UI/UX improvements
- Balance and economy tuning

By contributing, you agree to preserve existing credits and attribution in this project.

## License Recommendation

To allow collaboration while preserving recognition:

- Code: `Apache-2.0`
- Assets (images/audio/models): `CC BY 4.0`
