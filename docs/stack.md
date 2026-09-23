# Stack tecnológico

## Automatización: n8n

n8n recibe eventos, ejecuta la lógica de precalificación, consulta y actualiza Supabase y envía mensajes mediante WhatsApp Cloud API.

- Edición: Self Hosted.
- Producción reportada: **2.35.5**.
- Imagen de producción: `n8nio/n8n:2.35.5`.
- Workflows actuales: `whatsapp-webhook` y `whatsapp-leads`.
- v1.2 planificada: un tercer workflow de nombre provisional `whatsapp-ia`.

## Producción: Contabo, Docker y Caddy

La producción opera en un Contabo Cloud VPS 6 con Ubuntu Server 24.04.5 LTS, Docker Engine 29.8.1 y Docker Compose 5.5.1. n8n persiste sus datos en `/opt/n8n/data`, montados en `/home/node/.n8n`, con política `restart: unless-stopped`.

Caddy se ejecuta mediante Docker, atiende HTTPS en el dominio `bot.proconsultores.com.mx` y actúa como proxy inverso hacia n8n. El puerto 5678 de n8n se publica solo localmente en el VPS; Caddy atiende los puertos públicos 80 y 443.

## Entorno local de desarrollo

El entorno local conserva Windows, Docker Desktop y una instalación independiente de n8n para desarrollo y pruebas. Puede compartir Supabase y credenciales de Meta con producción, por lo que no debe considerarse completamente aislado.

ngrok solo corresponde al flujo local histórico y no es el webhook operativo de producción. `dockers-run.txt` conserva un ejemplo de esa configuración y no es una definición de producción.

## Mensajería: WhatsApp Cloud API

Meta proporciona la recepción y el envío de mensajes de texto e interacciones con botones y listas. El webhook operativo es `https://bot.proconsultores.com.mx/webhook/whatsapp-leads`. La autenticación debe residir en credenciales de n8n; ningún access token debe incluirse en los exportes o documentos.

## Persistencia comercial: Supabase PostgreSQL

Supabase continúa funcionando como servicio externo. La tabla principal verificada es `public.leads`, que conserva los datos de precalificación, etapa, resultado, fechas y control de interacción/reset. La migración a Contabo no migró la base comercial ni cambió su estructura.

## IA y correo previstos

La IA y el correo electrónico son alcance planificado de v1.2, no componentes instalados del stack actual. La herramienta de envío de correo todavía no está decidida entre n8n, Make u otra alternativa. No se han configurado servicios de correo ni destinatarios reales.

## Control de versiones y seguridad

Git/GitHub conserva workflows exportados y documentación. No debe contener credenciales, secretos, datos personales, la base interna de n8n ni respaldos. La auditoría histórica y sus hallazgos se encuentran en [Auditoría v1.9](audit-1.9.md); no constituye una lista automática de requisitos para v1.2.
