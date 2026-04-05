#!/usr/bin/env bash
# Zenflow mock repo adapter — Slice 5 only.
# Replaced by the real repo-adapter in Slice 10.
#
# Usage:
#   bash mock-repo-adapter.sh --create-branch <story_id> <branch_name>
#   bash mock-repo-adapter.sh --create-pr <story_id> <title> <head_branch> <base_branch>

set -euo pipefail

case "${1:-}" in
  --create-branch)
    STORY_ID="${2:?--create-branch requires <story_id> <branch_name>}"
    BRANCH_NAME="${3:?--create-branch requires <story_id> <branch_name>}"
    echo "[MOCK repo] Branch created: ${BRANCH_NAME} (base: main)"
    ;;
  --create-pr)
    STORY_ID="${2:?--create-pr requires <story_id> <title> <head_branch> <base_branch>}"
    TITLE="${3:?--create-pr requires <story_id> <title> <head_branch> <base_branch>}"
    HEAD="${4:?--create-pr requires <story_id> <title> <head_branch> <base_branch>}"
    BASE="${5:?--create-pr requires <story_id> <title> <head_branch> <base_branch>}"
    echo "https://github.com/mock-org/mock-repo/pull/$(shuf -i 100-999 -n 1)"
    ;;
  "")
    echo "Usage: mock-repo-adapter.sh --create-branch | --create-pr" >&2
    exit 1
    ;;
  *)
    echo "Unknown command: ${1}" >&2
    exit 1
    ;;
esac
