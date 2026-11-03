# Estado actual

Fecha de revisión documental: **3 de noviembre de 2026**. La evidencia operativa de workflows conserva su referencia al **2 de noviembre**. El día 3 se revisaron el nuevo export local del webhook y el respaldo SQL suministrado; el usuario reportó la verificación directa de tablas y permisos en Supabase al **3 de noviembre**.

El usuario reporta publicados en Contabo `whatsapp-webhook`, `whatsapp-leads`, `whatsapp-monitor` y `whatsapp-incidentes`. Esta actualización incorpora su reporte de pruebas operativas realizadas entre el **21 de octubre y el 2 de noviembre de 2026**, además de la inspección local de los cuatro JSON. Las capturas, resultados de n8n y consultas SQL de esas pruebas se encuentran en la conversación de trabajo; no se han incorporado como archivos de evidencia al repositorio.

El **3 de noviembre** se inspeccionó el nuevo `workflows/whatsapp-webhook.json` frente a Git HEAD `bec3a33`: incorpora un filtro previo de mensaje entrante y un acuse explícito para la rama sin mensaje. No se comprobó su publicación ni se ejecutaron workflows en producción.

Se distingue **evidencia operativa reportada por el usuario**, **hechos comprobados localmente en los exports** y **pendientes**. No hubo acceso directo a producción ni consultas a servicios durante esta revisión. Los exports, incluido su campo `active`, no prueban la configuración viva ni su equivalencia exacta. La infraestructura y los antecedentes de migración conservan como referencia la confirmación del **2 de octubre de 2026**; no se revalidaron versiones, recursos o respaldos en noviembre.

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

Meta utiliza el dominio de Contabo como destino del webhook. Supabase continúa como servicio externo y la tabla comercial principal sigue siendo `public.leads`. Durante la migración no se introdujeron mecanismos experimentales de idempotencia ni colas de mensajes.

## Workflows y migración

Al 2 de noviembre se reportan cuatro workflows publicados:

| Workflow | Responsabilidad observada en el export |
|---|---|
| `whatsapp-webhook` | Recibir mensajes, invocar el flujo comercial y detectar estados fallidos de Meta con código `131042`. Tiene asociado `whatsapp-incidentes` como workflow de errores. |
| `whatsapp-leads` | Ejecutar la precalificación, persistir el estado, responder por WhatsApp y crear registros en Airtable cuando corresponde. |
| `whatsapp-monitor` | Consultar diariamente consumo de Meta, guardar el resumen mensual en Supabase y alertar umbrales mediante Slack API. |
| `whatsapp-incidentes` | Clasificar incidentes de autenticación/facturación y reservar, enviar y confirmar alertas por tipo. |

La migración trasladó los datos persistentes de n8n desde la instalación local detenida hacia el VPS. Se conservaron la base interna de n8n, los workflows, la configuración, la clave de cifrado y las credenciales cifradas. La restauración fue comprobada mediante el funcionamiento de los workflows y una prueba comercial real.

Como antecedente, el 2 de octubre los archivos `workflows/whatsapp-leads.json` y `workflows/whatsapp-webhook.json` fueron reportados por el usuario como exportes de la versión final estabilizada de producción y reemplazaron los exportes anteriores. Son exportes versionados, no prueba de la configuración viva ni de equivalencia exacta. El valor intencional de `Fuente_lead` es `BOT IA`.

## Integración Airtable en producción

Antecedente reportado al **2 de octubre de 2026**: la integración fue añadida a `whatsapp-leads` desde n8n en Contabo y la versión final se reportó publicada. En esa fecha Airtable llevaba más de una semana funcionando sin errores reportados. La empresa retiró el aviso interno al agente por WhatsApp. La ruta final reportada es `Si cita -> Espera agente -> Create a record`: `Si cita` actualiza el lead en Supabase, `Espera agente` responde al usuario y `Create a record` crea el registro en Airtable.

