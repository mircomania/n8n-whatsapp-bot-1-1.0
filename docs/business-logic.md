# Lógica de negocio

Referencia: **v1.3 multicampaña, 5 de noviembre de 2026**. Las reglas comerciales aprobadas y las pruebas reportadas por el usuario se distinguen de la configuración observada en los exports locales. La evidencia operativa está en [Estado actual](current-state.md).

## Identificación y selección de servicio

El teléfono original identifica al usuario. El webhook transmite cuatro strings: `telefono`, `mensaje`, `tipo` y `nombre_whatsapp`. Las respuestas de botones y listas se interpretan por su ID; el tipo de mensaje original se conserva.

`whatsapp-router` aplica estas prioridades:

1. **Servicio explícito:** detecta `mejoravit` o `laudo` como palabras completas, sin distinguir mayúsculas, y los IDs `servicio_mejoravit` / `servicio_laudo`. Una sola coincidencia identifica el servicio; ambas o ninguna dejan vacío este resultado y permiten continuar con las prioridades siguientes. No interpreta intención en lenguaje natural.
2. **Contexto vigente:** `servicio_activo` en `public.whatsapp_routing` debe ser uno de los dos servicios y `ultima_interaccion` una fecha válida, no futura, de menos de 24 horas. Exactamente 24 horas significa vencido.
3. **Historial:** si aún falta servicio, consulta `public.leads` y `public.leads_laudo`. Un `id` presente y admisible identifica un registro; un objeto vacío de `alwaysOutputData` no cuenta. Si solo una tabla contiene el lead, elige ese servicio. No usa `calificado` ni `etapa` para esta decisión.
4. **Menú:** si no hay historial único, ofrece Mejoravit o Laudo mediante los dos IDs de servicio. La selección vuelve como un nuevo mensaje y tiene prioridad explícita.

El servicio explícito puede cambiar el contexto aunque el anterior siga vigente. Un contexto vencido no obliga a mostrar el menú si hay historial en una sola tabla. La ventana se comprueba al recibir mensajes: no borra registros automáticamente.

Una decisión válida crea contexto o actualiza `servicio_activo` y `ultima_interaccion` del teléfono existente. Mostrar el menú no escribe contexto ni despacha a un bot. Cambiar de servicio no borra ni reinicia los historiales: cada bot retoma la etapa de su propia tabla, salvo su reset comercial.

## Mejoravit — `whatsapp-leads`

Persiste en **`public.leads`**. La etapa guardada determina el significado de la respuesta; se procesan los botones/IDs, sin verificar antigüedad o saldo contra fuentes externas.

| Etapa | Requisito o transición implementada |
|---|---|
| `estado` | Nuevo León, Ciudad de México o Estado de México → `trabajo`. Otro → `rechazado`, motivo `estado`. |
| `trabajo` | Pregunta por **más de 3 meses** de antigüedad laboral. `trabajo_si` → `subcuenta`; `trabajo_no` → rechazo, motivo `trabajo`. |
| `subcuenta` | Pregunta por **más de $33,500 MXN** en subcuenta de vivienda. `subcuenta_si` → `calificado`, registra calificación/fecha; `subcuenta_no` → rechazo, motivo `subcuenta`. |
| `calificado` / `re_cita` | `cita_si` solicita cita; `cita_no` finaliza sin solicitarla. Una respuesta inválida repite la pregunta. |

Los rechazos conservan sus datos/motivos y fijan reset de 24 horas. Las preguntas y la lógica comercial de Mejoravit se conservaron en v1.3. Hay diferencias heredadas observadas localmente: `¿Estado?` compara `nuevo leon` con un estado guardado como `Nuevo León`, y `Reset estado` no limpia `fecha_reset`. No se infiere que la ruta NL o el reset completo estén validados por la prueba positiva reportada; sus efectos concretos quedan por verificar, sin cambios de JSON en este cierre.

## Laudo — `whatsapp-laudo`

Persiste en **`public.leads_laudo`**, independientemente de Mejoravit. La regla comercial aprobada admite **48 años cumplidos o más**, incluida una persona de exactamente 48 años. El nombre técnico heredado `mayor_48` no cambia ese requisito. El bot recoge la respuesta declarada, no calcula la edad a partir de una fecha de nacimiento.

