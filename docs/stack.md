# Stack tecnológico

## Automatización: n8n

n8n recibe eventos, resuelve el servicio en un router y ejecuta la precalificación determinista de Mejoravit o Laudo, además de mantener monitoreo e incidentes independientes. Consulta/actualiza Supabase y envía mensajes mediante WhatsApp Cloud API.

- Edición: Self Hosted.
- Producción reportada al 2 de octubre de 2026: **2.35.5**; no revalidada en noviembre.
- Imagen de producción: `n8nio/n8n:2.35.5`.
- Seis workflows confirmados como publicados por el usuario al 5 de noviembre de 2026: `whatsapp-webhook`, `whatsapp-router`, `whatsapp-leads`, `whatsapp-laudo`, `whatsapp-monitor` y `whatsapp-incidentes`.
- v1.3 multicampaña desplegada en Contabo y validada en recorridos principales según reporte del usuario. Airtable, incorporado en v1.2, recibe ahora solicitudes de ambos bots.
- Webhook → router → bot mediante Execute Sub-workflow con referencias Database y contrato string de cuatro campos, incluido `nombre_whatsapp`. Los exports no acreditan publicación mediante `active`.

## Producción: Contabo, Docker y Caddy

Según el estado reportado al 2 de octubre de 2026, la producción opera en un Contabo Cloud VPS 6 con Ubuntu Server 24.04.5 LTS, Docker Engine 29.8.1 y Docker Compose 5.5.1. n8n persiste sus datos en `/opt/n8n/data`, montados en `/home/node/.n8n`, con política `restart: unless-stopped`.

Caddy se ejecuta mediante Docker, atiende HTTPS en el dominio `bot.proconsultores.com.mx` y actúa como proxy inverso hacia n8n. El puerto 5678 de n8n se publica solo localmente en el VPS; Caddy atiende los puertos públicos 80 y 443.

## Entorno local de desarrollo

El entorno local conserva Windows, Docker Desktop y una instalación independiente de n8n para desarrollo y pruebas. Puede compartir Supabase y credenciales de Meta con producción, por lo que no debe considerarse completamente aislado.

ngrok solo corresponde al flujo local histórico y no es el webhook operativo de producción. `dockers-run.txt` conserva un ejemplo de esa configuración y no es una definición de producción.

## Mensajería: WhatsApp Cloud API

Meta proporciona la recepción y el envío de mensajes de texto e interacciones con botones y listas. El webhook público conserva `https://bot.proconsultores.com.mx/webhook/whatsapp-leads` aunque ahora despacha al router; el usuario confirmó que la configuración de Meta no cambió. La autenticación debe residir en credenciales de n8n; ningún access token debe incluirse en los exportes o documentos.

## Persistencia comercial: Supabase PostgreSQL

Supabase continúa como servicio externo. `public.leads` conserva Mejoravit y `public.leads_laudo` el historial separado de Laudo; `public.whatsapp_routing` mantiene servicio activo y última interacción por teléfono. La vigencia del contexto es menor de 24 horas, evaluada al recibir un mensaje, sin borrado automático por vencimiento. Las consultas de contexto, etapas y calificación de leads controlados fueron reportadas por el usuario durante las pruebas del 5 de noviembre. La migración histórica del VPS no trasladó esta base. No se infiere el esquema completo o sus permisos desde los JSON.

El monitoreo utiliza además `whatsapp_monitor_monthly` según verificación operativa reportada. Los exports llaman a `guardar_resumen_whatsapp`, `registrar_alerta_whatsapp`, `reservar_alerta_incidente` y `confirmar_alerta_incidente`. Sus definiciones originales, junto con el esquema y los permisos reportados al 3 de noviembre, están preparadas en [supabase/](../supabase/README.md). No son migraciones administradas por Supabase CLI. El respaldo solo cubre monitoreo/incidentes: no incluye DDL de `leads`, `leads_laudo` o `whatsapp_routing`. La revisión fue estática; no valida restauración ni permisos efectivos contra la instancia viva.

## Notificaciones operativas: Slack API

`whatsapp-monitor` y `whatsapp-incidentes` usan solicitudes HTTP a Slack API con credencial `slackApi` administrada por n8n. El canal operativo reportado es `#whatsapp-monitor`; no se utiliza un Incoming Webhook de Slack en estos exports. Se comprueba la respuesta `ok` antes de confirmar umbrales o incidentes en Supabase. Los límites de validación están en [Estado actual](current-state.md).

## Destino empresarial: Airtable

Airtable es la salida interna automatizada de ambos servicios en v1.3. El nodo nativo de cada bot crea registros cuando un usuario calificado solicita una cita; el registro no representa una cita confirmada. La configuración utiliza la base “Base Leads Nueva” y la tabla “Leads global”. La autenticación es una credencial de Airtable almacenada en n8n, con acceso acotado a esa base. No se documenta el token.

Supabase sigue como base comercial y conversacional. `source_aux` distingue `whatsapp_mejoravit` y `whatsapp_laudo`; `Fuente_lead` y `source: BOT IA` son etiquetas comerciales intencionales, no uso de inteligencia artificial. `name` recibe el perfil provisional de WhatsApp del evento actual: se recorta a 120 caracteres y viaja por los contratos de n8n sin guardarse en Supabase. El usuario confirmó su llegada a Airtable en ambos servicios; no es identidad verificada. Los exports locales no prueban igualdad exacta con producción.

La autenticación de Meta utiliza, según el procedimiento operativo reportado, un token con vigencia aproximada de seis meses que requiere renovación periódica. No se ha afirmado que se renueve automáticamente; es una dependencia operativa que debe vigilarse.

## Control de versiones y seguridad

Git/GitHub conserva workflows exportados y documentación. No debe contener credenciales, secretos, datos personales, la base interna de n8n ni respaldos. La auditoría histórica y sus hallazgos se encuentran en [Auditoría v1.9](audit-1.9.md); no constituye una lista automática de requisitos para v1.3 ni una auditoría vigente de los seis workflows.