Configuración reportada: nodo nativo Airtable, recurso `Record`, operación `Create`, base “Base Leads Nueva” y tabla “Leads global”. Se usa una credencial Airtable Personal Access Token guardada en n8n, con permisos `data.records:read`, `data.records:write` y `schema.bases:read`, limitada a esa base. No se documenta el token.

El mapeo reportado incluye `phone` desde `Revisar tabla.telefono`; `state_google_ads` desde el estado del lead; `source` y `Fuente_lead` con valor fijo `BOT IA`; `company` y `company_aux` con `Proconsultores`; y `no_llamar` activado. El export coincide con esos valores. Otros campos visibles podían permanecer vacíos. `BOT IA` es una etiqueta comercial y no significa que se use IA.

El registro representa la solicitud de cita de un usuario que superó la precalificación. No significa que la cita tenga fecha u horario confirmados.

### Validación reportada

Durante las primeras pruebas, n8n rechazó el valor `BOT IA` de `source` porque no aparecía entre las opciones reconocidas por la configuración del nodo. Tras actualizar esa configuración, la prueba manual reportada creó un registro en Airtable. La observación de operación superior a una semana sin errores también fue reportada por el usuario; no equivale a una prueba exhaustiva.

Esta es una prueba manual del flujo reportado. No se han documentado pruebas exhaustivas con múltiples leads, verificación automática de todos los registros de producción ni funcionamiento a largo plazo.

## Monitoreo diario y registro mensual de Meta

**Implementación publicada reportada; configuración inspeccionada localmente al 2 de noviembre.** `whatsapp-monitor` contiene un Schedule Trigger a las 09:00 y zona `America/Mexico_City`, además de entrada manual. El usuario comprobó ejecución diaria hasta el 31 de octubre y ejecuciones automáticas fallidas el 1 y 2 de noviembre. La siguiente ejecución automática completa tras la corrección sigue pendiente.

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

El usuario ejecutó manualmente `Resumen mensual` y `HTTP Request1`, comprobó la creación de noviembre y verificó que octubre conservaba sus estadísticas. Esto verifica parcialmente el cambio de mes; no acredita todavía una ejecución automática completa tras el ajuste. Los ceros provisionales no demuestran consumo real nulo ni explican por qué Meta omitió las estadísticas.

El mismo día se actualizó en Supabase `public.guardar_resumen_whatsapp`. Según la comprobación operativa reportada, la condición `ON CONFLICT ... DO UPDATE ... WHERE NOT (...)` impide sustituir estadísticas positivas existentes cuando la nueva consulta trae cero mensajes y cero costos. **Protección implementada según el reporte; prueba específica pendiente.** Crear noviembre y conservar octubre no prueba el intento de sobrescritura sobre un registro positivo del mismo mes.

El export envía los valores numéricos a la RPC, pero no envía `sin_datos_meta`; esa marca es local a `Resumen mensual` y no consta su persistencia. La definición original suministrada el 3 de noviembre se conserva en [monitor-functions.sql](../supabase/monitor-functions.sql): si el bloqueo impide actualizar, `IF NOT FOUND` devuelve la fila existente. Esto resuelve la incertidumbre por inspección del SQL; siguen pendientes el intento de sobrescritura y la comprobación de la respuesta en n8n. No son migraciones de Supabase CLI.

## Incidentes de Meta y límite de 24 horas

`whatsapp-incidentes` admite `meta_autenticacion` y `meta_facturacion`:

- **Autenticación:** su Error Trigger clasifica errores de autenticación solo cuando el workflow del evento es `whatsapp-webhook`; reconoce texto como `Authorization failed` y referencias a código 190. El export receptor lo configura como workflow de errores. No se demuestra cobertura directa de errores de `whatsapp-leads` o `whatsapp-monitor`.
- **Facturación `131042`:** una rama del receptor recorre estados de entrega `failed`, detecta el código y llama a `whatsapp-incidentes` sin esperar su finalización. Distingue la referencia a falta de método de pago de un diagnóstico general de elegibilidad de pago. Devuelve el primer caso coincidente del evento.

