# Estado actual

Fecha de revisión documental: **5 de noviembre de 2026**. La **v1.3 multicampaña está desplegada en Contabo y validada en sus recorridos principales**, según confirmación del usuario de ese día. Se mantienen los antecedentes de infraestructura del **2 de octubre** y las pruebas de monitoreo/incidentes del **2 y 3 de noviembre**, con sus límites originales.

El usuario confirmó publicados los seis workflows: `whatsapp-webhook`, `whatsapp-router`, `whatsapp-leads`, `whatsapp-laudo`, `whatsapp-monitor` y `whatsapp-incidentes`. La arquitectura vigente usa el router entre receptor y bots comerciales; no la llamada directa histórica a Mejoravit. La URL pública conserva `/webhook/whatsapp-leads` y no se cambió la configuración de Meta.

Se separan **pruebas de producción confirmadas por el usuario**, **consultas directas de Supabase reportadas durante esas pruebas**, **comprobaciones estáticas locales** y **pendientes**. Codex no accedió a producción ni ejecutó n8n o SQL durante este cierre. Los exports, sus IDs y su propiedad `active` no demuestran publicación ni equivalencia exacta con la instancia viva. Las pruebas no acreditan cobertura exhaustiva ni operación prolongada sin fallos.

## Validación de v1.3 — 5 de noviembre de 2026

### Pruebas de producción confirmadas por el usuario

- Recepción real de mensajes desde WhatsApp y distribución por el router a Mejoravit y Laudo.
- Recuperación de conversaciones previamente iniciadas y continuidad mediante contexto y registros históricos.
- Cambio explícito entre campañas y funcionamiento del menú interactivo de servicios.
- Ruta positiva completa de Laudo hasta Supabase y Airtable, incluida una prueba con estado **Otro**.
- Ruta positiva completa de Mejoravit hasta Supabase y Airtable.
- Prueba de respuesta negativa con resultado esperado; el reporte no individualiza todos los rechazos ni todos los bordes comerciales.
- Extracción y transmisión del nombre de perfil hasta `name` de Airtable en ambos servicios.
- Conservación local de respaldos de los workflows anteriores por el usuario; no se verificó su integridad o restauración.

Son resultados reportados y confirmados por el usuario en la sesión de trabajo. No se incorporaron al repositorio nombres, teléfonos, capturas o payloads reales de los leads controlados. Las pruebas comerciales del día 5 no convierten en verificadas las pruebas pendientes del monitoreo o de incidentes.

### Consultas directas de Supabase reportadas

El usuario informó que las consultas ejecutadas durante las pruebas comprobaron contexto, etapas y calificación de los leads controlados. Se registran como comprobaciones de Supabase **reportadas por el usuario**, distintas de las verificaciones locales de archivos. No se infieren a partir de ellas el DDL completo, RLS, permisos efectivos, índices, concurrencia ni validación de todos los registros.

La regla comercial de Laudo admite **48 años cumplidos o más**, incluyendo exactamente 48, y el estado Otro. No se reportó de forma específica una prueba numérica del borde de 48 años; el workflow interpreta botones declarados, no verifica documentos ni calcula edad.

### Comprobaciones estáticas locales del cierre

Se inspeccionaron los seis JSON: cantidades de nodos del inventario, nombres e IDs de nodo únicos dentro de cada workflow, conexiones con destinos existentes y contratos de entrada. Webhook, router y ambos bots transmiten `telefono`, `mensaje`, `tipo` y `nombre_whatsapp` como strings. El nombre se extrae por contacto coincidente, se recorta y limita a 120 caracteres, llega a Airtable y no se incluye en las escrituras Supabase. Estas observaciones no ejecutan el motor n8n.

El router implementa prioridad explícita → contexto de menos de 24 horas → historial único → menú. Guarda el servicio seleccionado antes del despacho. El detalle técnico se concentra en [Arquitectura](architecture.md) y las transiciones en [Lógica de negocio](business-logic.md).

**Diferencias y límites observados:**

