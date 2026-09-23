# Bot de precalificación por WhatsApp

Sistema de atención y precalificación de leads de Mejoravit, desarrollado para Pro Consultores con WhatsApp Cloud API, n8n y Supabase PostgreSQL.

La v1.0 corresponde al MVP inicial. La v1.1, cuyo alcance fue el despliegue en producción, está completada en Contabo. La v1.2 está planificada para integrar Airtable al flujo de precalificación y registrar leads que solicitan una cita; la integración todavía no está implementada.

## Flujo actual de producción

```text
WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker
  -> n8n en Contabo: whatsapp-webhook
  -> n8n: whatsapp-leads
  -> Supabase PostgreSQL: public.leads
  -> respuesta por WhatsApp y aviso actual al agente cuando corresponde
```

La arquitectura objetivo de v1.2 conservará los dos workflows y añadirá la creación de un registro en Airtable cuando un usuario calificado solicite una cita. Ese registro no significa que exista una cita confirmada.

La instalación de producción funciona de forma independiente del entorno local de Windows. El entorno local se conserva para desarrollo y pruebas, pero modificar sus exportes no modifica automáticamente la instalación publicada. Ambos entornos pueden compartir integraciones reales, por lo que las pruebas locales deben tratarse como operativamente sensibles.

## Estado y documentación

- [Estado actual](docs/current-state.md): producción en Contabo, entorno local, versiones, validaciones y respaldos.
- [Proyecto](docs/project.md): propósito, alcance y estado del producto.
- [Arquitectura](docs/architecture.md): componentes actuales y arquitectura planificada para v1.2.
- [Lógica de negocio](docs/business-logic.md): etapas y reglas deterministas de precalificación.
- [Roadmap](docs/roadmap.md): versiones, estados y trabajo futuro.
- [Registro de decisiones](docs/decisions.md): decisiones técnicas, comerciales y operativas.
- [Stack](docs/stack.md): tecnologías y responsabilidades.
- [Auditoría histórica v1.9](docs/audit-1.9.md): hallazgos y propuestas de la antigua planificación de hardening v1.1.
- [Instrucciones para agentes](AGENTS.md): reglas permanentes para futuras sesiones.

## Estructura relevante

```text
.
├── AGENTS.md
├── dockers-run.txt
├── docs/
│   ├── architecture.md
│   ├── audit-1.9.md
│   ├── business-logic.md
│   ├── current-state.md
│   ├── decisions.md
│   ├── project.md
│   ├── roadmap.md
│   └── stack.md
└── workflows/
    ├── whatsapp-leads.json
    ├── whatsapp-leads-v1.json
    ├── whatsapp-webhook.json
    └── whatsapp-webhook-v1.json
```

`dockers-run.txt` es el nombre real del ejemplo local existente. Contiene configuración histórica de desarrollo y no debe reutilizarse como definición de producción.

## Seguridad

Este repositorio es público. No deben incorporarse tokens, credenciales, teléfonos, NSS, datos de leads, respaldos internos, variables sensibles ni endpoints temporales. Los secretos se administran mediante credenciales de n8n o variables de entorno según corresponda.

Los JSON son exportes para control de versiones. Modificarlos no actualiza por sí solo la instalación publicada, y una tarea documental no autoriza su importación ni modificación.

## Autor

Mircomania
