---
name: story-start
description: >
  Stage command for zen-story. Fetches a Jira story (mocked in Slice 2),
  checks for existing state, initializes state.json, and returns story context
  to the caller. Called by zen-story — not invoked directly by the user.
disable-model-invocation: true
---

# story-start

Stage command called by `zen-story`. Fetches the target story, initializes
workflow state, and outputs story context for the next stage.

> **Note (Slice 2):** Jira fetch is mocked via `scripts/mock-jira-story.sh`.
> Real Jira integration is wired in Slice 6.

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `story_id` | Argument passed by `zen-story` (e.g. `PROJ-123`) | No — if absent, present selection list |

---

## Steps

### 1 — Resolve story ID

If `story_id` was provided, use it directly. Skip to Step 2.

If no `story_id` was provided, fetch the mock assigned-story list:

```bash
bash scripts/mock-jira-story.sh --list
```

Present the returned stories to the user as a numbered list and ask them to
select one. Use the selected story's ID as `story_id` for all subsequent steps.

---

### 2 — Fetch story details

```bash
bash scripts/mock-jira-story.sh "$story_id"
```

The script prints a JSON object to stdout:

```json
{
  "id": "PROJ-123",
  "project_key": "PROJ",
  "title": "Add login page",
  "description": "Implement a login page with email and password fields.",
  "status": "To Do",
  "assignee": "dev@example.com"
}
```

Parse `project_key` from this output (field `project_key`).

---

### 3 — Check for existing state

Source the State Store:

```bash
source scripts/zenflow-store-state.sh
state_branch_exists "$story_id"
```

If state exists (exit code 0):

Present this message and stop — do not initialize state:

```
Existing workflow state found for $story_id.

  Run /zen-resume $story_id to continue from where you left off.
  Or reply "reset" to discard the existing state and start fresh.
```

If the user replies `reset`, continue to Step 4.
If the user runs `/zen-resume`, exit cleanly.

---

### 4 — Initialize state

```bash
state_init "$project_key" "$story_id"
```

This creates `~/.zenflow/$story_id/state.json` with `stage: "planning"` and
all other fields at their defaults (see `docs/state-schema.md`).

---

### 5 — Confirm and return context

Print a short confirmation:

```
Story started: $story_id — $title

  Stage       : planning
  State       : ~/.zenflow/$story_id/state.json
  Jira        : mocked (real adapter in Slice 6)

Passing context to story-plan…
```

Return the following context to `zen-story` for handoff to `story-plan`:

```
story_id:      $story_id
project_key:   $project_key
title:         $title
description:   $description
target_branch: main
```
