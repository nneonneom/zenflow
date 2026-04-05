---
name: zen-resume
description: >
  Reads saved workflow state for a story and re-invokes zen-story from the
  correct stage. User-invoked. Requires the story to have been started on
  this machine (local adapter).
---

# zen-resume

Resumes a paused workflow from where it left off.

---

## Usage

```
/zen-resume <story_id>
```

---

## Steps

### 1 — Verify state exists

```bash
source scripts/zenflow-store-state.sh
state_branch_exists "$story_id"
```

If not found:

```
No workflow state found for $story_id on this machine.

Run /zen-story $story_id to start a new workflow.
```

Exit.

---

### 2 — Read state and determine resume point

```bash
state_json=$(state_read "$story_id")
stage=$(echo "$state_json" | jq -r '.stage')
approved_plan=$(echo "$state_json" | jq -r '.approved_plan')
current_slice=$(echo "$state_json" | jq -r '.current_slice')
```

| `stage` | `approved_plan` | Resume at |
|---|---|---|
| `planning` | `false` | `story-plan` (plan not yet approved) |
| `planning` | `true` | Branch creation (plan approved, branch not yet created) |
| `development` | `true` | `story-implement` at `current_slice` |
| `review` | any | Print PR URL + check instructions; exit |
| `complete` | any | Print done message; exit |

---

### 3 — Resume

For `planning`/`development` stages, follow the `zen-story` skill from the
identified resume point, restoring context from `state.json` and the State
Store plan files.

For `review`:

```
PR is open and awaiting review.

  Story  : $story_id
  PR     : $pr_url

Run /zen-pr-check $story_id to check PR status.
```

For `complete`:

```
Workflow already complete for $story_id.

  PR     : $pr_url
  Stage  : complete
```
