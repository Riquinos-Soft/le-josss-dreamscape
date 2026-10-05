# Spec 003 — Pazo de Lourizán y viaje entre lugares

Estado: plan preparado el 2026-10-05; implementación pendiente. Nueva prioridad del usuario. Se han recibido los enlaces de Scaniverse y Google Photos. Se inspeccionaron los metadatos y previsualización del escaneo, se descargaron su malla Draco y textura, y se inspeccionó la miniatura del vídeo. El vídeo completo no pudo descargarse (HTTP 500); la malla todavía no se ha decodificado. Esta spec permite implementar por fases con Sol u otro modelo de implementación, sin una nueva auditoría completa en cada turno.

## Resultado buscado

Recorrer una primera versión reconocible del Pazo de Lourizán, Pontevedra, basada en el material del usuario. Conectar **Casa ↔ Pazo de Lourizán** mediante una acción explícita en los bordes: acercarse a una salida, abrir mapa, seleccionar destino y aparecer en una entrada segura del destino. Poder regresar por el mismo sistema.

«Primera versión de todo» comprende los dos lugares, sus salidas, el mapa y el viaje de ida/vuelta. El alcance físico de Lourizán será toda la zona útil documentada por la captura y el vídeo, acordada en fase 0. No equivale a afirmar que tenemos cobertura de toda la finca. Los interiores requieren referencias; si no aparecen, la primera entrega cubre exteriores. La ampliación de la casa a tres plantas y al bar permanece en Spec 002, pendiente de sus referencias.

## Base que se reutiliza

- Godot 4.7.2, GDScript, Compatibility y exportación Web sin hilos.
- Escaneo de casa aprobado, movimiento WASD/flechas y botón derecho, cámara elevada, ayuda para escalones y protección de bordes abiertos.
- Escalera modular ya comprobada; reutilizar solo donde corresponda al lugar real.
- Modelo de identidad de objetos e inventario existente. Su demostración vive en el patio y presupone un único suelo plano: no trasladarla automáticamente a Lourizán.
- Pipeline offline GLB → Blender → GLB preparado → escena Godot. Ejecutar desde checkout limpio no exige Blender ni el original.

Base de referencia: commit `2825626`; 189 checks y exportación Web registrados en desarrollo. Son resultados previos, no validación de esta spec. El paquete Web anterior mide 63,25 MiB y está cerca del límite provisional de 64 MiB de Spec 002.

## Experiencia y reglas del viaje

1. Cada lugar tiene inicialmente una salida señalizada y una entrada de llegada. Son puntos jugables elegidos con las referencias, no cualquier agujero del escaneo.
2. Al entrar andando en su `Area3D`, aparece **«M · Abrir mapa»** y un botón equivalente. Fuera de una salida, no se abre el selector de viaje. Tocar el borde nunca cambia de lugar automáticamente.
3. El mapa muestra Casa y Pazo de Lourizán como destinos con nombre, ubicación esquemática y selección visible. Señala «Estás aquí» y desactiva el destino actual. Destinos aún sin escena válida no son seleccionables.
4. Elegir un destino muestra el botón **«Viajar»**. Escape o «Volver» cierra el mapa y devuelve el control en el mismo lugar y posición. Ratón y teclado pueden seleccionar/confirmar/cancelar.
5. Mientras el mapa está abierto o se carga el destino, el personaje no se mueve; los clics del mapa no llegan al juego. Al recuperar control se vacía la intención de movimiento y el estado del botón derecho. Perder foco no deja teclas ni viajes pendientes.
6. Confirmar activa una transición breve con «Cargando…» y bloquea confirmaciones repetidas. Cambia únicamente el lugar, conserva el mismo personaje de sesión y coloca sus pies en un `Marker3D` validado sobre suelo firme. Velocidad a cero y cámara reajustada: no arrastrar su interpolación desde las coordenadas anteriores.
7. La llegada queda separada del área de salida. No debe abrirse el mapa, iniciarse otro viaje o caer del escenario al llegar.
8. Si faltan el recurso o la entrada, se conserva el origen y se muestra un error recuperable. No liberar el origen hasta validar el destino. Siempre se puede volver al juego; no quedar tras una pantalla de carga.

