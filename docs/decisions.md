# Registro de decisiones

## Propósito

Este documento registra decisiones técnicas, comerciales y operativas relevantes, junto con su contexto y consecuencias. No sustituye al roadmap: el roadmap organiza versiones y estados; este registro explica elecciones y motivos.

Las fechas históricas exactas no se inventan. Cuando no existe una fecha comprobada, se indica que la entrada es una síntesis histórica.

## Decisiones iniciales

### DEC-001 — Crear un bot determinista de atención y precalificación

Fecha: síntesis histórica; fecha exacta no verificada.

Estado: Implementada.

Contexto: Pro Consultores necesitaba atender y precalificar leads provenientes de WhatsApp.

Decisión: Utilizar WhatsApp Cloud API como canal, n8n para ejecutar workflows y Supabase PostgreSQL para almacenar leads y estado conversacional, con reglas deterministas de precalificación.

Motivo: Separar el canal, la automatización y la persistencia comercial mediante componentes adecuados al alcance inicial.

Consecuencias: El bot es una herramienta complementaria de captación y precalificación; no es el sistema central de operaciones de la empresa.

### DEC-002 — Separar recepción y lógica comercial

Fecha: síntesis histórica; fecha exacta no verificada.

Estado: Implementada.

Contexto: Era necesario separar la entrada de Meta de las reglas de negocio.

Decisión: Mantener dos workflows: `whatsapp-webhook` para recibir eventos y `whatsapp-leads` para ejecutar la precalificación y la derivación.

Motivo: Aislar responsabilidades y permitir que el flujo comercial trabaje con el estado persistido.

Consecuencias: La evolución futura debe preservar la responsabilidad determinista de `whatsapp-leads` y definir explícitamente cualquier nuevo enrutamiento.

Actualización — 5 de noviembre de 2026: DEC-017 conserva la separación entre recepción y lógica comercial, pero sustituye el enlace directo receptor → Mejoravit por receptor → router → bot. La descripción de dos workflows anterior es histórica, no la arquitectura vigente de v1.3.

### DEC-003 — Desarrollar inicialmente en Windows

Fecha: síntesis histórica; fecha exacta no verificada.

Estado: Implementada.

Decisión: Utilizar Docker Desktop y ngrok para el desarrollo y las pruebas iniciales.

Consecuencia: El entorno local se conserva como entorno independiente, pero puede compartir integraciones reales y no debe tratarse como completamente aislado.

## Decisiones posteriores

### DEC-004 — Migrar el bot funcional a Contabo

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Implementada.

Contexto: El bot necesitaba funcionar con tráfico real sin depender de una computadora local encendida.

Decisión: Ejecutar producción en un Contabo Cloud VPS 6 con Ubuntu Server, Docker, Docker Compose, n8n persistente y Caddy como proxy HTTPS. Mantener Supabase como servicio externo.

Motivo: Eliminar la dependencia operativa del equipo local y disponer de un dominio permanente.

Consecuencias: Producción y desarrollo local son instalaciones independientes. Los exportes del repositorio no prueban igualdad con la versión publicada sin comparación actual.

### DEC-005 — Reordenar las versiones del proyecto

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada; su definición de v1.2 fue parcialmente sustituida por DEC-011.

Decisión original: Considerar v1.1 como despliegue en producción, v1.2 como integración de IA y v1.9 como mantenimiento avanzado reservado. La antigua etapa de hardening v1.1 deja de ser un requisito previo para v1.2. El alcance de IA para v1.2 fue reemplazado por DEC-011; v1.1 y v1.9 mantienen su estado.

Consecuencia: La auditoría histórica se conserva como `docs/audit-1.9.md`; sus criterios no son requisitos vigentes automáticos.

### DEC-006 — Atender el mantenimiento según evidencia operativa

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada.

Decisión: Supervisar el bot, investigar cada problema concreto, aplicar correcciones focalizadas y comprobar el resultado. No implementar preventivamente todos los hallazgos de la auditoría histórica.

Motivo: Priorizar el impacto comercial y operativo real del bot, que es complementario.

Consecuencia: Los problemas técnicos no se consideran resueltos por diseño; se abren y validan según evidencia.

