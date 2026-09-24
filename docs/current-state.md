# Estado actual

Fecha de referencia: **23 de septiembre de 2026**.

Esta fotografía incorpora la información de producción confirmada por el usuario el 23 de septiembre de 2026. El despliegue previo de v1.1 y la integración v1.2 con Airtable están publicados en Contabo. El repositorio no demuestra por sí mismo acceso directo al VPS, n8n publicado, Meta, Supabase o Airtable; el estado de publicación aquí consignado se basa en esa confirmación y en la prueba manual reportada.

## Producción en Contabo

El bot funciona con tráfico real y no depende de que la computadora local permanezca encendida.

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

En la instalación operativa existen actualmente dos workflows:

| Workflow | Responsabilidad |
|---|---|
| `whatsapp-webhook` | Recibir eventos de Meta y dirigir los mensajes al flujo comercial. |
| `whatsapp-leads` | Ejecutar la precalificación, persistir el estado, responder por WhatsApp, avisar al agente y crear registros en Airtable cuando corresponde. |

La migración trasladó los datos persistentes de n8n desde la instalación local detenida hacia el VPS. Se conservaron la base interna de n8n, los workflows, la configuración, la clave de cifrado y las credenciales cifradas. La restauración fue comprobada mediante el funcionamiento de los workflows y una prueba comercial real.

Los JSON versionados en `workflows/` son exportes del repositorio. No se afirma que sean idénticos a la última versión publicada en Contabo sin una comparación actual documentada.

## Integración Airtable en producción

La integración fue añadida manualmente a `whatsapp-leads` desde n8n en Contabo y la nueva versión del workflow fue publicada. El tramo final reportado es `Si cita -> Espera agente -> Aviso agente -> Create a record`. `Si cita` actualiza el lead en Supabase; `Espera agente` envía la respuesta al usuario; `Aviso agente` notifica al agente por WhatsApp; y `Create a record` crea el registro en Airtable. Ambos mecanismos de salida están activos temporalmente, conforme a DEC-012.

Configuración reportada: nodo nativo Airtable, recurso `Record`, operación `Create`, base “Base Leads Nueva” y tabla “Leads global”. Se usa una credencial Airtable Personal Access Token guardada en n8n, con permisos `data.records:read`, `data.records:write` y `schema.bases:read`, limitada a esa base. No se documenta el token.

El mapeo manual reportado incluye `phone` desde `Revisar tabla.telefono`; `state_google_ads` desde el estado del lead; `source` con valor fijo `BOT IA`; `Fuente_lead` con valor `Llamada IA`; `company` y `company_aux` con `Proconsultores`; y `no_llamar` activado. Se indicó que otros campos visibles (`name`, `email`, `phone to clean`, `Recepción del lead`, `source_aux`, `tipo_recluta`, `age`) estaban vacíos. Las etiquetas `BOT IA` y `Llamada IA` identifican el origen del registro y no significan que se use IA.

El registro representa la solicitud de cita de un usuario que superó la precalificación. No significa que la cita tenga fecha u horario confirmados.

### Validación reportada

Durante las primeras pruebas, n8n rechazó el valor `BOT IA` de `source` porque no aparecía entre las opciones reconocidas por la configuración del nodo. Tras actualizar esa configuración, la prueba manual del tramo final terminó correctamente en los cuatro nodos. El usuario confirmó que el registro se creó en Airtable con los valores esperados.

Esta es una prueba manual del flujo reportado. No se han documentado pruebas exhaustivas con múltiples leads, verificación automática de todos los registros de producción ni funcionamiento a largo plazo.

## Estado de los exportes del repositorio

Los JSON de `workflows/` no incluyen la actualización Airtable publicada y son exportes anteriores. La sincronización está aplazada para observar el funcionamiento y realizar posibles ajustes. Contabo es la referencia operativa actual para esta integración. La sincronización de los exportes es una tarea pendiente independiente y no impide considerar v1.2 completada.

## Validaciones operativas reportadas

Se reportó la comprobación de:

- acceso al dominio mediante HTTPS;
- funcionamiento de n8n en Contabo y restauración de ambos workflows;
- funcionamiento de las credenciales;
- recepción de mensajes desde Meta;
- ejecución del flujo de precalificación;
- registro y actualización de datos en Supabase;
- respuestas por WhatsApp;
- recepción efectiva de un aviso al agente;
- funcionamiento con la computadora local apagada.

También se ejecutó el recorrido comercial ideal hasta la solicitud de cita y se observó que las ejecuciones terminaron sin errores. Estas comprobaciones validan el recorrido realizado, pero no constituyen una validación exhaustiva de condiciones excepcionales ni garantizan la entrega de todos los mensajes externos.

## Migración y entorno local

El entorno local de Windows se conserva para desarrollo y pruebas. Las instalaciones local y de Contabo son independientes: modificar un workflow local no modifica automáticamente producción.

Ambos entornos pueden usar el mismo proyecto de Supabase y las mismas integraciones de Meta. Por ello, las pruebas locales con credenciales o datos reales pueden producir efectos comerciales. No deben iniciarse simultáneamente con el mismo webhook de producción.

ngrok pertenece al flujo histórico local y no es el webhook operativo de producción.

## Supabase

La base de datos comercial no fue migrada. La tabla principal continúa siendo `public.leads`, con el esquema comercial existente y sin cambios de estructura introducidos durante este cierre documental. No se ejecutó SQL ni se modificaron datos o políticas.

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
- Exportar y sincronizar los JSON afectados una vez estabilizada la versión publicada, con la revisión de seguridad indicada en [Roadmap](roadmap.md).
- Política definitiva de idempotencia, reintentos, recuperación y notificaciones.
- Origen individual de los avisos al agente no recibidos.
