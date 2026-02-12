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

## Field Notes (Pitfalls We Hit)

1. `401 Invalid API key` on Droid

- The running container uses `deploy/vpc-droid/config.generated.yaml`, not `cliproxyapi-official/config.yaml`.
- `dummy-not-used` in other local configs does not affect this deployment.
- Ensure Droid uses the same value as `CLIPROXY_CLIENT_API_KEY` in `.env`.
- Quick check:

```bash
curl -s -o /dev/null -w "%{http_code}\n" \
  -H "Authorization: Bearer <YOUR_API_KEY>" \
  http://127.0.0.1:8317/v1/models
```

2. `502 unknown provider for model gemini-claude-opus-4-5-thinking`

- This happened when alias mapping was missing/outdated.
- Keep alias mapping in `config.template.yaml`:
  - `claude-opus-4-6-thinking` -> `gemini-claude-opus-4-5-thinking`
  - `claude-opus-4-6-thinking` -> `gemini-claude-opus-4-6-thinking` (`fork: true`)
- Re-render and restart after alias edits:

```bash
bash scripts/render-config.sh
bash scripts/up.sh
```

3. VPC Droid UI does not show custom model names

- Root cause we saw: `~/.factory/settings.json` on VPC had `customModels: []`.
- Even when `cliproxy` returns models from `/v1/models`, Droid UI can still miss them if custom entries are absent.
- Check count:

```bash
jq '.customModels|length? // 0' ~/.factory/settings.json
```

- If changed, restart Droid process once to reload settings:

```bash
pkill droid
droid
```

4. Docker start fails with `bind: address already in use` on `8317`

- Usually caused by existing local service (for example Homebrew `cliproxyapi`) already listening on `8317`.
- Check:

```bash
lsof -i tcp:8317
```

- Stop conflicting process/service, then run `bash scripts/up.sh` again.

5. Auth files copied but not reflected

- After copying `auths/*.json` to VPC, restart the container:

```bash
docker compose restart cliproxyapi
```

## Security

- Commit these files: `docker-compose.yml`, `config.template.yaml`, scripts, README.
- Do not commit: `.env`, `config.generated.yaml`, `auths/*.json`.
