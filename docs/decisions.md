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

Estado: Aprobada e implementada en la documentación.

Decisión: Considerar v1.1 como despliegue en producción, v1.2 como integración de IA y v1.9 como mantenimiento avanzado reservado. La antigua etapa de hardening v1.1 deja de ser un requisito previo para v1.2.

Consecuencia: La auditoría histórica se conserva como `docs/audit-1.9.md`; sus criterios no son requisitos vigentes automáticos.

### DEC-006 — Atender el mantenimiento según evidencia operativa

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada.

Decisión: Supervisar el bot, investigar cada problema concreto, aplicar correcciones focalizadas y comprobar el resultado. No implementar preventivamente todos los hallazgos de la auditoría histórica.

Motivo: Priorizar el impacto comercial y operativo real del bot, que es complementario.

Consecuencia: Los problemas técnicos no se consideran resueltos por diseño; se abren y validan según evidencia.

### DEC-007 — Mantener temporalmente el aviso al agente por WhatsApp

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada / vigente temporalmente.

Contexto: Se reportaron ocho solicitudes de cita cuyos avisos no fueron recibidos. No se ha demostrado que todos los casos compartan causa.

Decisión: No modificar ahora el workflow. Como procedimiento temporal, el agente inicia una interacción con el número del bot al menos una vez cada 24 horas para mantener abierta la ventana de atención de WhatsApp.

Consecuencia: El procedimiento es manual y no garantiza la entrega permanente. La ejecución exitosa de n8n no prueba la recepción externa.

### DEC-008 — Incorporar IA después de la precalificación

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada / Planificada.

Decisión: Diseñar en v1.2 un tercer workflow, de nombre provisional `whatsapp-ia`, para gestionar las citas de usuarios que ya superaron el filtro determinista.

Motivo: Separar la conversación de citas de las reglas comerciales de precalificación.

Consecuencias: La IA no reemplaza la precalificación. Debe recibir las respuestas posteriores según el estado persistido y no puede inventar disponibilidad, oficinas, horarios ni confirmaciones.

### DEC-009 — Notificar internamente las citas por correo

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada / Planificada.

Decisión: Una cita realmente confirmada generará una notificación por correo a destinatarios autorizados de la empresa. El personal registrará manualmente la información en su tabla o sistema interno.

Motivo: Sustituir la dependencia de la ventana de mensajería de WhatsApp para la comunicación interna sin crear inicialmente una integración con la tabla de la empresa.

Consecuencias: El evento, los campos, la prevención de duplicados, los cambios posteriores, el tratamiento de fallos y la herramienta de envío quedan pendientes de definición en v1.2. No se ha configurado correo ni se ha elegido definitivamente n8n o Make.

### DEC-010 — Modelo operativo previsto para v1.2

Fecha: septiembre de 2026; fecha exacta de decisión no registrada.

Estado: Aprobada / Planificada.

Decisión: Buscar una operación sencilla: la IA gestiona citas durante el día, las confirmaciones generan correos y la empresa revisa y registra las nuevas citas cada mañana. También se contemplan dos o tres revisiones técnicas semanales.

Consecuencia: El objetivo aproximado de 10 minutos diarios y esas frecuencias son estimaciones deseadas, no métricas actualmente verificadas ni garantías de detección inmediata.
