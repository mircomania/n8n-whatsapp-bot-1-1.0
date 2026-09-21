# Lógica de negocio

## Identificación y estado

Cada lead se identifica por su número de WhatsApp. Antes de interpretar una respuesta, el workflow consulta `public.leads` para recuperar su etapa, datos y `fecha_reset`.

La etapa persistida determina el significado de la siguiente respuesta. Una respuesta nunca debe interpretarse solo por su contenido sin considerar esa etapa.

## Lead nuevo

Si el teléfono no existe:

1. Se crea el registro.
2. Se guardan el teléfono y el mensaje original.
3. Se establece la etapa inicial `estado`.
4. Se envía la primera pregunta.

La restricción única existente sobre `telefono` evita dos registros no nulos con el mismo teléfono, pero no evita procesar dos veces un mensaje.

## Etapas de precalificación

### `estado`

Las opciones admitidas incluyen Nuevo León, Ciudad de México y Estado de México. Una opción admitida se guarda y avanza a `trabajo`. La opción “Otro” lleva a `rechazado`, registra `motivo_rechazo = estado` y establece una fecha de reset. Una respuesta inválida vuelve a solicitar la selección.

### `trabajo`

Se comprueba el tiempo mínimo exigido por el proceso comercial. Si cumple, se guarda la respuesta y avanza a `subcuenta`. Si no, pasa a `rechazado`, registra el motivo y establece una fecha de reset.

### `subcuenta`

Se comprueba el requisito mínimo de subcuenta de vivienda. Si cumple, continúa hacia la calificación y el flujo de cita; si no, se rechaza con su motivo y fecha de reset.

### `calificado` y `re_cita`

El usuario puede solicitar o rechazar una cita. Una solicitud registra el avance, envía una confirmación y activa el aviso al agente. Un rechazo finaliza la ruta correspondiente y permite una reactivación posterior conforme al reset.

### `cita`, `fin` y `rechazado`

Son estados de resultado o espera observados en los datos. La reactivación no ocurre necesariamente en el momento exacto de vencer la fecha; se evalúa en la siguiente interacción.

## Reset: comportamiento actual

- Para rechazos se configura un reset de 24 horas.
- Para estados finales de cita/fin se utiliza el periodo configurado en el workflow.
- Si `fecha_reset` existe y es anterior a la hora actual, se ejecuta `Reset estado`.
- La implementación exportada solo actualiza `etapa = estado`.

La limpieza de `fecha_reset` y de otros campos de una precalificación anterior **no está implementada** en ese nodo. Debe definirse qué información se reinicia y cuál se conserva antes de corregirlo en v1.1. Una fecha vencida en la base no demuestra por sí sola un fallo, porque la comprobación depende de una nueva interacción.

## Protección temporal actual

El workflow compara `ultima_interaccion` y descarta interacciones con menos de 1500 ms de separación. Este control reduce respuestas rápidas destinadas a una etapa anterior, pero no es idempotencia: no usa `wamid`, no resuelve carreras y no garantiza entrega única de mensajes o avisos.

## Derivación humana

La ruta actual de cita incluye `Si cita -> Espera agente -> Aviso agente`. v1.1 debe asegurar que una respuesta duplicada no produzca varios avisos y que una notificación fallida pueda recuperarse después de registrar la cita.

## Evolución con IA

Una futura capa de IA podrá complementar la atención, pero no sustituir sin controles las reglas deterministas de precalificación. El diseño deberá hacer explícitos los límites y la transferencia entre automatización, IA y agente humano.
