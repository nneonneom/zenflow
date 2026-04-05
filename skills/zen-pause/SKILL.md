---
name: zen-pause
description: >
  Checkpoints the current workflow state and tells the user how to resume.
  With the local adapter, state is already persisted — this is a UX
  confirmation step. User-invoked.
---

# zen-pause

Confirms that the current workflow state is saved and prints resume instructions.

> **Note:** With the local adapter (`ZENFLOW_STATE_ADAPTER=local`), state is
> written to disk after every `state_write` call. `zen-pause` does not need to
> flush anything — it confirms and summarizes.

---

## Steps

### 1 — Read current state

```bash
source scripts/zenflow-store-state.sh
```

Prompt the user: "Which story are you pausing? (story ID)"

Or, if invoked as `/zen-pause $story_id`, use the provided ID directly.

```bash
state_json=$(state_read "$story_id")
```

---

### 2 — Print state summary and resume instructions

```
Workflow paused.

  Story       : $story_id — $title
  Stage       : $stage
  Slice       : $current_slice / $total_slices
  Branch      : $feature_branch
  State file  : ~/.zenflow/$story_id/state.json

To resume from this machine: /zen-resume $story_id
Cross-machine resume: requires ZENFLOW_STATE_ADAPTER=api (not yet implemented)
```
