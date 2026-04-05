---
name: story-create-pr
description: >
  Stage command for zen-story. Generates a PR description from the story plan,
  creates the PR via the repo adapter, writes the PR URL to state.json, and
  returns the URL to zen-story. Called by zen-story — not invoked directly.
disable-model-invocation: true
---

# story-create-pr

Stage command called by `zen-story`. Creates the GitHub PR and writes the URL
to state.

> **Note (Slice 5):** Uses `scripts/mock-repo-adapter.sh`. Real `gh` CLI wired in Slice 10.

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `story_id` | Passed by `zen-story` | Yes |
| `title` | Passed by `zen-story` | Yes |
| `target_branch` | Passed by `zen-story` | Yes |

---

## Steps

### 1 — Load context from state

```bash
source scripts/zenflow-store-state.sh
state_json=$(state_read "$story_id")
feature_branch=$(echo "$state_json" | jq -r '.feature_branch')
plan_content=$(state_read_plan "$story_id")
```

---

### 2 — Generate PR description

Read `plan.md` from the State Store. Summarize the implementation into a PR
description with the following sections:

```markdown
## Summary
<1-3 sentence summary of what this PR does>

## Implementation Notes
<key decisions or non-obvious choices from the plan>

## Testing
<how to verify the changes work>
```

Keep the description concise — the plan is the detailed record, not the PR.

---

### 3 — Create PR

```bash
bash scripts/mock-repo-adapter.sh --create-pr \
  "$story_id" \
  "$title" \
  "$feature_branch" \
  "$target_branch"
```

Capture the PR URL from stdout.

---

### 4 — Write PR URL to state

```bash
state_write "$story_id" "{\"pr_url\": \"${pr_url}\"}"
```

---

### 5 — Confirm and return

Print:

```
PR created.

  Story  : $story_id — $title
  Branch : $feature_branch → $target_branch
  PR     : $pr_url

Returning to zen-story…
```

Return `pr_url` to `zen-story`.