| Etapa | Respuesta y transición implementada |
|---|---|
| `estado` | Nuevo León, Ciudad de México, Estado de México y **Otro** → `mayor_48`. Otro guarda `estado = otro`; no rechaza. |
| `mayor_48` | `laudo_edad_si` guarda `mayor_48 = true` → `pensionado`. `laudo_edad_no` guarda false, rechaza y conserva el motivo técnico `edad_no_supera_48`. |
| `pensionado` | `laudo_pensionado_si` guarda true y rechaza, motivo `pensionado`. `laudo_pensionado_no` guarda false → `credito_infonavit_activo`. |
| `credito_infonavit_activo` | `laudo_credito_si` guarda true y rechaza, motivo `credito_infonavit_activo`. `laudo_credito_no` guarda false, `calificado = true`, fecha y etapa `calificado` → solicitud de cita. |
| `calificado` / `re_cita` | `cita_si` solicita cita; `cita_no` pasa a `fin`. Las respuestas inválidas repiten la pregunta. |

Los booleanos comerciales se guardan como valores booleanos. Cada rechazo de requisito fija reset de 24 horas. Tras calificar, `¿Estado?` ofrece solicitud de cita NL para Nuevo León, MX para Ciudad/Estado de México y una pregunta neutral sin oficina para Otro. **Otro puede completar el recorrido y generar registro en Airtable**, también confirmado en la prueba de producción reportada.

### Textos de edad: antecedente y pendiente de publicación

El reporte de cierre identificó textos incompatibles con admitir exactamente 48 años en `Pregunta edad`, `RE pregunta edad` y `Final edad`. **Inspección local del 5 de noviembre:** el archivo recibido ya contiene “¿Tienes 48 años o más?” y un rechazo por “menos de 48 años”. Esa corrección local precede a esta tarea y se conserva intacta.

Permanece pendiente confirmar que los tres textos publicados corresponden a esa corrección y corregirlos allí si aún persiste la discrepancia reportada. No se presenta la inconsistencia como vigente en el archivo local ni se acredita una prueba específica del borde de 48 años en producción. No se cambian reglas ni nombres técnicos durante el cierre documental.

## Continuidad, resets y solicitud de cita

Cada bot busca o crea el lead, recupera su etapa y guarda el mensaje original y última interacción. Una respuesta nunca se interpreta al margen de esa etapa. Ambos exports contienen un filtro de interacciones inferiores a 1500 ms; no constituye idempotencia confiable ante duplicados o concurrencia.

Los estados `cita` y `rechazado` no tienen una regla propia en `¿Etapa?` en los exports; no se acredita una respuesta comercial adicional antes de su reset. El reset se evalúa al volver a escribir **después** de `fecha_reset`, no con un proceso programado. Rechazos de requisitos usan 24 horas; solicitar o declinar cita fija 30 días. `Reset estado` devuelve a la pregunta de estado; en Laudo también asigna `fecha_reset = {{ null }}`. No borra el historial comercial. La diferencia de reset de Mejoravit queda señalada arriba.

En ambos servicios, `cita_si` guarda `etapa = cita` y ejecuta `Si cita -> Espera agente -> Create a record`. Mejoravit conserva el campo técnico `fecha_cita`; Laudo usa `fecha_solicitud_cita`. Ambos representan la solicitud, no fecha u horario acordados. `cita_no` guarda `fin`, motivo `rechaza_cita` y fecha; una interacción posterior por `Fin` abre `re_cita` y pregunta de nuevo. No hay aviso interno al agente por WhatsApp.

## Airtable y nombre de perfil

Ambos bots crean registros en “Base Leads Nueva” / “Leads global” después de solicitar cita. Comparten `phone`, `state_google_ads`, `source` y `Fuente_lead: BOT IA`, `company` y `company_aux: Proconsultores`, y `no_llamar` activado. `source_aux` distingue `whatsapp_mejoravit` de `whatsapp_laudo`. `BOT IA` sigue siendo una etiqueta comercial.

`name` recibe `nombre_whatsapp` del evento actual. El webhook selecciona el contacto cuyo `wa_id` coincide con el remitente, recorta espacios exteriores y limita a 120 caracteres; conserva caracteres especiales y emojis, y transmite `""` si falta contacto/nombre. El router y los dos bots lo transportan sin guardarlo en Supabase. Si el perfil no llega en el mensaje que genera la solicitud, el registro recibe vacío, aunque hubiera estado disponible en un mensaje anterior.

El nombre es una **referencia provisional para el agente**, no identidad verificada, nombre legal ni validación de elegibilidad. La precalificación y el registro Airtable no confirman una cita ni aprueban un trámite.
