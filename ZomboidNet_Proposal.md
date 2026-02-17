# Propuesta de Feature: Zomboid.net (Interconexión Global S4)

## Objetivo
Crear una infraestructura de comunicación externa que conecte los servidores locales de Project Zomboid con un servidor centralizado (Vercel), permitiendo el intercambio de información, mercado global y chat inter-servidor.

## Componentes del Sistema

### 1. Servidor Central (Vercel)
- **Host:** Aplicación web alojada en Vercel.
- **Funciones:**
    - Chat Público Global: Todos los jugadores de diferentes servidores pueden comunicarse.
    - Mensajería Privada: Intercambio de mensajes directos.
    - Base de Datos de Intercambio: Registro de ofertas de items y precios.

### 2. Estandarización de Datos
- Para participar en la red global, el servidor local debe cumplir con un patrón de configuración estándar:
    - `S4_Shop_Data.lua` con IDs de items y precios base unificados.
    - `SandboxVars` siguiendo el perfil de "Economía Global Estándar".
- **Lore:** "La Red S4 garantiza que el dólar corporativo tenga el mismo valor en cualquier zona de la exclusión."

### 3. Sistema de Intercambio (Marketplace)
- Los jugadores pueden publicar items en "Zomboid.net".
- Si otro jugador en un servidor compatible compra el item, se genera una transferencia bancaria inter-servidor y el item se pone en la cola de "Entrega por Señal" del comprador.

## Detalles Técnicos Sugeridos

### Integración Lua -> Web
- Uso de la clase `getUrl()` o sistemas de gestión de requests HTTP de mods como `Java.type("java.net.URL")` (si el entorno lo permite).
- Comunicación asíncrona para no bloquear el hilo principal del juego durante las peticiones al chat de Vercel.

### Seguridad
- Autenticación obligatoria mediante el ID único de la tarjeta bancaria de S4 Economy.
- Sistema de anti-spam para el chat global.

---
*Documento creado para planificación futura en la rama `Zomboid.net`.*
