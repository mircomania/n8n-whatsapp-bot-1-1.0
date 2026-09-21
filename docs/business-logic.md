# Lógica de Negocio

## Identificación

Cada lead se identifica principalmente mediante su número de WhatsApp.

Antes de procesar una respuesta se consulta Supabase para determinar:

- Si el usuario existe.
- Su etapa actual.
- Sus datos almacenados.
- Su fecha de reset.

## Nuevo usuario

Si el teléfono no existe:

1. Crear registro.
2. Guardar teléfono.
3. Guardar mensaje original.
4. Establecer etapa inicial `estado`.
5. Enviar pregunta de ubicación.

## Etapa: estado

Opciones:

- Nuevo León.
- CDMX.
- Estado de México.
- Otro.

Si selecciona uno de los estados admitidos:

- Guardar estado.
- Cambiar etapa a `trabajo`.
- Enviar siguiente pregunta.

Si selecciona Otro:

- Marcar como rechazado.
- motivo_rechazo = estado.
- Establecer fecha_reset.
- Enviar mensaje de rechazo.

Las respuestas no válidas no avanzan la etapa.

## Etapa: trabajo

Se verifica si el usuario cumple con el tiempo mínimo de trabajo definido por el proceso comercial.

Si cumple:

- Guardar respuesta.
- Avanzar a `subcuenta`.

Si no cumple:

- etapa = rechazado.
- motivo_rechazo = trabajo.
- Establecer fecha_reset.

## Etapa: subcuenta

Se verifica si el usuario cumple el requisito mínimo definido para su subcuenta de vivienda.

Si cumple:

- Marcar avance de precalificación.
- Continuar al flujo de cita.

Si no cumple:

- etapa = rechazado.
- motivo_rechazo = subcuenta.
- Establecer fecha_reset.

## Etapa: cita

El usuario puede:

- Solicitar cita.
- Rechazar cita.

Si solicita cita:

- Registrar intención.
- Notificar al agente.
- Informar al usuario que será contactado.

Si no desea cita:

- Finalizar el flujo correspondiente.
- Permitir una futura reactivación según las reglas de reset.

## Reset

Los usuarios pueden volver a comenzar el proceso después de determinado tiempo.

Reglas actuales:

- Rechazados: reset después de 24 horas.
- Estados finales correspondientes a cita/fin: reset después del periodo configurado.

La fecha se almacena en:

`fecha_reset`

Antes de procesar la etapa se comprueba si:

`fecha_reset < fecha actual`

Si corresponde reiniciar:

- Limpiar o actualizar los campos necesarios.
- Regresar a la etapa inicial.
- Comenzar nuevamente la precalificación.

## Anti-spam

Se utiliza `ultima_interaccion` para evitar procesar múltiples mensajes enviados en un intervalo extremadamente corto.

El objetivo es impedir que respuestas repetidas destinadas a una etapa anterior sean procesadas después de que el usuario haya avanzado a una nueva etapa.

## Regla fundamental

La etapa almacenada en Supabase determina qué significa la siguiente respuesta del usuario.

Nunca se debe interpretar una respuesta únicamente por su contenido sin considerar la etapa actual.
