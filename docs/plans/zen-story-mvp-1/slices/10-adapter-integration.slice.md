# Slice 10 — Integrate Real Adapters into Stage Commands

[← Plan](../PLAN.md) | [← Slice 9: Real GitHub Integration](09-github-integration.slice.md) | [Slice 11: Full `zen-story` E2E →](11-zen-story-e2e.slice.md)

**Depends on:** Slices 6, 7, 8, 9
**Modules:** Commands / Workflows, all Adapters
**Status:** Not started

---

## Implementation Plan

### Files Changed

No new files — update existing stage command skills to source real adapters
instead of mocks. One stage at a time, validated before moving to the next.

| Stage command | Mock removed | Real adapter sourced | Also adds |
|---|---|---|---|
| `skills/story-start/SKILL.md` | `mock-jira-story.sh` | `issue-tracker-adapter.sh` | `jira_move_to_in_progress` call after state_init |
| `skills/story-plan/SKILL.md` | `mock-planning-core.sh` | `planning-core/SKILL.md` (Claude generates) | — |
| `skills/story-implement/SKILL.md` | `mock-teams-notifier.sh` | `notifier-adapter.sh` | — |
| `skills/story-create-pr/SKILL.md` | `mock-repo-adapter.sh` | `repo-adapter.sh` + `planning-core/SKILL.md` | Real PR description generation |
| `skills/zen-story/SKILL.md` | `mock-repo-adapter.sh` (branch creation) | `repo-adapter.sh` | — |

---

### Integration Order

Swap and validate one stage at a time — do not swap all four at once:

1. `story-start` — swap Jira mock; validate story fetch + state init
2. `story-plan` — swap Planning Core mock; validate real plan generation + approval flow
3. `story-implement` — swap Teams mock; validate notification delivery
4. `story-create-pr` + `zen-story` branch step — swap repo mock; validate branch + PR creation

Each stage is independently testable using the prior mocked stages for context.

---

### New Behavior in `story-start` (not in mock version)

After `state_init`, call `jira_move_to_in_progress`:

```bash
source scripts/issue-tracker-adapter.sh
jira_move_to_in_progress "$story_id"
```

This was deferred from Slice 6 because it requires `story-start` to be using
the real adapter.

---

## Acceptance Criteria

- [ ] `story-start` fetches real story from Jira and moves it to In Progress
- [ ] `story-plan` generates a real implementation plan via Planning Core (not mock)
- [ ] `story-implement` sends real Teams notifications via webhook
- [ ] `story-create-pr` creates a real GitHub PR with a generated description
- [ ] `zen-story` creates a real feature branch via `gh` CLI
- [ ] Each stage validated individually before the next swap
- [ ] No mock scripts are called after this slice is complete
