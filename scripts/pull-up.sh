#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

bash scripts/render-config.sh
docker compose pull
docker compose up -d

echo "cliproxyapi pulled and restarted."
