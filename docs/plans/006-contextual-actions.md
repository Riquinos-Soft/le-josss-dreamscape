# Acciones táctiles disponibles y presentación

- Base: `1a82e5f`; árbol limpio. Spec: `005-beta-controls-and-pixels.md`.
- Propietario/integrador: Codex, sin delegación. Estado: done, publicado `8cd29e0`.
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

Push y publicación del receptor `1790313532-1` completados. HTTPS `/release.txt`
coincide con `8cd29e07b19bd4799b49ad10b9a2b83b646a3cf6`; HTML/WASM/PCK responden
200. Edge móvil sobre esa URL verifica el ciclo y el paseo alejándose del objeto:
la captura `mobile-no-actions.png` muestra la desaparición de Recoger y de su texto.
Sin errores de consola. La etiqueta `beta-01-touch-pixels` sigue intacta.
