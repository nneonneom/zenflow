#!/usr/bin/env bash
# Zenflow mock Teams notifier — Slice 4 only.
# Replaced by the real notifier-adapter in Slice 10.
#
# Prints notification to stdout instead of sending a Teams webhook.
#
# Usage:
#   bash mock-teams-notifier.sh <story_id> <message>

set -euo pipefail

STORY_ID="${1:?Usage: mock-teams-notifier.sh <story_id> <message>}"
MESSAGE="${2:?Usage: mock-teams-notifier.sh <story_id> <message>}"

echo "[MOCK Teams — ${STORY_ID}] ${MESSAGE}"
