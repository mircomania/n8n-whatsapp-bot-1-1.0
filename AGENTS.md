# Instrucciones para agentes

Este archivo es el punto de entrada obligatorio para cualquier agente de IA que trabaje en este repositorio.

## Antes de actuar

1. Leer `README.md` y los documentos enlazados desde allí.
2. Consultar `docs/current-state.md` para conocer el estado operativo y su fecha de referencia.
3. Consultar `docs/decisions.md` antes de proponer cambios importantes de arquitectura o modificar el roadmap.
4. Consultar `docs/audit-1.9.md` cuando la tarea trate sobre los hallazgos históricos de mantenimiento avanzado.
5. Consultar `docs/roadmap.md` para respetar el alcance y el orden de las versiones.
6. Revisar el estado de Git y preservar cambios locales ajenos a la tarea.

No volver a solicitar información que ya esté registrada como verificada o aprobada. Si un dato documentado tiene fecha de referencia, tratarlo como una fotografía de ese momento y comprobar si necesita actualización antes de usarlo como estado actual.

## Clasificación de la información

Mantener siempre separadas estas categorías:

- **Hecho verificado:** observado directamente y acompañado por su evidencia o fecha de referencia.
- **Decisión aprobada:** elección autorizada, aunque todavía no esté implementada.
- **Propuesta:** alternativa sujeta a diseño o aprobación.
- **Pendiente de verificar:** información desconocida o no validada formalmente.

No convertir propuestas en decisiones ni pendientes en hechos. No marcar una tarea como completada si solo fue diseñada, documentada o parcialmente probada.

## Mapa documental

- `README.md`: entrada al repositorio y navegación.
- `docs/project.md`: propósito, alcance y estado general del producto.
- `docs/current-state.md`: infraestructura, versiones, datos y evidencia operativa con fecha de referencia.
- `docs/architecture.md`: componentes, responsabilidades y flujo entre sistemas.
- `docs/business-logic.md`: reglas de conversación y precalificación.
- `docs/decisions.md`: decisiones técnicas, comerciales y operativas y sus consecuencias.
- `docs/audit-1.9.md`: auditoría histórica de mantenimiento avanzado, elaborada durante la antigua planificación v1.1.
- `docs/roadmap.md`: trabajo completado, actual y futuro.
- `docs/stack.md`: tecnologías y responsabilidades.

Cuando se complete una etapa o cambie un hecho operativo, actualizar el documento responsable y corregir los enlaces o resúmenes afectados. Evitar copiar todo el contenido entre documentos.

## Límites de acceso y operación

- El contenido de Git no demuestra acceso directo a n8n, Supabase, Docker, ngrok, Meta ni al VPS.
- No modificar infraestructura, servicios externos, datos ni workflows publicados sin autorización explícita y un alcance técnico específico.
- En una tarea exclusivamente documental, no modificar los JSON de `workflows/`.
- No ejecutar SQL, migraciones, importaciones, despliegues, reinicios de contenedores ni operaciones destructivas por iniciativa propia.
- No contratar ni configurar infraestructura sin autorización.
- La v1.1 de despliegue está completada; la v1.2 de IA está planificada y la v1.9 queda reservada para mantenimiento avanzado. Respetar este orden y no presentar planes como implementación.

## Seguridad y privacidad

El repositorio es público. No incorporar:

- tokens, API keys, credenciales, claves de cifrado o variables sensibles;
- teléfonos reales, NSS u otros datos personales de leads o agentes;
- respaldos o datos internos de n8n;
- URLs privadas o endpoints temporales de desarrollo.

Usar variables de entorno, marcadores genéricos y credenciales administradas por n8n. Si se detecta información potencialmente sensible ya versionada, reportar su ubicación y categoría sin reproducir el valor; no modificarla ni eliminarla fuera del alcance autorizado.

Los respaldos históricos documentados no prueban que exista un respaldo actual, íntegro o restaurable. Nunca presentar una recuperación como validada sin una prueba de restauración registrada.

## Criterio de trabajo

- Contrastar la documentación con los exportes y la evidencia disponible; no inventar configuraciones.
- Registrar fechas en métricas y observaciones que puedan cambiar.
- Diseñar los reintentos junto con la idempotencia para no duplicar mensajes, escrituras ni avisos a agentes.
- Preservar las reglas deterministas de precalificación si en el futuro se incorpora IA, y definir de forma explícita la transición al agente humano.
