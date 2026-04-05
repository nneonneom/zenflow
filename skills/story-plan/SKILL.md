---
name: story-plan
description: >
  Stage command for zen-story. Generates a sliced implementation plan (mocked
  in Slice 3), presents it for user approval and refinement, then writes
  plan.md, status.md, and slices/ to the State Store and updates state.json.
  Called by zen-story — not invoked directly by the user.
disable-model-invocation: true
---

# story-plan

Stage command called by `zen-story`. Takes the story context from `story-start`,
generates a sliced implementation plan, gets user approval, and persists
everything to the State Store.

> **Note (Slice 3):** Plan generation is mocked via `scripts/mock-planning-core.sh`.
> Real Planning Core is wired in Slice 7.

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `story_id` | Passed by `zen-story` | Yes |
| `project_key` | Passed by `zen-story` | Yes |
| `title` | Passed by `zen-story` | Yes |
| `description` | Passed by `zen-story` | Yes |
| `target_branch` | Passed by `zen-story` | Yes (default: `main`) |

---

## Steps

### 1 — Clarifying questions *(if needed)*

Read the story `description`. If it is detailed enough to plan from, skip this
step entirely.

If the description is thin (missing acceptance criteria, unclear scope, or
ambiguous technology choices), ask at most 2 targeted questions before
proceeding. Do not ask more than 2 — make reasonable assumptions for anything
else and state them in the plan.

---

### 2 — Confirm target branch

Ask:

```
Target branch for the PR? [main]
```

Accept the default with Enter. Use whatever branch the user specifies.

---

### 3 — Generate mock plan

```bash
bash scripts/mock-planning-core.sh "$story_id" "$target_branch"
```

The script writes the following to a temp directory and prints the path to
stdout:

```
/tmp/zenflow-plan-$story_id/
  plan.md
  status.md
  slices/
    01-<slug>.slice.md
    02-<slug>.slice.md
    ...
```

Read the generated `plan.md` content.

---

### 4 — Present plan for approval

Print the full `plan.md` content to the user, then ask:

```
Does this plan look right? Reply "approve" to continue, or describe any changes.
```

If the user requests changes, edit the plan in place (update `plan.md` in the
temp directory) and re-present. Repeat until the user approves.

Changes to the plan do not require re-running `mock-planning-core.sh` — apply
them directly to the temp files.

---

### 5 — Persist to State Store

Source the State Store and write plan artifacts:

```bash
source scripts/zenflow-store-state.sh
state_write_plan "$story_id" \
  "$(cat /tmp/zenflow-plan-$story_id/plan.md)" \
  "$(cat /tmp/zenflow-plan-$story_id/status.md)" \
  "/tmp/zenflow-plan-$story_id/slices"
```

Then update state.json with approval and slice tracking:

```bash
total_slices=$(ls /tmp/zenflow-plan-$story_id/slices/ | wc -l | tr -d ' ')
state_write "$story_id" \
  "{\"approved_plan\": true, \"current_slice\": 1, \"total_slices\": ${total_slices}}"
```

---

### 6 — Confirm and return context

Print a short confirmation:

```
Plan approved and saved.

  Story       : $story_id — $title
  Slices      : $total_slices
  State       : ~/.zenflow/$story_id/
  Next        : feature branch creation → story-implement

Passing context to zen-story…
```

Return the following context to `zen-story` for handoff to branch creation:

```
story_id:      $story_id
project_key:   $project_key
title:         $title
target_branch: $target_branch
total_slices:  $total_slices
```
