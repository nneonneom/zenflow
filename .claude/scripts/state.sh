#!/usr/bin/env bash
# Zenflow State Store
# Source this file to use state_* functions.
# Requires: ZENFLOW_STATE_REPO env var, git, jq

set -euo pipefail

# Guard: fail early if required env var is missing
: "${ZENFLOW_STATE_REPO:?ZENFLOW_STATE_REPO is not set. Run /zen-setup to configure.}"

_state_branch() {
  echo "${1}/${2}"
}

# Returns 0 if the state branch exists on remote, 1 if not.
state_branch_exists() {
  local project_key="$1" story_id="$2"
  git ls-remote --heads "${ZENFLOW_STATE_REPO}" "$(_state_branch "${project_key}" "${story_id}")" | grep -q .
}

# Creates a new state branch for the given story with an initial state.json.
# Exits non-zero if the branch already exists.
state_init() {
  local project_key="$1" story_id="$2"
  local branch tmpdir now

  branch=$(_state_branch "${project_key}" "${story_id}")
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  tmpdir=$(mktemp -d)

  git clone --depth 1 "${ZENFLOW_STATE_REPO}" "${tmpdir}" 2>/dev/null
  git -C "${tmpdir}" checkout --orphan "${branch}"
  git -C "${tmpdir}" rm -rf . --quiet 2>/dev/null || true

  cat > "${tmpdir}/state.json" <<JSON
{
  "story_id": "${story_id}",
  "project_key": "${project_key}",
  "stage": "story-start",
  "target_branch": "main",
  "feature_branch": null,
  "pr_url": null,
  "approved_plan": false,
  "assigned_to": null,
  "created_at": "${now}",
  "updated_at": "${now}"
}
JSON

  git -C "${tmpdir}" add state.json
  git -C "${tmpdir}" commit -m "init: ${story_id}"
  git -C "${tmpdir}" push origin "${branch}"
  rm -rf "${tmpdir}"
}

# Prints state.json contents to stdout.
state_read() {
  local project_key="$1" story_id="$2"
  local branch tmpdir result

  branch=$(_state_branch "${project_key}" "${story_id}")
  tmpdir=$(mktemp -d)

  git clone --depth 1 --branch "${branch}" --single-branch "${ZENFLOW_STATE_REPO}" "${tmpdir}" 2>/dev/null
  result=$(cat "${tmpdir}/state.json")
  rm -rf "${tmpdir}"
  echo "${result}"
}

# Merges a JSON patch into state.json and pushes.
# json_patch example: '{"stage":"story-plan","feature_branch":"zenflow/PROJ-123-add-login"}'
state_write() {
  local project_key="$1" story_id="$2" json_patch="$3"
  local branch tmpdir now updated stage

  branch=$(_state_branch "${project_key}" "${story_id}")
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  tmpdir=$(mktemp -d)

  git clone --depth 1 --branch "${branch}" --single-branch "${ZENFLOW_STATE_REPO}" "${tmpdir}" 2>/dev/null
  updated=$(jq --arg now "${now}" ". * ${json_patch} | .updated_at = \$now" "${tmpdir}/state.json")
  stage=$(echo "${updated}" | jq -r '.stage')
  echo "${updated}" > "${tmpdir}/state.json"

  git -C "${tmpdir}" add state.json
  git -C "${tmpdir}" commit -m "update: ${story_id} → ${stage}"
  git -C "${tmpdir}" push origin "${branch}"
  rm -rf "${tmpdir}"
}

# Writes plan.md to the state branch and pushes.
state_write_plan() {
  local project_key="$1" story_id="$2" content="$3"
  local branch tmpdir

  branch=$(_state_branch "${project_key}" "${story_id}")
  tmpdir=$(mktemp -d)

  git clone --depth 1 --branch "${branch}" --single-branch "${ZENFLOW_STATE_REPO}" "${tmpdir}" 2>/dev/null
  printf '%s' "${content}" > "${tmpdir}/plan.md"

  git -C "${tmpdir}" add plan.md
  git -C "${tmpdir}" commit -m "plan: ${story_id}"
  git -C "${tmpdir}" push origin "${branch}"
  rm -rf "${tmpdir}"
}

# Prints plan.md contents to stdout.
state_read_plan() {
  local project_key="$1" story_id="$2"
  local branch tmpdir result

  branch=$(_state_branch "${project_key}" "${story_id}")
  tmpdir=$(mktemp -d)

  git clone --depth 1 --branch "${branch}" --single-branch "${ZENFLOW_STATE_REPO}" "${tmpdir}" 2>/dev/null
  result=$(cat "${tmpdir}/plan.md")
  rm -rf "${tmpdir}"
  echo "${result}"
}
