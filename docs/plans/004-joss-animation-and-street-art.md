# Plan delegable — Animación de Joss y normalización de la calle

Estado: **ejecución parcial autorizada por el desarrollador el 2026-09-25**.
D01/G01/G02/G04 e I01 completados para animación. G03 (vegetación)
no se ejecuta en esta petición. R01 sigue pendiente de revisión artística del
usuario. Ejecución secuencial por el agente disponible; Grok no está conectado.
Base al activar: `9c0bd9f75259d669a763cddb965e695764219a68`; árbol limpio.

Contrato ejecutado: cuatro frames por dirección a 8 FPS (32 celdas, 4×8),
conservando tamaño, pivote y escala. Sustituye la propuesta inicial de seis frames
tras inspeccionar las poses generadas. Los muros usan alfa continua suave:
el desarrollador rechazó expresamente el tramado de puntos.

## Objetivo y contexto

Completar una siguiente iteración visual de la calle existente sin crear otra
demo: caminar con Joss animado, mantener pies/escala estables, y sustituir una
zona acotada de vegetación escaneada por masas pixel coherentes. Conservar asfalto,
acceso al garaje, transparencia de muros, movimiento, límites y respawn.

Leer antes de planificar ejecución:

- `docs/specs/002-street-trial.md`, alcance y estado real de la calle.
- `docs/specs/003-agent-workflow.md`, escalado y propiedad de archivos.
- Game Bible: [arte](https://app.notion.com/p/3e678dc87e92814fb15ed3373c8cca85),
  [assets](https://app.notion.com/p/3e678dc87e92816687f4e0a522ed4f56) y
  [personajes](https://app.notion.com/p/3e678dc87e928129b15bc2c833de2e09).
- `game/assets/art/characters/char_joss_idle_directions_v02.json` y su PNG (8 direcciones).
- `references/joss-character-v2-reference.png`, ficha maestra actual aportada por el desarrollador.
- `game/world/jacobo_risa_street.gd/.tscn`, sólo las partes indicadas por tarea.

Base: el integrador debe registrar `git rev-parse HEAD` al activar el plan. No
usar un SHA de ejemplo. Registrar también `git status --short`; no incluir
cambios locales previos ajenos en las entregas.

Fuera de alcance: interiores, viajes por portal, casa/bar nuevos, diálogo,
inventario, NPCs, persistencia, sistemas genéricos, cambio de motor/renderizador,
publicación, PRs, animación por IA de vídeo o contratación de nuevos proveedores.

## Contratos provisionales que se conservan

Para esta prueba únicamente: adulto de 1.8 m, cuerpo de 48 píxeles lógicos,
celda 64x64, pivote de pies (32,60), 0.0375 m por píxel, textura nearest sin mipmaps,
cámara ortográfica de 13.5 m de alto, mundo a 360 filas lógicas a 720p (escala 2x).
El HUD conserva resolución independiente. Son valores de prueba, no un estándar
global aprobado ni una sustitución silenciosa de los pendientes de la Bible.

La cápsula existente de 0.35 m de radio y 1.8 m de altura sigue siendo física.
Los sprites no añaden colisiones. Los materiales de fachada conservan el recorte
local con `street_wall_fade.gdshaderinc`; nunca volver transparente toda la calle.

## Orden y propiedad

| ID | Resultado | Ejecutor preferido | Depende de | Escritura exclusiva |
| --- | --- | --- | --- | --- |
| D01 | Cerrar las decisiones de esta oleada | Astra sólo para las decisiones abiertas | Activación del plan | Plan/contratos, mediante integrador |
| G01 | Hoja walk normalizada y metadatos | Grok + herramienta de imagen disponible | D01 | Nuevos PNG/JSON de walk y fuente propia |
| G02 | Presentación idle/walk direccional aislada | Grok | D01; contrato G01, asset final para validar | Nuevo script y recurso de animación |
| G03 | Vegetación limpia alrededor del garaje | Grok/artista asistido | D01 | Nuevos assets de vegetación y manifiesto de posiciones |
| G04 | Pruebas de presentación | Grok distinto o ejecución secuencial | G01 y G02 | Nuevo test específico |
| I01 | Integración única y regresión | Integrador económico | G01–G04 | Escena, wrapper, Makefile, CI y docs de estado |
| R01 | Revisión visual y cierre | Integrador + desarrollador; Astra si hay decisión | I01 | Registro de aceptación |

G01/G02/G03 pueden avanzar en paralelo después de D01 si cada ejecutor tiene su
contexto y archivos reservados. G02 usa el contrato congelado, no inventa una
hoja temporal incompatible. Un cambio de G01 invalida primero a G02/G04. Sólo el
integrador modifica archivos compartidos o hace commits durante esa oleada.

## D01 — Decisiones antes de ejecutar

**Estado:** planned. **Salida:** contratos concretos, no código.

1. Comparar la última captura del garaje con la ficha de Joss y la plaza.
2. Confirmar si se conserva el contrato provisional para esta oleada. Si se
   quiere cambiarlo globalmente, solicitar Astra con dos alternativas y efecto
   en sprites, cámara, UI y assets ya importados. No bloquear por esto tareas
   que sólo conservan el contrato existente.
3. Ocho direcciones ya solicitadas por el desarrollador, incluyendo diagonales.
   Propuesta local para walk: 6 frames por dirección, 8 FPS, loop; spritesheet de
   4 columnas por 8 filas, cada celda 64x64, orden de filas
   down/up/left/right/down_left/down_right/up_left/up_right, pivote (32,60),
   altura máxima 48 px. El número de frames/FPS sigue siendo una propuesta.
4. Precisar si se aprueba generar esos assets y con qué herramienta disponible.
   No prometer generación visual desde Grok si esa conexión no tiene herramienta.
5. Mantener `interact` fuera de esta oleada; documentar que el slice completo de
   la Bible pide más estados y no queda cumplido por este plan.
6. Cambiar G01–G03 a ready sólo cuando contratos y propietarios estén anotados.

**Aceptación:** no quedan dudas sobre tamaño, orden, FPS, pivote ni alcance.

## G01 — Asset walk de Joss

**Lectura mínima:** JSON de idle, fuente/prompt en `assets/source/ai/`, sección
Spritesheet contract de Notion y contrato D01.

**Archivos permitidos:** nuevos `assets/source/ai/char_joss_walk_directions_v01.*`
y `game/assets/art/characters/char_joss_walk_directions_v01.png/.json/.png.import`.
No editar el idle aprobado para la prueba ni el controlador.

**Pasos:**

1. Comprobar que idle abre y conservar turquesa, mochila marrón, peinado, bigote,
   zapatos y proporciones. No sustituir identidad por un aventurero genérico.
2. Preparar prompt con exactamente el contrato D01. Ejecutar la herramienta
   autorizada disponible, o entregar el prompt como bloqueo de producción de
   imagen; no afirmar que un archivo ha sido generado si falta esa capacidad.
3. Conservar fuente original, prompt exacto y procedencia. Normalizar cada frame
   sin desplazar el pivote ni estirar el cuerpo entre direcciones.
4. Verificar transparencia y ausencia de halos, recortes de pies/mochila,
   elementos adicionales y cambios de ropa. Inspeccionar a 1x y 2x.
5. Registrar frame_width/height, frame_count, directions, fps, loop, pivot,
   body_height, producción=draft y rutas de fuente/runtime en JSON.
6. Entregar hoja, metadata y evidencia. Un preview GIF es útil, no el maestro.

**Aceptación:** 32 frames y orden exacto seg?n D01; pies en
el mismo apoyo; silueta consistente; nearest; fuente reproducible; no runtime
de vídeo ni atlas de resolución excesiva. No marcar approved sin revisión.

**Pedir Astra:** sólo si el movimiento exige cambiar escala o contrato común.
Un frame defectuoso se corrige con la herramienta de arte o se reporta, no se
convierte en una decisión arquitectónica.

## G02 — Presentación del personaje, sin tocar movimiento

**Lectura mínima:** `_process` del wrapper actual, escena del jugador, cámara,
metadata de idle y contrato D01/G01.

**Archivos permitidos:** `game/player/street_character.gd` y
`game/assets/art/characters/char_joss_animations_v01.tres` (ambos nuevos).
El integrador conecta el nodo; no editar `player.gd`, cámara compartida o wrapper.

**Contrato:** script de presentación sobre `AnimatedSprite3D`, exportaciones
`movement_actor: CharacterBody3D` y `movement_view: Camera3D`. Recurso con 16
animaciones: `idle_` y `walk_` para down/up/left/right/down_left/down_right/up_left/up_right. Mantener los
nombres exactos. Ningún singleton, estado de inventario ni sistema de eventos.

**Pasos:**

1. Crear los clips a partir de los atlases y metadatos entregados; no codificar
   coordenadas que contradigan el JSON.
2. Elegir dirección relativa a cámara usando velocidad horizontal real. Umbral
   inicial 0.1 m/s; conservar última dirección al detenerse. Resolver empate
   diagonal de forma determinista y documentar la elección.
3. Idle parado, walk cuando hay desplazamiento; detenerse contra un muro no debe
   seguir mostrando avance por usar sólo intención de teclado.
4. Conservar pivote, escala, nearest, alfa recortada y billboarding de la prueba.
5. Evitar reiniciar la animación cada frame cuando su nombre no cambia.
6. Exponer sólo lo necesario para G04; no añadir API genérica de animación.

**Aceptación:** ocho direcciones reales; transición estable idle/walk; detenerse y
reanudar sin saltos de escala; animación a FPS del contrato; movimiento y respawn
siguen siendo responsabilidad del controlador existente.

**Pedir Astra:** si hace falta cambiar el contrato del controlador o la cámara.

## G03 — Masas vegetales de la zona del garaje

**Lectura mínima:** referencia de plaza, captura original del garaje, shader del
scan y `add_plant_accents`. Zona de trabajo: tramo Z=16..28 del mapa actual.

**Archivos permitidos:** assets nuevos versionados dentro de
`game/assets/art/vegetation/`, fuentes propias fuera de runtime y un manifiesto
`assets/source/ai/jacobo_garage_vegetation_v01.json`.

**Pasos:**

1. Identificar en el original qué es muro y qué vegetación. Mantener el hueco de
   entrada, la explanada y el asfalto; no esconder errores de suelo con plantas.
2. Producir como máximo dos variantes de masa vegetal, con paleta y densidad
   compatibles con Joss, silueta a 1x y transparencia limpia. Usar el contrato de
   píxel provisional, no otra densidad elegida por comodidad del generador.
3. En el manifiesto, listar posición XYZ en metros, variante, escala/pivote y qué
   fragmento del scan se propone ocultar. No escribir máscaras globales a ciegas.
4. Separar lo fiel (posición, volumen aproximado) de lo reinterpretado (hojas,
   flores, paleta nocturna). No añadir iluminación o decoración narrativa nueva.
5. Entregar composiciones de referencia y nota sobre posible oclusión. Colisión
   explícitamente ausente en los sprites; los límites pertenecen al wrapper.

**Aceptación:** menos ruido fotográfico, entrada reconocible y despejada, no más
de dos texturas nuevas, lectura coherente y sin tapar permanentemente a Joss.

**Pedir Astra:** si se propone reemplazar todo el mapa o cambiar el render pipeline.

## G04 — Pruebas de presentación

**Archivos permitidos:** `game/tests/test_street_character.gd` nuevo. Integrador
añade el test a Makefile/CI, no este ejecutor.

1. Cargar la presentación real y sus recursos, no una copia de su lógica.
2. Comprobar existencia/duración de clips, dimensiones de frames y pivote.
3. Probar ocho direcciones con cámara actual y una orientación alternativa,
   incluyendo los límites de sectores de 22.5 grados.
4. Probar idle tras movimiento, empates diagonales, bloqueo por pared y que una
   actualización repetida no reinicie continuamente el ciclo.
5. Salir distinto de cero ante fallo y registrar cada caso con nombre legible.
6. Entregar `godot --headless --path game --script res://tests/test_street_character.gd`
   con salida real. No declarar validación visual a partir de un test headless.

**Aceptación:** detecta regresiones observables, no tests de getters o constantes
sin conducta. No cambia implementación para ocultar un fallo.

## I01 — Integración y regresión

**Propietario:** único integrador. **Archivos reservados:** wrapper/escena de calle,
Makefile, `.github/workflows/ci.yml`, specs, README y lista de tareas.

1. Revisar los tres diffs y G04. Confirmar que no hay escrituras solapadas.
2. Sustituir el nodo de presentación por AnimatedSprite3D y asignar las referencias
   exportadas. Retirar sólo el código direccional ya sustituido del wrapper.
3. Incorporar vegetación del manifiesto y ocultar únicamente fragmentos acordados.
4. Ejecutar `gdformat --check game`, `gdlint game`, importación headless y tests
   existentes más G04. Leer los logs porque Godot puede terminar con código 0
   después de un error de script al arrancar.
5. Ejecutar nativamente la escena; capturar spawn, entrada al garaje, personaje
   detrás de muro, idle y walk a 1280x720 y 800x600.
6. Exportar Web: `godot --headless --path game --export-release Web ../build/web/index.html`.
   Preparar la preview de calle sin cambiar el main_scene del patio en el código.
7. Medir payload y comprobar errores. Si cambia rendimiento o presupuesto,
   documentar evidencia antes de prometer el mismo objetivo.
8. Crear commits locales por unidades que funcionen; no push ni PR. Anotar SHA
   y desbloquear R01 sólo con las comprobaciones realizadas.

## R01 — Revisión y aceptación

- Recorrer calle → explanada → puerta → calle, y ambos extremos.
- Mantener movimiento contra los bordes y provocar una caída excepcional.
- Verificar que las fachadas dejan ver al personaje sin perder colisión.
- Revisar píxel, pies y silueta a tamaño real, sin juzgar sólo una imagen ampliada.
- Probar gameplay Web en Chrome/Safari y registrar versión/OS/resultado cuando
  realmente se haga. Export/HTTP no sustituyen esa validación.
- El desarrollador revisa el parecido y el acabado; hasta entonces arte=draft.
- Registrar done sólo para tareas aceptadas; una limitación pendiente no desaparece
  porque se haya agotado el tiempo de un agente.
