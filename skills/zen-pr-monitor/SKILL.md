---
name: zen-pr-monitor
description: >
  Scheduled cron skill. Scans ~/.zenflow/ for stories in review, checks PR
  status via gh CLI, sends Teams notification on approval, and re-invokes
  zen-story to address review comments. Runs on a schedule — not user-invoked.
---

# zen-pr-monitor

Background PR monitor. Runs on a cron schedule to check active PRs and react
to review events.

---

## Steps

### 1 — Find stories in review

Scan `~/.zenflow/` for `state.json` files where `stage == "review"`:

```bash
source scripts/zenflow-store-state.sh
source scripts/repo-adapter.sh
source scripts/notifier-adapter.sh
```

For each story directory in `~/.zenflow/`:

```bash
state_json=$(state_read "$story_id")
stage=$(echo "$state_json" | jq -r '.stage')
[[ "$stage" != "review" ]] && continue
```

If no stories are in review, exit cleanly with no output.

---

### 2 — Check PR status

```bash
pr_url=$(echo "$state_json" | jq -r '.pr_url')
pr_status=$(repo_get_pr_status "$pr_url")
review_decision=$(echo "$pr_status" | jq -r '.reviewDecision')
```

---

### 3 — React to status

**If `APPROVED`:**

```bash
notify_teams "$story_id" "PR approved — $pr_url. Workflow complete."
state_write "$story_id" '{"stage": "complete"}'
```

**If `CHANGES_REQUESTED`:**

```bash
comments=$(repo_get_pr_comments "$pr_url")
```

Re-invoke `zen-story` with the story ID and review comments as context.
Instruct `story-implement` to address the comments and push new commits.
The PR updates automatically.

**If `REVIEW_REQUIRED` or no decision yet:** take no action, continue to next story.

---

### Cron Schedule

Default interval: 30 minutes. Configure via `/schedule` or Claude Code's
cron system. The skill exits immediately if no stories are in review, so
frequent scheduling has minimal cost.
