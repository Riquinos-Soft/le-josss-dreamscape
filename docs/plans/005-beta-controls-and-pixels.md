# Plan Beta 01

- Base: `eb46cfd`; árbol limpio. Propietario e integrador: Codex, sin delegación.
- Spec: `docs/specs/005-beta-controls-and-pixels.md`; petición directa del usuario.
- Decisiones: ajuste visual beta reversible con los shaders existentes, sin nuevo
  estándar artístico, cambio de cámara ni modificación de colisiones.
- Alcance: controles táctiles, coordinación de colocación, pruebas táctiles,
  shaders de pixelado/escaneo/asfalto y capturas/documentación de comparación.
- Orden: guardar antes; simplificar estados y arrastre; retocar shaders; pruebas,
  inspección nativa/Web; commit y push de la rama; publicación y comprobación HTTPS.
- Fuera de alcance: nuevos assets generados, infraestructura, cambios en main.
- Estado: review; implementación y export verificados, publicación pendiente.
  Presupuesto/coste no disponible.
- Validación: 56 comprobaciones táctiles sobre ambas escenas, 33 de objeto en
  calle y 63 de ciclo en patio correctas; lint/formato y export Web correctos.
  Edge 152 con emulación móvil: recogida, inicio de colocación delante, dos botones,
  bloqueo vertical y retorno horizontal; sin errores de consola.
- Capturas comparables guardadas en `references/beta-01/`. El ajuste reduce el
  detalle del personaje junto con el mundo deliberadamente para esta comparación.
- Limitaciones: pruebas físicas Android/iOS pendientes. Persiste el aviso de
  `pkg_resources` del linter. Los despliegues de main pueden reemplazar la beta.