- El router local no tiene campo `id` y conserva `active: false`. Su ID de producción figura por confirmación del usuario y en la llamada del webhook. No se modificó el export para aparentar verificación de publicación.
- Había una modificación local previa de `whatsapp-laudo.json`. Los textos `Pregunta edad`, `RE pregunta edad` y `Final edad` ya son coherentes con admitir 48 años; la discrepancia reportada no se reproduce en esos textos locales. Queda pendiente confirmar su correspondencia con los publicados y corregir allí el texto si aún difiere. El cierre documental no cambió ese JSON ni su estado Git previo.
- En Mejoravit se conservan la comparación `nuevo leon` frente al valor guardado `Nuevo León` y un reset que solo escribe la etapa. Sus efectos concretos en la ruta NL y después del vencimiento no se dan por resueltos por las pruebas positivas reportadas.
- No se acreditan idempotencia, concurrencia de creación de contexto, recuperación de fallos parciales, cobertura completa de errores o procesamiento general de lotes Meta.

La documentación y el respaldo SQL se revisaron de forma local. No se repitieron pruebas operativas ni se elaboró una nueva certificación de seguridad de los servicios externos.

## Producción en Contabo

Estado reportado al 2 de octubre de 2026: el bot funciona con tráfico real y no depende de que la computadora local permanezca encendida. La tabla siguiente conserva esa fecha de referencia.

| Elemento | Estado operativo reportado |
|---|---|
| Proveedor | Contabo |
| Plan | Cloud VPS 6 |
| Recursos | 6 vCPU, 12 GB RAM, 200 GB SSD |
| Región | Estados Unidos (Este) |
| Sistema operativo | Ubuntu Server 24.04.5 LTS |
| Docker Engine | 29.8.1 |
| Docker Compose | 5.5.1 |
| n8n | Self Hosted 2.35.5 |
| Imagen | `n8nio/n8n:2.35.5` |
| Dominio | `https://bot.proconsultores.com.mx` |
| Webhook | `https://bot.proconsultores.com.mx/webhook/whatsapp-leads` |
| Proxy HTTPS | Caddy ejecutado mediante Docker |
| Directorio principal | `/opt/n8n` |
| Compose | `/opt/n8n/compose.yaml` |
| Caddyfile | `/opt/n8n/Caddyfile` |
| Persistencia | `/opt/n8n/data` montado en `/home/node/.n8n` |
| Reinicio | `restart: unless-stopped` |

n8n publica el puerto 5678 únicamente en la interfaz local del VPS. Caddy atiende los puertos públicos 80 y 443, administra HTTPS y funciona como proxy inverso hacia n8n. También atiende la verificación GET de Meta y dirige los POST de WhatsApp al workflow receptor.

Meta conserva el dominio y la URL del webhook. Supabase continúa como servicio externo: `public.leads` conserva Mejoravit; v1.3 añade el historial separado de Laudo y el contexto del router. Durante la migración histórica no se introdujeron mecanismos experimentales de idempotencia ni colas de mensajes.

## Workflows y migración

Inventario de v1.3 al **5 de noviembre de 2026**: los IDs de producción y la publicación fueron confirmados por el usuario; los conteos se comprobaron en los exports locales. Antecedente: al 2 de noviembre se reportaban cuatro workflows; v1.3 incorpora router y Laudo.

| Workflow | ID de producción reportado | Nodos locales | Responsabilidad |
|---|---|---:|---|
| `whatsapp-webhook` | `hqkg7XY6QQRbUixD` | 9 | Receptor Meta, extracción de entrada/perfil, llamada al router y detección `131042`. |
| `whatsapp-router` | `1kC2Z69ssI0xMWtK` | 18 | Selección de servicio, contexto, historial, menú y despacho. |
| `whatsapp-leads` | `4grFx6GCtkfCtebO` | 44 | Precalificación de Mejoravit en `public.leads` y derivación Airtable. |
| `whatsapp-laudo` | `jcaIuhviy427ailO` | 50 | Precalificación de Laudo en `public.leads_laudo` y derivación Airtable. |
| `whatsapp-monitor` | `6AgILmSn4Qf5mjAt` | 11 | Consumo diario, resumen mensual y umbrales Slack. |
| `whatsapp-incidentes` | `7xMeGjyPHSF7anEo` | 11 | Reserva, envío y confirmación de alertas de autenticación/facturación. |

La arquitectura vigente de los seis componentes está en [Arquitectura](architecture.md). Las pruebas y migraciones anteriores se conservan como antecedentes fechados.

