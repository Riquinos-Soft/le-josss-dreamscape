# Lourizán — referencias recibidas

Inspección inicial: 2026-10-05. Usuario identifica el lugar como Pazo de Lourizán, Pontevedra.

- [Escaneo compartido](https://scaniverse.com/scan/tcmlw54mcgjhp2xd): página y previsualización inspeccionadas. Malla Draco y textura descargadas desde los enlaces que publica esa página; hashes y tamaños en [source-report.json](source-report.json).
- [Vídeo compartido](https://photos.app.goo.gl/yXEAJaEVuWxP76n18): página accesible y miniatura inspeccionada. La URL MP4 publicada por la página devolvió HTTP 500. No se ha reproducido ni analizado el vídeo completo.

Metadatos declarados por Scaniverse: `mesh`, 205.373 puntos, 264.177 triángulos; límites aproximados 22,98 × 46,31 m horizontales y 13,52 m verticales en unidades de captura. Escala aún sin calibración con una medida real; los recuentos no se han comprobado decodificando la geometría.

La previsualización muestra una fachada parcial, terrazas, escalinatas y camino/plaza pavimentados con un parterre alargado. Hay cortes de captura y superficies ausentes; no hay evidencia de cobertura de toda la finca ni de interiores. La miniatura del vídeo muestra un camino arbolado, cuya conexión con el escaneo sigue pendiente.

Alcance inicial propuesto: recorrer el camino pavimentado, llegar a las escalinatas y terraza junto a la fachada y regresar. Validar continuidad y seguridad de ese recorrido al importar la malla. Ubicar salida y llegada sobre el camino estable, separadas entre sí; las coordenadas se decidirán sobre la geometría, no sobre esta miniatura.

Descargas locales y HTML de diagnóstico: `build/verification/lourizan/` (ignorado, no respaldado por Git). Malla `mesh.drc` de 853.382 bytes y textura `tex.jpg` de 8.389.733 bytes. El GLB reproducible está en `game/assets/lourizan/exterior.glb`; la receta es `tools/prepare_lourizan_scan.py` con las dependencias de `tools/requirements-lourizan.txt` (Python 3.13 usado). Se invierte V al convertir las UV a glTF; sin esa conversión la fotografía se aplica a regiones equivocadas. La textura se reduce a 4096 px y se guarda como JPEG; la colisión se simplifica a 55.000 triángulos. Ver [preparation.json](preparation.json). No introducir un decodificador Draco ni conexión a Scaniverse en el juego.

El usuario descartó el vídeo. Pendientes: calibrar con una medida real y ampliar la captura si se quiere recorrer más allá de esta zona. El pavimento capturado tiene huecos finos; un apoyo de colisión invisible bajo el tramo comprobado permite caminar sin alterar su apariencia. Ver [Spec 003](../../../docs/specs/003-lourizan-and-travel.md).
