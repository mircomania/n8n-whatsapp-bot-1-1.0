# Arquitectura

## Arquitectura de producción reportada

Referencia: **v1.3 multicampaña, 5 de noviembre de 2026**. El usuario confirmó los seis workflows publicados y las pruebas de los recorridos principales en Contabo. Se inspeccionaron los seis exports locales, sin acceder a producción. El inventario, los IDs reportados y la separación de evidencias están en [Estado actual](current-state.md).

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker / Contabo
  -> whatsapp-webhook
       -> ¿Es mensaje entrante?
            -> True: Edit Fields -> mensaje -> Call 'whatsapp-router'
                 -> whatsapp-router
                      -> servicio explícito / contexto / historial
                      -> si no resuelve: Seleccionar servicio -> fin
                      -> si resuelve: crear o actualizar contexto
                           -> Preparar despacho -> Destino final
                                -> whatsapp-leads -> public.leads
                                -> whatsapp-laudo -> public.leads_laudo
                           -> respuesta WhatsApp / Airtable al solicitar cita
                 -> Respond to Webhook
            -> False: Confirmar evento Meta (HTTP 200 sin cuerpo)
       -> detectar estado failed con código 131042
            -> whatsapp-incidentes (sin esperar)
       -> errores asociados al receptor
            -> whatsapp-incidentes (filtro de autenticación)

whatsapp-monitor (diario/manual)
  -> Meta pricing_analytics -> RPC de resumen mensual en Supabase
  -> evaluar pasos de 1.000 mensajes / US$20 -> Slack API
  -> registrar umbrales después de confirmación

whatsapp-incidentes
  -> preparar tipo -> reservar en Supabase -> Slack API
  -> confirmar envío o liberar reserva y terminar con error
