# Stack Tecnológico

## Automatización

### n8n

Responsable de:

- Recibir eventos de WhatsApp.
- Procesar mensajes.
- Ejecutar la lógica de precalificación.
- Consultar y actualizar Supabase.
- Enviar respuestas mediante WhatsApp Cloud API.
- Controlar las etapas del usuario.

Versión utilizada durante desarrollo:

n8n 2.21.7 Self Hosted.

---

## Contenedores

### Docker

n8n se ejecuta actualmente dentro de un contenedor Docker.

Entorno actual:

- Host: Windows.
- Puerto n8n: 5678.
- Persistencia mediante bind mount.
- Datos locales de n8n almacenados fuera del contenedor.

La información persistente de n8n NO debe almacenarse en GitHub.

---

## Mensajería

### WhatsApp Cloud API

Proveedor:

Meta.

Utilizada para:

- Recibir mensajes.
- Enviar mensajes de texto.
- Enviar botones interactivos.
- Enviar listas interactivas.
- Recibir respuestas interactivas.

La autenticación se almacena mediante Credentials de n8n.

Nunca deben almacenarse Access Tokens directamente en los workflows versionados.

---

## Base de datos

### Supabase

Base de datos PostgreSQL utilizada para persistir los leads y el estado de la conversación.

Información almacenada:

- Teléfono.
- Estado.
- Tiempo trabajando.
- Subcuenta.
- Nombre.
- NSS.
- Etapa.
- Estado de calificación.
- Motivo de rechazo.
- Fecha de calificación.
- Fecha de cita.
- Fecha de finalización.
- Última interacción.
- Mensaje original.
- Fecha de reset.

---

## Desarrollo local

### ngrok

Utilizado exclusivamente durante desarrollo para exponer el webhook local de n8n mediante HTTPS.

Arquitectura actual:

WhatsApp Cloud API
→ ngrok
→ localhost:5678
→ n8n

ngrok será eliminado al migrar el proyecto a producción.

---

## Control de versiones

### Git / GitHub

El repositorio contiene:

- Workflows exportados de n8n.
- Documentación.
- Configuración reproducible cuando corresponda.

No contiene:

- Tokens.
- Credentials.
- Base de datos interna de n8n.
- Datos de leads.
- Secrets.
