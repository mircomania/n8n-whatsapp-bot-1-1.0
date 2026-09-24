# Bot de precalificación por WhatsApp

Sistema de atención y precalificación de leads de Mejoravit para Pro Consultores, mediante WhatsApp Cloud API, n8n y Supabase PostgreSQL. La v1.0 (MVP), la v1.1 (despliegue en Contabo) y la v1.2 (integración con Airtable) están completadas. La integración v1.2 fue configurada y publicada en n8n de producción en Contabo.

## Flujo de producción

```text
WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker
  -> n8n en Contabo: whatsapp-webhook
  -> n8n: whatsapp-leads
       -> precalificación determinista
       -> Supabase PostgreSQL: public.leads
       -> respuesta al usuario por WhatsApp
       -> aviso al agente por WhatsApp
       -> creación de registro en Airtable
```

Supabase conserva la persistencia comercial y conversacional principal. Airtable recibe información para que la empresa consulte y gestione los leads. El registro de Airtable corresponde a una solicitud de cita de un usuario calificado; no confirma fecha ni horario. El aviso al agente por WhatsApp continúa activo junto con la creación del registro.

La publicación en Contabo fue confirmada por el usuario. La prueba manual reportada completó los nodos del tramo final y verificó la creación del registro. Los JSON de `workflows/` en este repositorio son exportes anteriores y todavía no reflejan la versión publicada; su sincronización está pendiente por separado.

La instalación local de Windows es independiente de producción y puede compartir integraciones reales. Las pruebas locales deben tratarse como operativamente sensibles.

## Estado y documentación

- [Estado actual](docs/current-state.md): producción en Contabo, integración de Airtable, validaciones y exportes pendientes.
- [Proyecto](docs/project.md): propósito, alcance y estado de las versiones.
- [Arquitectura](docs/architecture.md): componentes y flujo actual y publicado.
- [Lógica de negocio](docs/business-logic.md): etapas y reglas deterministas de precalificación.
- [Roadmap](docs/roadmap.md): versiones completadas y trabajo futuro.
- [Registro de decisiones](docs/decisions.md): decisiones técnicas, comerciales y operativas.
- [Stack](docs/stack.md): tecnologías y responsabilidades.
- [Auditoría histórica v1.9](docs/audit-1.9.md): hallazgos y propuestas de mantenimiento avanzado.
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

`dockers-run.txt` contiene configuración histórica local y no debe reutilizarse como definición de producción.

## Seguridad

Este repositorio es público. No incorporar tokens, credenciales, teléfonos, NSS, datos de leads, respaldos internos, variables sensibles ni endpoints temporales. Las credenciales de integración se administran mediante n8n.

Los JSON son exportes de control de versiones. Modificarlos no actualiza por sí solo la instalación publicada; la documentación del estado desplegado distingue la versión operativa de esos exportes anteriores.

## Autor

Mircomania
