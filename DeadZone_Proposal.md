# Propuesta de Feature: DeadZone (Zona de Farmeo)

## Objetivo
Crear un sistema de eventos de combate "Riesgo vs Recompensa" donde los jugadores pueden invocar hordas de zombies en ubicaciones específicas a cambio de recompensas monetarias automáticas.

## Mecánicas Principales

### 1. El Objeto: Baliza de Respuesta Táctica (Tactical Beacon)
- **Obtención:** Comprable en la GoodShop (Categoría: Tools/Hardware).
- **Uso:** El jugador la coloca en el suelo y activa una interfaz similar a la de las señales actuales.
- **Configuración:** Permite establecer un nombre de operación y un código de frecuencia.

### 2. El Evento: Llamada a la Horda
- Al activar la baliza, el servidor genera una horda concentrada en un radio de 20-30 metros.
- **Lore:** El dispositivo emite una frecuencia subsónica que atrae o "estimula" la aparición de zombies en esa zona específica (justificando el spawn).

### 3. Recompensa: Contrato de Exterminio
- El sistema detecta muertes de zombies dentro del radio de la baliza activa.
- **Pago:** Cada zombie eliminado otorga un crédito directo (ej. $15-25) a la tarjeta bancaria activa del dueño de la baliza.
- **Niveles de Dificultad:** Posibilidad de elegir entre "Patrulla Ligera", "Infección Media" o "Horda Masiva", con pagos proporcionales.

## Detalles Técnicos Sugeridos

### Servidor (Lógica)
- Implementar `OnZombieDead` en el servidor para verificar proximidad a balizas activas.
- Utilizar `addZombiesInOutfit` o `createHorde` para el spawn controlado.
- Gestionar un estado de "Baliza Activa" en `ModData` para evitar abusos o acumulaciones infinitas.

### Cliente (Interfaz)
- Nueva sección en la aplicación de señales para monitorear el progreso de la horda actual y los créditos acumulados en tiempo real.

---
*Documento creado para planificación futura en la rama `deadZone`.*
