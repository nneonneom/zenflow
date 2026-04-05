---
name: zen-story
description: >
  Main orchestrator for the story implementation workflow. Calls stage commands
  in sequence: story-start → story-plan → branch creation → story-implement →
  story-create-pr → PR Monitor handoff. User-invoked from inside a project repo.
---

# zen-story

Orchestrates the full story implementation workflow from a Jira story to a
merged PR. Must be run from inside the project repo — it uses `git` for branch
and PR operations.

> **Note (Slice 5):** All adapters are mocked. Real adapters wired in Slice 10.

---

## Usage

```
/zen-story [story_id]
```

`story_id` is optional. If omitted, `story-start` will present a list of
assigned stories to choose from.

---

## Steps

### 1 — Check for existing state

```bash
source scripts/zenflow-store-state.sh
state_branch_exists "$story_id"   # skip if story_id not yet known
```

If state exists for the given story ID:

```
Existing workflow state found for $story_id.

  Run /zen-resume $story_id to continue from where you left off.
  Or run /zen-reset $story_id to discard existing state and start fresh.
```

Exit. Do not proceed.

If no story ID was provided and no existing state check is possible, skip this
step — `story-start` handles the case where state already exists after the
user selects a story.

---

### 2 — story-start

Follow all steps in `skills/story-start/SKILL.md`.

Capture the returned context:
- `story_id`, `project_key`, `title`, `description`, `target_branch`

---

### 3 — story-plan

Follow all steps in `skills/story-plan/SKILL.md`, passing the story context
from Step 2.

Capture the returned context:
- `story_id`, `project_key`, `title`, `target_branch`, `total_slices`

---

### 4 — Create feature branch

```bash
branch_name="zenflow/${story_id}-$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | cut -c1-50)"
bash scripts/mock-repo-adapter.sh --create-branch "$story_id" "$branch_name"
```

Write the branch name to state:

```bash
state_write "$story_id" "{\"feature_branch\": \"${branch_name}\"}"
```

---

### 5 — story-implement

Follow all steps in `skills/story-implement/SKILL.md`, passing `story_id`
and `total_slices`.

---

### 6 — story-create-pr

Follow all steps in `skills/story-create-pr/SKILL.md`, passing the story
context.

Capture the returned `pr_url`.

---

### 7 — Handoff to PR Monitor

Write final state:

```bash
state_write "$story_id" "{\"stage\": \"review\", \"pr_url\": \"${pr_url}\"}"
```

Print handoff summary:

```
Workflow handed off to PR Monitor.

  Story  : $story_id — $title
  Branch : $branch_name
  PR     : $pr_url
  Stage  : review

PR Monitor will check for review comments and approvals.
Run /zen-pr-check $story_id to check PR status manually.
```