El flujo utiliza las RPC `reservar_alerta_incidente` y `confirmar_alerta_incidente` para limitar las notificaciones a **una cada 24 horas por tipo**. Solo envía si `debe_notificar` lo autoriza. Tras `ok === true` confirma la reserva; si Slack no confirma, intenta liberarla y termina con error. Los exports no incluyen esa lógica SQL; la fuente original suministrada el 3 de noviembre se conserva en [incident-functions.sql](../supabase/incident-functions.sql). La reserva dura 5 minutos y el bloqueo de 24 horas se mide desde el aviso confirmado. La confirmación exige tipo y UUID, pero no comprueba que la reserva siga vigente; no se alteró ese comportamiento.

**Pruebas operativas reportadas:** se simuló `Authorization failed` y se recibió la alerta en Slack; también se simuló `131042`, se comprobó el recorrido receptor → incidentes → Slack y su registro en Supabase, y se restableció el estado de esa prueba. En una transacción SQL revertida se verificaron primera reserva autorizada, segunda reserva del mismo tipo rechazada, confirmación y nuevo rechazo durante el bloqueo, sin registros permanentes de esa prueba SQL. Falta observar un ciclo completo de 24 horas con incidentes reales separados por ese intervalo.

## Estado de los exportes del repositorio

La [auditoría del 2 de noviembre](audit-2026-11-02.md) conserva la fotografía de cuatro exports y el cierre de privacidad de ese día: dos opciones ambiguas del catálogo cacheado `source` de Airtable fueron anonimizadas sin alterar lógica comercial; el endpoint histórico de `dockers-run.txt` se reclasificó como placeholder. La anonimización no borra versiones anteriores de Git ni equivale a auditar todo su historial.

### Nuevo webhook revisado el 3 de noviembre

**Hecho verificado localmente:** JSON válido con 9 nodos, frente a 7 en HEAD `bec3a33`. Los siete nodos anteriores conservan todos sus parámetros y ajustes; tres cambian de posición. Se añade `¿Es mensaje entrante?` antes de extraer los campos comerciales:

- **True:** `Edit Fields -> mensaje -> Call 'whatsapp-leads' -> Respond to Webhook`, sin cambios en los parámetros o conexiones internas del recorrido previo.
- **False:** `Confirmar evento Meta`, con respuesta configurada HTTP 200 y sin cuerpo (`respondWith: noData`).
- **Rama independiente:** `Detectar fallo Meta 131042 -> Call 'whatsapp-incidentes'`, con código, destino y opciones de ejecución idénticos a HEAD. También se conserva el workflow de errores configurado.

El IF comprueba que `body.entry[0].changes[0].value.messages[0].from` tenga un valor verdadero mediante acceso opcional. Evita dirigir a `Edit Fields` los eventos sin ese remitente, incluidos estados habituales de entrega. No valida por completo el payload o el tipo de mensaje ni procesa mensajes de entradas/cambios posteriores del lote.

Las conexiones y referencias a workflows apuntan a elementos existentes. `pinData` **existe como objeto vacío**; no contiene datos fijados. `staticData` está ausente. No se detectaron credenciales, tokens, datos personales literales o payloads de prueba en este export. Los identificadores de nodos, workflows e instancia son metadatos técnicos.

