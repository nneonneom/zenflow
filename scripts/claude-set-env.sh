#!/usr/bin/env bash
# Usage: set-env.sh <VAR_NAME> <VALUE>
# Upserts a key in the env section of .claude/settings.local.json

set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <VAR_NAME> <VALUE>"
  exit 1
fi

VAR_NAME="$1"
VALUE="$2"

# Create file with empty object if it doesn't exist
if [[ ! -f "$SETTINGS" ]]; then
  echo '{}' > "$SETTINGS"
fi

# Ensure .env key exists, then set the var
updated=$(jq --arg k "$VAR_NAME" --arg v "$VALUE" '
  .env //= {} | .env[$k] = $v
' "$SETTINGS")

echo "$updated" > "$SETTINGS"
echo "Set $VAR_NAME in $SETTINGS"
