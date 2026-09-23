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

## v1.2 — Integración de IA y gestión de citas

**Estado: planificada.** No implementar todavía.

- Incorporar un tercer workflow, de nombre provisional `whatsapp-ia`.
- Mantener `whatsapp-leads` como responsable de la precalificación determinista.
- Enrutar hacia IA las respuestas posteriores de usuarios que superaron la precalificación y solicitaron una cita.
- Solicitar y registrar el nombre del usuario.
- Coordinar fecha y horario con disponibilidad realmente existente.
- Confirmar la cita solo cuando se cumplan las reglas comerciales y las validaciones necesarias.
- Registrar la información de la cita en `public.leads`, definiendo antes los campos y estados definitivos.
- Enviar al usuario un comprobante por WhatsApp con la información autorizada de la cita.
- Sustituir el aviso interno por WhatsApp por una notificación por correo electrónico a destinatarios autorizados.
- Permitir que la empresa registre manualmente la cita en su propio sistema a partir del correo.

Durante v1.2 deben definirse el enrutamiento, la disponibilidad, las oficinas y horarios, el evento de confirmación, la prevención de correos duplicados, los cambios posteriores y el tratamiento de fallos. La herramienta de correo no está seleccionada; no se ha elegido definitivamente n8n ni Make.

## v1.3 a v1.8 — Evolución futura

**Estado: sin definir.** Estas versiones quedan reservadas para funcionalidades y mejoras que se decidan posteriormente. No se inventan fechas, requisitos ni funcionalidades.

## v1.9 — Mantenimiento avanzado

**Estado: reservada / no priorizada.**

Esta versión reúne los hallazgos y propuestas de la antigua planificación de hardening v1.1. La auditoría histórica se conserva en [docs/audit-1.9.md](audit-1.9.md), con su fecha original.

La v1.9 no es requisito previo para comenzar v1.2. Sus criterios no deben presentarse como implementados ni como una puerta obligatoria de desarrollo. Los problemas técnicos se atenderán individualmente, según evidencia operativa, impacto y decisiones aprobadas.

## Metodología de mantenimiento

El bot es una herramienta complementaria de captación y precalificación. Se mantendrá supervisión operativa; cada error o inconsistencia confirmada se investigará y corregirá de forma focalizada, comprobando el resultado. No se convertirán automáticamente todos los hallazgos de la auditoría histórica en trabajo obligatorio.

La operación prevista para v1.2 contempla una revisión diaria de nuevas citas y entre dos y tres revisiones técnicas semanales. El objetivo aproximado de 10 minutos diarios y esas frecuencias son estimaciones operativas, no métricas actuales verificadas ni garantías de detección inmediata.
