#!/usr/bin/env bash
# Zenflow issue-tracker-adapter — real Jira operations.
# Built in Slice 6. Used by story-start from Slice 10 onward.
# Requires: jira-cli (primary), curl (REST fallback).
# Env vars: JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN (from ~/.claude/settings.json).
#
# Source this file to use the functions below. Never invoke directly.

set -euo pipefail

# Fetch a single story by ID. Prints JSON matching mock-jira-story.sh output shape.
# Primary: jira-cli. Fallback: REST API.
jira_fetch_story() {
  local story_id="$1"

  if command -v jira &>/dev/null; then
    jira issue view "$story_id" --output json 2>/dev/null \
      | jq '{
          id: .key,
          project_key: (.key | split("-")[0]),
          title: .fields.summary,
          description: (.fields.description // ""),
          status: .fields.status.name,
          assignee: (.fields.assignee.emailAddress // "")
        }'
  else
    jira_fetch_story_rest "$story_id"
  fi
}

# Fetch stories assigned to the current user that are not closed.
# Prints JSON array matching mock-jira-story.sh --list output shape.
jira_fetch_assigned_stories() {
  local project_key="${1:-}"
  local jql="assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC"
  if [[ -n "$project_key" ]]; then
    jql="project = ${project_key} AND ${jql}"
  fi

  if command -v jira &>/dev/null; then
    jira issue list --jql "$jql" --output json 2>/dev/null \
      | jq '[.[] | {
          id: .key,
          project_key: (.key | split("-")[0]),
          title: .fields.summary,
          status: .fields.status.name,
          assignee: (.fields.assignee.emailAddress // "")
        }]'
  else
    _jira_rest_issue_list "$jql"
  fi
}

# Move a story to "In Progress". Transition name may vary by project config.
jira_move_to_in_progress() {
  local story_id="$1"

  if command -v jira &>/dev/null; then
    jira issue move "$story_id" "In Progress" 2>/dev/null \
      || echo "Warning: could not transition ${story_id} to In Progress — check transition name in Jira" >&2
  else
    _jira_rest_transition "$story_id" "In Progress"
  fi
}

# --- REST API fallback functions ---

jira_fetch_story_rest() {
  local story_id="$1"
  curl -sf \
    -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
    -H "Accept: application/json" \
    "${JIRA_BASE_URL}/rest/api/3/issue/${story_id}" \
    | jq '{
        id: .key,
        project_key: .fields.project.key,
        title: .fields.summary,
        description: (.fields.description.content[0].content[0].text // ""),
        status: .fields.status.name,
        assignee: (.fields.assignee.emailAddress // "")
      }'
}

_jira_rest_issue_list() {
  local jql="$1"
  curl -sf \
    -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
    -H "Accept: application/json" \
    -G --data-urlencode "jql=${jql}" \
    "${JIRA_BASE_URL}/rest/api/3/search" \
    | jq '[.issues[] | {
        id: .key,
        project_key: .fields.project.key,
        title: .fields.summary,
        status: .fields.status.name,
        assignee: (.fields.assignee.emailAddress // "")
      }]'
}

_jira_rest_transition() {
  local story_id="$1" transition_name="$2"
  # Fetch available transitions, find matching ID, POST to execute
  local transition_id
  transition_id=$(
    curl -sf \
      -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
      -H "Accept: application/json" \
      "${JIRA_BASE_URL}/rest/api/3/issue/${story_id}/transitions" \
      | jq -r --arg name "$transition_name" \
        '.transitions[] | select(.name == $name) | .id'
  )

  if [[ -z "$transition_id" ]]; then
    echo "Warning: transition '${transition_name}' not found for ${story_id}" >&2
    return 1
  fi

  curl -sf \
    -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"transition\": {\"id\": \"${transition_id}\"}}" \
    "${JIRA_BASE_URL}/rest/api/3/issue/${story_id}/transitions" \
    > /dev/null
}
