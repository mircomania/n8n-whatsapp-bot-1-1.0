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

## v1.3 — Multicampaña Mejoravit y Laudo

**Estado: desplegada en Contabo el 5 de noviembre de 2026 y validada en sus recorridos principales**, según confirmación del usuario. Los seis workflows publicados son receptor, router, Mejoravit, Laudo, monitoreo e incidentes; el inventario está en [Estado actual](current-state.md).

- [x] Incorporar router con prioridad de servicio explícito, contexto vigente de menos de 24 horas, historial único y menú de selección.
- [x] Mantener contexto por teléfono y datos comerciales separados en `leads` y `leads_laudo`, con continuidad y cambio explícito de campaña reportados.
- [x] Implementar Laudo con edad mínima de 48 años cumplidos, no pensionado y sin crédito Infonavit activo; admitir Otro estado.
- [x] Conectar ambos bots al router y conservar la URL del webhook público sin cambiar la configuración de Meta.
- [x] Verificar, según el reporte de producción, rutas positivas de ambos servicios hasta Supabase/Airtable, Laudo con Otro y una respuesta negativa con resultado esperado.
- [x] Transmitir nombre de perfil provisional a Airtable en ambos bots sin persistirlo en Supabase; llegada confirmada por el usuario.

El registro en Airtable sigue siendo una solicitud de cita, sin fecha u horario confirmados. Las pruebas de producción son las reportadas por el usuario; la lectura local de exports no prueba publicación, cobertura exhaustiva o estabilidad prolongada. Se conservaron copias locales de workflows anteriores según su reporte, sin acreditar restauración.

Pendientes del cierre:

- [ ] Revisar por completo mensajes predefinidos de anuncios, campañas y sitios web para identificar el servicio correspondiente. No hay evidencia de revisión integral completada.
- [ ] Confirmar en producción la corrección textual de `Pregunta edad`, `RE pregunta edad` y `Final edad`. La discrepancia se reportó como pendiente, pero el archivo local recibido ya admite exactamente 48 años; no se modificó en el cierre documental. No consta prueba específica del borde de edad.
- [ ] Completar el respaldo estructural de tablas multicampaña y probar restauración, compilación y permisos efectivos en entorno aislado.
- [ ] Verificar escenarios de duplicados, concurrencia, fallos parciales, acuses HTTP y cobertura de errores no acreditados. Las diferencias heredadas de Mejoravit en reset/ruta NL están registradas en [Lógica de negocio](business-logic.md), sin corrección funcional autorizada en este cierre.

Estos pendientes no convierten las propuestas históricas de v1.9 en requisitos automáticos ni invalidan las pruebas concretas completadas. Las nuevas decisiones se registran en [DEC-017 a DEC-020](decisions.md).

## v1.4 a v1.8 — Evolución futura

**Estado: sin alcance definido**, salvo decisiones posteriores verificadas. No se asignan funcionalidades ni fechas.

## v1.9 — Mantenimiento avanzado

**Estado: reservada / no priorizada.** La auditoría histórica se conserva en [docs/audit-1.9.md](audit-1.9.md). Sus propuestas no son requisitos obligatorios para las versiones posteriores.

## Mantenimiento operativo de octubre y noviembre de 2026

**Estado: implementación publicada reportada; comprobaciones concretas actualizadas al 3 de noviembre, con validaciones pendientes.** Este mantenimiento precedente no se reasigna retroactivamente al alcance multicampaña de v1.3 ni declara completada v1.9.

- Implementado y reportado como publicado: `whatsapp-monitor`, registro mensual en Supabase, alertas Slack cada 1.000 mensajes y US$20; `whatsapp-incidentes`, autenticación y facturación `131042`, reserva de una alerta cada 24 horas por tipo (DEC-014 y DEC-015).
- Verificado según reporte operativo: alerta real de 1.000 mensajes y registro del umbral; incidentes simulados de autenticación y facturación hasta Slack; lógica SQL de reserva/bloqueo en transacción revertida; recorrido comercial hasta Airtable.
- Corregido el 2 de noviembre: aceptar respuesta de Meta solo con ID y generar ceros provisionales; crear manualmente noviembre separado de octubre. Protección SQL de estadísticas positivas implementada según reporte, con prueba específica pendiente en ese cierre del día 2 (DEC-016).
- Confirmado por el usuario el 3 de noviembre: PASS de protección contra ceros con retorno del registro existente mediante `BEGIN`/`ROLLBACK` en Supabase; ejecución automática completa del monitor; recorrido comercial del webhook probado en producción hasta Airtable. Véase la [evidencia SQL](../supabase/README.md#prueba-ejecutada-en-supabase--3-de-noviembre-de-2026).
- Pendiente: estadísticas reales de noviembre (los ceros siguen siendo provisionales); consumo real de US$20; ciclo real de 24 horas; integración completa con n8n bajo el escenario de bloqueo de ceros.
- Respaldo SQL **versionado en GitHub**, confirmado por el usuario el 3 de noviembre: dos tablas, cuatro definiciones originales y permisos en [supabase/](../supabase/README.md). Siguen pendientes restauración y compilación en PostgreSQL aislado, permisos efectivos en esa restauración y conservación de evidencia sin datos sensibles. Cierre de seguridad local realizado: dos valores ambiguos cacheados anonimizados; endpoint histórico reclasificado como placeholder; IDs técnicos conservados. Cualquier publicación posterior requiere autorización y no sanea el historial previo de Git.

Las verificaciones y sus límites se detallan en [Estado actual](current-state.md) y en la [auditoría de exports](audit-2026-11-02.md). La implementación no equivale a validación exhaustiva ni resuelve automáticamente las propuestas de mantenimiento avanzado.

## Metodología de mantenimiento

El bot es una herramienta complementaria de captación y precalificación, con mantenimiento por excepción y monitoreo diario automatizado. Se investigarán errores confirmados y casos excepcionales relevantes y se atenderán cambios comerciales o mantenimiento de credenciales/infraestructura cuando corresponda. No se planifican refactors preventivos sin evidencia.
