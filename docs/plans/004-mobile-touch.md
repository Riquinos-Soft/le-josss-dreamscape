# Plan 004 — Mobile touch controls

- Base: `be68bc5d1fbe479848dcd7a0a86fc702ba5f5d6f`; árbol inicialmente limpio.
- Spec: `docs/specs/004-mobile-touch.md`; petición directa del desarrollador.
- Propietario e integrador único: Codex, ejecución secuencial, sin delegación.
- Decisiones cerradas: joystick relativo a cámara, botones de acciones existentes,
  pausa vertical; sin decisiones arquitectónicas pendientes.
- Archivos: player/touch_controls.gd, player.gd, items/item_loop.gd,
  courtyard.tscn, pruebas táctiles, listas CI/Makefile y documentación de controles.
- Pasos: implementar entrada y UI; probar casos de la spec y regresiones; exportar;
  revisar diff; commit local; publicar export mediante receptor restringido OVH.
- Fuera de alcance: cambios de infraestructura, PR, nuevos sistemas de juego.
- Push de la rama autorizado posteriormente por el desarrollador.
- Estado: done (2026-09-25); commit funcional `6396a87`, publicado y subido a
  `origin/feature-touchpad-movement-controls`. Coste/tokens: no disponible.
- Validación: 320 comprobaciones headless, 18 táctiles nativas, lint/formato y export
  Web pasan. Edge 152 con emulación táctil arranca sin errores de consola y muestra
  la UI horizontal, recogida y bloqueo vertical. Capturas en `build/verification/`.
- Avisos: importador del GLB existente asume byte stride; gdtoolkit avisa de
  pkg_resources obsoleto. Pruebas del receptor no ejecutables en Windows (`fcntl`).
- Publicación: receptor SSH restringido, release `6396a87305281afa207f9ca94d2000d6369c7881`,
  ejecución `1790311373-1`. HTTPS `/release.txt` coincide; HTML/WASM/PCK responden
  200 y WASM usa `application/wasm`. No cambios de infraestructura ni de `main`.
- Revisión visual final: aviso vertical legible, etiquetas de giro compatibles
  con la fuente exportada, objeto recogido mediante toque; consola sin errores.
- Pendiente únicamente: prueba física en Chrome Android y Safari iOS.

## Corrección tras aviso del desarrollador

La URL pública pasó a servir `860487b`, sustituyendo la publicación táctil anterior.
`origin/main` también cambió la escena inicial a la calle (`252581d`). Se integra
esa revisión en la rama de controles, conservando animaciones y objetos de la calle.
El HUD táctil se conecta a ambas escenas. La prueba táctil ejecuta ahora las dos:
36 comprobaciones correctas, incluyendo apuntado real sobre el suelo de la calle.
Las paredes transparentes bloqueaban el rayo de apuntado; se saltan sus caras
verticales sin omitir la validación de alcance y obstáculos desde el jugador.
Pruebas adicionales: objeto de calle 33 y ciclo de patio 63, sin fallos.

Corrección publicada: `9842a9b`, ejecución del receptor `1790312053-1`.
36 pruebas táctiles también pasan con renderizado nativo; lint/formato/export pasan.
Comprobación en la URL pública con Edge 152 en emulación móvil: calle con joystick
y botones, recogida mediante toque, aviso vertical y regreso a horizontal; sin
errores de consola. `/release.txt` y HTML/WASM/PCK verificados por HTTPS.
La rama de feature está subida; un futuro despliegue de `main` puede sustituir esta
publicación temporal mientras la corrección no se integre allí.
