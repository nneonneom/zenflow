---
name: zen-reset
description: >
  Delete all local workflow state for a story. Requires typing the story ID
  to confirm. Does not close the GitHub PR or revert Jira status.
---

# zen-reset

Delete local workflow state for a story so it can be started fresh.

---

## Usage

```
/zen-reset <story_id>
```

---

## Steps

### 1 — Verify state exists

```bash
source scripts/zenflow-store-state.sh
state_branch_exists "$story_id"
```

If not found: "No local state found for $story_id." Exit.

---

### 2 — Read context for confirmation message

```bash
state_json=$(state_read "$story_id")
```

---

### 3 — Warn and confirm

```
⚠ This will permanently delete all local workflow state for $story_id.

  Story  : $story_id — $title
  Stage  : $stage
  PR     : $pr_url  ← this PR will NOT be closed

This cannot be undone. Type "$story_id" to confirm, or anything else to cancel.
```

Wait for user input. If the input does not exactly match `$story_id`, print
"Cancelled." and exit without deleting anything.

---

### 4 — Delete state

```bash
rm -rf "${HOME}/.zenflow/${story_id}"
```

---

### 5 — Confirm

```
State cleared for $story_id.

Run /zen-story $story_id to start a new workflow.
Note: The GitHub PR and Jira story status were not changed.
```
