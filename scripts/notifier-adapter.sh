#!/usr/bin/env bash
# Zenflow notifier-adapter — real Teams webhook notifications.
# Built in Slice 8. Used by story-implement and PR Monitor from Slice 10 onward.
# Requires: curl.
# Env vars: TEAMS_WEBHOOK_URL (from ~/.claude/settings.json).
#
# Source this file to use the functions below. Never invoke directly.

set -euo pipefail

# Send a plain-text notification to the configured Teams channel.
# Usage: notify_teams <story_id> <message>
notify_teams() {
  local story_id="$1" message="$2"

  if [[ -z "${TEAMS_WEBHOOK_URL:-}" ]]; then
    echo "Warning: TEAMS_WEBHOOK_URL not set — skipping Teams notification" >&2
    return 0
  fi

  local payload
  payload=$(jq -n \
    --arg title "Zenflow — ${story_id}" \
    --arg text "${message}" \
    '{"title": $title, "text": $text}')

  curl -sf \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$TEAMS_WEBHOOK_URL" \
    > /dev/null
}
