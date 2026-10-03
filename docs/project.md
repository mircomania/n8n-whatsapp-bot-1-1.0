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
- Mantener una operación complementaria de captación, sin convertir el bot en el sistema central de operaciones de la empresa.

La meta comercial inicial es generar aproximadamente 20 leads calificados mensuales. Es una meta de negocio, no una métrica alcanzada o verificada.

## Estado del producto

- **v1.0 — MVP:** completada.
- **v1.1 — Despliegue en producción:** completada en Contabo.
- **v1.2 — Integración con Airtable:** completada, implementada y publicada en producción. Airtable es la salida interna automatizada vigente; el aviso al agente por WhatsApp fue retirado.
- **v1.9 — Mantenimiento avanzado:** reservada y no priorizada; no fue requisito para cerrar v1.2.

El registro de Airtable se genera cuando un usuario calificado solicita una cita. No representa una cita confirmada con fecha y horario. Supabase sigue siendo la base principal. Los JSON actuales fueron reportados por el usuario como exportes de la versión estabilizada; `Fuente_lead` usa el valor intencional `BOT IA`.

## Operación y mantenimiento

El seguimiento de nuevos registros se realizará como parte del mantenimiento operativo habitual. La prueba manual reportada confirmó la creación de un registro con los valores esperados; no equivale a pruebas exhaustivas con múltiples leads ni demuestra funcionamiento a largo plazo.

La operación está estable y se mantiene por excepción: investigar errores reales, atender casos excepcionales relevantes, cambios comerciales solicitados y mantenimiento necesario. No se planifican refactors preventivos sin evidencia. Los exportes locales no sustituyen a la instancia viva como referencia operativa.
