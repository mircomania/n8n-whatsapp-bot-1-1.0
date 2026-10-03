# Arquitectura

## Arquitectura actual de producción

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker
  -> n8n en Contabo: whatsapp-webhook
  -> n8n: whatsapp-leads
       -> precalificación determinista
       -> persistencia comercial y conversacional en Supabase
       -> respuesta al usuario por WhatsApp
       -> registro en Airtable para solicitudes de cita calificadas
```

La integración Airtable está implementada y publicada en la instancia de n8n de producción en Contabo. El usuario reportó que los JSON locales son exportes finales de esa versión. La revisión estructural confirma el tramo de cita y el valor intencional `Fuente_lead: BOT IA`; los exportes no sustituyen una verificación directa de la instancia viva.

## Workflows y responsabilidades

### `whatsapp-webhook`

Punto de entrada de eventos de Meta y enrutamiento al workflow comercial. No se añadió un tercer workflow.

### `whatsapp-leads`

Busca o crea el lead en `public.leads`, interpreta la etapa persistida, conserva las reglas deterministas, actualiza los datos y envía respuestas al usuario. El tramo de solicitud de cita publicado es:

```text
Si cita
  -> Espera agente
  -> Create a record (Airtable)
```

`Si cita` actualiza la información correspondiente en Supabase. `Espera agente` envía la respuesta al usuario. `Create a record` crea el registro en Airtable. El nodo `Aviso agente` fue retirado según DEC-013.

### Supabase

`public.leads` sigue siendo la base principal para persistencia comercial y estado conversacional. Su estructura no cambió para esta integración.

### Airtable

Airtable recibe registros comerciales de usuarios que superaron la precalificación y solicitaron una cita, para que la empresa los consulte y gestione. El registro no confirma una cita ni implica una fecha u horario acordados. La conexión usa el nodo nativo de Airtable de n8n y una credencial almacenada en n8n.

La base configurada es “Base Leads Nueva” y la tabla es “Leads global”. Los campos exactos están resumidos en [Estado actual](current-state.md); los valores secretos de autenticación no se documentan.

## Validación reportada

La prueba manual reportada creó un registro en Airtable tras corregir la validación de `source`. El usuario reportó más de una semana sin errores. La inspección local parseó ambos JSON y no encontró conexiones a nodos inexistentes. En `whatsapp-webhook`, el nodo ejecutor tiene una etiqueta con `-test`, pero el ID configurado y el nombre cacheado apuntan a `whatsapp-leads`.

## Salida interna vigente

El aviso interno anterior por WhatsApp fue retirado. Airtable es actualmente la salida interna automatizada; WhatsApp Cloud API continúa atendiendo a los usuarios.
