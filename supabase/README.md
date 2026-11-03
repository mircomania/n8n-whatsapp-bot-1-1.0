# Respaldo SQL de monitoreo e incidentes

Fecha de referencia: **3 de noviembre de 2026 (03-11-2026)**. Fotografía estructural del sistema de monitoreo e incidentes de WhatsApp en Supabase, basada en las definiciones y la configuración verificadas y proporcionadas por el usuario. Codex no accedió a la base de datos durante la elaboración o revisión documental. La prueba operativa reportada por el usuario se registra por separado más abajo.

Las cuatro funciones proceden del texto SQL extraído mediante `pg_get_functiondef()` que el usuario pegó en la conversación. Se retiraron únicamente los escapes de presentación: barras de fin de línea, `&#x20;`, `\*` y `\--`. Se conservaron parámetros, tipos, lenguajes, cuerpos y las cuatro cláusulas `SET search_path TO ''`. No se reconstruyeron funciones a partir de los exports de n8n ni se optimizó su lógica.

`schema.sql` ya existía y se conservó sin cambios. Su DDL fue reconstruido a partir de la estructura de tablas reportada por el usuario; no es una extracción literal de `pg_dump`. Este directorio no es un respaldo íntegro del proyecto Supabase y no contiene un volcado de datos para restauración, credenciales o configuración de conexión.

## Archivos y responsabilidades

| Archivo | Contenido |
|---|---|
| [schema.sql](schema.sql) | Dos tablas, claves primarias, restricción `mes_primer_dia`, propietario, RLS y privilegios de tabla. |
| [monitor-functions.sql](monitor-functions.sql) | `guardar_resumen_whatsapp` y `registrar_alerta_whatsapp`, con permisos de ejecución por firma. |
| [incident-functions.sql](incident-functions.sql) | `reservar_alerta_incidente` y `confirmar_alerta_incidente`, con permisos de ejecución por firma. |

`public.whatsapp_monitor_monthly` almacena el consumo y costo mensual por cuenta, umbrales avisados y fechas de consulta/actualización. Su clave primaria es `(waba_id, mes)` y el día de `mes` debe ser 1. Los costos se almacenan como `numeric(12,4)` y el umbral monetario avisado como `numeric(12,2)`; los argumentos `numeric` de las funciones conservan la precisión no restringida de la fuente.

`public.whatsapp_incident_alerts` almacena el último aviso y la reserva temporal por tipo. Su clave primaria es `tipo_incidente`; `reserva_id` es UUID y `ultimo_aviso_en`/`reserva_hasta` admiten NULL.

| Función | Retorno y comportamiento original |
|---|---|
| `guardar_resumen_whatsapp` | `SETOF whatsapp_monitor_monthly`. Inserta o actualiza el mes; bloquea la sustitución de estadísticas positivas por cero mensajes y cero costo. Si se bloquea, `IF NOT FOUND` devuelve el registro existente. |
| `registrar_alerta_whatsapp` | `SETOF whatsapp_monitor_monthly`. Actualiza ambos umbrales usando `GREATEST`, solo con umbrales no negativos y para un registro existente; no crea filas ni actualiza `actualizado_en`. |
| `reservar_alerta_incidente` | `TABLE(debe_notificar boolean, token_reserva uuid)`. Admite `meta_autenticacion` y `meta_facturacion`; crea una reserva de 5 minutos si el último aviso permite la ventana de 24 horas y no hay una reserva vigente. Si no reserva, devuelve false y UUID nulo. |
| `confirmar_alerta_incidente` | `boolean`. Exige `p_enviado` no nulo y coincidencia de tipo/UUID; libera la reserva y registra la fecha del aviso solo si se indica envío. Devuelve si se actualizó exactamente una fila. |

## Seguridad y permisos

Las tablas tienen propietario `postgres`, RLS activado, sin FORCE RLS ni políticas explícitas, según la configuración reportada. Se mantienen los privilegios de tabla para `service_role` y `postgres`, sin acceso para `anon` ni `authenticated`; también se revocan privilegios de `PUBLIC` para evitar acceso heredado. No se agregan políticas ni permisos de esquema/globales.