### DEC-007 — Mantener temporalmente el aviso al agente por WhatsApp

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Histórica; sustituida por DEC-013.

Contexto: Se reportaron ocho solicitudes de cita cuyos avisos no fueron recibidos. No se ha demostrado que todos los casos compartan causa.

Decisión histórica: No modificar entonces el workflow. Como procedimiento temporal, el agente iniciaba una interacción con el número del bot al menos una vez cada 24 horas para mantener abierta la ventana de atención de WhatsApp.

Consecuencia histórica: El procedimiento era manual y no garantizaba la entrega permanente. DEC-013 retiró posteriormente el aviso interno al agente, por lo que ese procedimiento ya no forma parte de la operación vigente.

### DEC-008 — Incorporar IA después de la precalificación

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Sustituida por DEC-011; no forma parte del alcance aprobado vigente de v1.2.

Decisión: Diseñar en v1.2 un tercer workflow, de nombre provisional `whatsapp-ia`, para gestionar las citas de usuarios que ya superaron el filtro determinista.

Motivo: Separar la conversación de citas de las reglas comerciales de precalificación.

Consecuencias: La IA no reemplaza la precalificación. Debe recibir las respuestas posteriores según el estado persistido y no puede inventar disponibilidad, oficinas, horarios ni confirmaciones.

### DEC-009 — Notificar internamente las citas por correo

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Sustituida por DEC-011; no forma parte del alcance aprobado vigente de v1.2.

Decisión: Una cita realmente confirmada generará una notificación por correo a destinatarios autorizados de la empresa. El personal registrará manualmente la información en su tabla o sistema interno.

Motivo: Sustituir la dependencia de la ventana de mensajería de WhatsApp para la comunicación interna sin crear inicialmente una integración con la tabla de la empresa.

Consecuencias originales: En el alcance de entonces quedaban pendientes el evento, los campos, la prevención de duplicados, los cambios posteriores, el tratamiento de fallos y la herramienta de envío. Esa decisión fue sustituida antes de implementarse por DEC-011; no son pendientes vigentes de v1.2.

### DEC-010 — Modelo operativo previsto para v1.2

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Sustituida en lo relativo al modelo de citas con IA, correo y revisión diaria de esos avisos. La frecuencia de revisiones técnicas queda sin confirmar como decisión vigente.

Decisión: Buscar una operación sencilla: la IA gestiona citas durante el día, las confirmaciones generan correos y la empresa revisa y registra las nuevas citas cada mañana. También se contemplan dos o tres revisiones técnicas semanales.

Consecuencia: El objetivo aproximado de 10 minutos diarios y la revisión diaria de correos pertenecían al alcance anterior; no son objetivos vigentes de v1.2. La frecuencia técnica mencionada requiere confirmación antes de tratarse como compromiso operativo.

### DEC-011 — Sustituir IA y correo por integración con Airtable

Fecha: 23 de septiembre de 2026.

Estado: Implementada y publicada; complementada por DEC-012 y actualizada por DEC-013.

Contexto: La empresa redefinió el alcance de la siguiente versión y necesita consultar y gestionar en Airtable los leads que solicitan cita tras superar la precalificación.

Decisión original: La v1.2 integraría Airtable en el tramo final del workflow existente `whatsapp-leads`. Cuando un usuario calificado solicitara una cita, el flujo actualizaría Supabase y crearía un registro en Airtable para sustituir el aviso interno al agente por WhatsApp. Se conservarían los dos workflows actuales y Supabase como base principal. La creación del registro representa una solicitud de cita, no una cita confirmada.

Motivo: Incorporar al flujo existente el destino que la empresa utilizará para consultar y gestionar los leads recibidos, sin crear un sistema adicional de citas.

Consecuencias: Se descartaron del alcance de v1.2 la IA, el workflow `whatsapp-ia`, la coordinación automatizada de disponibilidad y las notificaciones por correo. La integración Airtable fue implementada y publicada. DEC-012 mantuvo temporalmente ambos mecanismos; DEC-013 retiró después el aviso por WhatsApp. La base y tabla fueron configuradas en producción. Los exportes locales se reportaron como actualizados; `Fuente_lead: BOT IA` es el valor intencional confirmado por el usuario.

