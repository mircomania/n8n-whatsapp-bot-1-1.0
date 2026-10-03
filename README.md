# Bot de precalificación por WhatsApp

Sistema de atención y precalificación de leads de Mejoravit para Pro Consultores, mediante WhatsApp Cloud API, n8n y Supabase PostgreSQL. La v1.0 (MVP), la v1.1 (despliegue en Contabo) y la v1.2 (integración con Airtable) están completadas. La operación está estable y se mantiene por excepción.

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
       -> creación de registro en Airtable al solicitar cita calificada
```

Supabase conserva la persistencia comercial y conversacional principal. Airtable es la salida interna automatizada para solicitudes de cita de usuarios calificados. El registro no confirma fecha ni horario. El aviso interno al agente por WhatsApp fue retirado.

El usuario confirmó la publicación final en Contabo y reportó más de una semana de operación de Airtable sin errores. Los JSON actuales fueron reportados como exportes de esa versión estabilizada. `source` y `Fuente_lead` usan la etiqueta comercial `BOT IA`; esto no significa que el workflow utilice inteligencia artificial.

La instalación local de Windows es independiente de producción y puede compartir integraciones reales. Las pruebas locales deben tratarse como operativamente sensibles.

## Estado y documentación

- [Estado actual](docs/current-state.md): producción en Contabo, integración Airtable, observaciones y auditoría de exportes.
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
    └── whatsapp-webhook.json
```

`dockers-run.txt` contiene configuración histórica local y no debe reutilizarse como definición de producción.

## Seguridad

Este repositorio es público. No incorporar tokens, credenciales, teléfonos, NSS, datos de leads, respaldos internos, variables sensibles ni endpoints temporales. Las credenciales de integración se administran mediante n8n.

Los JSON son exportes de control de versiones. Modificarlos no actualiza por sí solo la instalación publicada; la instancia viva de Contabo y los exportes locales se distinguen en la documentación.

## Autor

Mircomania
