# VPC Droid Deployment (Single Config)

This layout is optimized for using Droid from your VPC with one `cliproxy` config template and one auth directory.

## What This Gives You

- One runtime config template: `config.template.yaml`
- One generated runtime config (local only): `config.generated.yaml`
- One auth store: `auths/`
- One container service: `cliproxyapi`
- Stable Droid endpoint: `http://<VPC_HOST>:8317/v1`

## 1) Prepare Files

1. Copy `.env.example` to `.env`.
2. Set `.env` values:
   - `CLIPROXY_CLIENT_API_KEY` (required)
   - `REMOTE_MGMT_SECRET_KEY` (optional)
3. Put your OAuth auth files (for example `antigravity-*.json`) into `auths/`.

You can copy from local with:

```bash
bash scripts/sync-auths-from-local.sh
```

Then render runtime config:

```bash
bash scripts/render-config.sh
```

## 2) Start Service

```bash
bash scripts/up.sh
docker compose logs -f cliproxyapi
```

## 3) Validate

```bash
curl -sS -H "Authorization: Bearer <YOUR_API_KEY>" \
  http://127.0.0.1:8317/v1/models | jq '.object, (.data|length)'
```

Expected: `"list"` and model count.

## 4) Droid Connection

Use these in Droid custom model/provider settings:

- Base URL: `http://<VPC_HOST>:8317/v1`
- API key: `<YOUR_API_KEY>`
- Provider: `openai`

Recommended model IDs:

- `gemini-claude-opus-4-6-thinking`
- `gpt-5-codex`
- `gpt-5.1-codex`
- `gpt-5.2-codex`
- `gpt-5.3-codex`

Legacy-compatible alias is also kept:

- `gemini-claude-opus-4-5-thinking` -> routed to Opus 4.6

## Notes

- Keep `remote-management.allow-remote: false` unless you explicitly need remote management APIs.
- If Droid does not refresh model list, restart Droid once after updating models.
- For image updates: `bash scripts/pull-up.sh`

## Security

- Commit these files: `docker-compose.yml`, `config.template.yaml`, scripts, README.
- Do not commit: `.env`, `config.generated.yaml`, `auths/*.json`.
