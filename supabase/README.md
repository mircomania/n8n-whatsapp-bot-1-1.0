# Respaldo SQL de monitoreo e incidentes

Fecha de referencia: **3 de noviembre de 2026 (03-11-2026)**. La estructura y los permisos de esta fotografía de producción fueron reportados por el usuario como verificados directamente en Supabase. Esta tarea no consulta ni modifica la base de datos.

**Preparación parcial:** `schema.sql` contiene las dos tablas, restricciones, RLS y permisos informados. Los archivos de funciones están pendientes del JSON original anunciado por el usuario; todavía no puede considerarse un respaldo estructural completo ni validado para restauración.

## Archivos y responsabilidades

| Archivo | Contenido |
|---|---|
| [schema.sql](schema.sql) | DDL de `public.whatsapp_monitor_monthly` y `public.whatsapp_incident_alerts`, propietario, RLS y privilegios de tabla. |
| `monitor-functions.sql` (pendiente) | Definiciones originales de `guardar_resumen_whatsapp` y `registrar_alerta_whatsapp`, y sus permisos. |
| `incident-functions.sql` (pendiente) | Definiciones originales de `reservar_alerta_incidente` y `confirmar_alerta_incidente`, y sus permisos. |

`whatsapp_monitor_monthly` conserva el consumo mensual por cuenta y mes, el costo estimado, los últimos umbrales notificados y fechas de consulta/actualización. Su clave primaria es `(waba_id, mes)`; `mes_primer_dia` exige el día 1.

`whatsapp_incident_alerts` conserva el último aviso y la reserva temporal por tipo de incidente. Su clave primaria es `tipo_incidente`.

Las llamadas observadas en los exports de n8n usan `guardar_resumen_whatsapp` para guardar el resumen, `registrar_alerta_whatsapp` para registrar los umbrales avisados, `reservar_alerta_incidente` para obtener autorización de envío y `confirmar_alerta_incidente` para confirmar o liberar la reserva. Sus argumentos, retornos y lógica se contrastarán con el JSON original; no se reconstruyen a partir de los workflows.

## Seguridad y permisos reportados

- Ambas tablas pertenecen a `postgres`, tienen RLS activado, sin FORCE RLS ni políticas explícitas.
- `service_role` y `postgres` disponen de todos los privilegios de tabla; `anon` y `authenticated` no tienen permisos. El DDL revoca también los privilegios de `PUBLIC` para evitar acceso heredado por esos roles.
- Las cuatro funciones son `SECURITY INVOKER`. Se deben conservar exactamente sus argumentos, retornos, `search_path` y demás configuración de seguridad de origen.
- Los permisos de ejecución reportados son para `service_role` y `postgres`, sin acceso para `anon` ni `authenticated`. Las ACL de funciones se incorporarán con sus firmas originales, evitando el acceso heredado por `PUBLIC`.

Los archivos no incluyen datos de las tablas, tokens, credenciales ni configuración de conexión. El UUID de reserva es parte del esquema, no un token real incluido en el respaldo.

## Dependencias y restauración

Se requiere PostgreSQL con el esquema `public` y los roles `postgres`, `service_role`, `anon` y `authenticated`, y un rol restaurador con permisos suficientes. No se crean roles, no se cambian privilegios de esquema ni se modifican permisos globales. Las dependencias adicionales de los cuerpos de las funciones se verificarán cuando se reciba el JSON.

Orden previsto: crear primero las tablas de `schema.sql` y su configuración RLS/permisos; después cargar `monitor-functions.sql` e `incident-functions.sql` con sus permisos de ejecución. Revisar las ACL de tablas y funciones al finalizar. Este orden no constituye autorización para ejecutar SQL.

Estos archivos **no son migraciones administradas por Supabase CLI** ni se aplican automáticamente. El DDL usa `CREATE TABLE` y presupone objetos ausentes; no es un mecanismo para sobrescribir o reconciliar una base existente. No contiene borrado de objetos ni copia de registros.

Una restauración requiere revisión manual, completar las definiciones originales y realizar pruebas en un entorno aislado. No hay restauración validada. El esquema fue reconstruido a partir de la estructura reportada; no se presenta como un `pg_dump` íntegro ni como copia de todos los objetos, extensiones, permisos o datos del proyecto Supabase.

## Controles pendientes

- Incorporar las cuatro definiciones del JSON y compararlas sin cambios funcionales.
- Comprobar firmas, retornos, dependencias, `search_path`, `SECURITY INVOKER` y permisos de ejecución por firma.
- Contrastar argumentos y resultados con las llamadas de los exports de n8n.
- Completar revisión de sintaxis PostgreSQL y coherencia; no se ha ejecutado este SQL.
