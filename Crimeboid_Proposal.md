# Propuesta de Feature: Crimeboid.net (La Dark Web de Knox)

## Objetivo
Implementar una plataforma clandestina en el computador conocida como "Crimeboid.net", enfocada en misiones criminales, vandalismo, sabotaje y contratos de "limpieza" poco éticos.

## El Concepto
A diferencia de Twitboid, Crimeboid es anónimo y peligroso. Las misiones aquí no buscan el bien común, sino satisfacer rencores, eliminar competencia o simple caos.

## Lista de Contratos (Crimeboid Feed)

### 1. El Yakuza Deshonrado
- **Encargo:** "Matar y dejar sin ropa a cierto zombie (un antiguo líder Yakuza) en estas coordenadas [X,Y]. Está protegido por su antigua 'familia' (horda de 40 zombies)."
- **Recompensa:** $10,000.
- **Lore:** "Si no puede descansar con honor, que descanse con frío."

### 2. Vandalismo Inmobiliario
- **Encargo:** "Destruir los ventanales y vandalizar la sala principal de esta casa en [X,Y]. No soporto ver que alguien viva mejor que yo."
- **Recompensa:** $7,500.
- **Objetivo:** Destruir X cantidad de muebles o paredes en la zona.

### 3. El Desguace del Jefe
- **Encargo:** "Localizar un deportivo rojo en [X,Y] y destruirlo completamente. Era de mi ex-jefe y prometí que nadie más lo conduciría."
- **Recompensa:** $3,500.

### 4. El Sabotaje del Karaoke (Nuevo)
- **Encargo:** "Ve al bar de Riverside y destruye todas las radios y micrófonos. Estoy harto de que los zombies sigan reproduciendo 'esa' canción por las noches."
- **Recompensa:** $4,200.

### 5. El Gran Robo de Gnomos (Nuevo)
- **Encargo:** "Mi vecino tenía una colección de Gnomos de Jardín en [X,Y]. Róbalos todos (mínimo 5) y tráemelos. Quiero que vea mi jardín desde el cielo y sufra."
- **Recompensa:** $6,000.

### 6. El Chef Envidioso (Nuevo)
- **Encargo:** "Entra en la cocina de la mansión en Louisville y quema todos los libros de cocina que encuentres. Si yo no puedo cocinar un risotto decente, nadie más tendrá la receta."
- **Recompensa:** $8,000.

### 7. Multa de Estacionamiento Extrema (Nuevo)
- **Encargo:** "Encuentra el auto en [X,Y], quítale las 4 ruedas y déjalas en el maletero. Solo quiero que el dueño se lleve una sorpresa si decide volver a la vida."
- **Recompensa:** $5,500.

### 8. Crisis del Papel Higiénico (Nuevo)
- **Encargo:** "Un 'prepper' en los suburbios de West Point tiene un alijo masivo de papel higiénico. Quémalo todo. Ver su reserva de 100 rollos convertida en cenizas no tiene precio."
- **Recompensa:** $2,500.

### 9. La Venganza de los Disfraces (Nuevo)
- **Encargo:** "Entra en la tienda de disfraces invadida por zombies con trajes de animales. Recupera el retrato de un perro que hay en la oficina del fondo. No preguntes para qué."
- **Recompensa:** $9,000.

### 10. Operación "Bolsa en la Puerta" (Nuevo)
- **Encargo:** "Pon un trapo sucio quemado o basura justo en la puerta principal de la estación de policía. Un pequeño mensaje de parte de los antiguos residentes."
- **Recompensa:** $1,200.

## Mecánicas de Crimen
- **Notoriedad:** Realizar estas misiones aumenta tu nivel de búsqueda (Wanted Level). Si es muy alto, los servicios de la Corporación S4 podrían cobrarte "tasas de riesgo" más altas.
- **Anonimato:** Las misiones se aceptan con un alias. 
- **Verificación:** El sistema detecta la destrucción de tiles o la posesión de ítems específicos mediante `OnObjectAboutToBeRemoved` o chequeos de inventario.

---
*Documento creado para planificación futura en la rama `Crimeboid.net`.*
