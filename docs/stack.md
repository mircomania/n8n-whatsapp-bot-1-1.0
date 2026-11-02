# Stack tecnológico

## Automatización: n8n

n8n recibe eventos, ejecuta la lógica de precalificación, consulta y actualiza Supabase y envía mensajes mediante WhatsApp Cloud API.

- Edición: Self Hosted.
- Producción reportada al 2 de octubre de 2026: **2.35.5**; no revalidada en noviembre.
- Imagen de producción: `n8nio/n8n:2.35.5`.
- Workflows reportados como publicados al 2 de noviembre de 2026: `whatsapp-webhook`, `whatsapp-leads`, `whatsapp-monitor` y `whatsapp-incidentes`.
- La integración Airtable de v1.2 está implementada y publicada en `whatsapp-leads` en Contabo.

## Producción: Contabo, Docker y Caddy

Según el estado reportado al 2 de octubre de 2026, la producción opera en un Contabo Cloud VPS 6 con Ubuntu Server 24.04.5 LTS, Docker Engine 29.8.1 y Docker Compose 5.5.1. n8n persiste sus datos en `/opt/n8n/data`, montados en `/home/node/.n8n`, con política `restart: unless-stopped`.

Caddy se ejecuta mediante Docker, atiende HTTPS en el dominio `bot.proconsultores.com.mx` y actúa como proxy inverso hacia n8n. El puerto 5678 de n8n se publica solo localmente en el VPS; Caddy atiende los puertos públicos 80 y 443.

## Entorno local de desarrollo

El entorno local conserva Windows, Docker Desktop y una instalación independiente de n8n para desarrollo y pruebas. Puede compartir Supabase y credenciales de Meta con producción, por lo que no debe considerarse completamente aislado.

ngrok solo corresponde al flujo local histórico y no es el webhook operativo de producción. `dockers-run.txt` conserva un ejemplo de esa configuración y no es una definición de producción.

## Mensajería: WhatsApp Cloud API

Meta proporciona la recepción y el envío de mensajes de texto e interacciones con botones y listas. El webhook operativo es `https://bot.proconsultores.com.mx/webhook/whatsapp-leads`. La autenticación debe residir en credenciales de n8n; ningún access token debe incluirse en los exportes o documentos.

## Persistencia comercial: Supabase PostgreSQL

Supabase continúa funcionando como servicio externo. La tabla principal verificada es `public.leads`, que conserva los datos de precalificación, etapa, resultado, fechas y control de interacción/reset. La migración a Contabo no migró la base comercial ni cambió su estructura.

El monitoreo utiliza además `whatsapp_monitor_monthly` según verificación operativa reportada. Los exports llaman a `guardar_resumen_whatsapp`, `registrar_alerta_whatsapp`, `reservar_alerta_incidente` y `confirmar_alerta_incidente`. No hay definiciones SQL ni migraciones confirmadas en el repositorio; la inspección de las llamadas no valida permisos, RLS o implementación de las funciones.

## Notificaciones operativas: Slack API

`whatsapp-monitor` y `whatsapp-incidentes` usan solicitudes HTTP a Slack API con credencial `slackApi` administrada por n8n. El canal operativo reportado es `#whatsapp-monitor`; no se utiliza un Incoming Webhook de Slack en estos exports. Se comprueba la respuesta `ok` antes de confirmar umbrales o incidentes en Supabase. Los límites de validación están en [Estado actual](current-state.md).

## Destino empresarial: Airtable

Airtable es un destino adicional operativo en producción. El nodo nativo de n8n crea registros cuando un usuario calificado solicita una cita; el registro no representa una cita confirmada. La configuración utiliza la base “Base Leads Nueva” y la tabla “Leads global”. La autenticación es una credencial de Airtable almacenada en n8n, con acceso acotado a esa base. No se documenta el token.

Supabase sigue como base principal comercial y conversacional. Los JSON actuales fueron reportados como exportes finales de producción. `Fuente_lead: BOT IA` es el valor intencional confirmado por el usuario.

La autenticación de Meta utiliza, según el procedimiento operativo reportado, un token con vigencia aproximada de seis meses que requiere renovación periódica. No se ha afirmado que se renueve automáticamente; es una dependencia operativa que debe vigilarse.

## Control de versiones y seguridad

Git/GitHub conserva workflows exportados y documentación. No debe contener credenciales, secretos, datos personales, la base interna de n8n ni respaldos. La auditoría histórica y sus hallazgos se encuentran en [Auditoría v1.9](audit-1.9.md); no constituye una lista automática de requisitos para v1.2.
