# Slice 3 — `story-plan` with Mocked Planning Core

[← Plan](../PLAN.md) | [← Slice 2: `story-start` Mocked](02-story-start-mocked.slice.md) | [Slice 4: `story-implement` Mocked →](04-story-implement-mocked.slice.md)

**Depends on:** Slice 2
**Modules:** Commands / Workflows, Planning Core, State Store
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/story-plan/SKILL.md` | Stage command skill — clarifying questions, plan approval, State Store writes |
| `scripts/mock-planning-core.sh` | Mock plan generator — writes plan.md, status.md, slices/ to a temp dir and prints its path |

---

### `mock-planning-core.sh` Interface

```bash
bash scripts/mock-planning-core.sh <story_id> [target_branch]
# Prints /tmp/zenflow-plan-<story_id>/ to stdout
```

Output directory structure:

```
/tmp/zenflow-plan-<story_id>/
  plan.md
  status.md
  slices/
    01-project-structure.slice.md
    02-core-logic.slice.md
    03-tests.slice.md
```

The mock always generates 3 slices. Real Planning Core (Slice 7) generates
slices appropriate to the story.

---

### `story-plan` Behavior

1. Read story context from caller (story_id, title, description, target_branch)
2. If description is thin: ask at most 2 clarifying questions; otherwise skip
3. Confirm target PR branch (default: `main`)
4. Call `mock-planning-core.sh <story_id> <target_branch>` → capture temp dir path
5. Present `plan.md` content to user; accept edits and re-present until user replies `approve`
6. Call `state_write_plan` with plan.md, status.md, and slices/ from the temp dir
7. Call `state_write` to set `approved_plan: true`, `current_slice: 1`, `total_slices: N`
8. Print confirmation and return context to `zen-story`

---

### State Writes

After approval, the following are persisted via the State Store:

| What | How |
|---|---|
| `~/.zenflow/$story_id/plan.md` | `state_write_plan` — plan.md content |
| `~/.zenflow/$story_id/status.md` | `state_write_plan` — status.md content |
| `~/.zenflow/$story_id/slices/` | `state_write_plan` — slices/ directory |
| `state.json` patch | `state_write` — `approved_plan: true`, `current_slice: 1`, `total_slices: N` |

---

### Reuse from Prior Slices

- `scripts/zenflow-store-state.sh` — sourced as-is; `state_write_plan` and `state_write` used directly
- `state.json` schema from `docs/state-schema.md` — `approved_plan`, `current_slice`, `total_slices` fields

---

### Error Cases

| Error | Handling |
|---|---|
| `mock-planning-core.sh` fails | Skill exits with error message; state is not written |
| User never replies `approve` | Loop continues until approval; user can abandon by ending the session |
| `state_write_plan` fails | Error propagates from adapter; skill exits with message |
| `state_write` fails after `state_write_plan` succeeds | State is partially written — plan files exist but state.json not updated; surface error clearly |

---

## Acceptance Criteria

- [ ] `story-plan` presents the mock plan to the user for review before writing anything
- [ ] User can request changes to the plan and see a revised version before approving
- [ ] Replying `approve` triggers State Store writes
- [ ] `~/.zenflow/$story_id/plan.md` exists and contains the approved plan content
- [ ] `~/.zenflow/$story_id/status.md` exists and lists slices with `⬜ Not started` status
- [ ] `~/.zenflow/$story_id/slices/` contains one file per slice
- [ ] `state.json` has `approved_plan: true`, `current_slice: 1`, `total_slices: 3`
- [ ] `state.json` `updated_at` is refreshed after the write
- [ ] Confirmation output shows story ID, slice count, and state path
- [ ] Story context (story_id, project_key, title, target_branch, total_slices) is present in output for handoff
