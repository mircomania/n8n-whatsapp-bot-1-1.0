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
- Mantener una operación complementaria de captación, sin convertir el bot en el sistema central de operaciones de la empresa.

La meta comercial inicial es generar aproximadamente 20 leads calificados mensuales. Es una meta de negocio, no una métrica alcanzada o verificada.

## Flujo funcional actual

1. Meta entrega un evento al webhook de producción.
2. El receptor dirige el mensaje admitido al workflow principal.
3. El workflow identifica el teléfono y consulta `public.leads`.
4. Un lead nuevo inicia en `estado`; uno existente continúa según su etapa y reset.
5. Cada respuesta válida actualiza datos y avanza el proceso; una inválida vuelve a solicitar la respuesta.
6. Un incumplimiento registra el rechazo y su motivo.
7. Una solicitud de cita actualiza el lead y activa el aviso al agente.

## Estado del producto

- **v1.0 — MVP:** completada. Incluye el bot determinista de precalificación y derivación.
- **v1.1 — Despliegue en producción:** completada. El bot funcional fue migrado a Contabo, con dominio permanente, HTTPS, restauración de n8n y validación del recorrido comercial. No incorporó nuevas funcionalidades comerciales.
- **v1.2 — Integración de IA:** planificada. Incorporará la gestión posterior a la precalificación, citas y notificaciones internas por correo. No está implementada.
- **v1.9 — Mantenimiento avanzado:** reservada y no priorizada. Reúne la auditoría histórica y no es requisito previo para comenzar v1.2.

La producción funciona en Contabo. El entorno local de Windows se conserva para desarrollo y pruebas, pero es independiente y puede compartir integraciones reales; no debe considerarse completamente aislado.

## Mantenimiento

La metodología aprobada es supervisar la operación, investigar cada error o inconsistencia observada, aplicar una corrección focalizada y comprobar el resultado. No se convertirán automáticamente todos los hallazgos históricos de hardening en tareas obligatorias.

## Alcance futuro

La v1.2 contempla un tercer workflow para gestionar citas con IA después de que el usuario supere la precalificación determinista. La IA no sustituirá las reglas actuales. También se contempla una notificación interna por correo electrónico para que la empresa registre manualmente las citas confirmadas. Ambos elementos siguen planificados.
