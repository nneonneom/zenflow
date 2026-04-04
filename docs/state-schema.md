# Zenflow State Schema

This document describes the state stored by the State Store and the
environment variables required by Zenflow adapters.

---

## Storage Layout

State is managed by the State Store adapter selected via `ZENFLOW_STATE_ADAPTER`
(default: `local`). The adapter is sourced by `scripts/zenflow-store-state.sh`.

### Local adapter (default)

State lives in `~/.zenflow/` on the current machine. No git repo or external
service required.

```
~/.zenflow/

  PROJ-123/
    state.json     — workflow state (see schema below)
    plan.md        — full implementation plan with slice backlog
    status.md      — current slice tracker
    slices/        — per-slice detail files (written by story-plan)

  PROJ-456/
    state.json
    ...
```

Each story or epic gets its own subfolder keyed by its Jira ID. No item's
files ever touch another's. The `~/.zenflow/` directory is created
automatically on the first `state_init` call.

> **Note:** The local adapter is machine-local. Cross-machine resume and team
> handoff are not available with this adapter — they require the API adapter.

### API adapter (future)

When `ZENFLOW_STATE_ADAPTER=api`, the State Store calls a DynamoDB+S3 service.
Structured state (`state.json`) goes to DynamoDB; documents (`plan.md`,
`status.md`, `slices/`) go to S3. Not yet implemented — see
`scripts/state-adapter-api.sh`.

---

## `state.json` Schema

```json
{
  "story_id":      "PROJ-123",
  "project_key":   "PROJ",
  "stage":         "story-start | story-plan | story-implement | story-create-pr | complete",
  "target_branch": "main",
  "feature_branch": "zenflow/PROJ-123-concise-description",
  "pr_url":        null,
  "approved_plan": false,
  "current_slice": null,
  "total_slices":  null,
  "assigned_to":   "user@example.com",
  "created_at":    "2026-04-03T00:00:00Z",
  "updated_at":    "2026-04-03T00:00:00Z"
}
```

| Field | Type | Description |
|---|---|---|
| `story_id` | string | Jira story ID (e.g. `PROJ-123`) |
| `project_key` | string | Jira project key (e.g. `PROJ`) |
| `stage` | string | Current workflow stage |
| `target_branch` | string | PR merge target (default: `main`) |
| `feature_branch` | string \| null | Feature branch name, set after branch creation |
| `pr_url` | string \| null | GitHub PR URL, set after PR creation |
| `approved_plan` | boolean | True once the user has approved the implementation plan |
| `current_slice` | integer \| null | 1-indexed current implementation slice |
| `total_slices` | integer \| null | Total number of implementation slices in the plan |
| `assigned_to` | string \| null | Email of the team member currently owning the workflow |
| `created_at` | ISO 8601 | Timestamp when state was initialized |
| `updated_at` | ISO 8601 | Timestamp of the last `state_write` call |

### Stage values

| Value | Meaning |
|---|---|
| `story-start` | Initial state — story fetched, state initialized |
| `story-plan` | Implementation plan being generated or awaiting approval |
| `story-implement` | Active implementation — slices being executed |
| `story-create-pr` | PR creation in progress |
| `complete` | PR approved, workflow finished |

---

## Required Env Vars

Set these in the `env` section of `~/.claude/settings.json` using
`scripts/claude-set-env.sh`. These are used by the Jira, Teams, and State
Store adapters.

| Var | Description | Required |
|---|---|---|
| `JIRA_BASE_URL` | Atlassian base URL (e.g. `https://yourcompany.atlassian.net`) | Yes |
| `JIRA_EMAIL` | Atlassian account email | Yes |
| `JIRA_API_TOKEN` | Atlassian API token — used by `jira-cli` and REST API fallback | Yes |
| `TEAMS_WEBHOOK_URL` | Microsoft Teams incoming webhook URL | No — leave blank until Slice 8 |
| `ZENFLOW_STATE_ADAPTER` | `local` (default) or `api` | No — defaults to `local` |

`GITHUB_TOKEN` is not needed — `gh` CLI handles GitHub auth via `gh auth login`.

---

## State Store Functions

Implemented per-adapter. Source `scripts/zenflow-store-state.sh` to use the
functions — never invoke it directly.

| Function | Signature | Does |
|---|---|---|
| `state_branch_exists` | `state_branch_exists <story_id>` | Returns 0 if `{story_id}/state.json` exists, 1 if not |
| `state_init` | `state_init <project_key> <story_id>` | Creates `{story_id}/state.json` via the configured adapter |
| `state_read` | `state_read <story_id>` | Prints `{story_id}/state.json` to stdout |
| `state_write` | `state_write <story_id> <json_patch>` | Merges patch into `state.json`, updates `updated_at` |
| `state_write_plan` | `state_write_plan <story_id> <plan_content> <status_content> [<slice_files_dir>]` | Writes `plan.md`, `status.md`, and optionally `slices/` to `{story_id}/` |
| `state_read_plan` | `state_read_plan <story_id>` | Prints `{story_id}/plan.md` to stdout |
