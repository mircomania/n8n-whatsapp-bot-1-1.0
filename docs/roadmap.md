# Roadmap

## v1.0 — MVP

**Estado: completada.** Desarrollo inicial del bot de atención y precalificación mediante n8n, WhatsApp Cloud API y Supabase, con reglas deterministas y derivación al agente.

## v1.1 — Despliegue en producción

**Estado: completada.** El bot funcional fue migrado a Contabo, se configuraron dominio y HTTPS, se restauró n8n y se validó el recorrido comercial reportado.

## v1.2 — Integración con Airtable

**Estado: completada — implementada y publicada.**

- [x] Crear el Personal Access Token de Airtable con acceso limitado a la base necesaria y los permisos requeridos por la integración.
- [x] Configurar la credencial en n8n y comprobar la conexión.
- [x] Seleccionar la base y tabla de destino.
- [x] Configurar el nodo nativo Airtable `Record` / `Create`.
- [x] Mapear los campos comerciales definidos.
- [x] Incorporar el nodo al tramo final de `whatsapp-leads`.
- [x] Resolver la validación de la opción `BOT IA` en el campo `source`.
- [x] Ejecutar correctamente la prueba manual y comprobar la creación del registro en Airtable.
- [x] Publicar la nueva versión de `whatsapp-leads` en Contabo.
- [x] Retirar el aviso al agente por WhatsApp y dejar Airtable como salida interna, según DEC-013.

La integración registra en Airtable la solicitud de cita de un usuario que superó la precalificación. El registro no implica que haya fecha u horario confirmados. Supabase continúa como base principal y las reglas comerciales no cambiaron. La validación fue manual; no se afirma que existan pruebas exhaustivas con múltiples leads o seguimiento de largo plazo.

Los workflows finales fueron reportados como exportados desde producción y reemplazaron los archivos anteriores. El mapeo `Fuente_lead: BOT IA` fue confirmado como intencional.

## v1.3 a v1.8 — Evolución futura

**Estado: sin definir.** No se asignan funcionalidades ni fechas.

## v1.9 — Mantenimiento avanzado

**Estado: reservada / no priorizada.** La auditoría histórica se conserva en [docs/audit-1.9.md](audit-1.9.md). Sus propuestas no son requisitos obligatorios para las versiones posteriores.

## Mantenimiento operativo de octubre y noviembre de 2026

**Estado: implementación publicada reportada; validación parcial al 2 de noviembre.** No se asigna a v1.3–v1.8 ni se declara completada v1.9.

- Implementado y reportado como publicado: `whatsapp-monitor`, registro mensual en Supabase, alertas Slack cada 1.000 mensajes y US$20; `whatsapp-incidentes`, autenticación y facturación `131042`, reserva de una alerta cada 24 horas por tipo (DEC-014 y DEC-015).
- Verificado según reporte operativo: alerta real de 1.000 mensajes y registro del umbral; incidentes simulados de autenticación y facturación hasta Slack; lógica SQL de reserva/bloqueo en transacción revertida; recorrido comercial hasta Airtable.
- Corregido el 2 de noviembre: aceptar respuesta de Meta solo con ID y generar ceros provisionales; crear manualmente noviembre separado de octubre. Protección SQL de estadísticas positivas implementada según reporte, con prueba específica pendiente (DEC-016).
- Pendiente: siguiente ejecución automática completa; estadísticas reales de noviembre; consumo real de US$20; ciclo real de 24 horas; intento de sobrescritura con ceros y consumo por n8n de la fila existente devuelta por la RPC.
- Respaldo SQL preparado al 3 de noviembre: dos tablas, cuatro definiciones originales y permisos en [supabase/](../supabase/README.md). Pendiente aprobar su incorporación, probar restauración aislada y conservar evidencia sin datos sensibles. Cierre de seguridad local realizado: dos valores ambiguos cacheados anonimizados; endpoint histórico reclasificado como placeholder; IDs técnicos conservados. La publicación requiere autorización y no sanea el historial previo de Git.

Las verificaciones y sus límites se detallan en [Estado actual](current-state.md) y en la [auditoría de exports](audit-2026-11-02.md). La implementación no equivale a validación exhaustiva ni resuelve automáticamente las propuestas de mantenimiento avanzado.

## Metodología de mantenimiento

El bot es una herramienta complementaria de captación y precalificación, con mantenimiento por excepción y monitoreo diario automatizado. Se investigarán errores confirmados y casos excepcionales relevantes y se atenderán cambios comerciales o mantenimiento de credenciales/infraestructura cuando corresponda. No se planifican refactors preventivos sin evidencia.