Mapa inicial: panel 2D esquemático con dos marcadores seleccionables; no necesita servicios cartográficos, conexión ni coordenadas personales. Una base geográfica precisa podrá añadirse después con datos y atribución adecuados. No se simula el trayecto entre Pontevedra y la casa ni se inventa su distancia.

## Composición propuesta, limitada a dos lugares

Una raíz de sesión conserva `Player`, `CameraRig`, el mapa y un `LocationSlot`. Cada lugar aporta geometría, entorno/luz, `Arrival` y `Exit`; no crea otro jugador, cámara ni inventario. Solo un lugar queda activo tras cada viaje. No autoload, registro genérico, streaming por celdas, backend ni guardado.

Archivos propuestos (crear solo cuando la fase los necesite):

- `game/world/dreamscape.tscn` y `dreamscape.gd`: composición de sesión y cambio de lugar.
- `game/world/locations/home.tscn`: geometría aprobada de casa, llegada y salida.
- `game/world/locations/lourizan.tscn`: geometría del nuevo lugar, llegada y salida.
- `game/world/travel/exit.tscn` y `exit.gd`: área y señal de disponibilidad, sin decidir qué mundo cargar.
- `game/world/travel/travel_map.tscn` y `travel_map.gd`: selector modal de los dos destinos.
- `game/assets/lourizan/`: GLB y texturas de ejecución.
- `assets/source/lourizan/README.md` y `preparation.json`: procedencia, escala, ajustes y cobertura.
- `game/tests/test_location_travel.gd`: comportamiento de salidas, cancelación, viaje, retorno y fallos.

Conservar `home_exterior.tscn` como envoltorio ejecutable de la casa para los tests existentes. Extraer su geometría a una escena reutilizada por ambos envoltorios, conservando materiales y colisión; evitar dos copias divergentes del escaneo. La nueva raíz pasa a ser escena principal solo cuando la ida/vuelta esté comprobada. El patio sigue ejecutable para verificar objetos.

Carga: preparar el recurso del destino mientras se muestra el estado de carga; comprobar su estructura antes del intercambio. Una instancia entrante puede coexistir brevemente, inactiva, con la saliente durante la validación. Medir ese pico y liberar origen/referencias después del intercambio. No precargar ambos escaneos al arrancar. La carga diferida no reduce por sí sola los bytes descargados del PCK Web.

Estado: conservar el personaje de sesión y evitar mover la identidad de objetos a las escenas de lugar. El viaje con objetos y la persistencia de cambios en lugares descargados no forman parte de esta primera entrega; no afirmar que ya funcionan. No añadir serialización ni un inventario nuevo.

Dentro de cada lugar se camina en una escena física continua; el mapa conecta lugares distintos. Esto extiende el alcance de ADR 004 sin sustituir su decisión sobre casa/calle/bar. Registrar la decisión concreta en un ADR breve al implementar la composición, no crear una arquitectura de mundos futuros.

## Referencias y fidelidad de Lourizán