Las definiciones originales omiten la cláusula de seguridad: se conserva así, con el valor predeterminado `SECURITY INVOKER`, sin introducir `SECURITY DEFINER`. Los permisos no forman parte del texto de `CREATE OR REPLACE FUNCTION`: las ACL al final de cada archivo reproducen por separado la configuración reportada por el usuario, con EXECUTE para `service_role` y `postgres` y revocación para `PUBLIC`, `anon` y `authenticated`. Cada archivo de funciones agrupa creación y ACL en una transacción. Véase la [documentación de CREATE FUNCTION de PostgreSQL](https://www.postgresql.org/docs/current/sql-createfunction.html).

No se configura un propietario de funciones por inferencia: en una creación nueva será el rol restaurador. No se alteran atributos de los roles, privilegios por defecto u objetos ajenos. Revisar el propietario y las ACL efectivas en el entorno aislado, especialmente si ya existen objetos o privilegios por defecto adicionales; estos archivos no reconcilian arbitrariamente una instalación existente.

Los nombres `token_reserva` y `p_token_reserva` describen parámetros UUID generados durante la operación; no son credenciales ni valores reales incluidos en el respaldo.

## Dependencias y orden de restauración

Se requiere un PostgreSQL compatible con los tipos y sentencias originales, lenguajes `sql`/`plpgsql`, esquema `public` y roles `postgres`, `service_role`, `anon` y `authenticated`. El orden descrito presupone una restauración como `postgres`, con permisos para crear los objetos y aplicar sus ACL. Si se utiliza otro rol, revisar primero el propietario resultante y los privilegios implícitos para no ampliar el acceso reportado. No se crean roles ni lenguajes.

`reservar_alerta_incidente` requiere `gen_random_uuid()` resoluble durante la ejecución con `search_path` vacío, normalmente la función nativa de `pg_catalog`. No se añade una extensión por inferencia. Comprobar esa dependencia en el entorno de restauración; PostgreSQL documenta [gen_random_uuid() como generador UUID](https://www.postgresql.org/docs/current/functions-uuid.html).

Orden para revisión y prueba manual en un entorno aislado:

1. Revisar versión, roles, dependencias, privilegios por defecto y ausencia de objetos en conflicto.
2. Crear las tablas con `schema.sql`, incluida su configuración de propietario, RLS y ACL.
3. Cargar `monitor-functions.sql` y `incident-functions.sql`; cada uno crea sus funciones y aplica las ACL antes del COMMIT. No hay llamadas entre estas cuatro funciones y no dependen del orden relativo entre esos dos archivos.
4. Verificar firmas, retornos, propietario, RLS, políticas, ACL y las cuatro configuraciones `search_path` vacías.
5. Repetir en el entorno restaurado el caso de ceros ya validado en Supabase y probar registro monotónico de umbrales, bloqueo de reservas, vencimiento, liberación y confirmación con UUID correcto/incorrecto. Comprobar después el consumo de respuestas por n8n, usando integraciones aisladas.

Los archivos de funciones incluyen `SET LOCAL search_path = pg_catalog, public` únicamente para la sesión/transacción de restauración: permite resolver el tipo de retorno no cualificado `whatsapp_monitor_monthly` conservado de la fuente. No modifica las cláusulas vacías almacenadas en las funciones ni persiste al terminar la transacción. Las tablas deben existir antes de crear las funciones de monitoreo.

**No son migraciones administradas por Supabase CLI** y no se aplican automáticamente. `schema.sql` usa `CREATE TABLE`, y los archivos de funciones conservan `CREATE OR REPLACE FUNCTION`; no ejecutar sobre una instalación existente sin revisión específica. No hay comandos de borrado ni datos para cargar, pero los cuerpos de las funciones realizan las escrituras descritas cuando son invocados. No se deben invocar como comprobación en producción.

## Validaciones y diferencias documentales

### Validaciones estáticas realizadas por Codex

- Comparación literal de las cuatro definiciones con el SQL suministrado, después de retirar únicamente escapes de presentación; las transacciones, el `SET LOCAL` y las ACL son envoltorios externos identificados, no cambios en las definiciones.
- Revisión estática de firmas, lenguajes, retornos, delimitadores, parámetros y columnas contra `schema.sql`. Coinciden los conflictos con las claves primarias y los campos que se leen/escriben. El esquema original y los cuatro workflows se conservaron sin cambios, comprobados por SHA-256.
- Las cinco llamadas RPC de los exports (incluidas confirmación y liberación) envían los argumentos de las cuatro firmas. La reserva devuelve los campos que espera `¿Notificar incidente?`; el resumen y los umbrales devuelven filas de la tabla mensual que consume el monitor. No se simuló PostgREST ni n8n.
- La inspección del SQL confirmó el retorno del registro existente al bloquear ceros. Ese comportamiento también quedó verificado en la prueba de Supabase reportada a continuación. No consta la fecha en que se incorporó ese bloque a producción.
- Revisión de secretos y privacidad: sin tokens de servicios, API keys, contraseñas, claves privadas, valores reales de reserva, identificadores de cuenta, teléfonos, NSS o datos de leads en estos cuatro archivos.

### Prueba ejecutada en Supabase — 3 de noviembre de 2026

**Resultado: PASS. Evidencia operativa reportada por el usuario; no ejecutada por Codex.** Se probó `public.guardar_resumen_whatsapp` mediante una transacción controlada con `BEGIN` y `ROLLBACK`.

El registro existente de octubre de 2026 contenía **1.871 mensajes y US$7,3984 de costo estimado**. Se intentó actualizarlo con **0 mensajes y US$0**. La función bloqueó la sobrescritura y devolvió una fila con los valores originales. Una verificación posterior confirmó que los datos y las fechas permanecieron intactos.

La prueba específica de protección contra ceros y retorno del registro existente está **completada**. Este resultado no valida la restauración del respaldo, sus permisos efectivos en otro entorno ni la integración completa con n8n bajo este escenario.

## Limitaciones y pendientes

En la revisión estática realizada por Codex no se dispuso de PostgreSQL ni de un parser PostgreSQL y no se compiló ni ejecutó SQL. Esa revisión fue estática/manual y léxica, y es distinta de la prueba operativa PASS ejecutada en Supabase y reportada por el usuario. Codex no accedió a la configuración viva ni realizó pruebas de restauración o integración.

La fuente conserva comportamientos que deben contemplarse en las pruebas: no añade validación general de contadores/costos negativos; la reserva dura 5 minutos, pero `confirmar_alerta_incidente` comprueba tipo/UUID sin exigir vigencia temporal de `reserva_hasta`; el bloqueo de 24 horas empieza al confirmar el envío. No se modificaron estos comportamientos para el respaldo.

Siguen pendientes:

- Restauración y compilación de los archivos SQL en un entorno PostgreSQL aislado.
- Verificación de permisos efectivos en esa restauración.
- Validación de integración completa con n8n bajo el escenario de bloqueo de ceros y retorno del registro existente.

Versionar las definiciones no valida la recuperación de los datos ni constituye un respaldo de producción actual, íntegro y restaurable.
