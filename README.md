# Bot de precalificación por WhatsApp

Sistema de atención y precalificación de leads de Mejoravit, desarrollado para Pro Consultores con WhatsApp Cloud API, n8n y Supabase PostgreSQL.

El MVP v1.0 está completado y funciona con tráfico real en un entorno local. El proyecto se encuentra en **v1.1 Hardening**; la migración al VPS de producción corresponde a v1.2 y no debe iniciarse antes de cerrar los criterios de v1.1.

## Flujo general

```text
WhatsApp Cloud API
  -> webhook HTTPS local mediante ngrok
  -> n8n: whatsapp-webhook
  -> n8n: whatsapp-leads
  -> Supabase PostgreSQL
  -> respuesta por WhatsApp o derivación a agente
```

El receptor normaliza el evento y llama al workflow principal. El flujo principal consulta y actualiza el lead, aplica las reglas de precalificación, envía respuestas y deriva las solicitudes de cita.

## Estado y documentación

- [Estado actual verificado](docs/current-state.md): infraestructura, versiones, workflows, Supabase, datos y respaldos.
- [Auditoría técnica v1.1](docs/audit-1.1.md): hallazgos, riesgos, propuestas y criterios de aceptación.
- [Proyecto](docs/project.md): objetivo, alcance y estado del producto.
- [Arquitectura](docs/architecture.md): componentes y flujos actuales y futuros.
- [Lógica de negocio](docs/business-logic.md): etapas y reglas de conversación.
- [Roadmap](docs/roadmap.md): versiones y trabajo pendiente.
- [Stack](docs/stack.md): tecnologías y responsabilidades.
- [Instrucciones para agentes](AGENTS.md): reglas permanentes para futuras sesiones.

## Estructura relevante

```text
.
├── AGENTS.md
├── dockers-run.txt
├── docs/
│   ├── architecture.md
│   ├── audit-1.1.md
│   ├── business-logic.md
│   ├── current-state.md
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
