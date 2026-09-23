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

El estado conversacional reside en Supabase, no en una ejecución prolongada de n8n. La instalación local de Windows conserva una copia independiente para desarrollo y pruebas; no es el punto de entrada operativo de Meta.

## Responsabilidades actuales

### `whatsapp-webhook`

Es el punto de entrada de Meta. Recibe el evento y dirige los mensajes admitidos al workflow de precalificación.

### `whatsapp-leads`

Es el workflow principal. Busca o crea el lead en `public.leads`, interpreta la etapa persistida, aplica las reglas deterministas, actualiza datos, responde al usuario y activa el aviso al agente cuando se solicita una cita.

Actualmente existen dos workflows. La arquitectura publicada no incluye todavía un workflow de IA.

### Supabase

`public.leads` mantiene el estado comercial y conversacional. No se modificó su estructura durante la migración a Contabo.

## Limitación operativa conocida

La ruta actual de cita incluye un aviso al agente mediante WhatsApp. Se reportaron ocho leads con solicitudes de cita cuyos avisos no fueron recibidos. No hay evidencia individual suficiente para afirmar que los ocho casos tuvieron la misma causa.

La causa operativa conocida que debe contemplarse es la ventana de atención de WhatsApp: si han transcurrido más de 24 horas desde la última interacción iniciada por el agente con el número del bot, un mensaje normal puede ser rechazado. El procedimiento temporal es que el agente inicie una interacción con el bot al menos una vez cada 24 horas. Es una medida manual y no garantiza la entrega permanente.

No se modifica actualmente el workflow para resolver este problema. Una ejecución exitosa de n8n tampoco garantiza por sí sola la recepción del mensaje externo.

## Arquitectura objetivo de v1.2

La v1.2 contempla tres workflows:

1. `whatsapp-webhook` — punto de entrada de Meta y futuro enrutamiento según el estado del usuario.
2. `whatsapp-leads` — conserva la precalificación determinista actual.
3. `whatsapp-ia` — nombre provisional para gestionar la conversación posterior a la precalificación y la solicitud de cita.

El enrutamiento exacto se definirá durante el desarrollo de v1.2. No basta con ejecutar el tercer workflow una sola vez: las respuestas posteriores del usuario deberán continuar llegando al flujo de IA según el estado persistido.

Cuando el usuario supere el filtro y solicite una cita, `whatsapp-leads` deberá transferir el contexto necesario al flujo de IA y comunicar al usuario que continuará la atención para coordinarla. La IA no sustituirá la precalificación determinista.

El flujo de IA podrá solicitar el nombre, registrar la información autorizada, coordinar fecha y horario, confirmar según disponibilidad real, registrar la cita y enviar un comprobante por WhatsApp. No podrá inventar horarios, disponibilidad, direcciones ni confirmaciones. Si hace falta validación humana, la cita no se comunicará como confirmada antes de cumplir las condiciones acordadas.

La ubicación obtenida durante la precalificación podrá utilizarse para identificar la oficina correspondiente. El origen de oficinas, horarios, disponibilidad, campos y transiciones todavía debe definirse. No se modifica ahora la estructura de Supabase.

La respuesta afirmativa actual conduce a la etapa persistida `cita`; la nueva arquitectura debe contemplar ese valor y no asumir `cita_si`.

## Notificación interna prevista

Cuando una cita quede realmente confirmada, la v1.2 contempla generar una notificación por correo electrónico a destinatarios autorizados de la empresa. El mecanismo concreto, el evento, la prevención de duplicados, los cambios posteriores y la detección de fallos todavía están pendientes. No se ha seleccionado definitivamente n8n o Make, ni se ha configurado correo.

La empresa utilizará inicialmente el correo para registrar manualmente la cita en su propio sistema. No se contempla desarrollar de inicio una integración automática con esa tabla.

## Seguridad y límites

Los secretos deben mantenerse en credenciales de n8n o variables de entorno, nunca en JSON, documentación o GitHub. La arquitectura documentada no implica acceso del repositorio al VPS ni autorización para modificar servicios externos.