La migración trasladó los datos persistentes de n8n desde la instalación local detenida hacia el VPS. Se conservaron la base interna de n8n, los workflows, la configuración, la clave de cifrado y las credenciales cifradas. La restauración fue comprobada mediante el funcionamiento de los workflows y una prueba comercial real.

Como antecedente, el 2 de octubre los archivos `workflows/whatsapp-leads.json` y `workflows/whatsapp-webhook.json` fueron reportados por el usuario como exportes de la versión final estabilizada de producción y reemplazaron los exportes anteriores. Son exportes versionados, no prueba de la configuración viva ni de equivalencia exacta. El valor intencional de `Fuente_lead` es `BOT IA`.

## Integración Airtable en producción

Antecedente reportado al **2 de octubre de 2026**: la integración fue añadida a `whatsapp-leads` desde n8n en Contabo y la versión final se reportó publicada. En esa fecha Airtable llevaba más de una semana funcionando sin errores reportados. La empresa retiró el aviso interno al agente por WhatsApp. La ruta final reportada es `Si cita -> Espera agente -> Create a record`: `Si cita` actualiza el lead en Supabase, `Espera agente` responde al usuario y `Create a record` crea el registro en Airtable.

Configuración reportada: nodo nativo Airtable, recurso `Record`, operación `Create`, base “Base Leads Nueva” y tabla “Leads global”. Se usa una credencial Airtable Personal Access Token guardada en n8n, con permisos `data.records:read`, `data.records:write` y `schema.bases:read`, limitada a esa base. No se documenta el token.

Actualización v1.3 — 5 de noviembre: ambos bots conservan `Si cita -> Espera agente -> Create a record`. El mapeo observado incluye `phone` desde `Revisar tabla.telefono`, `state_google_ads` desde el estado, `source` y `Fuente_lead: BOT IA`, `company` y `company_aux: Proconsultores`, y `no_llamar` activado. `source_aux` distingue `whatsapp_mejoravit` / `whatsapp_laudo`. `name` recibe el perfil actual a través de `nombre_whatsapp`, sin guardarse en Supabase; es una referencia provisional, no identidad verificada. El usuario confirmó su llegada en ambos servicios. Si no viene perfil en el evento que genera el registro, se envía vacío. `BOT IA` es una etiqueta comercial y no significa que se use IA.

El registro representa la solicitud de cita de un usuario que superó la precalificación. No significa que la cita tenga fecha u horario confirmados.

### Validación histórica de Airtable

Durante las primeras pruebas, n8n rechazó el valor `BOT IA` de `source` porque no aparecía entre las opciones reconocidas por la configuración del nodo. Tras actualizar esa configuración, la prueba manual reportada creó un registro en Airtable. La observación de operación superior a una semana sin errores también fue reportada por el usuario; no equivale a una prueba exhaustiva.

Esta es una prueba manual del flujo reportado. No se han documentado pruebas exhaustivas con múltiples leads, verificación automática de todos los registros de producción ni funcionamiento a largo plazo.

## Monitoreo diario y registro mensual de Meta

**Implementación publicada reportada; configuración inspeccionada localmente al 2 de noviembre.** `whatsapp-monitor` contiene un Schedule Trigger a las 09:00 y zona `America/Mexico_City`, además de entrada manual. El usuario comprobó ejecución diaria hasta el 31 de octubre y ejecuciones automáticas fallidas el 1 y 2 de noviembre. Al cierre del 2 de noviembre seguía pendiente la siguiente ejecución automática completa tras la corrección. **Actualización del 3 de noviembre:** el usuario confirmó que `whatsapp-monitor` completó correctamente su ejecución automática de ese día. No se reportaron nuevas cifras de consumo real de noviembre.

La consulta de `pricing_analytics` usa el inicio del mes y el instante actual en esa zona, con granularidad `DAILY` y dimensiones `PRICING_CATEGORY,PRICING_TYPE`. `Resumen mensual` valida la cuenta consultada, suma mensajes gratuitos, regulares y otros, y calcula costo estimado y mes. Estos volúmenes corresponden a las estadísticas consultadas de Meta; no se equiparan al total de ejecuciones de n8n ni de leads.

