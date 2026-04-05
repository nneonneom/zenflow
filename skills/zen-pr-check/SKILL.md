---
name: zen-pr-check
description: >
  User-invoked manual PR check. Shows PR status and review comments for a
  story, and offers to address changes requested interactively.
---

# zen-pr-check

Check the current PR status for a story on demand.

---

## Usage

```
/zen-pr-check [story_id]
```

---

## Steps

### 1 — Resolve story ID

If no `story_id` provided, list all stories where `stage == "review"`:

```bash
source scripts/zenflow-store-state.sh
```

Scan `~/.zenflow/` for stories in review and present a numbered list.

---

### 2 — Fetch PR status and comments

```bash
source scripts/repo-adapter.sh
pr_url=$(state_read "$story_id" | jq -r '.pr_url')
pr_status=$(repo_get_pr_status "$pr_url")
comments=$(repo_get_pr_comments "$pr_url")
```

---

### 3 — Print summary

```
PR Status: $story_id

  PR          : $pr_url
  State       : $state
  Review      : $reviewDecision
  Comments    : $comment_count

  Review comments:
    - @reviewer: "..."
    - @reviewer: "..."
```

---

### 4 — Offer to address changes (if applicable)

If `reviewDecision == "CHANGES_REQUESTED"`:

```
There are review comments. Address them now? [y/n]
```

On yes: invoke `story-implement` with the review comments as context.
Claude addresses the comments and pushes new commits. The PR updates automatically.
