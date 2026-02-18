# S4_Economy_ZEnicko

## English

S4 Economy (Project Zomboid B42) is a multiplayer economy mod with banking, ATMs, cards, transfers, a dynamic shop system, and airdrop events.

This project is open to code, balance, translation, and QA contributions while preserving author and contributor credits.

### Features

- Banking and card economy (balance, transfer, deposit, withdraw)
- GoodShop dynamic data with server-authoritative sync
- Player shop cart flow (buy/sell) with live refresh
- Airdrop events and world interactions
- Admin tools to update/reset shop data
- UI modules for ATM, bank, computer, network, and system panels

### Knox News Reference Source

- Timeline/events and media reference source for Knox News:
  `https://steamcommunity.com/sharedfiles/filedetails/?id=3389064477`

### Repository Layout (Workshop Package)

- `workshop.txt`
- `preview.png`
- `Contents/mods/S4EcoPack/42/...`
- `Contents/mods/S4EcoPack/common/...`

### Runtime Notes

- Server is the source of truth for shop data (`ModData`).
- Live client updates are applied on `OnReceiveGlobalModData`.
- Shop admin actions:
  `Update Data` -> `ShopDataAddon` (add missing entries only)
  `Add Data` -> `OverWriteShopDataAddon` (add + overwrite existing entries)
  `Erase All` -> `ResetShopData`

### Refresh Data Flow

- `Refresh` is available in player and admin item lists.
- Refresh triggers `RefreshShopDataFromLua` on server.
- Server reloads `S4_Shop_Data.lua` and applies it to runtime `S4_ShopData`.
- Runtime data is transmitted back through `ModData`, then UI refreshes values.

Behavior:

- New entries in `S4_Shop_Data` are added.
- Existing entries are overwritten with file values.
- Missing entries in `S4_Shop_Data` are removed in overwrite mode.

### Useful File References

- Server command router: `Contents/mods/S4EcoPack/common/media/lua/server/S4ServerCommand.lua`
- Shop logic: `Contents/mods/S4EcoPack/common/media/lua/server/S4Shop.lua`
- Client data sync: `Contents/mods/S4EcoPack/common/media/lua/client/S4_Eco_Client.lua`
- Admin shop UI: `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Admin_UI/S4_IE_GoodShopAdmin.lua`
- Shop list UI (Refresh button): `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Shop_UI/UI/S4_ItemListBox.lua`

### Troubleshooting

- If admin actions seem to do nothing, verify server-side execution first.
- Typical runtime log path:
  `C:\Users\<user>\Zomboid\Lua\S4Economy\S4_AdminShop.log`

### Credits

- Server/modpack version: `ZEnicko`
- Base mod author: `Pkoko`
- Base mod: `https://steamcommunity.com/sharedfiles/filedetails/?id=3480405054`
- Author profile: `https://steamcommunity.com/profiles/76561198867336456`

### Contributing

Pull requests are welcome for:

- Bug fixes
- Performance and stability
- Translation updates
- UI/UX improvements
- Balance and economy tuning

By contributing, you agree to preserve existing credits and attribution in this project.

### License

To allow collaboration while preserving recognition:

- Code: `Apache-2.0`
- Assets (images/audio/models): `CC BY 4.0`

---

## Espanol

S4 Economy (Project Zomboid B42) es un mod de economia multijugador con banca, cajeros, tarjetas, transferencias, un sistema de tienda dinamico y eventos de airdrop.

Este proyecto esta abierto a contribuciones de codigo, balance, traduccion y QA, manteniendo siempre creditos de autor y colaboradores.

### Caracteristicas

- Economia bancaria y con tarjetas (saldo, transferencia, deposito, retiro)
- Datos dinamicos de GoodShop con sincronizacion autoritativa del servidor
- Flujo de carrito de tienda (compra/venta) con refresco en vivo
- Eventos de airdrop e interacciones del mundo
- Herramientas admin para actualizar/resetear datos de tienda
- Modulos UI para ATM, banco, computadora, red y paneles del sistema

### Fuente de Referencia Knox News

- Fuente de referencia para timeline/eventos y recursos de Knox News:
  `https://steamcommunity.com/sharedfiles/filedetails/?id=3389064477`

### Estructura del Repositorio (Paquete Workshop)

- `workshop.txt`
- `preview.png`
- `Contents/mods/S4EcoPack/42/...`
- `Contents/mods/S4EcoPack/common/...`

