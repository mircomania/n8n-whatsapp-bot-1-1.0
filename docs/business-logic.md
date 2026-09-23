# Lógica de negocio

## Identificación y estado

Cada lead se identifica por su número de WhatsApp. Antes de interpretar una respuesta, el workflow consulta `public.leads` para recuperar su etapa, datos y `fecha_reset`.

La etapa persistida determina el significado de la siguiente respuesta. Una respuesta nunca debe interpretarse solo por su contenido sin considerar esa etapa.

## Precalificación determinista actual

Si el teléfono no existe, se crea el registro, se guarda el teléfono y el mensaje original, se establece la etapa inicial `estado` y se envía la primera pregunta.

Las etapas comerciales actuales son:

- `estado`: se validan Nuevo León, Ciudad de México y Estado de México. La opción “Otro” lleva a `rechazado` con su motivo y fecha de reset.
- `trabajo`: se valida el tiempo mínimo exigido por el proceso comercial. Si no cumple, pasa a `rechazado`.
- `subcuenta`: se valida el requisito mínimo de subcuenta de vivienda. Si no cumple, pasa a `rechazado`.
- `calificado` y `re_cita`: el usuario puede solicitar o rechazar una cita.
- `cita`, `fin` y `rechazado`: estados de resultado, espera o reactivación observados en la operación.

Una respuesta inválida vuelve a solicitar la opción correspondiente. Los motivos de rechazo y los datos comerciales se conservan en `public.leads` según la lógica actual. La integración planificada con Airtable no cambia las reglas ni las condiciones de calificación.

## Reset

El reset se evalúa cuando el usuario vuelve a escribir después de que `fecha_reset` haya vencido. No es un proceso programado que cambie el estado exactamente en el instante del vencimiento.

La semántica completa de los campos que deben limpiarse o conservarse no se modifica en esta actualización documental. Tampoco se modifica la estructura de Supabase.

## Solicitud de cita y aviso actual

La ruta actual registra la solicitud de cita y envía un aviso al agente mediante WhatsApp. La respuesta afirmativa conduce a la etapa persistida `cita`; no debe asumirse que el valor almacenado sea `cita_si`.

Se reportaron ocho solicitudes de cita cuyos avisos no fueron recibidos por el agente. El dato no demuestra una causa común. El procedimiento temporal es que el agente inicie una interacción con el número del bot al menos una vez cada 24 horas, para mantener abierta su ventana de atención para mensajes normales. Es manual y no constituye una garantía permanente de entrega.

## Salida comercial prevista en v1.2

Cuando un usuario que superó satisfactoriamente la precalificación solicite una cita, `whatsapp-leads` actualizará el lead en Supabase y creará el registro correspondiente en Airtable. Esa creación sustituirá el aviso actual al agente mediante WhatsApp una vez implementada la integración.

El evento es la solicitud de cita del usuario calificado. El registro de Airtable no significa que exista una cita confirmada con fecha y horario. Las reglas comerciales y las etapas actuales se mantienen sin cambios.

La base, tabla, columnas y mapeo de datos se definirán durante la implementación. Supabase continuará siendo la base principal comercial y conversacional.
