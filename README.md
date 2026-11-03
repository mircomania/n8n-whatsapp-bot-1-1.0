# Bot de precalificación por WhatsApp

Sistema de atención y precalificación de leads de Mejoravit para Pro Consultores, mediante WhatsApp Cloud API, n8n y Supabase PostgreSQL. La v1.0 (MVP), la v1.1 (despliegue en Contabo) y la v1.2 (integración con Airtable) están completadas. La operación se mantiene por excepción, con monitoreo diario de consumo y alertas de incidentes de Meta.

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

Además del recorrido comercial, `whatsapp-monitor` consulta diariamente el consumo de Meta, guarda el resumen mensual en Supabase y notifica umbrales mediante Slack API. `whatsapp-incidentes` gestiona alertas de autenticación y facturación `131042`, con reserva de una alerta cada 24 horas por tipo.

Supabase conserva la persistencia comercial y conversacional principal. Airtable es la salida interna automatizada para solicitudes de cita de usuarios calificados. El registro no confirma fecha ni horario. El aviso interno al agente por WhatsApp fue retirado.

Al 2 de noviembre de 2026, el usuario reporta los cuatro workflows publicados en Contabo. La evidencia operativa y sus límites están en [Estado actual](docs/current-state.md); los exports no demuestran por sí solos la configuración viva. `source` y `Fuente_lead` usan la etiqueta comercial `BOT IA`; esto no significa que el workflow utilice inteligencia artificial.

La instalación local de Windows es independiente de producción y puede compartir integraciones reales. Las pruebas locales deben tratarse como operativamente sensibles.

## Estado y documentación

- [Estado actual](docs/current-state.md): producción en Contabo, Airtable, consumo mensual, incidentes y pruebas reportadas.
- [Proyecto](docs/project.md): propósito, alcance y estado de las versiones.
- [Arquitectura](docs/architecture.md): componentes y flujo actual y publicado.
- [Lógica de negocio](docs/business-logic.md): etapas y reglas deterministas de precalificación.
- [Roadmap](docs/roadmap.md): versiones completadas y trabajo futuro.
- [Registro de decisiones](docs/decisions.md): decisiones técnicas, comerciales y operativas.
- [Stack](docs/stack.md): tecnologías y responsabilidades.
- [Respaldo SQL](supabase/README.md): tablas, funciones y permisos reportados al 3 de noviembre; restauración todavía no probada.
- [Auditoría de exports del 2 de noviembre](docs/audit-2026-11-02.md): seguridad, diferencias y comprobaciones locales.
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
│   ├── audit-2026-11-02.md
│   ├── business-logic.md
│   ├── current-state.md
│   ├── decisions.md
│   ├── project.md
│   ├── roadmap.md
│   └── stack.md
├── supabase/
│   ├── README.md
│   ├── schema.sql
│   ├── monitor-functions.sql
│   └── incident-functions.sql
└── workflows/
    ├── whatsapp-incidentes.json
    ├── whatsapp-leads.json
    ├── whatsapp-monitor.json
    └── whatsapp-webhook.json
```

`dockers-run.txt` contiene configuración histórica local y no debe reutilizarse como definición de producción.

## Seguridad

Este repositorio es público. No incorporar tokens, credenciales, teléfonos, NSS, datos de leads, respaldos internos, variables sensibles ni endpoints temporales. Las credenciales de integración se administran mediante n8n.

El cierre de seguridad del 2 de noviembre anonimiza dos valores ambiguos de la caché Airtable sin cambiar la lógica. Los demás identificadores revisados son metadatos de integración o del catálogo de origen; el endpoint histórico resultó ser un placeholder. La [auditoría](docs/audit-2026-11-02.md) registra la clasificación y los límites de la revisión, incluido el historial previo de Git.

Los JSON son exportes de control de versiones. Modificarlos no actualiza por sí solo la instalación publicada; la instancia viva de Contabo y los exportes locales se distinguen en la documentación.

## Autor

Mircomania
