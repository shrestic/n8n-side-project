# n8n Self-Hosted

## Quick Start

```bash
# Start n8n
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f
```

## Access

- **n8n UI**: http://localhost:5678
- **Webhook URL**: http://localhost:5678/webhook/

## Configuration

Edit `.env` to customize settings. Restart after changes:

```bash
docker compose restart
```
