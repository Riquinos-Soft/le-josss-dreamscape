# Plan 004 — Controles táctiles

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
