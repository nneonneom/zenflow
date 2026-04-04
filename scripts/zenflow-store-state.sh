#!/usr/bin/env bash
# Zenflow State Store
# Source this file to use state_* functions.
# Requires: git, jq. Must be sourced from within the zenflow project repo.
#
# State is stored on a single orphan branch ("zenflow-state") in the working
# repo, with one subfolder per story: {story-id}/state.json, plan.md, etc.
# No separate repo or env vars required — the working repo's origin is used.

set -euo pipefail

_ZENFLOW_STATE_BRANCH="zenflow-state"

# Guard: must be sourced from within a git repo that has a remote named origin.
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Zenflow error: not inside a git repository. Navigate to your project directory first." >&2
  return 1
fi
if ! git remote get-url origin &>/dev/null; then
  echo "Zenflow error: no 'origin' remote found. Make sure you're in the correct project." >&2
  return 1
fi

_zenflow_repo_url() {
  git remote get-url origin
}

# Returns 0 if story state exists on the zenflow-state branch, 1 if not.
state_branch_exists() {
  local story_id="$1"
  local tmpdir exists

  git ls-remote --heads "$(_zenflow_repo_url)" "${_ZENFLOW_STATE_BRANCH}" | grep -q . || return 1

  tmpdir=$(mktemp -d)
  git clone --depth 1 --branch "${_ZENFLOW_STATE_BRANCH}" --single-branch "$(_zenflow_repo_url)" "${tmpdir}" 2>/dev/null
  exists=1
  [[ -f "${tmpdir}/${story_id}/state.json" ]] && exists=0
  rm -rf "${tmpdir}"
  return ${exists}
}

# Creates initial state for a story in the zenflow-state branch.
# Creates the zenflow-state branch as an orphan if it doesn't exist yet.
state_init() {
  local project_key="$1" story_id="$2"
  local now tmpdir repo_url

  repo_url=$(_zenflow_repo_url)
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  tmpdir=$(mktemp -d)

  if git ls-remote --heads "${repo_url}" "${_ZENFLOW_STATE_BRANCH}" | grep -q .; then
    git clone --depth 1 --branch "${_ZENFLOW_STATE_BRANCH}" --single-branch "${repo_url}" "${tmpdir}" 2>/dev/null
  else
    git clone --depth 1 "${repo_url}" "${tmpdir}" 2>/dev/null
    git -C "${tmpdir}" checkout --orphan "${_ZENFLOW_STATE_BRANCH}"
    git -C "${tmpdir}" rm -rf . --quiet 2>/dev/null || true
  fi

  mkdir -p "${tmpdir}/${story_id}"
  cat > "${tmpdir}/${story_id}/state.json" <<JSON
{
  "story_id": "${story_id}",
  "project_key": "${project_key}",
  "stage": "story-start",
  "target_branch": "main",
  "feature_branch": null,
  "pr_url": null,
  "approved_plan": false,
  "current_slice": null,
  "total_slices": null,
  "assigned_to": null,
  "created_at": "${now}",
  "updated_at": "${now}"
}
JSON

  git -C "${tmpdir}" add "${story_id}/state.json"
  git -C "${tmpdir}" commit -m "init: ${story_id}"
  git -C "${tmpdir}" push origin "${_ZENFLOW_STATE_BRANCH}"
  rm -rf "${tmpdir}"
}

# Prints state.json contents to stdout.
state_read() {
  local story_id="$1"
  local tmpdir result

  tmpdir=$(mktemp -d)
  git clone --depth 1 --branch "${_ZENFLOW_STATE_BRANCH}" --single-branch "$(_zenflow_repo_url)" "${tmpdir}" 2>/dev/null
  result=$(cat "${tmpdir}/${story_id}/state.json")
  rm -rf "${tmpdir}"
  echo "${result}"
}

# Merges a JSON patch into state.json and pushes.
# json_patch example: '{"stage":"story-plan","feature_branch":"zenflow/PROJ-123-add-login"}'
state_write() {
  local story_id="$1" json_patch="$2"
  local tmpdir now updated stage

  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  tmpdir=$(mktemp -d)

  git clone --depth 1 --branch "${_ZENFLOW_STATE_BRANCH}" --single-branch "$(_zenflow_repo_url)" "${tmpdir}" 2>/dev/null
  updated=$(jq --arg now "${now}" ". * ${json_patch} | .updated_at = \$now" "${tmpdir}/${story_id}/state.json")
  stage=$(echo "${updated}" | jq -r '.stage')
  echo "${updated}" > "${tmpdir}/${story_id}/state.json"

  git -C "${tmpdir}" add "${story_id}/state.json"
  git -C "${tmpdir}" commit -m "update: ${story_id} → ${stage}"
  git -C "${tmpdir}" push origin "${_ZENFLOW_STATE_BRANCH}"
  rm -rf "${tmpdir}"
}

# Writes plan.md, status.md, and optionally slices/ to the story folder and pushes.
# state_write_plan <story_id> <plan_content> <status_content> [<slice_files_dir>]
state_write_plan() {
  local story_id="$1" plan_content="$2" status_content="$3" slice_files_dir="${4:-}"
  local tmpdir

  tmpdir=$(mktemp -d)
  git clone --depth 1 --branch "${_ZENFLOW_STATE_BRANCH}" --single-branch "$(_zenflow_repo_url)" "${tmpdir}" 2>/dev/null
  printf '%s' "${plan_content}" > "${tmpdir}/${story_id}/plan.md"
  printf '%s' "${status_content}" > "${tmpdir}/${story_id}/status.md"

  if [[ -n "${slice_files_dir}" && -d "${slice_files_dir}" ]]; then
    mkdir -p "${tmpdir}/${story_id}/slices"
    cp "${slice_files_dir}"/* "${tmpdir}/${story_id}/slices/"
  fi

  git -C "${tmpdir}" add "${story_id}/"
  git -C "${tmpdir}" commit -m "plan: ${story_id}"
  git -C "${tmpdir}" push origin "${_ZENFLOW_STATE_BRANCH}"
  rm -rf "${tmpdir}"
}

# Prints plan.md contents to stdout.
state_read_plan() {
  local story_id="$1"
  local tmpdir result

  tmpdir=$(mktemp -d)
  git clone --depth 1 --branch "${_ZENFLOW_STATE_BRANCH}" --single-branch "$(_zenflow_repo_url)" "${tmpdir}" 2>/dev/null
  result=$(cat "${tmpdir}/${story_id}/plan.md")
  rm -rf "${tmpdir}"
  echo "${result}"
}