### Notas de Runtime

- El servidor es la fuente de verdad para datos de tienda (`ModData`).
- Las actualizaciones en cliente se aplican en `OnReceiveGlobalModData`.
- Acciones admin de tienda:
  `Update Data` -> `ShopDataAddon` (solo agrega faltantes)
  `Add Data` -> `OverWriteShopDataAddon` (agrega + sobrescribe existentes)
  `Erase All` -> `ResetShopData`

### Flujo de Refresco de Datos

- `Refresh` esta disponible en listas de items de jugador y admin.
- Refresh ejecuta `RefreshShopDataFromLua` en servidor.
- El servidor recarga `S4_Shop_Data.lua` y lo aplica a `S4_ShopData` en runtime.
- Los datos runtime se retransmiten por `ModData` y luego la UI refresca valores.

Comportamiento:

- Entradas nuevas en `S4_Shop_Data` se agregan.
- Entradas existentes se sobrescriben con los valores del archivo.
- Entradas faltantes en `S4_Shop_Data` se eliminan en modo overwrite.

### Referencias de Archivos Utiles

- Enrutador de comandos servidor: `Contents/mods/S4EcoPack/common/media/lua/server/S4ServerCommand.lua`
- Logica de tienda: `Contents/mods/S4EcoPack/common/media/lua/server/S4Shop.lua`
- Sync de datos cliente: `Contents/mods/S4EcoPack/common/media/lua/client/S4_Eco_Client.lua`
- UI admin de tienda: `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Admin_UI/S4_IE_GoodShopAdmin.lua`
- UI de lista de tienda (boton Refresh): `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Shop_UI/UI/S4_ItemListBox.lua`

### Solucion de Problemas

- Si acciones admin no hacen nada, verifica primero ejecucion en servidor.
- Ruta de log runtime tipica:
  `C:\Users\<usuario>\Zomboid\Lua\S4Economy\S4_AdminShop.log`

### Creditos

- Version server/modpack: `ZEnicko`
- Autor del mod base: `Pkoko`
- Mod base: `https://steamcommunity.com/sharedfiles/filedetails/?id=3480405054`
- Perfil del autor: `https://steamcommunity.com/profiles/76561198867336456`

### Contribuir

Pull requests bienvenidos para:

- Correccion de bugs
- Performance y estabilidad
- Actualizaciones de traduccion
- Mejoras UI/UX
- Balance y ajuste de economia

Al contribuir, aceptas mantener los creditos y atribucion existentes en este proyecto.

### License

To allow collaboration while preserving recognition:

- Code: `Apache-2.0`
- Assets (images/audio/models): `CC BY 4.0`

### Future Roadmap & Ideas

The following features are planned for future development branches:

- **DeadZone (`deadZone`)**: Combat-focused "Farming Zones" where players call in hordes via beacons to earn bounties per kill.
- **SafeZone (`safezone`)**: Premium subscription-based area protection that prevents zombie incursions or removes them within a defined radius.
- **Jobs (`jobs`)**: Professional career system (Programmer, Banker, Journalist, etc.) with daily salaries and specific tasks.
- **Twitboid (`Twitboid`)**: A social network quest system where NPCs and players post contracts for car recovery, item retrieval, or specific bounties.
- **Crimeboid.net (`Crimeboid.net`)**: A dark web for illicit activities, vandalism, sabotaging vehicles, or "messy" wetwork contracts.
- **VehicleShop (`vehicleShop`)**: Corporate vehicle dealership allowing players to purchase and spawn cars at their signal locations.
- **Zomboid.net (`Zomboid.net`)**: Global interconnection system via Vercel for inter-server chat and a shared marketplace.

---

## Espanol

S4 Economy (Project Zomboid B42) es un mod de economia multijugador con banca, cajeros, tarjetas, transferencias, un sistema de tienda dinamico y eventos de airdrop.

Este proyecto esta abierto a contribuciones de codigo, balance, traduccion y QA, manteniendo siempre creditos de autor y colaboradores.

### Caracteristicas

- Economia bancaria y con tarjetas (saldo, transferencia, deposito, retiro)
- Datos dinamicos de GoodShop con sincronizacion autoritativa del servidor
- Flujo de carrito de tienda (compra/venta) con refresco en vivo
- Eventos de airdrop e interacciones del mundo
- Herramientas admin para actualizar/resetear datos de tienda
- Modulos UI para ATM, banco, computadora, red y paneles del sistema

