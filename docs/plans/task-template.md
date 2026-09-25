# Plantilla de plan y paquete delegable

Copiar y completar. No entregar campos vacíos como si fueran requisitos resueltos.
Una tarea pequeña puede ser breve; una tarea compleja necesita todos sus contratos.

## Cabecera del plan

- Objetivo observable y spec asociada:
- Referencias exactas de Game Bible / diseño:
- Commit base y cambios locales previos:
- Estado y fecha de última revisión:
- Decisiones cerradas / pendientes de Astra:
- Integrador único:
- Fuera de alcance:
- Orden de dependencias y oleadas paralelas:
- Archivos compartidos reservados al integrador:

## Paquete `<ID> — <resultado>`

### Asignación

- Estado: planned / ready / running / review / done / blocked.
- Ejecutor preferido y capacidad comprobada:
- Propietario real de la tarea:
- Dependencias que deben estar entregadas:
- Tamaño previsto / presupuesto explícito, si existe:

### Contexto mínimo

1. Leer `<ruta:sección>` para entender `<contrato>`.
2. Leer `<ruta>` para reutilizar `<comportamiento existente>`.
3. No releer todo el repo; si falta una entrada, describir cuál y su impacto.

### Límites de edición

| Archivo permitido | Cambio permitido | Propietario |
| --- | --- | --- |
| `<ruta>` | `<responsabilidad>` | `<ID>` |

Prohibido tocar: `<archivos / contratos / áreas>`.
Si se descubre una modificación fuera de la lista, explicar por qué al integrador
antes de escribirla; no asumir permiso sobre archivos reservados a otro agente.

### Contrato de entrada/salida

- Entradas: formatos, dimensiones, nombres, estado previo, unidades.
- Salidas: rutas, tipos, campos, señales, APIs o assets exactos.
- Comportamiento observable: disparador → resultado.
- Errores/bordes: casos que deben conservar estado o fallar explícitamente.
- Invariantes que no se pueden cambiar.

### Pasos ejecutables

1. Comprobar precondiciones con `<comando/lectura>`.
2. Implementar `<acción localizada>` reutilizando `<pieza existente>`.
3. Cubrir `<casos relevantes>` sin añadir tests que sólo repitan la implementación.
4. Ejecutar `<comandos precisos>` y leer salida, no sólo código de salida.
5. Inspeccionar `<captura/resultado>` a `<resolución/condiciones>` si es visual.
6. Entregar el paquete con el formato siguiente; no hacer cambios fuera de alcance.

### Criterios de aceptación

- [ ] `<criterio verificable con prueba o evidencia concreta>`.
- [ ] `<regresión que debe permanecer intacta>`.
- [ ] `<limitación registrada con honestidad>`.

### Cuándo detenerse y pedir Astra

`<decisión concreta no resuelta que requiere revisión; no "si hay problemas">`.
Los fallos de sintaxis/importación o una corrección local siguen siendo del ejecutor.

### Entrega del ejecutor

```text
Tarea / versión de paquete / commit base:
Resultado observable:
Archivos cambiados:
Pruebas: comando → resultado → ruta del log:
Evidencia visual:
Limitaciones / decisiones pendientes:
Cambios fuera del paquete: ninguno, o detallar autorización:
Tiempo / reintentos / coste real disponible:
Estado propuesto: review, no done sin integración:
```

### Revisión del integrador

- Revisar diff y confirmar propiedad de archivos.
- Comprobar todos los criterios con la evidencia entregada.
- Ejecutar las pruebas de integración afectadas; repetir sólo si hay motivo.
- Resolver conflictos sin descartar trabajo ajeno.
- Crear commit atómico y registrar SHA, resultado y siguiente tarea desbloqueada.
