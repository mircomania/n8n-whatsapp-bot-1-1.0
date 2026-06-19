# WhatsApp Lead Qualification Bot

Automated lead qualification system built with **n8n, WhatsApp Cloud API, Supabase, and Docker**.

## Overview

This project is an automated conversational workflow designed to qualify incoming leads through WhatsApp before transferring them into a business process.

The system receives WhatsApp messages, validates user information through multiple qualification stages, stores lead data in Supabase, and manages automated responses based on user status and business rules.

## Features

- Automated lead registration.
- Multi-step qualification workflow.
- Interactive WhatsApp buttons and list messages.
- Conditional qualification logic.
- Automatic rejection handling.
- Appointment scheduling flow.
- User reset and requalification system.
- Supabase database integration.
- Real-time WhatsApp webhook processing.
- Persistent user state management.

## Architecture

The workflow follows this general flow:

```text
WhatsApp User
      |
      v
WhatsApp Cloud API
      |
      v
n8n Webhook
      |
      v
Lead Qualification Workflow
      |
      +----> Supabase Database
      |
      +----> Automated WhatsApp Responses
```

## Tech Stack

- n8n
- WhatsApp Cloud API
- Supabase
- Docker
- ngrok

## Workflows

### whatsapp-webhook

Receives incoming WhatsApp messages, processes webhook payloads, and normalizes incoming data before passing it to the main qualification workflow.

### whatsapp-leads

Main business logic workflow responsible for:

- Lead creation.
- Qualification stages.
- User state validation.
- Employment validation.
- Housing account validation.
- Appointment scheduling.
- User status updates.
- Automated responses.

## Project Structure

```text
workflows/
├── whatsapp-webhook.json
├── whatsapp-webhook-v1.json
├── whatsapp-leads.json
└── whatsapp-leads-v1.json
```

## Docker Setup

A container startup example is available in:

```text
docker-run.txt
```

The Docker environment allows running n8n locally and exposing webhook endpoints for development using ngrok.

## Security

Credentials, API tokens, environment variables, and production secrets are intentionally excluded from this repository.

## Highlights

- Designed as a real-world automation workflow.
- Integration between messaging API, automation platform, and database.
- Business logic implementation through low-code backend workflows.
- Event-driven webhook architecture.
- Stateful conversation management.

## Author

Mircomania
