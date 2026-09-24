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
       -> aviso al agente por WhatsApp
       -> creación de registro en Airtable
```

La integración Airtable está implementada y publicada directamente en la instancia de n8n de producción en Contabo. El repositorio no se ha sincronizado todavía con los exportes de esa versión; por tanto, los JSON bajo `workflows/` representan exportaciones anteriores y no son la referencia operativa de la integración.

## Workflows y responsabilidades

### `whatsapp-webhook`

Punto de entrada de eventos de Meta y enrutamiento al workflow comercial. No se añadió un tercer workflow.

### `whatsapp-leads`

Busca o crea el lead en `public.leads`, interpreta la etapa persistida, conserva las reglas deterministas, actualiza los datos y envía respuestas al usuario. El tramo de solicitud de cita publicado es:

```text
Si cita
  -> Espera agente
  -> Aviso agente
  -> Create a record (Airtable)
```

`Si cita` actualiza la información correspondiente en Supabase. `Espera agente` envía la respuesta al usuario. `Aviso agente` conserva el aviso interno por WhatsApp. `Create a record` crea el registro en Airtable. Ambos últimos mecanismos están conectados y activos temporalmente, según DEC-012.

### Supabase

`public.leads` sigue siendo la base principal para persistencia comercial y estado conversacional. Su estructura no cambió para esta integración.

### Airtable

Airtable recibe registros comerciales de usuarios que superaron la precalificación y solicitaron una cita, para que la empresa los consulte y gestione. El registro no confirma una cita ni implica una fecha u horario acordados. La conexión usa el nodo nativo de Airtable de n8n y una credencial almacenada en n8n.

La base configurada es “Base Leads Nueva” y la tabla es “Leads global”. Los campos exactos están resumidos en [Estado actual](current-state.md); los valores secretos de autenticación no se documentan.

## Validación reportada

La prueba manual recorrió los cuatro nodos finales. Tras corregir la validación de la opción `BOT IA` en el campo `source`, cada nodo terminó correctamente y el usuario confirmó que el registro apareció en Airtable con los valores esperados. Esta prueba no demuestra cobertura exhaustiva con múltiples leads ni funcionamiento a largo plazo.

## Limitación operativa conocida

Se reportaron ocho solicitudes de cita cuyos avisos no fueron recibidos. No hay evidencia individual suficiente para atribuir todos los casos a una misma causa. Una causa operativa conocida es el rechazo de mensajes normales fuera de la ventana de atención de WhatsApp. El procedimiento temporal documentado es que el agente inicie una interacción con el bot al menos una vez cada 24 horas; es manual y no garantiza la entrega.
