# Spec 003 — Trabajo por tareas con Astra y ejecutores económicos

Estado: protocolo solicitado por el desarrollador. Documentado; la ejecución
automática con Grok no está conectada ni validada en esta sesión.

## Objetivo y límites

Reservar Astra para decisiones con riesgo de retrabajo y entregar la ejecución
acotada a Grok u otro modelo económico disponible. Reducir coste total, incluyendo
reintentos y revisión, no sólo el coste de una llamada. Este documento organiza
el trabajo: no añade un orquestador, backend, sistema de agentes ni dependencia
al juego. No cambia el motor ni las decisiones aceptadas del repositorio.

La Game Bible en Notion es la referencia de diseño/arte. La spec de una función
describe su alcance y aceptación; un plan en `docs/plans/` descompone su ejecución.
No crear una nueva spec por cada subtarea, ni convertir una propuesta en aprobada.

## Cuándo solicitar Astra

El ejecutor se detiene antes de implementar la parte afectada y solicita Astra
cuando necesita resolver cualquiera de estas decisiones:

- Cambiar arquitectura, contratos compartidos o un ADR aceptado.
- Fijar un estándar visual transversal: resolución lógica definitiva, unidades,
  cámara común, formato maestro de animación o pipeline de assets.
- Resolver requisitos incompatibles entre Game Bible, spec y código que puedan
  causar una migración o rehacer varios assets/sistemas.
- Diagnosticar un fallo demostrado entre varios subsistemas, o decidir una
  optimización basada en medidas cuando compromete diseño o compatibilidad Web.
- Ampliar el alcance o elegir entre alternativas con consecuencias costosas de
  revertir que no están resueltas en el paquete de tarea.

No se solicita Astra por renombrados, importaciones, errores de sintaxis, pruebas
fallidas con causa local, documentación o implementación de contratos ya fijados.
Una tarea larga no es automáticamente una decisión arquitectónica.

Formato de escalado, breve y concreto:

```text
Necesito revisión con Astra para <decisión>.
Tarea / paso detenido: <ID y paso>.
Evidencia: <fallo, medidas o requisitos concretos; archivos y líneas>.
Alternativas: A <impacto>; B <impacto>.
Recomendación y riesgo de seguir sin resolverlo: <...>.
Trabajo independiente que puede continuar: <IDs o ninguno>.
```

Se pide al usuario cambiar al modelo adecuado sólo si Astra no está ya activo
o autorizado para esa decisión. No repetir la petición ni simular un cambio de
modelo. Una respuesta de Astra debe cerrar una decisión concreta, actualizar el
contrato y devolver la tarea al ejecutor económico; no absorber toda la ejecución.

## Roles y responsabilidad

| Rol | Trabajo | No puede hacer por su cuenta |
| --- | --- | --- |
| Planificador/revisor Astra, cuando se necesita | Resolver decisiones difíciles, fijar contratos, revisar riesgo | Reabrir ADRs resueltos sin evidencia o convertirse en ejecutor de tareas rutinarias |
| Ejecutor Grok/económico | Implementar un paquete listo, probarlo y entregar evidencia | Cambiar contratos, ampliar alcance, marcar revisión visual del usuario como hecha |
| Integrador único | Reservar archivos, comprobar resultados, registrar pruebas, crear commits atómicos | Aceptar un resumen sin revisar el diff o hacer push automático |
| Desarrollador | Dirección de producto, aprobación artística y decisiones solicitadas | No se le pide confirmar cada acción reversible ya autorizada |

Grok es una preferencia de ejecución del usuario, no una capacidad supuesta.
Antes de asignar trabajo se comprueba qué modelos/agentes están disponibles.
Si Grok no está conectado, entregar el paquete para una sesión externa o usar
el modelo económico ya autorizado. No instalar proveedores, gastar créditos,
inventar tarifas o afirmar paralelismo que no se ha ejecutado.

## Ciclo de una tarea

`planned → ready → running → review → done`, o `blocked` con causa y siguiente paso.

1. Leer sólo la spec, páginas de Bible y archivos relevantes; registrar revisión
   base (`git rev-parse HEAD`) y cambios locales que no pertenecen a la tarea.
2. Resolver las decisiones abiertas antes de declarar el paquete `ready`.
3. Crear el plan con la [plantilla](../plans/task-template.md). Cada tarea contiene
   entradas, archivos permitidos, pasos, contratos, verificaciones y exclusiones.
4. Asignar un propietario por tarea y reservar sus archivos antes de escribir.
5. Ejecutar, inspeccionar resultados y corregir fallos locales. Guardar logs útiles,
   no volcar sesiones completas ni copiar secretos al paquete.
6. Entregar diff, pruebas con resultado real, capturas si aplica y limitaciones.
7. El integrador revisa el cambio, ejecuta la validación de integración pertinente
   y crea un commit local por unidad funcional. Sólo entonces pasa a `done`.
8. Actualizar estado del plan y documentación. No repetir toda la batería tras un
   cambio de texto ni volver a investigar decisiones que siguen siendo válidas.

## Paralelismo sin pisarse

- Las tareas con dependencias abiertas no arrancan, aunque haya agentes libres.
- Dos escritores no comparten un archivo. Los archivos de composición, las
  listas de tests, la spec y el registro de estado pertenecen al integrador.
- Lecturas/revisiones pueden ser paralelas; escritura sólo en conjuntos disjuntos.
- Se trabaja en la rama actual. No crear ramas/worktrees ni cambiar el flujo Git
  sin instrucción explícita; un workspace compartido exige integración secuencial.
- En una oleada paralela sólo el integrador hace commits. Evita que un agente
  incluya accidentalmente cambios ajenos. Con un único agente rige el commit
  automático habitual al terminar una unidad coherente.
- Un cambio del usuario invalida primero los paquetes afectados; el integrador
  avisa a sus propietarios y actualiza versiones/dependencias antes de continuar.
- Si no se puede garantizar propiedad exclusiva, serializar. Más agentes no
  garantiza menos coste ni menos tiempo.

## Control del coste y contexto

- Un paquete debe poder revisarse y probarse de forma independiente. Dividirlo
  por resultado observable, no por número arbitrario de líneas.
- Entregar al ejecutor una lista de lectura y contratos suficientes; no reenviar
  todo el historial ni pedir una auditoría completa del repo para cada tarea.
- No realizar la misma implementación con dos modelos para compararlos por defecto.
- Tras dos intentos fallidos dirigidos al mismo problema, resumir evidencia y
  revisar el diagnóstico. Pedir Astra si se cumple uno de los criterios anteriores;
  un error local repetido no autoriza una migración ni una escalada automática.
- Registrar tiempo/reintentos y tokens/coste real cuando el proveedor lo exponga.
  Si no están disponibles, poner `no disponible`; no estimar ahorro como un hecho.
- Cualquier presupuesto numérico se toma de lo acordado con el usuario. Este
  protocolo no autoriza gasto ilimitado, ni impone cuotas inventadas.

## Aceptación del protocolo

- Existe un plan concreto con dependencias y paquetes copiables para Grok.
- Cada paquete permite comprobar resultado, archivos y pruebas sin adivinar.
- Los bloqueos que requieren Astra incluyen evidencia y una decisión formulada.
- La integración conserva un único responsable de archivos compartidos y commits.
- Se distingue documentación lista de automatización realmente conectada.
- No se modifica gameplay, se crean PRs ni se publica nada por implementar este protocolo.
