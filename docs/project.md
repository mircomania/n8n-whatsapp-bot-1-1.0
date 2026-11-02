# Proyecto

## Descripción

Bot de WhatsApp para atender y precalificar leads de Mejoravit, desarrollado para Pro Consultores. Conduce una conversación estructurada mediante reglas deterministas y deriva la solicitud de cita de un usuario calificado.

WhatsApp Cloud API proporciona el canal, n8n coordina la automatización y Supabase PostgreSQL conserva los datos comerciales y el estado conversacional. Cuando un usuario calificado solicita una cita, el workflow crea un registro en Airtable para la gestión interna.

## Objetivos

- Responder de manera consistente a cada mensaje admitido.
- Aplicar las reglas deterministas de precalificación por ubicación, situación laboral y subcuenta.
- Conservar el estado entre ejecuciones independientes.
- Registrar resultados y motivos de rechazo.
- Crear en Airtable un registro cuando un usuario calificado solicita una cita.
- Observar consumo mensual de Meta e incidentes de autenticación/facturación y notificarlos mediante Slack.
- Mantener una operación complementaria de captación, sin convertir el bot en el sistema central de operaciones de la empresa.

La meta comercial inicial es generar aproximadamente 20 leads calificados mensuales. Es una meta de negocio, no una métrica alcanzada o verificada.

## Estado del producto

- **v1.0 — MVP:** completada.
- **v1.1 — Despliegue en producción:** completada en Contabo.
- **v1.2 — Integración con Airtable:** completada, implementada y publicada en producción. Airtable es la salida interna automatizada vigente; el aviso al agente por WhatsApp fue retirado.
- **v1.9 — Mantenimiento avanzado:** reservada y no priorizada; no fue requisito para cerrar v1.2.

El registro de Airtable se genera cuando un usuario calificado solicita una cita. No representa una cita confirmada con fecha y horario. Supabase sigue siendo la base principal. Los JSON actuales fueron reportados por el usuario como exportes de la versión estabilizada; `Fuente_lead` usa el valor intencional `BOT IA`.

## Monitoreo e incidentes

Al 2 de noviembre de 2026 el usuario reporta publicados los cuatro workflows: recepción, precalificación, monitoreo e incidentes. `whatsapp-monitor` consulta diariamente consumo de Meta, conserva resúmenes mensuales en Supabase y notifica pasos de 1.000 mensajes y US$20 mediante Slack API. `whatsapp-incidentes` gestiona autenticación y facturación `131042`, con reserva de una alerta cada 24 horas por tipo.

La corrección de noviembre admite estadísticas ausentes como ceros provisionales. La protección SQL contra sobrescribir valores positivos está implementada según comprobación reportada, con prueba específica pendiente. La siguiente ejecución automática completa también está pendiente. [Estado actual](current-state.md) distingue lo implementado, las pruebas operativas reportadas y las limitaciones; este mantenimiento no recibe una versión nueva por inferencia.

## Operación y mantenimiento

El seguimiento de nuevos registros se realizará como parte del mantenimiento operativo habitual. La prueba manual reportada confirmó la creación de un registro con los valores esperados; no equivale a pruebas exhaustivas con múltiples leads ni demuestra funcionamiento a largo plazo.

La operación se mantiene por excepción, apoyada por monitoreo diario: investigar errores reales, atender casos excepcionales relevantes, cambios comerciales solicitados y mantenimiento necesario. No se planifican refactors preventivos sin evidencia. Los exportes locales no sustituyen a la instancia viva como referencia operativa.
