# Beta 01 — Colocación sencilla y comparación visual

Petición del desarrollador: simplificar los controles táctiles y aumentar el
pixelado general, especialmente los setos del borde del camino. Esta es una
referencia beta para comparar; no fija el estándar definitivo de assets.

- Sin objeto: Recoger sólo si hay un objeto al alcance y sin obstáculos.
  Con objeto en inventario: un botón Colocar.
- Colocar muestra la previsualización a 1,3 m delante del personaje. Sigue delante
  mientras camina o gira hasta que se arrastra el objeto.
- Durante la colocación sólo se muestran Girar (90 grados, un sentido) y Confirmar.
  Confirmar se oculta cuando la posición no es válida; Girar mantiene su posición.
  Desaparecen el giro duplicado, Colocar y Cancelar de ese estado.
- Un toque en el suelo no desplaza el objeto. Arrastrar desde la previsualización
  lo mueve; al soltar conserva esa posición del mundo, aunque cambie la cámara.
- La colocación conserva alcance, colisiones, suelo inclinado e identidad.
  Una posición sin soporte se muestra roja y rechaza la confirmación.
  La previsualización no desaparece al arrastrarla fuera del camino: se puede
  volver a agarrar y corregir sin necesitar Cancelar.
- Joystick simultáneo, pérdida de foco y bloqueo vertical se mantienen.
- Mundo a unos 180 píxeles de alto, ampliado con vecino más próximo en bloques
  enteros de al menos 2 píxeles. HUD sin pixelar. Paleta del escaneo de 8 niveles
  por canal; verdes de vegetación agrupados en cuatro tonos; asfalto de grano mayor.
- Comparación: `references/beta-01/before-mobile.png` procede de la publicación
  anterior; `after-mobile.png` muestra la misma cámara y tamaño tras este ajuste.
  Anotar commit publicado y parámetros para reproducir la beta.

Interpretación aplicada tras preguntar y continuar sin respuesta: conservar
Colocar y retirar Cancelar. No cambiar controles de escritorio.

Validación: pruebas táctiles sobre patio y calle; ciclo de objetos; renderizado
nativo y Web con inspección de capturas; publicar y comprobar la URL pública.

Refinamiento de acciones: no se muestran instrucciones para recoger cuando no es
posible. Las zonas de acciones ocultas tampoco aceptan toques. Botones con iconos
vectoriales, contorno lavanda, confirmación verde, sombra y respuesta al pulsar;
se conservan las zonas táctiles y el texto nítido. La etiqueta Beta 01 original
permanece intacta como referencia previa a este refinamiento.