Se comprobaron **30 casos locales** sobre la condición exportada, el detector `131042` y las conexiones, con entradas sintéticas fuera del repositorio. Pasaron mensajes, estados de entrega y casos sin campos; también se constató la limitación de la primera entrada/cambio y el paso de un remitente sin tipo. Estas pruebas no ejecutan n8n ni acreditan recepción HTTP real, notificación Slack o publicación. Falta verificar el recorrido completo en una instancia autorizada. No se modificó ningún JSON durante esta revisión; el diff del webhook procede del archivo entregado por el usuario. El detalle está en el [seguimiento de la auditoría](audit-2026-11-02.md#seguimiento-del-webhook--3-de-noviembre-de-2026).

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

## Migración y entorno local

El entorno local de Windows se conserva para desarrollo y pruebas. Las instalaciones local y de Contabo son independientes: modificar un workflow local no modifica automáticamente producción.

Ambos entornos pueden usar el mismo proyecto de Supabase y las mismas integraciones de Meta. Por ello, las pruebas locales con credenciales o datos reales pueden producir efectos comerciales. No deben iniciarse simultáneamente con el mismo webhook de producción.

ngrok pertenece al flujo histórico local y no es el webhook operativo de producción.

## Dependencia operativa de Meta

Según el procedimiento operativo reportado, la autenticación de Meta utiliza un token con vigencia aproximada de seis meses y requiere renovación periódica. No se afirma que la renovación sea automática ni se consigna una fecha de expiración. Es una dependencia que debe vigilarse.

## Supabase

La base de datos comercial no fue migrada. La tabla principal continúa siendo `public.leads`, con el esquema comercial existente. El monitoreo añade persistencia mensual y RPC operativas reportadas, descritas arriba, sin sustituir `public.leads`. Durante esta revisión documental no se ejecutó SQL ni se modificaron datos o políticas.

Se prepararon en [supabase/](../supabase/README.md) las dos tablas y cuatro funciones del monitoreo/incidentes con referencia al 3 de noviembre. El esquema y los permisos proceden de la configuración verificada y reportada por el usuario; las funciones proceden de las definiciones suministradas de `pg_get_functiondef()`. Se conservaron firmas, cuerpos, retornos y `search_path` vacío; las ACL reflejan EXECUTE para `service_role`/`postgres` y ausencia de acceso para `PUBLIC`, `anon` y `authenticated`. Ambas tablas tienen RLS activado, sin FORCE RLS ni políticas explícitas. La revisión fue estática, sin ejecutar SQL ni probar restauración; no es una copia de los datos o de todo el proyecto.

La etapa persistida que se observa actualmente después de una respuesta afirmativa a la solicitud de cita es `cita`. No debe asumirse que el valor `cita_si` sea el valor almacenado.

## Acceso administrativo

Se reportó la configuración de acceso SSH mediante una clave ED25519 generada en Windows y registrada en el VPS. La autenticación por clave fue comprobada y posteriormente se desactivó la autenticación SSH mediante contraseña. El acceso de root mediante clave pública permanece habilitado.

No se documentan contraseñas, claves privadas, claves públicas completas ni otros secretos. La autenticación SSH es independiente de la autenticación de la interfaz web de n8n.

## Respaldos

Existe una copia local de la instalación de n8n realizada el **21 de septiembre de 2026**, utilizada durante la migración. La instalación restaurada fue validada mediante una prueba comercial real.

No se contrató Auto Backup de Contabo ni se configuraron respaldos automáticos periódicos de producción. Tampoco se realizó una prueba independiente de restauración del respaldo histórico. La copia de Windows no debe presentarse como respaldo actualizado de datos generados posteriormente en producción.

GitHub conserva documentación y exportes de workflows, pero no es un respaldo completo de n8n. No se incorporan bases internas, respaldos ni credenciales al repositorio.

## Pendientes operativos y de control documental

- Existencia de un respaldo actual, íntegro y restaurable de producción.
- Siguiente ejecución automática completa de `whatsapp-monitor` después de la corrección del 2 de noviembre.
- Prueba específica de protección de un registro positivo frente a ceros y consumo por n8n de la fila existente que devuelve el SQL suministrado.
- Recepción posterior de estadísticas reales de noviembre; los ceros actuales son provisionales.
- Consumo real que alcance US$20 y ciclo operativo completo de 24 horas entre incidentes reales.
- Revisión de cobertura de errores, concurrencia y recuperación de reservas/alertas; no hay garantía general de idempotencia o reintentos.
- Revisión/aprobación del respaldo SQL preparado y prueba de restauración en un entorno aislado; conservación de evidencia operativa sin datos sensibles.
- Aprobación del usuario antes de commit o push. Los dos valores ambiguos ya fueron anonimizados en el árbol de trabajo; su naturaleza y eventual tratamiento en versiones previas de Git no se han confirmado.
