# Roadmap

## v1.0 — MVP

- [x] Configurar n8n mediante Docker.
- [x] Integrar WhatsApp Cloud API.
- [x] Configurar webhook de Meta.
- [x] Crear workflow receptor.
- [x] Crear workflow principal.
- [x] Integrar Supabase.
- [x] Registrar nuevos leads.
- [x] Implementar sistema de etapas.
- [x] Implementar listas interactivas.
- [x] Implementar botones interactivos.
- [x] Validar respuestas.
- [x] Implementar rechazo por estado.
- [x] Implementar rechazo por situación laboral.
- [x] Implementar rechazo por subcuenta.
- [x] Implementar flujo de cita.
- [x] Implementar derivación a agente.
- [x] Implementar fecha de reset.
- [x] Implementar protección básica contra spam.
- [x] Configurar credenciales de Meta.
- [x] Realizar pruebas con tráfico real.
- [x] Versionar workflows mediante GitHub.

## v1.1 — Hardening

- [ ] Implementar idempotencia mediante Message ID (`wamid`).
- [ ] Detectar webhooks duplicados.
- [ ] Evitar procesamiento doble del mismo mensaje.
- [ ] Revisar manejo de errores de API.
- [ ] Configurar workflow de errores de n8n.
- [ ] Revisar logs y observabilidad.
- [ ] Definir estrategia de backups.

## v1.2 — Producción

- [ ] Contratar/configurar VPS.
- [ ] Instalar Docker.
- [ ] Desplegar n8n.
- [ ] Configurar persistencia.
- [ ] Configurar reinicio automático del contenedor.
- [ ] Configurar dominio/subdominio.
- [ ] Configurar HTTPS.
- [ ] Eliminar dependencia de ngrok.
- [ ] Migrar workflows.
- [ ] Configurar credentials de producción.
- [ ] Actualizar webhook de Meta.
- [ ] Realizar pruebas end-to-end.
- [ ] Activar monitoreo.

## Futuro

Posibles mejoras:

- Dashboard de leads.
- Métricas de conversión por etapa.
- Recordatorios automáticos de citas.
- Seguimiento de leads que abandonan el flujo.
- Integración con CRM.
- Alertas para agentes.
- Historial de conversaciones.
- Métricas de tiempos de respuesta.
- Automatización del seguimiento post-cita.