Referencias recibidas: [Scaniverse](https://scaniverse.com/scan/tcmlw54mcgjhp2xd) y [Google Photos](https://photos.app.goo.gl/yXEAJaEVuWxP76n18). Véase [inventario y límites de evidencia](../../assets/source/lourizan/README.md). La previsualización muestra fachada parcial, terrazas, escalinatas y camino/plaza con parterre; la miniatura del vídeo muestra un camino arbolado. No se ha establecido su conexión espacial.

Datos iniciales de Scaniverse: malla (no splat), 264.177 triángulos declarados, volumen aproximado 22,98 × 46,31 m horizontal y 13,52 m vertical sin calibración. Material descargado: Draco 0,85 MB y JPEG 8,39 MB; aún no son un asset GLB de ejecución. Preferir exportación GLB si llega del usuario; alternativamente decodificar Draco offline y validar UV/orientación. No aplicar el script de preparación de casa directamente al `.drc`.

Recorrido candidato para la primera versión: camino/plaza pavimentada → escalinata → terraza junto a fachada → regreso al camino → salida al mapa. Validar al importar; es una propuesta basada en la previsualización, no una ruta comprobada. Extender hacia el camino arbolado solo cuando el vídeo o más captura establezca su trazado.

Fase 0 debe registrar: archivos y hashes, formato, límites y orientación, textura/triángulos, qué cubre el vídeo, zonas incompletas y una dimensión conocida si está disponible. Seleccionar varios fotogramas representativos con sus tiempos; no generar una reconstrucción a partir de cada fotograma por defecto.

El mapeo fija posiciones y volúmenes observados. El vídeo ayuda a identificar fachada, recorridos, desniveles, accesos y puntos reconocibles. No rellenar espacios desconocidos con arquitectura inventada. Las aproximaciones necesarias para caminar se documentan y mantienen la silueta y distribución observadas. Un borde jugable se coloca sobre terreno estable antes del fin del escaneo.

Reutilizar `tools/prepare_home_scan.py` solo tras leerlo y comprobar sus supuestos; parametrizar entradas/salidas si basta. Mantener los originales intactos, preparar copias offline y dejar GLB/texturas reproducibles dentro del repo. No introducir IA/reconstrucción adicional salvo que el material recibido lo haga necesario. El look pixelado se pospone hasta que el lugar y el viaje sean reconocibles y jugables.

## Fases pequeñas de implementación

Cada fase termina con algo inspeccionable, validación proporcional, actualización de estado y un commit local funcional. No mezclar fases para compensar información faltante.

### 0 — Inventario y alcance real (parcialmente completada)

Leer esta spec y `assets/source/home_scan/README.md`; inspeccionar el nuevo mapeo y vídeo. Crear la ficha de Lourizán con escala, cobertura, referencias y un recorrido propuesto sobre una vista del modelo. Identificar llegada, salida y puntos de referencia. Si falta una medida, declarar escala provisional. **Cierre:** se distingue qué se puede reconstruir ahora y qué no; ninguna distribución se presenta como observada sin evidencia.

### 1 — Lourizán visible

Preparar el GLB/texturas, crear `locations/lourizan.tscn` y un envoltorio de inspección con el personaje/cámara actuales. Primero conservar silueta y textura; simplificar solo lo necesario para importar y recorrer. **Prueba visual:** ejecutar la escena con F6 y comparar la vista con fotogramas del vídeo. **Cierre:** material, orientación y proporciones coherentes, sin recursos externos necesarios para ejecutar. No sustituir aún la escena principal.

### 2 — Primer recorrido físico

Añadir colisiones simplificadas, ajustar llegada sobre suelo y delimitar huecos/bordes. Corregir bloqueos del terreno y comprobar escaleras solo donde existan. **Prueba visual:** caminar desde la llegada pasando por los puntos reconocibles hasta la futura salida y volver, sin atravesar paredes ni caer. **Cierre:** recorrido nativo y una captura; registrar las limitaciones de cámara/cobertura. No ampliar el controlador sin un fallo concreto que lo justifique.

### 3 — Una sesión y lugares intercambiables

Leer `home_exterior.tscn`, su script y los scripts de jugador/cámara. Extraer el contenido de casa sin alterar su apariencia, crear la raíz de sesión y conectar temporalmente Lourizán como lugar inicial de prueba. Introducir solo el control de bloqueo/reanudación necesario en el jugador y un reajuste explícito de cámara al llegar. **Prueba:** casa y Lourizán funcionan bajo la misma composición, con un único jugador y cámara; los tests del escaneo y patio siguen pasando. Todavía sin viaje público.

### 4 — Salida y mapa

Añadir `Exit` a ambos lugares, acción `open_travel_map` en M, aviso y mapa modal. Elegir destino puede mostrar la selección antes de implementar la carga. **Prueba visual:** abrir cerca del borde, cancelar, volver a moverse; fuera del borde no se abre; teclado/ratón y pérdida de foco no filtran movimiento. **Cierre:** interfaz legible a 1280×720 y 800×600, ruta de cancelación funcional.

### 5 — Viajar y regresar

Conectar «Viajar» con preparación/validación/cambio de lugar. Añadir protección contra dobles confirmaciones, recuperación de fallo y entradas fuera de las salidas. **Prueba:** Casa → Lourizán → Casa, tres ciclos; comprobar mismo jugador, cámara reajustada, velocidad limpia y ausencia de instancias duplicadas. **Cierre:** flujo completo por la interfaz, sin teleport de debug; convertir `dreamscape.tscn` en la escena principal.

### 6 — Entrega Web y acabado mínimo

Añadir solo señalización y props necesarios para orientarse. Ejecutar los tests completos, importación desde checkout limpio, recorrido nativo y export Web. Servir y comprobar el recorrido en navegador; si no hay prueba real de navegador, dejar esa aceptación pendiente. Medir payload y el pico de memoria de la transición cuando sea posible; la antigua cota de 64 MiB no puede asumirse válida al sumar otro escaneo. Simplificar texturas/geometría o registrar un presupuesto revisado con cifras antes de aceptar. **Cierre:** capturas de ambos lugares y del mapa, pruebas registradas y limitaciones explícitas.

## Definition of Done

- Checkout limpio importa y ejecuta sin Blender, originales ni rutas personales.
- Casa aprobada y Lourizán basado en las nuevas referencias son recorribles con los controles actuales.
- Desde una salida se abre el mapa explícitamente, se elige el otro lugar, se llega sobre suelo y se puede regresar andando a la salida de ese lugar.
- Cancelar no desplaza al personaje; confirmar repetidamente no duplica escenas; fallo de carga permite seguir en el origen.
- Un jugador y una cámara activos tras cada transición, sin arrastre de movimiento/interpolación ni bucle de viaje al llegar.
- Colisiones, cámara y avisos permiten completar tres idas/vueltas. Sin movimiento a través de paredes ni desaparición del personaje bajo el terreno.
- Tests existentes conservados, nuevos tests de comportamiento pasando, export Web correcta y aceptación de navegador diferenciada de exportación.
- Documentación y assets reflejan procedencia, escala, cobertura real y resultados medidos.

## Instrucción reutilizable para Sol

> Implementa únicamente la siguiente fase pendiente de `docs/specs/003-lourizan-and-travel.md`. Comprueba primero Git y el estado de esta spec. Lee los archivos indicados para esa fase y sus dependencias directas; reutiliza las decisiones ya tomadas. Mantén el exterior aprobado y el controlador actual. No inventes zonas no documentadas ni añadas sistemas fuera de alcance. Verifica lo que cambia, registra comando/resultado/limitaciones en `docs/development.md`, actualiza el estado de la fase y crea un commit local funcional según AGENTS.md. Termina indicando qué puedo abrir y probar, el commit y el siguiente paso. Si falta un archivo o referencia imprescindible, identifica el dato concreto y completa solo trabajo independiente de él.

No hace falta cambiar de modelo para cada fase ni delegar a otros agentes. Si una fase crece, dividirla en dos resultados comprobables y anotar el punto de continuación. El plan no presupone precios o rendimiento de un modelo concreto.

## Estado para la siguiente sesión

- Fase 0: enlaces, inventario, hashes y previsualizaciones registrados. Pendientes inspección geométrica completa, vídeo reproducible y calibración.
- Fases 1–6: pendientes; no implementadas ni validadas.
- Primera acción: importar/decodificar la malla descargada para inspeccionar su cobertura; recibir el vídeo local/descargable para completar el trazado. La fachada y plaza capturadas permiten avanzar a fase 1 sin inventar el resto de la finca.
- Trabajo independiente disponible: fases 3–4 pueden prepararse usando casa y fixtures ligeros de test. No presentar esos fixtures como Lourizán ni habilitar un destino público sin su escena real.
