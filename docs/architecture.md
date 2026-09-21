# Arquitectura

## Arquitectura actual

```text
Usuario
  -> WhatsApp Cloud API / webhook de Meta
  -> ngrok (exposición HTTPS local)
  -> n8n: whatsapp-webhook
       -> extracción y normalización
       -> filtro actual
       -> Execute Sub-workflow
  -> n8n: whatsapp-leads
       -> consulta/actualización de public.leads
       -> lógica por etapa
       -> respuestas por WhatsApp Cloud API
       -> aviso al agente cuando corresponde
```

El estado conversacional reside en Supabase, no en una ejecución prolongada de n8n. Cada mensaje inicia una ejecución que interpreta la siguiente respuesta usando la etapa persistida del lead.

## Responsabilidades

### `whatsapp-webhook`

Punto de entrada de Meta. El exporte actual:

- recibe el POST;
- intenta extraer `telefono`, `tipo` y `mensaje` desde `messages[0]`;
- acepta texto, respuesta de lista o respuesta de botón;
- comprueba después si existe `tipo`;
- llama a `whatsapp-leads` y responde al webhook.

Aunque existe un filtro, el orden actual no valida de forma segura todos los eventos antes de acceder a `messages[0]`. En v1.1 la validación estructural debe preceder a la extracción para tolerar estados y otros eventos de Meta. Tampoco se propaga actualmente `wamid`.

### `whatsapp-leads`

Workflow principal encargado de:

- buscar o crear el lead en `public.leads`;
- aplicar un control temporal de interacción;
- evaluar `fecha_reset` cuando existe;
- enrutar por `etapa`;
- validar y persistir respuestas;
- enviar preguntas y resultados;
- registrar citas y avisar al agente.

El flujo exportado contiene 44 nodos, incluidos 16 `HTTP Request`. No se identificaron reintentos explícitos ni un workflow centralizado de errores.

### Supabase

`public.leads` mantiene el estado comercial y conversacional. La unicidad de `telefono` protege la identidad del lead, no la unicidad de cada evento. El esquema completo está en [Estado actual](current-state.md).

## Controles actuales y límites

- `ultima_interaccion` descarta mensajes en intervalos menores a 1500 ms, pero no garantiza idempotencia ni exclusión concurrente.
- `fecha_reset` se evalúa cuando el usuario vuelve a escribir; no hay un reinicio programado en el instante del vencimiento.
- `Reset estado` solo asigna `etapa = estado`; la limpieza coherente del resto de campos está pendiente.
- La ruta `Si cita -> Espera agente -> Aviso agente` no muestra una garantía explícita de notificación única o recuperación.
- Los errores y reintentos deben diseñarse junto con la idempotencia para evitar efectos duplicados.

## Arquitectura objetivo de v1.1

El diseño definitivo todavía debe aprobarse, pero la arquitectura endurecida debe incorporar:

1. Validación del evento antes de normalizarlo.
2. Identificación por `wamid` y registro duradero del procesamiento.
3. Protección ante ejecuciones concurrentes y duplicados.
4. Estados recuperables para mensajes y notificaciones con fallos parciales.
5. Reset con semántica explícita de limpieza y conservación histórica.
6. Manejo de errores, reintentos limitados, métricas y alertas sin datos personales.

Una tabla independiente de mensajes en Supabase es una posibilidad, no una decisión aprobada. Véanse los criterios en [Auditoría v1.1](audit-1.1.md).

## Arquitectura objetivo de v1.2

```text
Usuario
  -> WhatsApp Cloud API
  -> dominio o subdominio HTTPS permanente
  -> Contabo VPS
  -> n8n en Docker con persistencia y reinicio automático
  -> Supabase administrado (servicio externo)
```

Contabo y el plan Cloud VPS 6 están aprobados como referencia. El VPS aún no se ha contratado y la topología detallada, proxy, certificados, secretos, backups y monitoreo todavía deben definirse e implementarse. Supabase seguirá externo salvo aprobación expresa de otro cambio.

## Seguridad

Los secretos deben mantenerse en credenciales de n8n o variables de entorno, nunca en JSON, documentación o GitHub. Los exportes existentes requieren una revisión autorizada de identificadores y destinos fijos potencialmente sensibles; el hallazgo se registra sin reproducir valores en la auditoría.
