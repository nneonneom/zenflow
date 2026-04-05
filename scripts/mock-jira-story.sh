#!/usr/bin/env bash
# Zenflow mock Jira story fetcher — Slice 2 only.
# Replaced by the real issue-tracker-adapter in Slice 6.
#
# Usage:
#   bash mock-jira-story.sh --list          Print mock assigned-story list as JSON array
#   bash mock-jira-story.sh <story_id>      Print mock story object as JSON

set -euo pipefail

case "${1:-}" in
  --list)
    cat <<JSON
[
  { "id": "PROJ-101", "project_key": "PROJ", "title": "Add login page",          "status": "To Do", "assignee": "dev@example.com" },
  { "id": "PROJ-102", "project_key": "PROJ", "title": "Fix password reset flow", "status": "To Do", "assignee": "dev@example.com" },
  { "id": "PROJ-103", "project_key": "PROJ", "title": "Add user profile page",   "status": "To Do", "assignee": "dev@example.com" }
]
JSON
    ;;
  PROJ-101)
    cat <<JSON
{
  "id": "PROJ-101",
  "project_key": "PROJ",
  "title": "Add login page",
  "description": "Implement a login page with email and password fields. Include form validation and an error state for invalid credentials.",
  "status": "To Do",
  "assignee": "dev@example.com"
}
JSON
    ;;
  PROJ-102)
    cat <<JSON
{
  "id": "PROJ-102",
  "project_key": "PROJ",
  "title": "Fix password reset flow",
  "description": "The password reset email link expires too quickly. Extend the token TTL to 24 hours and improve the expired-link error message.",
  "status": "To Do",
  "assignee": "dev@example.com"
}
JSON
    ;;
  PROJ-103)
    cat <<JSON
{
  "id": "PROJ-103",
  "project_key": "PROJ",
  "title": "Add user profile page",
  "description": "Create a profile page showing name, email, and avatar. Allow the user to update their display name.",
  "status": "To Do",
  "assignee": "dev@example.com"
}
JSON
    ;;
  "")
    echo "Usage: mock-jira-story.sh --list | <story_id>" >&2
    exit 1
    ;;
  *)
    # Generic fallback for any other ID — useful for manual testing
    cat <<JSON
{
  "id": "${1}",
  "project_key": "$(echo "${1}" | sed 's/-.*//')",
  "title": "Mock story ${1}",
  "description": "This is a mock story for ${1}. Replace with real Jira fetch in Slice 6.",
  "status": "To Do",
  "assignee": "dev@example.com"
}
JSON
    ;;
esac
