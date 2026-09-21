# Roadmap

## v1.0 — MVP completado

- [x] Ejecutar n8n localmente mediante Docker.
- [x] Integrar WhatsApp Cloud API y el webhook de Meta.
- [x] Crear el workflow receptor y el workflow principal.
- [x] Integrar `public.leads` de Supabase.
- [x] Registrar leads y persistir su etapa.
- [x] Implementar listas, botones y validación de respuestas.
- [x] Implementar precalificación por estado, trabajo y subcuenta.
- [x] Registrar rechazo y motivo.
- [x] Implementar el flujo de cita y derivación al agente.
- [x] Implementar `fecha_reset` y su comprobación al volver a interactuar.
- [x] Implementar protección temporal básica mediante `ultima_interaccion`.
- [x] Probar el MVP con tráfico real y versionar los exportes.

“Implementado” describe el alcance del MVP; el reset, el filtrado y la protección temporal tienen correcciones pendientes documentadas en v1.1.

## v1.1 — Hardening (etapa actual)

Debe completarse antes de iniciar la operación sobre el VPS.

### Mensajes e idempotencia

- [ ] Propagar y validar el identificador `wamid`.
- [ ] Aprobar el modelo duradero de registro y estados de mensajes.
- [ ] Garantizar un solo procesamiento efectivo por mensaje.
- [ ] Proteger las ejecuciones simultáneas.
- [ ] Recuperar mensajes pendientes y fallos parciales sin duplicar efectos.
- [ ] Garantizar una única notificación al agente por solicitud.

### Webhook y estado

- [ ] Validar la estructura del evento antes de acceder a `messages[0]`.
- [ ] Ignorar de forma segura estados y tipos no admitidos.
- [ ] Definir los campos que el reset limpia y conserva.
- [ ] Corregir el reset para consumir o reemplazar `fecha_reset`.
- [ ] Investigar, sin asumir corrupción, el caso observado en `re_cita` con reset vencido.

### Resiliencia y operación

- [ ] Diseñar reintentos compatibles con idempotencia para Meta y Supabase.
- [ ] Configurar manejo centralizado de errores o un mecanismo equivalente.
- [ ] Incorporar logs, métricas y alertas sin secretos ni datos personales.
- [ ] Auditar RLS, permisos de Data API y generación automática de `id`.
- [ ] Revisar valores potencialmente sensibles en archivos públicos y acordar su remediación.
- [ ] Verificar un respaldo actual y validar una restauración controlada.
- [ ] Ejecutar la regresión completa del flujo comercial.
- [ ] Cumplir todos los criterios de [Auditoría v1.1](audit-1.1.md).

## v1.2 — Producción

Decisión aprobada: **Contabo Cloud VPS 6**, con referencia de 6 vCPU, 12 GB RAM y 200 GB SSD. El presupuesto aproximado es USD 9 mensuales; el precio final no está verificado y el VPS no se ha contratado.

- [ ] Contratar el VPS después del cierre de v1.1.
- [ ] Preparar Ubuntu Server.
- [ ] Instalar Docker y Docker Compose.
- [ ] Desplegar n8n con persistencia y política de reinicio apropiada.
- [ ] Configurar dominio o subdominio permanente y HTTPS.
- [ ] Configurar credenciales de producción de forma segura.
- [ ] Eliminar la dependencia de ngrok.
- [ ] Migrar los workflows de forma controlada.
- [ ] Verificar y actualizar el webhook de Meta.
- [ ] Ejecutar pruebas end-to-end.
- [ ] Activar monitoreo, alertas y estrategia operativa de backups.

Supabase continuará como servicio externo salvo que se apruebe expresamente un cambio de arquitectura.

## Futuro

- Dashboard para agentes y métricas de conversión.
- Seguimiento de abandonos, citas y post-cita.
- Integración con CRM y alertas operativas.
- Historial de conversación con controles de privacidad.
- Inteligencia artificial como complemento previo a la derivación humana, preservando las reglas deterministas y una transición controlada.
