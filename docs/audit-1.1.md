# Auditoría técnica v1.1

Fecha de referencia: **21 de septiembre de 2026**.

## Objetivo

Establecer una base verificable para endurecer el MVP antes de migrarlo al VPS de producción. Esta auditoría documenta hallazgos y criterios de cierre; no implementa correcciones.

## Componentes revisados

- Documentación y archivos versionados del repositorio.
- Exportes `whatsapp-webhook` y `whatsapp-leads`, incluidos sus duplicados con sufijo `-v1`.
- Configuración local de Docker y n8n informada y verificada durante la auditoría.
- Estructura y estadísticas agregadas de `public.leads` en Supabase.
- Evidencia visual de ejecuciones de n8n y respaldos históricos.

## Evidencia disponible

- El workflow receptor exportado tiene 5 nodos; el principal tiene 44.
- El principal contiene 16 nodos `HTTP Request`.
- Los identificadores exportados coinciden con los archivos del repositorio.
- Los pares con y sin sufijo `-v1` eran idénticos byte a byte en la revisión.
- Una captura puntual mostró 103 ejecuciones de producción, 0 fallidas y 0,83 segundos de promedio.
- La estructura, restricciones y fotografía agregada de Supabase están registradas en [Estado actual](current-state.md).

Las cifras de ejecuciones y datos son observaciones fechadas, no garantías históricas. Los hallazgos siguientes provienen de inspección de código/configuración; no todos fueron reproducidos como fallos con tráfico real.

## Hallazgos técnicos

### A. Falta de idempotencia confiable

`whatsapp-webhook` normaliza `telefono`, `tipo` y `mensaje`, pero no entrega el identificador único `wamid` al flujo principal. `whatsapp-leads` descarta interacciones separadas por menos de 1500 ms mediante `ultima_interaccion`; esto es una protección temporal básica, no impide de forma confiable duplicados ni ejecuciones simultáneas.

Riesgo: mensajes, cambios de etapa o notificaciones al agente pueden procesarse más de una vez.

Corrección propuesta: diseñar un registro independiente de mensajes por identificador único, posiblemente en Supabase, con estados de procesamiento. La estructura aún no está aprobada. El diseño debe cubrir duplicados, concurrencia, fallos parciales, recuperación de pendientes y prevención de notificaciones duplicadas.

### B. Reset incompleto

El nodo `Reset estado` solo actualiza `etapa = estado`. No limpia `fecha_reset` ni restablece los demás campos asociados a la precalificación anterior.

Riesgo: una fecha ya vencida puede provocar nuevos resets en interacciones posteriores y dejar una combinación incoherente de datos históricos y estado actual.

Corrección propuesta: acordar qué campos se reinician, cuáles se conservan como historial y cómo se consume o reemplaza `fecha_reset`; implementarlo y probarlo por cada etapa elegible.

### C. Normalización prematura del webhook

El nodo de extracción intenta acceder a `messages[0]` antes de que el evento quede validado como mensaje de usuario. El filtro posterior comprueba la existencia de `tipo`, pero eventos de estado u otras estructuras pueden no alcanzar ese punto de forma segura.

Riesgo: errores o ejecuciones incompletas ante payloads válidos de Meta que no contienen mensajes de usuario.

Corrección propuesta: validar primero la forma y el tipo del evento; solo después extraer y normalizar los campos admitidos. Definir el acuse de recibo para eventos ignorados y casos inválidos.

### D. Manejo de errores y reintentos

No se identificaron reintentos explícitos ni un workflow centralizado de errores en los exportes. El flujo depende de WhatsApp Cloud API, Supabase y 16 solicitudes HTTP.

Riesgo: fallos transitorios o ejecuciones interrumpidas pueden dejar estado parcial. Un reintento ingenuo puede duplicar respuestas, escrituras o avisos.

Corrección propuesta: clasificar operaciones reintentables, definir límites y backoff, registrar errores con contexto no sensible y coordinar cualquier reintento con el mecanismo de idempotencia.

### E. Derivación al agente

La ruta de cita ejecuta `Si cita -> Espera agente -> Aviso agente` sin una garantía de entrega única visible en los exportes.

Riesgo: una entrada duplicada puede generar varios avisos; un fallo después de registrar la cita y antes de notificar puede dejar la derivación incompleta.

Corrección propuesta: modelar el estado de la notificación, impedir envíos duplicados y permitir recuperación controlada de notificaciones pendientes.

### F. Datos potencialmente sensibles en exportes versionados

La inspección detectó identificadores numéricos fijos y destinos configurados dentro de nodos HTTP, incluido el nodo de aviso al agente. También `dockers-run.txt` contiene un endpoint temporal de ngrok. No se reproducen aquí sus valores.

Riesgo: el repositorio es público y estos valores pueden revelar identificadores de integración, datos de contacto o endpoints de desarrollo aunque los tokens se administren como credenciales de n8n.

Corrección propuesta: realizar una revisión de secretos y privacidad con alcance explícito, decidir qué valores deben parametrizarse y, si corresponde, sanear el historial. No modificar ni eliminar estos datos durante una tarea documental.

## Riesgos y decisiones todavía pendientes

- Definir el modelo definitivo de idempotencia y recuperación de mensajes.
- Definir la semántica de reset y la retención de historial.
- Establecer la política de reintentos y el workflow de errores.
- Determinar métricas, alertas y retención de logs sin datos personales.
- Auditar RLS, permisos de Data API y generación de `id` en Supabase.
- Verificar un respaldo reciente y ejecutar una restauración controlada.
- Ejecutar pruebas de regresión de todas las rutas comerciales.
- Resolver de forma autorizada la exposición potencial descrita, sin publicar valores en documentación.

## Criterios de aceptación de v1.1

v1.1 puede cerrarse cuando exista evidencia de que:

- Cada `wamid` admitido produce como máximo un procesamiento efectivo, incluso con entregas duplicadas y ejecuciones concurrentes.
- Los mensajes pendientes o fallidos tienen estados explícitos y un procedimiento de recuperación que no duplica efectos.
- La notificación al agente es única por solicitud y recuperable después de un fallo parcial.
- El webhook ignora de forma segura eventos de estado, payloads sin mensaje y tipos no soportados, y responde a Meta según el comportamiento definido.
- El reset limpia o conserva exactamente los campos acordados, consume la fecha vencida y supera pruebas por todas las etapas elegibles.
- Los fallos transitorios de Meta y Supabase siguen una política de reintentos limitada, observable y compatible con la idempotencia.
- Existe manejo centralizado o equivalente para errores, con alertas y logs útiles que no exponen secretos ni datos personales.
- Se completó la regresión del alta, estado, trabajo, subcuenta, calificación, cita, rechazo, finalización, reactivación y respuestas inválidas.
- Se verificó un respaldo actual y se documentó una restauración controlada satisfactoria.
- Se revisaron las configuraciones relevantes de seguridad de Supabase y los valores sensibles en archivos versionados.
- La documentación y los exportes autorizados reflejan la implementación final, sin marcar como cumplido lo que no tenga evidencia.

## Fuera de alcance de esta auditoría documental

No se ejecutó SQL, no se modificaron datos ni políticas de Supabase, no se importaron o publicaron workflows, no se reinició Docker, no se alteró ngrok y no se contrató ni configuró el VPS. Tampoco se validó todavía la restauración de respaldos ni se reprodujeron todos los riesgos con tráfico.
