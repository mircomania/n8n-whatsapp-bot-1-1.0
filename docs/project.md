# WhatsApp Lead Qualification Bot

## Descripción

Sistema automatizado de atención y precalificación de leads mediante WhatsApp, desarrollado para Pro Consultores.

El objetivo es recibir usuarios provenientes principalmente de campañas publicitarias, realizar una precalificación automática mediante una conversación estructurada y derivar a un agente humano únicamente los leads que cumplen los requisitos definidos.

El sistema utiliza WhatsApp Cloud API como canal de comunicación, n8n para la automatización y Supabase para persistir el estado y los datos de cada lead.

## Flujo general

1. El usuario inicia una conversación por WhatsApp.
2. Meta envía el mensaje mediante webhook.
3. n8n normaliza los datos recibidos.
4. Se identifica al usuario mediante su número de WhatsApp.
5. Supabase determina si el usuario es nuevo o existente.
6. Si es nuevo, se crea su registro y comienza la precalificación.
7. Cada respuesta se valida según la etapa actual.
8. Las respuestas válidas actualizan los datos y avanzan la etapa.
9. Las respuestas inválidas generan una nueva solicitud de respuesta.
10. Si el usuario no cumple un requisito, se registra el motivo de rechazo.
11. Si cumple los requisitos, puede solicitar una cita.
12. Los leads que solicitan una cita son derivados a un agente humano.

## Características

- Recepción de mensajes mediante Webhooks de Meta.
- Normalización de eventos de WhatsApp.
- Filtrado de eventos que no contienen mensajes.
- Identificación de usuarios por teléfono.
- Persistencia de conversaciones mediante etapas.
- Preguntas interactivas mediante botones y listas.
- Validación de respuestas.
- Rutas de aprobación y rechazo.
- Registro del motivo de rechazo.
- Solicitud de citas.
- Derivación a agente humano.
- Sistema de reinicio de usuarios.
- Protección básica contra mensajes enviados repetidamente.
- Persistencia de leads mediante Supabase.

## Estado actual

El bot se encuentra funcional y ha sido probado con tráfico real.

Actualmente se ejecuta localmente mediante Docker y n8n, exponiendo el webhook mediante ngrok.

Los workflows están versionados mediante GitHub.

## Objetivo de producción

Migrar la infraestructura desde el entorno local a un VPS, eliminando la dependencia del computador local y de ngrok.

El entorno de producción deberá contar con:

- n8n ejecutándose mediante Docker.
- Dominio/subdominio permanente.
- HTTPS.
- Persistencia de datos.
- Reinicio automático de servicios.
- Backups.
- Protección contra webhooks duplicados.
- Monitoreo básico de errores.
