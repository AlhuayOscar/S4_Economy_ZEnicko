# Propuesta de Feature: SafeZone (Servicio de Protección de Área)

## Objetivo
Implementar un servicio de suscripción premium de alta gama que permita a los ciudadanos de Knox Country asegurar una zona contra incursiones de hordas.

## Mecánicas del Servicio

### 1. Suscripción y Cobertura
- **Planes Disponibles:** Semanal, Mensual y Anual.
- **Tamaño de Zona:** Desde un núcleo mínimo de **3x3** hasta un máximo de **100x100** cuadrados.
- **Coste de Expansión:** El servicio es extremadamente costoso. Cada cuadrado (slot) adicional de cobertura añadirá un coste extra de **$5,000**. 
- **Lore:** La corporación utiliza tecnología satelital y emisores de alta frecuencia para crear una burbuja de interferencia que los zombies no pueden tolerar.

### 2. Efectos de Protección
- **Evitación:** Los zombies evitarán entrar en el área protegida, incluso si detectan a un jugador dentro de la misma.
- **Eliminación Automática:** En caso de que un zombie aparezca (spawn) dentro por error o sea forzado a entrar, el sistema lo eliminará del mapa automáticamente.
- **Mantenimiento:** El servicio requiere que el pago de la suscripción esté al día. Si el saldo es insuficiente al momento de la renovación, la protección caerá instantáneamente.

### 3. Gestión y Configuración
- Accesible a través de una nueva aplicación en el sistema del computador.
- Interfaz para definir el radio de protección y visualizar el coste total antes de contratar.
- Se requiere un dispositivo específico instalado en la zona (Emisor de Señal Premium) para que el servicio sea efectivo.

## Detalles Técnicos Sugeridos

### Servidor (Lógica)
- Implementar una verificación periódica (EveryOneMinute o similar) para barrer zombies dentro de las zonas seguras activas.
- Utilizar `IsoZombie:removeAndCleanup()` para eliminar zombies detectados dentro del área.
- Almacenado de zonas activas en `ModData` global para persistencia entre reinicios del servidor.

---
*Documento creado para planificación futura en la rama `safezone`.*
