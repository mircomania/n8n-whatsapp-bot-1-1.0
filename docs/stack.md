# Stack tecnológico

## Automatización: n8n

n8n recibe eventos, ejecuta la lógica de precalificación, consulta y actualiza Supabase y envía mensajes mediante WhatsApp Cloud API.

- Edición: Self Hosted.
- Versión local verificada: **2.35.5**.
- Workflows publicados: `whatsapp-webhook` y `whatsapp-leads`.

## Contenedores: Docker Desktop

El entorno actual ejecuta la imagen `n8nio/n8n` en un contenedor llamado `n8n`, sobre Windows 10, con el puerto 5678 publicado. La persistencia usa un bind mount de lectura y escritura hacia `/home/node/.n8n`; la política de reinicio local es `no`.

Estos son hechos del entorno local al 21 de septiembre de 2026, no una plantilla aprobada de producción. La configuración completa está en [Estado actual](current-state.md).

## Mensajería: WhatsApp Cloud API

Meta proporciona la recepción y el envío de mensajes de texto e interacciones con botones y listas. La autenticación debe residir en credenciales de n8n; ningún access token debe incluirse en los exportes o documentos.

## Persistencia comercial: Supabase PostgreSQL

La tabla verificada `public.leads` conserva el teléfono, datos de precalificación, etapa, resultado, fechas y control de interacción/reset. La restricción única de `telefono` evita duplicar teléfonos no nulos, pero no reemplaza la idempotencia por mensaje.

El esquema verificado está en [Estado actual](current-state.md). RLS, permisos de Data API y generación automática de `id` siguen pendientes de auditoría formal.

## Exposición local: ngrok

ngrok proporciona HTTPS temporal para el webhook local y está operativo. Se eliminará como dependencia en v1.2; las URLs temporales no son endpoints permanentes y no deben publicarse en la documentación.

## Producción aprobada

La referencia aprobada para v1.2 es Contabo Cloud VPS 6 con Ubuntu Server, Docker y Docker Compose. La contratación, el precio final y toda la configuración de producción permanecen pendientes.

## Control de versiones

Git/GitHub conserva workflows exportados y documentación. No debe contener credenciales, secretos, datos personales, la base interna de n8n ni respaldos. Los hallazgos de exposición potencial en archivos existentes están registrados sin valores en [Auditoría v1.1](audit-1.1.md).