### Fuente de Referencia Knox News

- Fuente de referencia para timeline/eventos y recursos de Knox News:
  `https://steamcommunity.com/sharedfiles/filedetails/?id=3389064477`

### Estructura del Repositorio (Paquete Workshop)

- `workshop.txt`
- `preview.png`
- `Contents/mods/S4EcoPack/42/...`
- `Contents/mods/S4EcoPack/common/...`

### Notas de Runtime

- El servidor es la fuente de verdad para datos de tienda (`ModData`).
- Las actualizaciones en cliente se aplican en `OnReceiveGlobalModData`.
- Acciones admin de tienda:
  `Update Data` -> `ShopDataAddon` (solo agrega faltantes)
  `Add Data` -> `OverWriteShopDataAddon` (agrega + sobrescribe existentes)
  `Erase All` -> `ResetShopData`

### Flujo de Refresco de Datos

- `Refresh` esta disponible en listas de items de jugador y admin.
- Refresh ejecuta `RefreshShopDataFromLua` en servidor.
- El servidor recarga `S4_Shop_Data.lua` y lo aplica a `S4_ShopData` en runtime.
- Los datos runtime se retransmiten por `ModData` y luego la UI refresca valores.

Comportamiento:

- Entradas nuevas en `S4_Shop_Data` se agregan.
- Entradas existentes se sobrescriben con los valores del archivo.
- Entradas faltantes en `S4_Shop_Data` se eliminan en modo overwrite.

### Referencias de Archivos Utiles

- Enrutador de comandos servidor: `Contents/mods/S4EcoPack/common/media/lua/server/S4ServerCommand.lua`
- Logica de tienda: `Contents/mods/S4EcoPack/common/media/lua/server/S4Shop.lua`
- Sync de datos cliente: `Contents/mods/S4EcoPack/common/media/lua/client/S4_Eco_Client.lua`
- UI admin de tienda: `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Admin_UI/S4_IE_GoodShopAdmin.lua`
- UI de lista de tienda (boton Refresh): `Contents/mods/S4EcoPack/common/media/lua/client/ISUI/Shop_UI/UI/S4_ItemListBox.lua`

### Solucion de Problemas

- Si acciones admin no hacen nada, verifica primero ejecucion en servidor.
- Ruta de log runtime tipica:
  `C:\Users\<usuario>\Zomboid\Lua\S4Economy\S4_AdminShop.log`

### Creditos

- Version server/modpack: `ZEnicko`
- Autor del mod base: `Pkoko`
- Mod base: `https://steamcommunity.com/sharedfiles/filedetails/?id=3480405054`
- Perfil del autor: `https://steamcommunity.com/profiles/76561198867336456`

### Contribuir

Pull requests bienvenidos para:

- Correccion de bugs
- Performance y estabilidad
- Actualizaciones de traduccion
- Mejoras UI/UX
- Balance y ajuste de economia

Al contribuir, aceptas mantener los creditos y atribucion existentes en este proyecto.

### Licencia

Para permitir colaboracion manteniendo reconocimiento:

- Codigo: `Apache-2.0`
- Assets (imagenes/audio/modelos): `CC BY 4.0`

### Roadmap de Futuras Ideas

Las siguientes caracteristicas estan planeadas en ramas de desarrollo independientes:

- **DeadZone (`deadZone`)**: Zonas de farmeo de combate donde los jugadores invocan hordas mediante balizas para ganar recompensas por cada baja.
- **SafeZone (`safezone`)**: Servicio premium de proteccion de area que evita incursiones de zombies o los elimina dentro de un radio definido.
- **Jobs (`jobs`)**: Sistema de carreras profesionales (Programador, Banquero, Periodista, etc.) con salarios diarios y tareas especificas.
- **Twitboid (`Twitboid`)**: Sistema de misiones tipo red social donde NPCs y jugadores publican contratos para recuperar vehiculos, objetos o recompensas especificas.
- **Crimeboid.net (`Crimeboid.net`)**: La "Dark Web" para actividades ilicitas, vandalismo, sabotaje de vehiculos o contratos de "limpieza" poco eticos.
- **VehicleShop (`vehicleShop`)**: Concesionario corporativo que permite comprar vehiculos y recibirlos por entrega aerea/terrestre en la señal del jugador.
- **Zomboid.net (`Zomboid.net`)**: Sistema de interconexion global mediante Vercel para chat inter-servidor y mercado compartido.