Actualización — 5 de noviembre de 2026: DEC-017 amplía la organización comercial de dos workflows con router y Laudo. Se mantiene la decisión de usar Airtable en lugar de IA/correo y la semántica de solicitud de cita. El mantenimiento independiente de monitoreo e incidentes sigue registrado en DEC-014 y DEC-015.

### DEC-012 — Mantener temporalmente WhatsApp y Airtable

Fecha: 23 de septiembre de 2026.

Estado: Implementada históricamente; sustituida por DEC-013.

Contexto: La integración Airtable de v1.2 fue configurada, probada y publicada. La planificación original contemplaba reemplazar por completo el aviso interno mediante WhatsApp.

Decisión histórica: Mantener conectados y activos `Aviso agente` y `Create a record`, con retirada del aviso aplazada para una decisión posterior.

Motivo: Conservar temporalmente el mecanismo de aviso existente mientras la empresa empieza a consultar los registros en Airtable.

Consecuencias históricas: Ambos mecanismos coexistieron temporalmente. DEC-013 retiró el aviso por WhatsApp; la creación Airtable registra una solicitud de cita y no confirma fecha u horario.

### DEC-013 — Retirar aviso interno por WhatsApp y dejar Airtable como salida única

Fecha: 2 de octubre de 2026.

Estado: Implementada, según confirmación del usuario sobre producción y los exportes finales.

Contexto: Airtable operó durante más de una semana sin errores reportados y la empresa decidió retirar el aviso interno al agente por WhatsApp.

Decisión: Eliminar del flujo productivo `Aviso agente`. Mantener la ruta `Si cita -> Espera agente -> Create a record`. Airtable queda como destino interno automatizado de usuarios calificados que solicitan cita.

Consecuencias: El agente deja de recibir el aviso interno por WhatsApp y esa derivación ya no depende de su ventana de 24 horas. Supabase continúa como base comercial y conversacional principal. El registro de Airtable sigue representando una solicitud de cita, no una cita confirmada. DEC-012 queda como antecedente histórico sustituido. El valor `Fuente_lead: BOT IA` está confirmado como intencional.

Actualización de verificación — 3 de noviembre de 2026: el usuario confirmó una prueba de `whatsapp-webhook` en producción cuyo recorrido comercial llegó correctamente hasta Airtable. Confirma el recorrido realizado, sin introducir una decisión nueva ni validar todos los escenarios.

### DEC-014 — Monitorear consumo de Meta por mes y notificar umbrales en Slack

Fecha: implementación y pruebas reportadas entre el 21 de octubre y el 2 de noviembre de 2026; fecha exacta de decisión no registrada.

Estado: Implementada y publicada según reporte del usuario; comprobada parcialmente con pruebas operativas y exports.

Contexto: Se necesita observar consumo y costo estimado de Meta sin alterar las reglas comerciales.

Decisión: Incorporar `whatsapp-monitor`, con consulta diaria del mes actual en `America/Mexico_City`, registro mensual en Supabase y alertas mediante Slack API cada 1.000 mensajes y US$20 acumulados. Registrar los umbrales avisados después de la confirmación de Slack.

Consecuencias: El monitoreo es independiente del recorrido comercial y no reemplaza Supabase ni Airtable. Se comprobó una alerta real de 1.000 mensajes y su registro; el consumo real de US$20 sigue sin probarse. El control por umbral no garantiza entrega única ante concurrencia o fallos parciales. Este mantenimiento no asigna una versión nueva ni cambia la reserva de v1.9.

Actualización de verificación — 3 de noviembre de 2026: el usuario confirmó que `whatsapp-monitor` completó correctamente su ejecución automática del día tras la corrección. No se confirman nuevas cifras reales de consumo de noviembre; sus ceros provisionales no se convierten en consumo real verificado.

### DEC-015 — Centralizar incidentes de autenticación y facturación de Meta

Fecha: implementación y pruebas reportadas entre el 21 de octubre y el 2 de noviembre de 2026; fecha exacta de decisión no registrada.

Estado: Implementada y publicada según reporte del usuario; con validación de casos simulados y pruebas SQL de bloqueo.

