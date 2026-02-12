#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${HOME}/.cli-proxy-api"
DST_DIR="${ROOT_DIR}/auths"

mkdir -p "${DST_DIR}"

if [ ! -d "${SRC_DIR}" ]; then
  echo "source directory not found: ${SRC_DIR}"
  exit 1
fi

copied=0
for pattern in "antigravity-*.json" "codex-*.json" "claude-*.json" "gemini-*.json" "qwen-*.json" "iflow-*.json"; do
  while IFS= read -r -d '' file; do
    cp "${file}" "${DST_DIR}/"
    copied=$((copied + 1))
  done < <(find "${SRC_DIR}" -maxdepth 1 -type f -name "${pattern}" -print0)
done

echo "copied auth files: ${copied}"
echo "target: ${DST_DIR}"
