# Proyecto

## Descripción

Bot multicampaña de WhatsApp para Pro Consultores. Atiende **Mejoravit y Laudo** con reglas deterministas de precalificación y deriva a Airtable las solicitudes de cita de usuarios calificados. La v1.3 fue desplegada y probada en producción en Contabo el **5 de noviembre de 2026**, según confirmación del usuario, con validación de los recorridos principales.

El sistema dispone de seis workflows: `whatsapp-webhook`, `whatsapp-router`, `whatsapp-leads`, `whatsapp-laudo`, `whatsapp-monitor` y `whatsapp-incidentes`. WhatsApp Cloud API aporta el canal; n8n coordina las conversaciones; Supabase conserva el contexto de servicio y los historiales comerciales separados; Airtable es la salida interna para solicitudes de cita.

## Objetivos

- Resolver el servicio por mensaje explícito, contexto vigente o historial, y solicitar elección cuando corresponda.
- Aplicar las reglas propias de Mejoravit y Laudo sin mezclar sus datos ni etapas.
- Conservar continuidad conversacional y permitir un cambio explícito entre campañas.
- Registrar resultados y motivos de rechazo en la tabla comercial del servicio.
- Crear en Airtable una solicitud de cita, con el nombre de perfil disponible como referencia provisional.
- Mantener el monitoreo mensual de Meta y los avisos de incidentes mediante Slack.
- Operar como herramienta complementaria de captación, sin sustituir el sistema central de la empresa.

La meta comercial inicial registrada es generar aproximadamente 20 leads calificados mensuales. Es una meta de negocio, no una métrica alcanzada; su alcance no se revalidó para v1.3.

## Estado del producto

| Versión | Estado |
|---|---|
| v1.0 — MVP | Completada. |
| v1.1 — Despliegue en producción | Completada en Contabo. |
| v1.2 — Integración con Airtable | Completada y publicada; retirado el aviso interno por WhatsApp. |
| v1.3 — Multicampaña | Desplegada el 5 de noviembre; recorridos principales validados según reporte del usuario. |
| v1.4–v1.8 | Sin alcance definido. |
| v1.9 — Mantenimiento avanzado | Reservada y no priorizada; sus propuestas históricas no son requisitos automáticos de v1.3. |

Laudo admite personas de **48 años cumplidos o más**, sin pensión ni crédito Infonavit activo, incluidos leads del estado Otro. Mejoravit conserva los filtros de ubicación, antigüedad laboral y subcuenta implementados. Las reglas y discrepancias del export están en [Lógica de negocio](business-logic.md).

## Alcance validado y límites

El usuario confirmó recepción real, distribución a ambos bots, continuidad por contexto/historial, cambio explícito de campaña, menú, recorridos positivos hasta Supabase/Airtable en ambos servicios y Laudo con Otro, una respuesta negativa con resultado esperado y transmisión del nombre de perfil. El detalle y las comprobaciones de Supabase reportadas están en [Estado actual](current-state.md#validación-de-v13--5-de-noviembre-de-2026).

El nombre de perfil no es identidad legal o verificada y no se guarda en Supabase. Un registro de Airtable representa una **solicitud de cita**, sin fecha u horario confirmados. Las etiquetas `BOT IA` siguen siendo valores comerciales, no uso de IA.

No se acredita cobertura exhaustiva ni operación prolongada sin fallos. Siguen pendientes la revisión completa de mensajes predefinidos de captación, la alineación de los textos de edad publicados con el export local, el respaldo completo y su restauración, y escenarios de mantenimiento no verificados. Véase el [roadmap](roadmap.md).

## Monitoreo y operación

Monitoreo e incidentes mantienen su función independiente del router. Sus antecedentes del 2 y 3 de noviembre —incluido el PASS SQL de protección contra ceros y la ejecución automática del monitor— y sus pendientes específicos se conservan en [Estado actual](current-state.md) y en el [respaldo SQL](../supabase/README.md). Las pruebas comerciales del día 5 no validan por extensión los escenarios pendientes del monitoreo.

La operación continúa por excepción: investigar errores confirmados, cambios comerciales aprobados y mantenimiento necesario de credenciales o infraestructura. La versión desplegada se documenta a partir del reporte operativo y de la inspección local; los exports no prueban por sí solos la configuración viva.