Decisión: Incorporar `whatsapp-incidentes`, asociado al receptor como workflow de errores y llamado directamente ante estados de facturación `131042`. Enviar a Slack los tipos `meta_autenticacion` y `meta_facturacion`, limitados mediante reserva en Supabase a una alerta cada 24 horas por tipo. Confirmar el envío solo si Slack lo acepta e intentar liberar la reserva si lo rechaza.

Consecuencias: El filtro de autenticación del export se restringe a errores de `whatsapp-webhook`. No se afirma cobertura general de `whatsapp-leads` o `whatsapp-monitor`, ni resolución de todos los hallazgos históricos. Las pruebas SQL se revirtieron; falta comprobar el ciclo real de 24 horas y la recuperación de fallos parciales. La ventana es propia de incidentes y no se aplica a los umbrales mensuales de consumo.

### DEC-016 — Admitir estadísticas ausentes de Meta y proteger los valores existentes

Fecha: 2 de noviembre de 2026.

Estado: Implementada según el código exportado y la comprobación operativa reportada de Supabase. La prueba específica de protección contra ceros quedó completada con PASS el 3 de noviembre; permanecen pendientes las validaciones indicadas abajo.

Contexto: Las ejecuciones automáticas del monitor del 1 y 2 de noviembre fallaron porque Meta respondió solo con el ID de cuenta, sin `pricing_analytics.data`.

Decisión: Aceptar provisionalmente esa respuesta con ceros y `sin_datos_meta: true`, manteniendo error para otras estructuras inesperadas. Actualizar `public.guardar_resumen_whatsapp` para impedir que una nueva consulta con cero mensajes y cero costo sobrescriba estadísticas positivas existentes.

