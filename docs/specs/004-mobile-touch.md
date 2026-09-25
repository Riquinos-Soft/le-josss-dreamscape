# Spec 004 — Navegador móvil en horizontal

Solicitud: jugar al prototipo publicado sin teclado, mando ni ratón.

- Joystick izquierdo analógico relativo a la cámara; un dedo mantiene su control
  aunque salga del círculo. Soltar, cancelar, perder foco, cambiar tamaño o
  reaparecer elimina la entrada para evitar movimiento atascado.
- Un segundo dedo puede recoger, iniciar colocación, apuntar tocando el suelo,
  girar 90 grados, confirmar y cancelar. Los controles no apuntan al mundo ni
  confirman por la emulación de ratón. Se conserva identidad y validación del objeto.
- Controles sólo en pantallas táctiles (argumento `--touch` para pruebas locales).
  Teclado y ratón de escritorio conservan su comportamiento.
- En móvil vertical se oculta el juego tras un mensaje para girar y se pausa
  la simulación. Volver a horizontal recupera la partida sin movimiento pendiente.
  No se depende del bloqueo de orientación del navegador, que puede no estar disponible.
- UI con márgenes y objetivos grandes, adaptada al viewport expandido existente.
- Sin cambios de motor, cámara, renderer, persistencia ni servicios.

Aceptación: pruebas de movimiento real, multitáctil, ciclo de objeto, cancelación,
foco y vertical/horizontal; regresiones existentes; ejecución nativa; export Web.
Publicar el export probado en el receptor OVH y comprobar `/release.txt` público.
La emulación de navegador no sustituye la prueba física en Chrome Android/Safari iOS.
