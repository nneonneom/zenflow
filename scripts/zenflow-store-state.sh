#!/usr/bin/env bash
# Zenflow State Store — adapter router
# Source this file to use state_* functions. Never invoke directly.
# Requires: jq.
#
# Set ZENFLOW_STATE_ADAPTER=local (default) or api to select the backend.

set -euo pipefail

_ZENFLOW_STATE_ADAPTER="${ZENFLOW_STATE_ADAPTER:-local}"
_ZENFLOW_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${_ZENFLOW_STATE_ADAPTER}" in
  local)
    # shellcheck source=scripts/state-adapter-local.sh
    source "${_ZENFLOW_SCRIPT_DIR}/state-adapter-local.sh"
    ;;
  api)
    # shellcheck source=scripts/state-adapter-api.sh
    source "${_ZENFLOW_SCRIPT_DIR}/state-adapter-api.sh"
    ;;
  *)
    echo "Zenflow error: unknown ZENFLOW_STATE_ADAPTER '${_ZENFLOW_STATE_ADAPTER}'. Valid values: local, api" >&2
    return 1
    ;;
esac