Consecuencias: Se creó manualmente el registro de noviembre y se comprobó la separación respecto de octubre. Los ceros no se consideran consumo real confirmado. La marca provisional no se envía en el cuerpo de la RPC del export. Al cierre del 2 de noviembre la protección SQL estaba implementada según el reporte, sin una copia SQL en el repositorio ni prueba específica de sobrescritura. Actualización confirmada por el usuario — 3 de noviembre de 2026: el [respaldo SQL original](../supabase/README.md) de las dos tablas y cuatro funciones está versionado en GitHub. La [prueba real en Supabase](../supabase/README.md#prueba-ejecutada-en-supabase--3-de-noviembre-de-2026), con `BEGIN`/`ROLLBACK`, conservó **1.871 mensajes y US$7,3984** ante el intento de sobrescribir octubre con ceros y devolvió el registro existente; la verificación posterior mantuvo datos y fechas intactos. Resultado: **PASS**. El monitor también completó su ejecución automática del día. El SQL incluye `IF NOT FOUND`; no consta la fecha de incorporación de ese bloque a producción.

Siguen pendientes restauración y compilación SQL en PostgreSQL aislado, permisos efectivos en esa restauración e integración completa con n8n bajo el escenario de bloqueo de ceros. Estas confirmaciones operativas se distinguen de las validaciones estáticas de Codex y no introducen decisiones técnicas nuevas.

## v1.3 multicampaña — cierre del 5 de noviembre de 2026

Las siguientes entradas registran las decisiones implementadas y la confirmación operativa del usuario al cierre de v1.3. No cambian retrospectivamente las decisiones históricas ni acreditan por sí mismas pruebas no reportadas. La evidencia y sus límites están en [Estado actual](current-state.md).

### DEC-017 — Introducir un router entre el receptor y los bots comerciales

Fecha de referencia: 5 de noviembre de 2026.

Estado: Implementada y publicada según confirmación del usuario; recorridos principales validados en producción según su reporte.

Contexto: El mismo canal WhatsApp debe atender Mejoravit y Laudo manteniendo separadas sus reglas y conversaciones.

Decisión: Conservar `whatsapp-webhook` como receptor de Meta y delegar a `whatsapp-router`, que llama a `whatsapp-leads` o `whatsapp-laudo`. El sistema queda compuesto por estos cuatro workflows comerciales y los independientes `whatsapp-monitor` / `whatsapp-incidentes`. Se conserva la URL pública anterior y la configuración de Meta.

Consecuencias: Se sustituye únicamente el enlace comercial directo descrito históricamente en DEC-002 y se amplía la organización original de DEC-011. Se mantienen recepción, acuses y rama `131042`, las reglas deterministas y el registro Airtable al solicitar cita. Las llamadas comparten cuatro campos string: `telefono`, `mensaje`, `tipo` y `nombre_whatsapp`. Los IDs y la publicación se reportan por el usuario; `active` no acredita estado vivo.

### DEC-018 — Priorizar servicio explícito, contexto e historial separado

Fecha de referencia: 5 de noviembre de 2026.

Estado: Implementada; continuidad, menú y cambio explícito de campaña comprobados en los recorridos reportados por el usuario.

Decisión: Resolver primero una identificación explícita única del servicio; después, un contexto válido de menos de 24 horas; después, existencia del teléfono en una sola tabla comercial. Si ambas o ninguna tabla contienen historial y no hay una prioridad anterior resuelta, ofrecer el menú de servicios. La detección explícita reconoce palabras completas e IDs de botón; no interpreta intención en lenguaje natural.

Persistencia: `public.whatsapp_routing` guarda contexto por teléfono. `public.leads` conserva Mejoravit y `public.leads_laudo` conserva Laudo. Una decisión válida crea o actualiza contexto y renueva la última interacción antes del despacho. El menú no escribe ni despacha. Cambiar de servicio no elimina ni reinicia los historiales comerciales.

Consecuencias: La ventana se evalúa al llegar un mensaje; exactamente 24 horas vence, sin borrado automático. Un contexto vencido todavía puede resolverse por historial único. Fechas ausentes, inválidas o futuras no validan contexto. La secuencia consulta/create/update no acredita atomicidad ni recuperación ante una carrera de creación; esos escenarios siguen pendientes, sin introducir un nuevo diseño en este cierre.

### DEC-019 — Definir la precalificación independiente de Laudo

Fecha de referencia: 5 de noviembre de 2026.

Estado: Implementada; ruta positiva, incluida Otro, hasta Supabase/Airtable confirmada por el usuario. No se afirma validación exhaustiva de bordes o de cada rechazo.

Decisión: Laudo admite Nuevo León, Ciudad de México, Estado de México y Otro. Requiere **48 años cumplidos o más**, no estar pensionado y no tener crédito Infonavit activo. Exactamente 48 sí califica. La etapa y el campo técnico `mayor_48`, así como el motivo heredado `edad_no_supera_48`, no redefinen ese mínimo comercial. El bot registra respuestas declaradas mediante botones; no verifica documentalmente edad o elegibilidad.

Consecuencias: Otro puede completar la precalificación y solicitar cita; su pregunta de cita es neutral, sin oficina local afirmada. Se conserva la tabla independiente y la distinción entre calificación, solicitud de cita y cita confirmada. Mejoravit mantiene sus propias reglas, sin aplicar a Laudo los requisitos de antigüedad o subcuenta.

Pendiente textual: el cierre reportó mensajes incompatibles con el mínimo de 48 en tres nodos. El archivo local recibido el día 5 ya contiene la corrección, como se registra en [Lógica de negocio](business-logic.md#textos-de-edad-antecedente-y-pendiente-de-publicación). Queda por confirmar esa correspondencia en producción y corregir el texto publicado si difiere; no se cambió el JSON ni se declara una prueba específica de exactamente 48 años.

### DEC-020 — Transmitir el perfil provisional directamente a Airtable

Fecha de referencia: 5 de noviembre de 2026.

Estado: Implementada; llegada del nombre a Airtable en ambos servicios confirmada por el usuario en producción.

Decisión: Extraer `contacts[].profile.name` únicamente del contacto cuyo `wa_id` coincide con el remitente, recortar espacios exteriores, limitar a 120 caracteres y transmitir como `nombre_whatsapp` hasta el campo existente `name` de Airtable. Conservar caracteres especiales/emojis dentro del límite y usar cadena vacía cuando falte nombre. No guardarlo en Supabase ni modificar la calificación o la etapa por ese dato.

Consecuencias: El nombre es una referencia provisional para el agente, no identidad legal o verificada. Depende del perfil disponible en el evento que genera el registro; no se recupera de mensajes anteriores. Los contratos y mappings de receptor, router y ambos bots incluyen el campo. Las pruebas reportadas y la inspección local no se extienden a una certificación de identidad o de todas las variantes de perfil.
