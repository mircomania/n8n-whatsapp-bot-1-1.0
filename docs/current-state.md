# Estado actual

Fecha de referencia: **23 de septiembre de 2026**.

Esta fotografía consolida la información operativa proporcionada para el cierre documental de v1.1. Describe producción en Contabo y conserva separada la instalación local de desarrollo. El repositorio no demuestra por sí mismo acceso directo al VPS, n8n publicado, Meta o Supabase.

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
| `whatsapp-leads` | Ejecutar la precalificación, persistir el estado, responder por WhatsApp y avisar al agente cuando corresponde. |

La migración trasladó los datos persistentes de n8n desde la instalación local detenida hacia el VPS. Se conservaron la base interna de n8n, los workflows, la configuración, la clave de cifrado y las credenciales cifradas. La restauración fue comprobada mediante el funcionamiento de los workflows y una prueba comercial real.

Los JSON versionados en `workflows/` son exportes del repositorio. No se afirma que sean idénticos a la última versión publicada en Contabo sin una comparación actual documentada.

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

## Pendientes de verificar

- Existencia de un respaldo actual, íntegro y restaurable de producción.
- Comparación actual entre los exportes versionados y los workflows publicados.
- Política definitiva de idempotencia, reintentos, recuperación y notificaciones.
- Origen individual de los avisos al agente no recibidos.
- Definiciones de disponibilidad de citas, oficinas, horarios y reglas para v1.2.
