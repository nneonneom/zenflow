# Slice 7 — Real Planning Core in Isolation

[← Plan](../PLAN.md) | [← Slice 6: Real Jira Adapter](06-jira-adapter.slice.md) | [Slice 8: Real Teams Adapter →](08-teams-adapter.slice.md)

**Depends on:** Slice 5
**Modules:** Planning Core
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/planning-core/SKILL.md` | Describes how Claude generates plans and PR descriptions — no script |

---

### Two Operations

**Generate Implementation Plan** (called by `story-plan`):
- Read story title + description
- Ask any clarifying questions needed (from `story-plan` skill, not here)
- Break work into ordered slices, each independently testable
- Write to `/tmp/zenflow-plan-$story_id/` — same directory structure as `mock-planning-core.sh`
- Print directory path to stdout so `story-plan` calls `state_write_plan` unchanged

**Generate PR Description** (called by `story-create-pr`):
- Read `plan.md` + story title
- Output markdown with Summary, Implementation Notes, Testing sections

---

### Slice Output Structure (per slice file)

```
## Goal
One sentence.

## Tasks
- [ ] task one
- [ ] task two

## Done when
Binary criterion — either passes or fails.
```

---

### Testing in Isolation

Manually run `story-plan` against a real story description and inspect:
- `/tmp/zenflow-plan-<story_id>/plan.md` — slice count and task quality
- `/tmp/zenflow-plan-<story_id>/slices/` — one file per slice, correct format

---

## Acceptance Criteria

- [ ] Plan output is written to `/tmp/zenflow-plan-$story_id/` with the same structure as `mock-planning-core.sh`
- [ ] Slice count reflects story complexity — not always 3
- [ ] Each slice file has a single goal, 3–6 tasks, and a binary done-when criterion
- [ ] PR description has Summary, Implementation Notes, and Testing sections
- [ ] `story-plan` and `story-create-pr` require no code changes when swapped from mock (interface identical)
