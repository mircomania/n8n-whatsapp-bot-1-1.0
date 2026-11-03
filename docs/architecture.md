# Arquitectura

## Arquitectura de producción reportada

Fecha de revisión: **3 de noviembre de 2026**. Los cuatro workflows fueron reportados como publicados al 2 de noviembre. El nuevo filtro del receptor se inspeccionó solo en el export local del día 3; su publicación y ejecución real no se comprobaron. El diagrama incorpora esa configuración local y no acredita equivalencia con la instancia viva.

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker
  -> n8n en Contabo: whatsapp-webhook
       -> ¿Es mensaje entrante?
            -> True: Edit Fields -> mensaje -> whatsapp-leads
                 -> precalificación determinista
                 -> Supabase: public.leads
                 -> respuesta al usuario por WhatsApp
                 -> Airtable para solicitudes de cita calificadas
            -> False: Confirmar evento Meta (HTTP 200 sin cuerpo)
       -> detectar estado failed con código 131042
            -> whatsapp-incidentes (llamada sin espera)
       -> errores de ejecución asociados
            -> whatsapp-incidentes (filtro de autenticación)

Schedule Trigger / ejecución manual
  -> whatsapp-monitor
       -> Meta: pricing_analytics del mes actual
       -> Supabase: guardar_resumen_whatsapp
       -> evaluar umbrales de 1.000 mensajes / US$20
       -> Slack API
       -> registrar umbrales si Slack confirma

whatsapp-incidentes
  -> preparar tipo admitido
  -> Supabase: reservar_alerta_incidente
  -> Slack API si la reserva lo permite
       -> confirmar_alerta_incidente (enviado)
       -> o liberar reserva y terminar con error
```

## Workflows y responsabilidades

### `whatsapp-webhook`

Recibe los POST de Meta. El export local revisado el 3 de noviembre añade `¿Es mensaje entrante?` antes de `Edit Fields`. La condición usa acceso opcional a `body.entry[0].changes[0].value.messages[0].from` y compara el resultado derivado con `MENSAJE`.

La salida True conserva `Edit Fields -> mensaje -> Call 'whatsapp-leads' -> Respond to Webhook`, incluidos parámetros y conexiones internos previos. La salida False ejecuta `Confirmar evento Meta`, configurado con HTTP 200 y sin cuerpo. Así se separan los eventos sin remitente antes de la extracción comercial; el filtro posterior `mensaje` sigue presente.

La rama independiente `Detectar fallo Meta 131042 -> Call 'whatsapp-incidentes'` no cambia su código ni parámetros: busca el primer estado `failed` con ese error y llama al subworkflow sin esperar su finalización, continuando por la salida regular ante error. `settings.errorWorkflow` también conserva la referencia a `whatsapp-incidentes`.

El IF solo examina el primer mensaje de la primera entrada y cambio. Un `from` verdadero sin `type` también pasa a True: no es una validación completa del evento ni una solución general para lotes. El detector de facturación sí recorre las entradas y cambios de su payload. La inspección y 30 casos locales comprueban condición, detector y conexiones; quedan pendientes el acuse HTTP y los recorridos completos en n8n. No se infiere un orden de ejecución, ausencia de fallos en otras ramas o entrega a Slack a partir de la configuración.

### `whatsapp-leads`

Busca o crea el lead en `public.leads`, interpreta la etapa persistida, aplica reglas deterministas, actualiza los datos y envía respuestas al usuario. En el cierre de seguridad solo se anonimizaron cuatro textos de dos opciones cacheadas de `source`; la configuración funcional conserva los valores de Git HEAD. El tramo de solicitud de cita sigue siendo:

```text
Si cita -> Espera agente -> Create a record (Airtable)
```

`Si cita` actualiza Supabase; `Espera agente` responde al usuario; `Create a record` crea el registro de Airtable. El aviso interno al agente por WhatsApp fue retirado según DEC-013. La creación del registro no confirma una fecha u horario de cita.

### `whatsapp-monitor`

Tiene entrada manual y programada a las 09:00, con zona `America/Mexico_City`. Consulta el mes actual a Meta con granularidad diaria y genera un resumen mensual. La consulta y la clave `mes` usan esa zona.

Si Meta devuelve exclusivamente el ID de cuenta, `Resumen mensual` genera ceros provisionales con `sin_datos_meta: true`. El cuerpo enviado a la RPC incluye los contadores, el costo, la cuenta, el mes y la fecha de consulta, pero no esa marca. La protección contra sobrescritura de valores positivos reside en la RPC, según la implementación comprobada y reportada por el usuario; no está definida en el JSON.

Las alertas comparan múltiplos de 1.000 mensajes y US$20 con los últimos umbrales avisados. Se envían mediante Slack API y se registran después de `ok`. No hay una reserva previa visible en esta ruta: la prevención de duplicados ante ejecuciones concurrentes o un fallo posterior al envío requiere verificación.

### `whatsapp-incidentes`

Tiene Error Trigger y entrada desde otro workflow. El filtro de errores de autenticación admite solo eventos cuyo workflow sea `whatsapp-webhook`; no constituye cobertura general de todos los workflows. La entrada directa permite procesar el incidente de facturación detectado por el receptor.

La reserva y confirmación de Supabase controlan una alerta cada 24 horas por `meta_autenticacion` o `meta_facturacion`. Si Slack confirma `ok === true`, registra envío; si no confirma, intenta liberar la reserva y termina con error. Las pruebas SQL reportadas validan el bloqueo en una transacción revertida. No se ha observado aún el ciclo real completo de 24 horas ni se dispone de SQL versionado para revisar la recuperación ante fallos parciales.

## Persistencia e integraciones

| Componente | Responsabilidad |
|---|---|
| Supabase `public.leads` | Persistencia comercial y conversacional principal. |
| Supabase `whatsapp_monitor_monthly` | Resúmenes independientes por mes, según consulta operativa reportada. |
| `guardar_resumen_whatsapp` | Guardar el resumen y proteger estadísticas positivas frente a una consulta con mensajes y costo en cero, según reporte operativo. |
| `registrar_alerta_whatsapp` | Registrar umbrales de consumo después de la confirmación de Slack. |
| `reservar_alerta_incidente` / `confirmar_alerta_incidente` | Reservar, confirmar o liberar alertas por tipo; límite de 24 horas. |
| Airtable | Recibir solicitudes de cita calificadas para gestión interna. |
| Slack API | Notificar consumo e incidentes en el canal operativo reportado `#whatsapp-monitor`. |

No hay definiciones SQL o migraciones confirmadas de las RPC en el repositorio. Los nombres se observan en las llamadas exportadas; la tabla mensual y la protección SQL están respaldadas por el reporte operativo del usuario. No se infieren esquemas adicionales, permisos, RLS o garantías de concurrencia.

Airtable conserva “Base Leads Nueva” / “Leads global” y el valor intencional `Fuente_lead: BOT IA`. Es una etiqueta comercial, no uso de inteligencia artificial. Las credenciales de Meta, Supabase, Airtable y Slack se referencian mediante n8n; los exports no contienen sus valores de autenticación según la revisión local.

## Evidencia y límites

[Estado actual](current-state.md) registra las pruebas operativas reportadas, las cifras fechadas y los pendientes de noviembre. La [auditoría del 2 de noviembre y su seguimiento del día 3](audit-2026-11-02.md) contiene la revisión local de conexiones, referencias, seguridad y código. Ninguna de esas comprobaciones locales demuestra por sí sola publicación, entrega externa o equivalencia con producción.
