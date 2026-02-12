#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
TEMPLATE_FILE="${ROOT_DIR}/config.template.yaml"
OUTPUT_FILE="${ROOT_DIR}/config.generated.yaml"

if [ ! -f "${TEMPLATE_FILE}" ]; then
  echo "template not found: ${TEMPLATE_FILE}"
  exit 1
fi

if [ -f "${ENV_FILE}" ]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

CLIPROXY_CLIENT_API_KEY="${CLIPROXY_CLIENT_API_KEY:-}"
REMOTE_MGMT_SECRET_KEY="${REMOTE_MGMT_SECRET_KEY:-}"

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\\/&]/\\&/g'
}

api_key_escaped="$(escape_sed "${CLIPROXY_CLIENT_API_KEY}")"
mgmt_key_escaped="$(escape_sed "${REMOTE_MGMT_SECRET_KEY}")"

sed \
  -e "s/__CLIPROXY_CLIENT_API_KEY__/${api_key_escaped}/g" \
  -e "s/__REMOTE_MGMT_SECRET_KEY__/${mgmt_key_escaped}/g" \
  "${TEMPLATE_FILE}" > "${OUTPUT_FILE}"

echo "generated: ${OUTPUT_FILE}"
