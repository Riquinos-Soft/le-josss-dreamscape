# Plan 006 — Available touch actions and presentation

- Base: `1a82e5f`; árbol limpio. Spec: `005-beta-controls-and-pixels.md`.
- Propietario/integrador: Codex, sin delegación. Estado: review, listo para publicar.
- Alcance: touch_controls.gd, sus pruebas y documentación; publicación Web.
- Contrato: Recoger depende de alcance y camino libre; Colocar de inventario;
  Girar de previsualización activa; Confirmar de posición válida. No desplazar
  Girar al ocultar Confirmar ni aceptar pulsaciones en zonas de acciones ocultas.
- Presentación: iconos propios dibujados con líneas, bordes, sombra y feedback
  de pulsación; no nuevos assets, dependencias, gestos ni cambios al mundo.
- Validación: distancia, obstáculos, recuperación de acciones, posición inválida
  y ciclo completo sobre ambas escenas; nativo, export y revisión Web móvil.
- Fuera de alcance: retocar el pixelado y sobrescribir la etiqueta Beta 01.

Validación: 76 comprobaciones táctiles pasan tanto headless como con renderizado
nativo; lint/formato y export Web correctos. Edge 152 con emulación móvil muestra
los nuevos iconos/bordes y completa recogida, colocación, giro y confirmación;
sin errores de consola. Capturas revisadas en `build/verification/mobile-*.png`.
Pruebas físicas Android/iOS pendientes. El linter mantiene su aviso de obsolescencia
de pkg_resources; no se han encontrado avisos de ejecución o exportación.
