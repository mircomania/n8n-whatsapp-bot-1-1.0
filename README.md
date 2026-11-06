# Bot de precalificación por WhatsApp

Sistema multicampaña de Pro Consultores para atender y precalificar leads de **Mejoravit y Laudo**, mediante WhatsApp Cloud API, n8n y Supabase PostgreSQL. La **v1.3 está desplegada en Contabo y validada en sus recorridos principales**, según las pruebas de producción confirmadas por el usuario el **5 de noviembre de 2026**. Las versiones v1.0, v1.1 y v1.2 permanecen completadas.

## Flujo de producción

```text
WhatsApp Cloud API / Meta
  -> https://bot.proconsultores.com.mx
  -> Caddy en Docker / Contabo
  -> whatsapp-webhook
  -> whatsapp-router
       -> whatsapp-leads (Mejoravit) -> Supabase: public.leads
       -> whatsapp-laudo (Laudo)    -> Supabase: public.leads_laudo
       -> menú cuando no se identifica un servicio
  -> Airtable al solicitar cita tras superar la precalificación

whatsapp-monitor    -> Meta / resumen mensual en Supabase / Slack API
whatsapp-incidentes -> reserva de alertas en Supabase / Slack API
```

Los **seis workflows** están publicados según la confirmación del usuario. La URL pública conserva `/webhook/whatsapp-leads`; no se modificó la configuración de Meta. El router prioriza servicio explícito, contexto activo de menos de 24 horas e historial en una sola tabla; si no resuelve, ofrece un menú. Cada bot conserva su historial comercial independiente.

Laudo admite **48 años cumplidos**, incluida exactamente esa edad, y la opción de estado **Otro**. Mejoravit conserva sus reglas propias. Las transiciones y los pendientes textuales se detallan en [Lógica de negocio](docs/business-logic.md).

El nombre de perfil se transmite como `nombre_whatsapp` hasta `name` de Airtable en ambos servicios, sin guardarse en Supabase. Es una referencia provisional para el agente, no una identidad verificada. Airtable recibe **solicitudes de cita**, sin confirmar fecha ni horario. Supabase conserva el estado comercial; el aviso interno por WhatsApp fue retirado. `source` y `Fuente_lead: BOT IA` son etiquetas comerciales, no uso de inteligencia artificial.

`whatsapp-monitor` consulta consumo diario, registra el mes y notifica umbrales de 1.000 mensajes y US$20. `whatsapp-incidentes` atiende autenticación y facturación `131042` con límite de una alerta cada 24 horas por tipo. Sus pendientes operativos se conservan separados de la validación comercial de v1.3.

## Estado y documentación

- [Estado actual](docs/current-state.md): inventario de seis workflows, pruebas reportadas al 5 de noviembre y límites de la evidencia.
- [Proyecto](docs/project.md): propósito, alcance y versiones.
- [Arquitectura](docs/architecture.md): receptor, router, bots e integraciones.
- [Lógica de negocio](docs/business-logic.md): prioridades, precalificación por servicio y solicitudes de cita.
- [Roadmap](docs/roadmap.md): v1.3 desplegada, pendientes y versiones futuras.
- [Registro de decisiones](docs/decisions.md): decisiones históricas y multicampaña.
- [Stack](docs/stack.md): tecnologías y responsabilidades.
- [Respaldo SQL](supabase/README.md): fotografía de monitoreo e incidentes del 3 de noviembre; no incluye las tablas comerciales multicampaña ni una restauración validada.
- [Auditoría del 2 y 3 de noviembre](docs/audit-2026-11-02.md): fotografía histórica de cuatro exports; no es una auditoría actual de v1.3.
- [Auditoría histórica v1.9](docs/audit-1.9.md): mantenimiento avanzado reservado.
- [Instrucciones para agentes](AGENTS.md): reglas permanentes de trabajo.

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
    ├── whatsapp-laudo.json
    ├── whatsapp-leads.json
    ├── whatsapp-monitor.json
    ├── whatsapp-router.json
    └── whatsapp-webhook.json
```

## Seguridad y límites

Este repositorio es público. No incorporar secretos, credenciales, teléfonos, nombres reales, NSS, datos de leads, respaldos internos ni endpoints temporales. Las credenciales se administran mediante n8n. `dockers-run.txt` es configuración histórica local, no una definición de producción.

Los JSON son exports para control de versiones: su propiedad `active` no demuestra publicación ni equivalencia con la instancia viva. Las pruebas de producción son reportes confirmados por el usuario; Codex no accedió a producción durante este cierre documental. La instalación local es independiente y puede compartir integraciones reales.

Las auditorías históricas conservan sus fechas y alcance; no certifican los seis workflows actuales ni todo el historial de Git. Permanecen pendientes el respaldo estructural completo, su restauración y escenarios de concurrencia/fallos parciales; véase el [roadmap](docs/roadmap.md).

## Autor

Mircomania
