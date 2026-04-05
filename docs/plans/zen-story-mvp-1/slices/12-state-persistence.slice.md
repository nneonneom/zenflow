# Slice 12 — State Persistence: `zen-pause` + `zen-resume`

[← Plan](../PLAN.md) | [← Slice 11: Full `zen-story` E2E](11-zen-story-e2e.slice.md) | [Slice 13: PR Monitor →](13-pr-monitor.slice.md)

**Depends on:** Slice 11
**Modules:** State Store, Commands / Workflows
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-pause/SKILL.md` | Checkpoints current state and tells user how to resume |
| `skills/zen-resume/SKILL.md` | Reads state and re-invokes `zen-story` from the correct stage |

---

### `zen-pause` Behavior

With the local adapter, state is already persisted after every `state_write`
call — there is nothing to flush. `zen-pause` is a UX checkpoint:

1. Source State Store; read `state.json` for `story_id`
2. Print a summary of current state (story_id, stage, current_slice, feature_branch)
3. Instruct the user how to resume:

```
Workflow paused.

  Story       : $story_id — $title
  Stage       : $stage
  Slice       : $current_slice / $total_slices
  Branch      : $feature_branch
  State       : ~/.zenflow/$story_id/state.json

To resume: /zen-resume $story_id
```

---

### `zen-resume` Behavior

```
/zen-resume <story_id>
```

1. Source State Store; call `state_branch_exists $story_id`
   — if not found: "No state found for $story_id. Run /zen-story $story_id to start fresh."
2. Read `state.json`: check `stage`
   - `planning` + `approved_plan: false` → resume at `story-plan`
   - `planning` + `approved_plan: true` → resume at branch creation (step 4 of `zen-story`)
   - `development` → resume at `story-implement` at `current_slice`
   - `review` → "PR is open at $pr_url — use /zen-pr-check $story_id to check status"
   - `complete` → "Workflow already complete for $story_id"
3. Resume `zen-story` from the correct step, passing restored context

---

### Cross-Machine Resume

Not available with the local adapter. State lives in `~/.zenflow/` on one
machine. Cross-machine resume requires `ZENFLOW_STATE_ADAPTER=api` — deferred
until the API adapter is built.

---

## Acceptance Criteria

- [ ] `/zen-pause` prints a clear state summary with resume instructions
- [ ] `/zen-resume PROJ-123` reads state and resumes at the correct stage
- [ ] Resume at `story-plan` re-presents the plan approval flow
- [ ] Resume at `story-implement` resumes from `current_slice`, not slice 1
- [ ] Resume when `stage: review` prints PR URL and check instructions instead of re-running
- [ ] Resume when `stage: complete` prints a done message and exits cleanly
- [ ] Resume with unknown story_id prints a clear error and exits
