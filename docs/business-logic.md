# Lógica de negocio

## Identificación y estado

Cada lead se identifica por su número de WhatsApp. Antes de interpretar una respuesta, el workflow consulta `public.leads` para recuperar su etapa, datos y `fecha_reset`.

La etapa persistida determina el significado de la siguiente respuesta. Una respuesta nunca debe interpretarse solo por su contenido sin considerar esa etapa.

## Precalificación determinista

Si el teléfono no existe, se crea el registro, se guarda el teléfono y el mensaje original, se establece la etapa inicial `estado` y se envía la primera pregunta.

Las etapas comerciales actuales son:

- `estado`: se validan Nuevo León, Ciudad de México y Estado de México. La opción “Otro” lleva a `rechazado` con su motivo y fecha de reset.
- `trabajo`: se valida el tiempo mínimo exigido por el proceso comercial. Si no cumple, pasa a `rechazado`.
- `subcuenta`: se valida el requisito mínimo de subcuenta de vivienda. Si no cumple, pasa a `rechazado`.
- `calificado` y `re_cita`: el usuario puede solicitar o rechazar una cita.
- `cita`, `fin` y `rechazado`: estados de resultado, espera o reactivación observados en la operación.

Una respuesta inválida vuelve a solicitar la opción correspondiente. Los motivos de rechazo y los datos comerciales se conservan en `public.leads`. La implementación de Airtable no cambió las condiciones de calificación ni las etapas anteriores.

## Reset

El reset se evalúa cuando el usuario vuelve a escribir después de que `fecha_reset` haya vencido. No es un proceso programado que cambie el estado exactamente en el instante del vencimiento.

## Solicitud de cita y salidas actuales

La respuesta afirmativa a la solicitud de cita conduce a la etapa persistida `cita`; no debe asumirse que el valor guardado sea `cita_si`.

Para un usuario que superó la precalificación y solicita cita, el tramo publicado realiza:

1. Actualiza la información correspondiente del lead en Supabase (`Si cita`).
2. Envía al usuario la respuesta de WhatsApp correspondiente (`Espera agente`).
3. Envía el aviso interno al agente mediante WhatsApp (`Aviso agente`).
4. Crea un registro comercial en Airtable (`Create a record`).

Los avisos por WhatsApp y la creación Airtable coexisten temporalmente. La retirada del aviso queda para una decisión posterior y no es requisito para el cierre de v1.2.

El registro Airtable representa una solicitud de cita de un usuario calificado. No significa que la cita tenga fecha u horario confirmados.

## Configuración de campos Airtable reportada

El nodo crea registros en “Base Leads Nueva” / “Leads global” con mapeo manual. Entre los campos documentados están `phone` desde el teléfono del lead, `state_google_ads` desde el estado, `source` con la etiqueta fija `BOT IA`, `Fuente_lead` con `Llamada IA`, `company` y `company_aux` con `Proconsultores`, y `no_llamar` activado. Las etiquetas `BOT IA` y `Llamada IA` identifican el origen comercial y no indican que el flujo use inteligencia artificial.

## Mantenimiento de reglas

La integración se añadió después de la precalificación. Las reglas comerciales existentes permanecen deterministas y no fueron redefinidas por la conexión con Airtable.