```

La URL pública conserva `/webhook/whatsapp-leads`; el usuario no cambió la configuración de Meta. Ese nombre histórico de la ruta no implica que el receptor invoque directamente Mejoravit en v1.3.

## Contrato comercial

Webhook, router y bots usan `telefono`, `mensaje`, `tipo` y `nombre_whatsapp`, todos strings. El teléfono proviene del remitente original. `mensaje` conserva `text.body` o el ID de la respuesta `interactive.button_reply` / `interactive.list_reply`; `tipo` conserva el tipo original. Los triggers de los tres subworkflows comerciales y los mappings de llamada incluyen esos cuatro campos.

El nombre se extrae de `contacts[].profile.name` solo para un contacto con `wa_id` coincidente. Se recortan espacios exteriores y se limita a 120 caracteres. Se admite vacío y se conserva el contenido especial/emojis dentro del límite. Es un dato provisional de perfil, no una identidad verificada.

## Workflows y responsabilidades

### `whatsapp-webhook` — receptor

El IF previo conserva el acceso opcional a `body.entry[0].changes[0].value.messages[0].from`. Los eventos sin ese remitente van a `Confirmar evento Meta`; los mensajes pasan por `Edit Fields`, el filtro de presencia de `tipo` y la llamada al router por ID. Se conserva `Respond to Webhook` después del subworkflow y la autenticación existente.

Solo se examina el primer mensaje de la primera entrada/cambio. El filtro de presencia de remitente/tipo no es una validación completa de eventos ni una implementación general de lotes. Las pruebas comerciales reportadas no acreditan todos los casos de acuse HTTP, datos malformados o respuesta vacía del subworkflow.

La rama independiente de facturación recorre estados `failed`, detecta `131042` y llama a `whatsapp-incidentes` sin esperar, continuando por la salida regular ante error. El receptor conserva ese workflow como `settings.errorWorkflow`. No se infiere cobertura automática de errores de los otros cinco workflows.

### `whatsapp-router` — selección y continuidad

`Obtener datos` conserva la entrada original antes de consultar `public.whatsapp_routing`. Las consultas de contexto e historial usan `alwaysOutputData: true`; un resultado vacío no demuestra que exista un registro.

La selección sigue estas prioridades, descritas comercialmente en [Lógica de negocio](business-logic.md#identificación-y-selección-de-servicio):

1. `Detectar servicio explícito` identifica una sola palabra completa `mejoravit` / `laudo` o sus IDs de menú, sin distinguir mayúsculas. Ambas o ninguna dejan el resultado explícito vacío.
2. `Resolver servicio prioritario` usa ese servicio o un contexto con servicio admitido y fecha válida, no futura, con antigüedad menor a 24 horas. Exactamente 24 horas queda vencido; la comparación usa timestamps.
3. TRUE de `¿Falta servicio?` consulta `leads` y después `leads_laudo`. `Resolver historial` consulta ambas salidas por nombre; acepta un `id` entero o una cadena no vacía. Solo un historial existente permite resolver. No decide por calificación ni etapa.
4. FALSE de `¿Falta servicio?` y la salida de historial convergen directamente en `Distribuir servicio`, sin Merge. Sus salidas 0/1 son Mejoravit/Laudo; el fallback ofrece botones `servicio_mejoravit` y `servicio_laudo` y termina sin persistir ni invocar bots.

`¿Existe contexto?` compara los teléfonos original y consultado: deben ser strings no vacíos e iguales. TRUE actualiza `servicio_activo` y `ultima_interaccion`; FALSE crea un registro con esos campos y el teléfono original. No modifica `created_at`. También se actualiza un contexto vencido si el registro existe. Las operaciones son una consulta seguida de create/update, no un upsert atómico; la concurrencia de dos creaciones no está validada.

Ambas operaciones llegan a `Preparar despacho`. Con `includeOtherFields: false`, reconstruye los cuatro datos comerciales desde `Obtener datos` y el servicio desde las dos salidas de `¿Existe contexto?` mediante `.all(0)` / `.all(1)`. No depende de lo devuelto por Supabase ni transfiere columnas adicionales. `Destino final` invoca únicamente el bot del servicio exacto; su fallback queda sin conexión. Las llamadas usan Database y conservan `options: {}` del modelo comercial del webhook, sin una configuración de espera explícita en el export.

El contexto se renueva en cada mensaje con servicio resuelto. Una mención explícita puede cambiar de campaña sin borrar ni reiniciar los historiales de los bots. La vigencia se evalúa al recibir un mensaje; no existe una limpieza automática por el mero vencimiento de 24 horas.

### `whatsapp-leads` y `whatsapp-laudo` — bots comerciales

Cada uno busca o crea el lead en su propia tabla, guarda mensaje/última interacción, evalúa reset y etapa, aplica sus reglas deterministas y responde por WhatsApp. Mejoravit usa `public.leads`; Laudo usa `public.leads_laudo`. Los datos de calificación no se copian entre tablas al cambiar de servicio.

Ambos conservan el tramo `Si cita -> Espera agente -> Create a record`. Airtable se ejecuta al solicitar cita después de calificar, no al elegir un servicio ni al superar la última pregunta. El registro no confirma fecha u horario. Las diferencias de reglas, los resets y la situación de los textos de edad están en [Lógica de negocio](business-logic.md).

### `whatsapp-monitor` — consumo independiente

Tiene entrada manual y Schedule Trigger a las 09:00 con zona `America/Mexico_City`. Consulta consumo diario del mes actual y guarda su resumen mediante `guardar_resumen_whatsapp`. No atribuye consumo por campaña ni equivale a contar leads o ejecuciones.

Si Meta devuelve exclusivamente el ID de cuenta, `Resumen mensual` produce ceros provisionales con `sin_datos_meta: true`. Esa marca no se envía a la RPC. La protección contra sobrescritura de estadísticas positivas reside en el SQL; al bloquear ceros devuelve el registro existente. El PASS reportado del 3 de noviembre se conserva en [supabase/README.md](../supabase/README.md#prueba-ejecutada-en-supabase--3-de-noviembre-de-2026).

Las alertas comparan pasos de 1.000 mensajes y US$20 con los últimos umbrales notificados; Slack API debe confirmar antes de `registrar_alerta_whatsapp`. No hay reserva previa visible en esta ruta. Concurrencia, fallos posteriores al envío y consumo real de US$20 siguen pendientes según [Estado actual](current-state.md).

### `whatsapp-incidentes` — alertas independientes

El Error Trigger admite autenticación únicamente si el evento corresponde a `whatsapp-webhook`. La entrada desde otro workflow permite procesar facturación `131042`. La nueva arquitectura de seis workflows no amplía por sí sola esa cobertura.

Las RPC reservan una alerta por tipo `meta_autenticacion` / `meta_facturacion`, con reserva de 5 minutos y bloqueo de 24 horas desde el aviso confirmado. Si Slack responde `ok === true`, se confirma; si no, se intenta liberar la reserva y se termina con error. La confirmación valida tipo/UUID, sin exigir vigencia temporal de la reserva. No se ha acreditado un ciclo real completo de 24 horas ni recuperación exhaustiva de fallos parciales.

## Persistencia e integraciones

| Componente | Responsabilidad |
|---|---|
| `public.whatsapp_routing` | Contexto por teléfono: servicio activo y última interacción; la clave primaria de teléfono fue reportada por el usuario. |
| `public.leads` | Historial comercial y conversacional de Mejoravit. |
| `public.leads_laudo` | Historial comercial y conversacional independiente de Laudo. |
| `public.whatsapp_monitor_monthly` | Resúmenes mensuales por cuenta y umbrales avisados. |
| `public.whatsapp_incident_alerts` | Reservas y último aviso por tipo de incidente. |
| Airtable | Solicitudes de cita y nombre de perfil provisional. `source_aux` distingue ambos servicios. |
| Slack API | Alertas de consumo e incidentes; canal operativo reportado `#whatsapp-monitor`. |

`nombre_whatsapp` se transporta hasta `Create a record.columns.value.name` en ambos bots; ninguna escritura Supabase del export incluye ese campo. El nombre depende del perfil disponible en el mensaje que genera el registro y no se recupera de un perfil guardado anteriormente.

El [respaldo SQL](../supabase/README.md) representa solo las dos tablas y cuatro RPC de monitoreo/incidentes al 3 de noviembre. No contiene DDL de `leads`, `leads_laudo` ni `whatsapp_routing`, ni datos comerciales. No se infieren sus permisos, políticas o índices a partir de los exports. Restauración y permisos efectivos siguen pendientes.

## Evidencia y límites

La publicación y las pruebas del 5 de noviembre proceden de la confirmación del usuario. Las comprobaciones locales de estructura, contratos y conexiones no ejecutan n8n ni prueban equivalencia con producción. El router local carece de `id` y conserva `active: false`, aunque su ID y publicación fueron reportados; no se alteró para aparentar correspondencia. Los detalles y pendientes se concentran en [Estado actual](current-state.md) y [Roadmap](roadmap.md).

Las auditorías del [2/3 de noviembre](audit-2026-11-02.md) y de [v1.9](audit-1.9.md) conservan sus fechas y alcance. No constituyen una auditoría nueva de v1.3.
