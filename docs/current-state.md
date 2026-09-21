# Estado actual verificado

Fecha de referencia: **21 de septiembre de 2026**.

Este documento conserva la fotografía operativa obtenida durante la auditoría previa a v1.1. Las métricas y conteos de datos no deben interpretarse como valores permanentes.

## Arquitectura en operación

```text
Usuario de WhatsApp
  -> WhatsApp Cloud API / webhook de Meta
  -> ngrok (HTTPS temporal de desarrollo)
  -> n8n local: whatsapp-webhook
  -> n8n local: whatsapp-leads
  -> Supabase PostgreSQL
  -> WhatsApp Cloud API / agente humano cuando corresponde
```

El bot funciona con tráfico real, pero continúa en un entorno local. ngrok está operativo y solo expone el webhook durante el desarrollo; ninguna URL temporal debe documentarse como endpoint permanente.

## Host, Docker y n8n

| Elemento | Estado verificado |
|---|---|
| Sistema anfitrión | Windows 10 |
| Ejecución | Docker Desktop, contenedor `n8n` |
| Imagen | `n8nio/n8n` |
| Versión de n8n | 2.35.5 Self Hosted |
| Puerto publicado | 5678 |
| Política de reinicio | `no` |
| Persistencia | bind mount con lectura y escritura hacia `/home/node/.n8n` |
| Origen del montaje | `%USERPROFILE%\.n8n` (ruta local normalizada para documentación pública) |

Los datos persistentes están fuera del sistema de archivos propio del contenedor. La ausencia de reinicio automático es la configuración local actual, no evidencia de un fallo. v1.2 debe adoptar una política apropiada para producción.

`dockers-run.txt` conserva un ejemplo histórico de ejecución y contiene una URL temporal de ngrok. No debe tratarse como configuración permanente ni copiarse a otros documentos.

## Workflows publicados

La auditoría se realizó sobre los JSON exportados desde la instalación local.

| Workflow | Archivo principal | Nodos | Responsabilidad |
|---|---|---:|---|
| `whatsapp-webhook` | `workflows/whatsapp-webhook.json` | 5 | Recibir eventos, extraer y normalizar campos y llamar al workflow principal. |
| `whatsapp-leads` | `workflows/whatsapp-leads.json` | 44 | Gestionar la precalificación, persistencia, respuestas y derivación a agente. |

Los identificadores internos de los workflows exportados coinciden con los disponibles en el repositorio. En la revisión del 21 de septiembre de 2026, cada archivo con sufijo `-v1` era idéntico byte a byte a su equivalente sin sufijo.

Una captura puntual de n8n mostró 103 ejecuciones de producción, 0 fallidas y una duración promedio de 0,83 segundos. Es una observación puntual, no una métrica histórica global ni una garantía de disponibilidad.

## Supabase PostgreSQL

Tabla principal verificada: `public.leads`.

| Columna | Tipo | Restricción documentada |
|---|---|---|
| `id` | `bigint` | `NOT NULL` |
| `telefono` | `text` | — |
| `estado` | `text` | — |
| `tiempo_trabajo` | `text` | — |
| `subcuenta` | `text` | — |
| `nombre` | `text` | — |
| `nss` | `text` | — |
| `etapa` | `text` | — |
| `calificado` | `boolean` | — |
| `created_at` | `timestamptz` | — |
| `updated_at` | `timestamptz` | — |
| `motivo_rechazo` | `text` | — |
| `fecha_calificado` | `timestamptz` | — |
| `fecha_cita` | `timestamptz` | — |
| `fecha_fin` | `timestamptz` | — |
| `ultima_interaccion` | `timestamptz` | — |
| `mensaje_original` | `text` | — |
| `fecha_reset` | `timestamptz` | — |

Restricciones verificadas:

- `leads_pkey`: clave primaria sobre `id`.
- `leads_telefono_key`: valor único de `telefono`.
- Ambas cuentan con índices únicos btree.

La generación automática de `id` no fue auditada formalmente. La unicidad de `telefono` ya existe y evita duplicar teléfonos no nulos, pero no hace idempotente el procesamiento de mensajes de WhatsApp.

No se verificaron durante esta auditoría las políticas RLS, permisos de Data API ni otras reglas de acceso de la tabla; no deben inferirse a partir de los workflows.

## Fotografía de los datos

Al 21 de septiembre de 2026 se observaron 409 leads, sin teléfonos nulos o vacíos y sin etapas nulas o desconocidas.

| Etapa | Registros |
|---|---:|
| `estado` | 232 |
| `rechazado` | 86 |
| `cita` | 28 |
| `fin` | 25 |
| `calificado` | 21 |
| `trabajo` | 11 |
| `subcuenta` | 4 |
| `re_cita` | 2 |

Se observaron 123 registros con `fecha_reset` vencida: 84 en `rechazado`, 21 en `cita`, 17 en `fin` y 1 en `re_cita`. Los primeros 122 son compatibles con el funcionamiento actual, que comprueba el vencimiento cuando el usuario vuelve a escribir y no necesariamente en el instante exacto. El origen del registro en `re_cita` no fue comprobado y no debe clasificarse automáticamente como error.

## Respaldos observados

Se verificó visualmente la existencia de `E:\Backup` y, dentro de él, estos elementos del 20 de agosto de 2026:

- `n8n-backup-2026-08-20/`
- `docker_data_2026-08-20.vhdx`

Estado de la evidencia:

- **Respaldos históricos existentes:** sí.
- **Respaldo actual verificado:** no determinado.
- **Restauración validada:** no determinada.

No se verificaron el contenido completo, la integridad, la capacidad de restauración, la cobertura de cambios posteriores ni la existencia de una copia más reciente. Los respaldos y datos internos de n8n no deben incorporarse al repositorio.

## Infraestructura futura aprobada

Para v1.2 se aprobó como referencia un **Contabo Cloud VPS 6** con 6 vCPU, 12 GB de RAM y 200 GB SSD. El presupuesto estimado es USD 9 mensuales, pero el precio final no fue verificado y el VPS todavía no ha sido contratado.

La producción debe usar Ubuntu Server, Docker y Docker Compose, persistencia, reinicio automático, dominio o subdominio permanente, HTTPS, credenciales seguras, migración controlada, verificación del webhook, pruebas end-to-end y monitoreo. ngrok dejará de ser una dependencia de producción. Supabase continuará como servicio externo salvo decisión de arquitectura posterior expresamente aprobada.

## Pendiente de verificar

- Generación automática de `public.leads.id`.
- RLS, permisos de Data API y configuración de seguridad de Supabase.
- Integridad, vigencia y restaurabilidad de los respaldos.
- Precio final y contratación del VPS.
- Configuración definitiva de producción, dominio, HTTPS, secretos y monitoreo.
- Comportamiento real de los riesgos de código bajo duplicados, concurrencia y fallos parciales.
- Origen del registro observado en `re_cita` con reset vencido.

Los hallazgos y criterios para resolver estas incertidumbres técnicas se detallan en [Auditoría v1.1](audit-1.1.md).
