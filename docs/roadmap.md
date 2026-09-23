# Roadmap

## v1.0 — MVP

**Estado: completada.**

Desarrollo inicial del bot de atención y precalificación para Pro Consultores mediante n8n, WhatsApp Cloud API y Supabase. Incluyó el flujo determinista de precalificación y la derivación al agente.

## v1.1 — Despliegue en producción

**Estado: completada.**

- Migrar el bot funcional a Contabo Cloud VPS 6.
- Instalar Ubuntu, Docker y Docker Compose.
- Restaurar n8n, sus workflows y credenciales cifradas.
- Configurar `bot.proconsultores.com.mx` y HTTPS con Caddy.
- Actualizar el webhook de Meta.
- Configurar acceso SSH mediante claves y desactivar el acceso SSH por contraseña.
- Validar el flujo comercial con tráfico real y con la computadora local apagada.

La v1.1 no incorporó nuevas funcionalidades de precalificación ni cambios en la lógica comercial. La instalación de producción está operativa en Contabo.

## v1.2 — Integración con Airtable

**Estado: planificada / pendiente de implementación.**

El objetivo es registrar en Airtable la información comercial de un usuario que completó satisfactoriamente la precalificación y solicitó una cita. El registro representa una solicitud de cita, no una cita confirmada con fecha y horario.

Alcance previsto:

- Identificar el punto de `whatsapp-leads` donde actualmente se envía el aviso al agente.
- Configurar la credencial de Airtable en n8n.
- Añadir una operación de creación de registro con base, tabla y campos que se definirán durante la implementación.
- Mapear los campos comerciales existentes a las columnas acordadas de Airtable.
- Sustituir el aviso interno al agente por WhatsApp por la creación del registro en Airtable.
- Validar la creación y recepción de registros mediante pruebas controladas.
- Comprobar que la integración no altera las reglas comerciales ni las etapas anteriores y que el workflow funciona correctamente en producción.

La integración conservará los dos workflows actuales (`whatsapp-webhook` y `whatsapp-leads`). Supabase seguirá siendo la base principal comercial y conversacional. La configuración de autenticación, el destino y el mapeo están pendientes. La v1.2 no incluye IA, un tercer workflow, gestión adicional de citas ni notificaciones por correo.

## v1.3 a v1.8 — Evolución futura

**Estado: sin definir.** Estas versiones quedan reservadas para funcionalidades y mejoras que se decidan posteriormente. No se inventan fechas, requisitos ni funcionalidades.

## v1.9 — Mantenimiento avanzado

**Estado: reservada / no priorizada.**

Esta versión reúne los hallazgos y propuestas de la antigua planificación de hardening v1.1. La auditoría histórica se conserva en [docs/audit-1.9.md](audit-1.9.md), con su fecha original.

La v1.9 no es requisito previo para comenzar v1.2. Sus criterios no deben presentarse como implementados ni como una puerta obligatoria de desarrollo. Los problemas técnicos se atenderán individualmente, según evidencia operativa, impacto y decisiones aprobadas.

## Metodología de mantenimiento

El bot es una herramienta complementaria de captación y precalificación. Se mantendrá supervisión operativa; cada error o inconsistencia confirmada se investigará y corregirá de forma focalizada, comprobando el resultado. No se convertirán automáticamente todos los hallazgos de la auditoría histórica en trabajo obligatorio.

La frecuencia definitiva y las responsabilidades operativas podrán ajustarse según la experiencia real.
