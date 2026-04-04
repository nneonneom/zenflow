#!/usr/bin/env bash
# Zenflow State Store — local filesystem adapter
# Sourced by zenflow-store-state.sh. Never invoke directly.
# Requires: jq.
#
# State is stored in ~/.zenflow/{story_id}/ on the current machine.
# Cross-machine resume and team handoff are not available with this adapter.

_ZENFLOW_LOCAL_DIR="${HOME}/.zenflow"

# Returns 0 if story state exists locally, 1 if not.
state_branch_exists() {
  local story_id="$1"
  [[ -f "${_ZENFLOW_LOCAL_DIR}/${story_id}/state.json" ]] && return 0 || return 1
}

# Creates initial state for a story.
state_init() {
  local project_key="$1" story_id="$2"
  local now story_dir

  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  story_dir="${_ZENFLOW_LOCAL_DIR}/${story_id}"

  mkdir -p "${story_dir}"
  cat > "${story_dir}/state.json" <<JSON
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
}

# Prints state.json contents to stdout.
state_read() {
  local story_id="$1"
  cat "${_ZENFLOW_LOCAL_DIR}/${story_id}/state.json"
}

# Merges a JSON patch into state.json.
# json_patch example: '{"stage":"story-plan","feature_branch":"zenflow/PROJ-123-add-login"}'
state_write() {
  local story_id="$1" json_patch="$2"
  local now state_file updated

  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  state_file="${_ZENFLOW_LOCAL_DIR}/${story_id}/state.json"
  updated=$(jq --arg now "${now}" ". * ${json_patch} | .updated_at = \$now" "${state_file}")
  echo "${updated}" > "${state_file}"
}

# Writes plan.md, status.md, and optionally slices/ to the story folder.
# state_write_plan <story_id> <plan_content> <status_content> [<slice_files_dir>]
state_write_plan() {
  local story_id="$1" plan_content="$2" status_content="$3" slice_files_dir="${4:-}"
  local story_dir

  story_dir="${_ZENFLOW_LOCAL_DIR}/${story_id}"
  mkdir -p "${story_dir}"
  printf '%s' "${plan_content}" > "${story_dir}/plan.md"
  printf '%s' "${status_content}" > "${story_dir}/status.md"

  if [[ -n "${slice_files_dir}" && -d "${slice_files_dir}" ]]; then
    mkdir -p "${story_dir}/slices"
    cp "${slice_files_dir}"/* "${story_dir}/slices/"
  fi
}

# Prints plan.md contents to stdout.
state_read_plan() {
  local story_id="$1"
  cat "${_ZENFLOW_LOCAL_DIR}/${story_id}/plan.md"
}
