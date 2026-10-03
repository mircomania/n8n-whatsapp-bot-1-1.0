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

## Metodología de mantenimiento

El bot es una herramienta complementaria de captación y precalificación, en operación estable con mantenimiento por excepción. Se investigarán errores confirmados y casos excepcionales relevantes y se atenderán cambios comerciales o mantenimiento de credenciales/infraestructura cuando corresponda. No se planifican refactors preventivos sin evidencia.
