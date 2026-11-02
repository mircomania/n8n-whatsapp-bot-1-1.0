# Arquitectura

## Arquitectura de producción reportada

Fecha de actualización: **2 de noviembre de 2026**. El usuario reporta publicados los cuatro workflows. El diagrama describe esa implementación y la configuración observada en los exports; no sustituye la comparación con la instancia viva.

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker
  -> n8n en Contabo: whatsapp-webhook
       -> whatsapp-leads
            -> precalificación determinista
            -> Supabase: public.leads
            -> respuesta al usuario por WhatsApp
            -> Airtable para solicitudes de cita calificadas
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

Recibe los POST de Meta y conserva la normalización y el enrutamiento al workflow comercial. Una segunda rama busca el primer estado `failed` con error `131042` y llama a `whatsapp-incidentes`. La llamada no espera la finalización del subworkflow y está configurada para continuar por la salida regular ante error.

`settings.errorWorkflow` referencia `whatsapp-incidentes`. La extracción comercial todavía accede a `messages[0]` antes del filtro de tipo: la rama nueva no demuestra que todos los eventos de estado se procesen y acusen correctamente. Sigue pendiente comprobar esos eventos y el acuse HTTP en el workflow completo.

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

[Estado actual](current-state.md) registra las pruebas operativas reportadas, las cifras fechadas y los pendientes de noviembre. La [auditoría del 2 de noviembre](audit-2026-11-02.md) contiene la revisión local de conexiones, referencias, seguridad y código. Ninguna de esas comprobaciones locales demuestra por sí sola publicación, entrega externa o equivalencia con producción.
