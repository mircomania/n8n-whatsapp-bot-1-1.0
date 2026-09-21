# Proyecto

## Descripción

Bot de WhatsApp para atender y precalificar leads de Mejoravit, desarrollado para Pro Consultores. Recibe usuarios provenientes principalmente de campañas, conduce una conversación estructurada y deriva a un agente humano a quienes llegan al flujo de cita.

WhatsApp Cloud API proporciona el canal, n8n coordina la automatización y Supabase PostgreSQL conserva los datos y la etapa de cada lead.

## Objetivos

- Responder de manera consistente a cada mensaje admitido.
- Aplicar reglas deterministas de precalificación por ubicación, situación laboral y subcuenta.
- Conservar el estado entre ejecuciones independientes.
- Registrar resultados y motivos de rechazo.
- Derivar solicitudes de cita al agente humano.
- Operar con controles de idempotencia, errores, recuperación y observabilidad antes de migrar a producción.

## Flujo funcional

1. Meta entrega un evento al webhook.
2. El receptor valida y normaliza el mensaje admitido.
3. El workflow principal identifica el teléfono y consulta `public.leads`.
4. Un lead nuevo inicia en `estado`; uno existente continúa según su etapa y reset.
5. Cada respuesta válida actualiza datos y avanza el proceso; una inválida vuelve a solicitar la respuesta.
6. Un incumplimiento registra el rechazo y su motivo.
7. Una solicitud de cita actualiza el lead y activa la derivación al agente.

El paso 2 describe la responsabilidad deseada. La implementación actual intenta extraer `messages[0]` antes de validar por completo el evento y debe corregirse en v1.1.

## Estado del producto

- **v1.0 — MVP:** completada; el bot lleva aproximadamente un mes operando con tráfico real al momento de la auditoría.
- **v1.1 — Hardening:** etapa actual; debe resolver idempotencia, concurrencia, reset, validación de webhooks, errores, observabilidad, recuperación y regresión.
- **v1.2 — Producción:** migración posterior a un VPS de Contabo ya seleccionado como proveedor, pero aún no contratado.

La operación actual depende de Windows 10, Docker Desktop y ngrok. La evidencia detallada y fechada se conserva en [Estado actual](current-state.md); los criterios técnicos están en [Auditoría v1.1](audit-1.1.md).

## Alcance futuro

Se contempla un dashboard para agentes e inteligencia artificial como complemento de la atención antes de la derivación humana. La IA no debe sustituir sin controles las reglas deterministas; cualquier diseño deberá definir la transición entre automatización, IA y agente.
