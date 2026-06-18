# WhatsApp Lead Qualification Bot

Automated lead qualification system built with n8n, WhatsApp Cloud API, Supabase and Docker.

## Features

- Automated lead registration
- Multi-step qualification flow
- Interactive WhatsApp buttons and lists
- Automatic rejection logic
- Appointment scheduling flow
- User reset and requalification system
- Supabase integration
- Real-time WhatsApp webhook processing

## Tech Stack

- n8n
- WhatsApp Cloud API
- Supabase
- Docker
- ngrok

## Workflows

### whatsapp-webhook

Receives incoming WhatsApp messages and normalizes webhook data before sending it to the main workflow.

### whatsapp-leads-test

Main business logic workflow responsible for:

- Lead creation
- Qualification stages
- State validation
- Employment validation
- Housing account validation
- Appointment scheduling
- User status updates
- Automated responses

## Project Structure

```text
workflows/
├─ whatsapp-webhook.json
├─ whatsapp-webhook-v2.json
├─ whatsapp-leads-test.json
└─ whatsapp-leads-test-v2.json
```

## Docker

Container startup example can be found in:

```text
docker-run.txt
```

## Notes

Credentials, API tokens and production secrets are intentionally excluded from this repository.
