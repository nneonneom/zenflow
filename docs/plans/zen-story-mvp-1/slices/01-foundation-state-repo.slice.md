# Slice 1 — Foundation: State Store Setup

[← Plan](../PLAN.md) | [Slice 2: `story-start` Mocked →](02-story-start-mocked.slice.md)

**Depends on:** —
**Modules:** State Store
**Status:** Complete

> **Architecture note (amended):** State Store is an adapter-pattern interface. `zenflow-store-state.sh` sources the adapter selected by `ZENFLOW_STATE_ADAPTER` (default: `local`). The local adapter writes to `~/.zenflow/{story-id}/` — no git repo, no orphan branch, no `ZENFLOW_STATE_REPO` env var needed. The API adapter (future) will call a DynamoDB+S3 service and is stubbed at `scripts/state-adapter-api.sh`. The original orphan-branch implementation was replaced during amendment to support `zen-epic` workflows that have no associated git repo.

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-setup/SKILL.md` | One-time setup wizard — user-facing |
| `scripts/zenflow-store-state.sh` | State Store adapter router — sources the correct adapter based on `ZENFLOW_STATE_ADAPTER`; never invoke directly |
| `scripts/state-adapter-local.sh` | Local filesystem adapter — writes to `~/.zenflow/{story-id}/`; default adapter |
| `scripts/state-adapter-api.sh` | API adapter stub — not yet implemented; swap in when DynamoDB+S3 service is ready |
| `docs/state-schema.md` | `state.json` schema reference |

---

### `state.json` Schema

```json
{
  "story_id": "PROJ-123",
  "project_key": "PROJ",
  "stage": "story-start | story-plan | story-implement | story-create-pr | complete",
  "target_branch": "main",
  "feature_branch": "zenflow/PROJ-123-concise-description",
  "pr_url": null,
  "approved_plan": false,
  "current_slice": null,
  "total_slices": null,
  "assigned_to": "user@example.com",
  "created_at": "2026-04-03T00:00:00Z",
  "updated_at": "2026-04-03T00:00:00Z"
}
```

---

### `state.sh` Functions

| Function | Signature | Does |
|---|---|---|
| `state_init` | `state_init <project_key> <story_id>` | Creates `{story_id}/state.json` via the configured adapter |
| `state_read` | `state_read <story_id>` | Prints `{story_id}/state.json` to stdout |
| `state_write` | `state_write <story_id> <json_patch>` | Merges patch into `state.json`, updates `updated_at` |
| `state_write_plan` | `state_write_plan <story_id> <plan_content> <status_content> [<slice_files_dir>]` | Writes `plan.md`, `status.md`, and `slices/` to `{story_id}/` |
| `state_read_plan` | `state_read_plan <story_id>` | Prints `{story_id}/plan.md` to stdout |
| `state_branch_exists` | `state_branch_exists <story_id>` | Returns 0 if `{story_id}/state.json` exists, 1 if not |

All functions are implemented per-adapter. The local adapter stores state in `~/.zenflow/{story_id}/`. No function touches working tree files or requires a git repo.

---

### Required Env Vars (`.claude/settings.json`)

| Var | Description |
|---|---|
| `JIRA_BASE_URL` | e.g. `https://yourcompany.atlassian.net` |
| `JIRA_EMAIL` | Atlassian account email |
| `JIRA_API_TOKEN` | Atlassian API token (used by `jira-cli` and REST API) |
| `TEAMS_WEBHOOK_URL` | Teams incoming webhook URL *(TBD — leave blank until Slice 8)* |
| `ZENFLOW_STATE_ADAPTER` | `local` (default) or `api` *(API adapter not yet implemented)* |

`GITHUB_TOKEN` is not needed — `gh` CLI handles auth via `gh auth login`.

---

### `zen-setup` Skill Behavior

One-time global credential setup — not per project. Per-project state is
created automatically on first `state_init` call.

1. Check Jira env vars (`JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`) — prompt and write any missing ones via `scripts/claude-set-env.sh`
2. Verify `gh` is installed and authenticated (`gh auth status`)
3. Check `TEAMS_WEBHOOK_URL` — inform user it is optional until Slice 8
4. Confirm setup is complete

---

### Error Cases

| Error | Handling |
|---|---|
| Missing env var | `zen-setup` prompts for value and writes it |
| `gh` not installed | Exit with install instructions |
| Unknown `ZENFLOW_STATE_ADAPTER` value | `zenflow-store-state.sh` exits with clear message listing valid values |
| `~/.zenflow/` not writable (local adapter) | `state_init` exits with permission error |
| Story state already exists on `state_init` | Prompt: resume existing or abort *(not implemented — deferred)* |

---

## Acceptance Criteria

- [ ] `zen-setup` completes without error on a fresh machine with valid credentials
- [ ] `zen-setup` prompts for and writes any missing Jira env vars
- [ ] `state_init` creates `~/.zenflow/{story_id}/state.json` with a valid schema
- [ ] `state_read` returns parseable JSON from an existing branch
- [ ] `state_write` merges a patch, commits, and pushes — `updated_at` is updated
- [ ] `state_write_plan` writes `plan.md`, `status.md`, and `slices/` to the branch and pushes
- [ ] `state_branch_exists` correctly returns 0/1 without side effects
- [ ] All required env vars are documented in `docs/state-schema.md`
