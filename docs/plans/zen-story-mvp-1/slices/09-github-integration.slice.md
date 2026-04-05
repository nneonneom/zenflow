# Slice 9 — Real GitHub Integration in Isolation

[← Plan](../PLAN.md) | [← Slice 8: Real Teams Adapter](08-teams-adapter.slice.md) | [Slice 10: Adapter Integration →](10-adapter-integration.slice.md)

**Depends on:** Slice 5
**Modules:** repo-adapter, Planning Core
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `scripts/repo-adapter.sh` | Real GitHub operations via `gh` CLI |

---

### Functions

| Function | Signature | Does |
|---|---|---|
| `repo_create_branch` | `repo_create_branch <branch_name> <base_branch>` | `git checkout -b`, push with `-u` |
| `repo_create_pr` | `repo_create_pr <title> <body> <head> <base>` | `gh pr create`, prints PR URL |
| `repo_get_pr_status` | `repo_get_pr_status <pr_url>` | Returns `{state, reviewDecision, reviews}` JSON |
| `repo_get_pr_comments` | `repo_get_pr_comments <pr_url>` | Returns array of CHANGES_REQUESTED review bodies |

---

### PR Description

`story-create-pr` calls Planning Core (Slice 7) to generate the PR body, then
passes it to `repo_create_pr`. No PR description logic lives in `repo-adapter.sh`.

---

### Prerequisites

- `gh auth login` must be run once — `zen-setup` validates this
- Must be run from inside the project repo (zen-story enforces this)

---

### Testing in Isolation

```bash
source scripts/repo-adapter.sh
repo_create_branch "zenflow/TEST-001-test-branch" "main"
repo_create_pr "Test PR" "Testing repo-adapter" "zenflow/TEST-001-test-branch" "main"
repo_get_pr_status "<pr_url>"
repo_get_pr_comments "<pr_url>"
```

---

## Acceptance Criteria

- [ ] `repo_create_branch` creates and pushes the branch; local git HEAD is on the new branch
- [ ] `repo_create_pr` creates the PR and returns a valid GitHub PR URL
- [ ] `repo_get_pr_status` returns correct state after PR is open
- [ ] `repo_get_pr_comments` returns CHANGES_REQUESTED reviews as JSON array
- [ ] All functions fail clearly (non-zero exit, message to stderr) if `gh` is unauthenticated
- [ ] Call site signatures match `mock-repo-adapter.sh` — no changes needed in `zen-story` or `story-create-pr`