La RPC `public.guardar_resumen_whatsapp` recibe el resumen. El usuario verificó registros separados por mes en `whatsapp_monitor_monthly` y reportó estos valores:

| Mes | Mensajes totales | Gratuitos | Regulares | Costo estimado (USD) | Umbral de mensajes avisado |
|---|---:|---:|---:|---:|---:|
| Octubre de 2026 | 1.871 | 1.000 | 871 | 7,3984 | 1.000 |
| Noviembre de 2026 | 0, provisional | Sin desglose operativo reportado | Sin desglose operativo reportado | 0, provisional | 0 |

Fotografía reportada al **2 de noviembre de 2026**, no consulta ejecutada durante esta auditoría. El umbral de costo avisado de noviembre también es 0.

### Alertas de consumo mediante Slack API

`Evaluar alertas` compara el consumo con los últimos umbrales notificados: pasos de **1.000 mensajes** y **US$20 acumulados**. Si se cruzan varios pasos entre consultas, genera una alerta para el umbral más alto detectado; los dos motivos pueden compartir una notificación. Se usa Slack API con credencial administrada por n8n y el canal operativo reportado `#whatsapp-monitor`.

El workflow comprueba `ok` en la respuesta de Slack antes de llamar a `registrar_alerta_whatsapp`. Una respuesta sin confirmación toma la ruta `Stop and Error`. El usuario confirmó una alerta real al superar 1.000 mensajes en octubre y su registro en Supabase. No se ha probado consumo real de US$20. Las alertas de consumo se controlan por umbral mensual: **el bloqueo de 24 horas corresponde a incidentes, no a estos umbrales**.

### Corrección de noviembre y estadísticas provisionales

El 1 y 2 de noviembre el monitor se ejecutó automáticamente, pero `Resumen mensual` falló porque Meta devolvió solo el WABA ID, sin `pricing_analytics.data`. El **2 de noviembre** se corrigió el código para aceptar exclusivamente esa forma de respuesta sin estadísticas y producir ceros con `sin_datos_meta: true`. Otras estructuras inesperadas siguen provocando error; una matriz de estadísticas vacía se procesa por una rama distinta y no lleva esa marca.

El usuario ejecutó manualmente `Resumen mensual` y `HTTP Request1`, comprobó la creación de noviembre y verificó que octubre conservaba sus estadísticas. Al cierre del 2 de noviembre esto verificaba parcialmente el cambio de mes y todavía no acreditaba una ejecución automática completa tras el ajuste; esa ejecución quedó confirmada el 3 de noviembre, como se indica arriba. Los ceros provisionales no demuestran consumo real nulo ni explican por qué Meta omitió las estadísticas.

El mismo día se actualizó en Supabase `public.guardar_resumen_whatsapp`. Según la comprobación operativa reportada, la condición `ON CONFLICT ... DO UPDATE ... WHERE NOT (...)` impide sustituir estadísticas positivas existentes cuando la nueva consulta trae cero mensajes y cero costos. **Antecedente al 2 de noviembre:** protección implementada según el reporte, con prueba específica entonces pendiente. Crear noviembre y conservar octubre no probaba el intento de sobrescritura sobre un registro positivo del mismo mes.

