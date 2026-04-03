# Slice 1 — Foundation: `zenflow-state` Repo Setup

[← Plan](../PLAN.md) | [Slice 2: `story-start` Mocked →](02-story-start-mocked.slice.md)

**Depends on:** —
**Modules:** State Store
**Status:** Ready to build

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-setup/SKILL.md` | One-time setup wizard — user-facing |
| `.claude/scripts/state.sh` | State Store helper — internal, never invoked directly |
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
| `state_init` | `state_init <project_key> <story_id>` | Creates branch `{project_key}/{story_id}` in state repo, writes initial `state.json` |
| `state_read` | `state_read <project_key> <story_id>` | Pulls branch, prints `state.json` to stdout |
| `state_write` | `state_write <project_key> <story_id> <json_patch>` | Merges patch into `state.json`, commits, pushes |
| `state_write_plan` | `state_write_plan <project_key> <story_id> <plan_content> <status_content> [<slice_files_dir>]` | Writes `plan.md`, `status.md`, and `slices/` to branch, commits, pushes |
| `state_branch_exists` | `state_branch_exists <project_key> <story_id>` | Returns 0 if branch exists, 1 if not |

All functions read `ZENFLOW_STATE_REPO` from env. No function touches project repo files.

---

### Required Env Vars (`.claude/settings.json`)

| Var | Description |
|---|---|
| `ZENFLOW_STATE_REPO` | SSH or HTTPS URL of the `zenflow-state` repo |
| `JIRA_BASE_URL` | e.g. `https://yourcompany.atlassian.net` |
| `JIRA_EMAIL` | Atlassian account email |
| `JIRA_API_TOKEN` | Atlassian API token (used by `jira-cli` and REST API) |
| `TEAMS_WEBHOOK_URL` | Teams incoming webhook URL *(TBD — leave blank until Slice 8)* |

`GITHUB_TOKEN` is not needed — `gh` CLI handles auth via `gh auth login`.

---

### `zen-setup` Skill Behavior

1. Check all required env vars are set in `.claude/settings.json` — list any missing ones
2. Verify `gh` is installed and authenticated (`gh auth status`)
3. Check if `ZENFLOW_STATE_REPO` exists and is accessible — if not, offer to create it via `gh repo create`
4. Clone state repo to a temp directory, verify read/write access, clean up
5. Confirm setup is complete

---

### Error Cases

| Error | Handling |
|---|---|
| Missing env var | `zen-setup` lists all missing vars and exits with instructions |
| `gh` not installed | Exit with install instructions |
| State repo unreachable | Offer to create it or re-check credentials |
| Branch already exists on `state_init` | Prompt: resume existing or abort |

---

## Acceptance Criteria

- [ ] `zen-setup` completes without error on a fresh machine with valid credentials
- [ ] `zen-setup` lists missing env vars clearly if any are absent
- [ ] `state_init` creates a branch in `zenflow-state` with a valid `state.json`
- [ ] `state_read` returns parseable JSON from an existing branch
- [ ] `state_write` merges a patch, commits, and pushes — `updated_at` is updated
- [ ] `state_write_plan` writes `plan.md`, `status.md`, and `slices/` to the branch and pushes
- [ ] `state_branch_exists` correctly returns 0/1 without side effects
- [ ] All required env vars are documented in `docs/state-schema.md`
