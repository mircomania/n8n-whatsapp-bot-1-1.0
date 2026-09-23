# Arquitectura

## Arquitectura actual de producción

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker
  -> n8n en Contabo: whatsapp-webhook
       -> recepción y enrutamiento del evento
  -> n8n: whatsapp-leads
       -> consulta/actualización de public.leads
       -> precalificación determinista
       -> respuestas por WhatsApp
       -> aviso al agente cuando corresponde
  -> Supabase PostgreSQL
```

El estado conversacional reside en Supabase. La instalación local de Windows conserva una copia independiente para desarrollo y pruebas; no es el punto de entrada operativo de Meta.

## Componentes actuales

### `whatsapp-webhook`

Es el punto de entrada de Meta. Recibe el evento y dirige los mensajes admitidos al workflow comercial.

### `whatsapp-leads`

Busca o crea el lead en `public.leads`, interpreta la etapa persistida, aplica las reglas deterministas, actualiza datos y responde al usuario. Cuando un usuario calificado solicita una cita, actualmente envía un aviso al agente por WhatsApp.

### Supabase

`public.leads` mantiene la persistencia comercial y conversacional. No se modificó su estructura durante la migración a Contabo.

### Airtable

Airtable no forma parte de la instalación operativa actual. Su integración está planificada para v1.2.

## Arquitectura objetivo de v1.2

La arquitectura conservará los dos workflows existentes:

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API
  -> whatsapp-webhook
  -> whatsapp-leads
       -> precalificación determinista
       -> actualización del lead en Supabase
       -> creación del registro correspondiente en Airtable
```

El punto de integración será el tramo final de `whatsapp-leads`, donde actualmente se envía el aviso al agente. La creación de un registro en Airtable sustituirá ese aviso interno. No se incorporará un tercer workflow.

Supabase permanecerá como base principal para datos comerciales y estado conversacional. Airtable recibirá los registros que la empresa necesita consultar y gestionar. Un registro creado a partir de una solicitud de cita no representa una cita confirmada ni implica fecha u horario confirmados.

La credencial de Airtable, base, tabla, columnas y mapeo de campos están pendientes de definición y configuración durante la implementación. No se presuponen campos ni identificadores.

## Limitación operativa actual

Se reportaron ocho leads con solicitudes de cita cuyos avisos no fueron recibidos. No hay evidencia individual suficiente para atribuir todos los casos a una misma causa. Una causa operativa conocida es el rechazo de mensajes normales fuera de la ventana de atención de WhatsApp. El procedimiento temporal documentado es que el agente inicie una interacción con el bot al menos una vez cada 24 horas; es manual y no garantiza la entrega.

## Seguridad y límites

Las credenciales se gestionarán mediante el sistema de credenciales de n8n. No se documentan secretos ni identificadores privados de Airtable.