**Actualización del 3 de noviembre — PASS:** el usuario confirmó una prueba real de `public.guardar_resumen_whatsapp` en Supabase con `BEGIN`/`ROLLBACK`. Frente al intento de actualizar octubre con cero mensajes y cero costo, la función conservó **1.871 mensajes y US$7,3984**, devolvió el registro existente y la verificación posterior confirmó datos y fechas intactos. La evidencia y su alcance se registran en [supabase/README.md](../supabase/README.md#prueba-ejecutada-en-supabase--3-de-noviembre-de-2026). La prueba SQL está completada; no acredita todavía la integración completa de n8n bajo este escenario.

El export envía los valores numéricos a la RPC, pero no envía `sin_datos_meta`; esa marca es local a `Resumen mensual` y no consta su persistencia. La definición original suministrada el 3 de noviembre se conserva en [monitor-functions.sql](../supabase/monitor-functions.sql): si el bloqueo impide actualizar, `IF NOT FOUND` devuelve la fila existente. La inspección del SQL y el PASS reportado confirman ese retorno; sigue pendiente la validación de integración completa con n8n ante el bloqueo de ceros. No son migraciones de Supabase CLI.

## Incidentes de Meta y límite de 24 horas

`whatsapp-incidentes` admite `meta_autenticacion` y `meta_facturacion`:

- **Autenticación:** su Error Trigger clasifica errores de autenticación solo cuando el workflow del evento es `whatsapp-webhook`; reconoce texto como `Authorization failed` y referencias a código 190. El export receptor lo configura como workflow de errores. No se demuestra cobertura directa de errores de `whatsapp-router`, `whatsapp-leads`, `whatsapp-laudo` o `whatsapp-monitor`.
- **Facturación `131042`:** una rama del receptor recorre estados de entrega `failed`, detecta el código y llama a `whatsapp-incidentes` sin esperar su finalización. Distingue la referencia a falta de método de pago de un diagnóstico general de elegibilidad de pago. Devuelve el primer caso coincidente del evento.

El flujo utiliza las RPC `reservar_alerta_incidente` y `confirmar_alerta_incidente` para limitar las notificaciones a **una cada 24 horas por tipo**. Solo envía si `debe_notificar` lo autoriza. Tras `ok === true` confirma la reserva; si Slack no confirma, intenta liberarla y termina con error. Los exports no incluyen esa lógica SQL; la fuente original suministrada el 3 de noviembre se conserva en [incident-functions.sql](../supabase/incident-functions.sql). La reserva dura 5 minutos y el bloqueo de 24 horas se mide desde el aviso confirmado. La confirmación exige tipo y UUID, pero no comprueba que la reserva siga vigente; no se alteró ese comportamiento.

**Pruebas operativas reportadas:** se simuló `Authorization failed` y se recibió la alerta en Slack; también se simuló `131042`, se comprobó el recorrido receptor → incidentes → Slack y su registro en Supabase, y se restableció el estado de esa prueba. En una transacción SQL revertida se verificaron primera reserva autorizada, segunda reserva del mismo tipo rechazada, confirmación y nuevo rechazo durante el bloqueo, sin registros permanentes de esa prueba SQL. Falta observar un ciclo completo de 24 horas con incidentes reales separados por ese intervalo.

## Antecedentes de los exports — 2 y 3 de noviembre

La [auditoría del 2 de noviembre](audit-2026-11-02.md) conserva la fotografía de cuatro exports y el cierre de privacidad de ese día: dos opciones ambiguas del catálogo cacheado `source` de Airtable fueron anonimizadas sin alterar lógica comercial; el endpoint histórico de `dockers-run.txt` se reclasificó como placeholder. La anonimización no borra versiones anteriores de Git ni equivale a auditar todo su historial.

### Nuevo webhook revisado el 3 de noviembre

Esta subsección conserva exclusivamente la fotografía del día 3. La llamada directa a Mejoravit que describe fue sustituida por el router en v1.3; no representa la ruta vigente.

**Hecho verificado localmente:** JSON válido con 9 nodos, frente a 7 en HEAD `bec3a33`. Los siete nodos anteriores conservan todos sus parámetros y ajustes; tres cambian de posición. Se añade `¿Es mensaje entrante?` antes de extraer los campos comerciales:

- **True:** `Edit Fields -> mensaje -> Call 'whatsapp-leads' -> Respond to Webhook`, sin cambios en los parámetros o conexiones internas del recorrido previo.
- **False:** `Confirmar evento Meta`, con respuesta configurada HTTP 200 y sin cuerpo (`respondWith: noData`).
- **Rama independiente:** `Detectar fallo Meta 131042 -> Call 'whatsapp-incidentes'`, con código, destino y opciones de ejecución idénticos a HEAD. También se conserva el workflow de errores configurado.

El IF comprueba que `body.entry[0].changes[0].value.messages[0].from` tenga un valor verdadero mediante acceso opcional. Evita dirigir a `Edit Fields` los eventos sin ese remitente, incluidos estados habituales de entrega. No valida por completo el payload o el tipo de mensaje ni procesa mensajes de entradas/cambios posteriores del lote.

Las conexiones y referencias a workflows apuntan a elementos existentes. `pinData` **existe como objeto vacío**; no contiene datos fijados. `staticData` está ausente. No se detectaron credenciales, tokens, datos personales literales o payloads de prueba en este export. Los identificadores de nodos, workflows e instancia son metadatos técnicos.

Se comprobaron **30 casos locales** sobre la condición exportada, el detector `131042` y las conexiones, con entradas sintéticas fuera del repositorio. Pasaron mensajes, estados de entrega y casos sin campos; también se constató la limitación de la primera entrada/cambio y el paso de un remitente sin tipo. Estas pruebas no ejecutan n8n ni acreditan recepción HTTP real, notificación Slack o publicación. El usuario confirmó después el recorrido comercial en producción hasta Airtable el 3 de noviembre. No se han reportado pruebas nuevas específicas del acuse HTTP de la rama False o de la detección `131042`; esas comprobaciones no se deducen del recorrido comercial. No se modificó ningún JSON durante esta revisión; el diff del webhook procede del archivo entregado por el usuario. El detalle está en el [seguimiento de la auditoría](audit-2026-11-02.md#seguimiento-del-webhook--3-de-noviembre-de-2026).

## Validaciones operativas reportadas

### Antecedentes al 2 de octubre de 2026

Se reportó la comprobación de:

- acceso al dominio mediante HTTPS;
- funcionamiento de n8n en Contabo y restauración de ambos workflows;
- funcionamiento de las credenciales;
- recepción de mensajes desde Meta;
- ejecución del flujo de precalificación;
- registro y actualización de datos en Supabase;
- respuestas por WhatsApp;
- funcionamiento con la computadora local apagada.
- Más de una semana de operación de Airtable sin errores reportados por el usuario, al 2 de octubre de 2026.
- Volumen comercial observado aproximado: 8 leads precalificados por semana y alrededor de 30 por mes. Son observaciones operativas, no garantías ni métricas contractuales.

También se ejecutó el recorrido comercial ideal hasta la solicitud de cita y se observó que las ejecuciones terminaron sin errores. Estas comprobaciones validan el recorrido realizado, pero no constituyen una validación exhaustiva de condiciones excepcionales ni garantizan la entrega de todos los mensajes externos.

### Recorrido comercial entre el 21 de octubre y el 2 de noviembre

El usuario reportó una prueba completa del recorrido comercial: el bot respondió, llegó el registro correspondiente a Airtable y no se observaron errores nuevos en los workflows comerciales durante esa prueba. La caída de volumen de ejecuciones se explicó por una pausa de campañas publicitarias; no se infiere una falla del bot a partir de ese descenso. Sigue siendo una prueba del recorrido realizado, no una regresión exhaustiva.

### Recorrido comercial del 3 de noviembre

El usuario confirmó que `whatsapp-webhook` fue probado en producción y que el recorrido comercial llegó correctamente hasta Airtable. Se registra como prueba operativa del recorrido realizado, separada de los 30 casos locales y de la prueba SQL de ceros; no valida por sí sola los demás escenarios pendientes.

## Migración y entorno local

El entorno local de Windows se conserva para desarrollo y pruebas. Las instalaciones local y de Contabo son independientes: modificar un workflow local no modifica automáticamente producción.

Ambos entornos pueden usar el mismo proyecto de Supabase y las mismas integraciones de Meta. Por ello, las pruebas locales con credenciales o datos reales pueden producir efectos comerciales. No deben iniciarse simultáneamente con el mismo webhook de producción.

ngrok pertenece al flujo histórico local y no es el webhook operativo de producción.

## Dependencia operativa de Meta

Según el procedimiento operativo reportado, la autenticación de Meta utiliza un token con vigencia aproximada de seis meses y requiere renovación periódica. No se afirma que la renovación sea automática ni se consigna una fecha de expiración. Es una dependencia que debe vigilarse.

## Supabase

La migración histórica del VPS no trasladó la base comercial. En v1.3 se usan tres tablas comerciales: `public.leads` para Mejoravit, `public.leads_laudo` para Laudo y `public.whatsapp_routing` para servicio activo por teléfono. El usuario confirmó las consultas de contexto/etapas/calificación durante las pruebas del día 5. Los historiales se conservan separados al cambiar explícitamente de campaña; la ventana de contexto se evalúa al recibir mensajes y no borra registros automáticamente. No se ejecutó SQL ni se modificaron datos o políticas en esta revisión documental.

El usuario confirmó el **3 de noviembre** que el respaldo estructural de las dos tablas y cuatro funciones del monitoreo/incidentes en [supabase/](../supabase/README.md) está **versionado en GitHub**. El esquema y los permisos proceden de la configuración verificada y reportada por el usuario; las funciones proceden de las definiciones suministradas de `pg_get_functiondef()`. Se conservaron firmas, cuerpos, retornos y `search_path` vacío; las ACL reflejan EXECUTE para `service_role`/`postgres` y ausencia de acceso para `PUBLIC`, `anon` y `authenticated`. Ambas tablas tienen RLS activado, sin FORCE RLS ni políticas explícitas. La revisión de Codex fue estática y no ejecutó SQL ni probó restauración; la prueba real de protección contra ceros en Supabase fue confirmada por el usuario por separado. El respaldo no es una copia de los datos o de todo el proyecto y no tiene una restauración validada. La inspección de `schema.sql` confirma que no contiene `public.leads`, `public.leads_laudo` ni `public.whatsapp_routing`; el respaldo estructural completo de las tablas multicampaña sigue pendiente. No se deducen permisos, políticas RLS o índices de esas tablas desde los workflows.

La etapa persistida que se observa actualmente después de una respuesta afirmativa a la solicitud de cita es `cita`. No debe asumirse que el valor `cita_si` sea el valor almacenado.

## Acceso administrativo

Se reportó la configuración de acceso SSH mediante una clave ED25519 generada en Windows y registrada en el VPS. La autenticación por clave fue comprobada y posteriormente se desactivó la autenticación SSH mediante contraseña. El acceso de root mediante clave pública permanece habilitado.

No se documentan contraseñas, claves privadas, claves públicas completas ni otros secretos. La autenticación SSH es independiente de la autenticación de la interfaz web de n8n.

## Respaldos

Existe una copia local de la instalación de n8n realizada el **21 de septiembre de 2026**, utilizada durante la migración. La instalación restaurada fue validada mediante una prueba comercial real.

Al 2 de octubre no se había contratado Auto Backup de Contabo ni configurado un respaldo automático periódico. No se aportó una actualización que valide esos mecanismos en este cierre. El 5 de noviembre el usuario confirmó copias locales de los workflows anteriores; son un antecedente adicional, sin comprobación de integridad o restauración. La copia de Windows no debe presentarse como respaldo actualizado de datos generados posteriormente en producción.

GitHub conserva documentación, exportes de workflows y el respaldo estructural SQL reportado como versionado al 3 de noviembre, pero no es un respaldo completo de n8n o de los datos de Supabase. No se incorporan bases internas, respaldos de datos ni credenciales al repositorio.

## Pendientes operativos y de control documental

- Verificación completa de mensajes predefinidos en anuncios, campañas y sitios web: incluir Mejoravit o Laudo según corresponda. No hay evidencia de una revisión integral completada.
- Confirmar en producción los tres textos de edad de Laudo ya corregidos en el archivo local y corregir cualquier discrepancia publicada; no se declara completada esa verificación ni la prueba específica del borde de 48 años.
- Respaldo estructural completo de las tablas multicampaña; el SQL versionado solo cubre monitoreo e incidentes.
- Verificar los efectos concretos de las diferencias heredadas de Mejoravit en la ruta NL y el reset; no se cambiaron durante el cierre.
- Existencia de un respaldo actual, íntegro y restaurable de producción.
- Validación de integración completa con n8n ante bloqueo de ceros y retorno del registro existente; la prueba SQL y la ejecución automática del monitor del 3 de noviembre ya están confirmadas.
- Recepción posterior de estadísticas reales de noviembre; los ceros actuales son provisionales.
- Consumo real que alcance US$20 y ciclo operativo completo de 24 horas entre incidentes reales.
- Revisión de cobertura de errores, concurrencia y recuperación de reservas/alertas; no hay garantía general de idempotencia o reintentos.
- Restauración y compilación de los archivos SQL en un entorno PostgreSQL aislado.
- Verificación de permisos efectivos en esa restauración; conservación de evidencia operativa sin datos sensibles.
- Autorización del usuario antes de nuevos commits o push. Los dos valores ambiguos ya fueron anonimizados; su naturaleza y eventual tratamiento en versiones previas de Git no se han confirmado.
