# Propuesta de Feature: VehicleShop (Entrega de Vehículos por Corporación)

## Objetivo
Permitir a los jugadores adquirir vehículos a través de la interfaz de S4 Economy y recibirlos mediante entrega aérea o terrestre en la ubicación de su señal instalada.

## Mecánicas del Servicio

### 1. Compra de Vehículos
- Los vehículos aparecerán en una nueva categoría dentro de la **GoodShop**.
- **Precios:** Elevados para reflejar la logística de traer un vehículo funcional a la zona de exclusión.

### 2. Logística de Entrega (Spawn)
- Al realizar la compra, el jugador debe seleccionar una **Señal Activa** (X,Y).
- El sistema verificará que haya espacio suficiente alrededor de la señal (mínimo un área de 3x5 de tiles libres).
- **Lore:** "S4 Delivery Corps" utiliza remolques pesados o helicópteros de transporte para dejar el vehículo exactamente donde se solicitó.

### 3. Estado del Vehículo
- Los vehículos se entregarán "Listos para Usar":
    - Tanque de combustible lleno (o al 50%).
    - Motor en condiciones operativas (condición > 80%).
    - Llave del vehículo añadida automáticamente al inventario del comprador o dejada en el contacto/guantera.

## Detalles Técnicos Sugeridos

### Servidor (Lógica)
- Uso de la función `addVehicle("Base.CarNormal", square)` del API de Zomboid.
- Lógica de verificación de colisiones para evitar que el vehículo spawnee dentro de paredes o árboles.
- Sincronización de llaves mediante `vehicle:addKey()`.

---
*Documento creado para planificación futura en la rama `vehicleShop`.*
