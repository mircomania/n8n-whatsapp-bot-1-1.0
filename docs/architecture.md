# Arquitectura

## Arquitectura actual

Usuario
↓
WhatsApp
↓
WhatsApp Cloud API
↓
Meta Webhook
↓
ngrok
↓
n8n — whatsapp-webhook
↓
Filtro de eventos
↓
Normalización
↓
Execute Sub-workflow
↓
n8n — whatsapp-leads
↓
Supabase
↓
Lógica de etapas
↓
WhatsApp Cloud API
↓
Usuario

## Workflows

### whatsapp-webhook

Responsabilidad:

Ser el punto de entrada de Meta.

Funciones principales:

- Recibir POST del webhook.
- Detectar eventos que contienen `messages`.
- Ignorar eventos como statuses.
- Extraer teléfono.
- Extraer tipo de mensaje.
- Normalizar respuestas de texto e interactivas.
- Ejecutar el workflow principal.

Salida normalizada aproximada:

{
"telefono": "XXXXXXXXXXX",
"mensaje": "estado_1",
"tipo": "interactive"
}

---

### whatsapp-leads

Responsabilidad:

Gestionar la lógica de negocio y el estado del lead.

Flujo general:

Entrada
↓
Buscar teléfono en Supabase
↓
¿Usuario existe?
├── NO → Crear usuario → Primera pregunta
└── SÍ → Continuar
↓
Control de interacción
↓
Control de fecha_reset
↓
Switch por etapa
↓
Validar respuesta
↓
Actualizar Supabase
↓
Enviar siguiente mensaje

## Persistencia

El estado de la conversación NO depende de la ejecución de n8n.

Supabase almacena la etapa actual de cada usuario.

Esto permite que cada mensaje sea procesado como una ejecución independiente.

## Etapas principales

- estado
- trabajo
- subcuenta
- cita
- rechazado
- fin

Pueden existir estados adicionales conforme evolucione el sistema.

## Seguridad

Los secretos deben almacenarse mediante:

- n8n Credentials.
- Variables de entorno cuando corresponda.

Nunca directamente en:

- JSON de workflows.
- GitHub.
- README.
- Código versionado.
