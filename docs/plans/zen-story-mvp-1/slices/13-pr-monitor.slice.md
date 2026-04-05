# Slice 13 — PR Monitor: `zen-pr-monitor` + `zen-pr-check`

[← Plan](../PLAN.md) | [← Slice 12: State Persistence](12-state-persistence.slice.md) | [Slice 14: Handoff →](14-handoff.slice.md)

**Depends on:** Slice 11
**Modules:** PR Monitor, repo-adapter, State Store, notifier-adapter
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-pr-monitor/SKILL.md` | Scheduled cron — polls active PRs, re-invokes `zen-story` on events |
| `skills/zen-pr-check/SKILL.md` | User-invoked fallback — checks a single PR on demand |

---

### `zen-pr-monitor` Behavior (scheduled)

Runs on a cron schedule (configured via `/schedule` or Claude Code's cron system).

1. Scan `~/.zenflow/` for stories where `state.json` has `stage: review`
2. For each: call `repo_get_pr_status $pr_url`
3. **If approved** (`reviewDecision: APPROVED`):
   - Call `notify_teams $story_id "PR approved — $pr_url"`
   - `state_write $story_id '{"stage": "complete"}'`
4. **If changes requested**:
   - Call `repo_get_pr_comments $pr_url` to get review feedback
   - Re-invoke `zen-story` with the story ID and review comments as context
   - `zen-story` calls `story-implement` to address comments and push

---

### `zen-pr-check` Behavior (user-invoked)

```
/zen-pr-check [story_id]
```

1. If no `story_id`: list all stories in `stage: review`
2. Call `repo_get_pr_status $pr_url` and `repo_get_pr_comments $pr_url`
3. Print a human-readable summary:

```
PR Status: PROJ-123

  PR      : https://github.com/.../pull/42
  State   : open
  Review  : CHANGES_REQUESTED
  Comments:
    - @reviewer: "Please add error handling for the empty case"
```

4. If changes requested, ask: "Address these comments now? [y/n]"
   — on yes: invoke `story-implement` with comment context

---

### Cron Schedule

Default: every 30 minutes. Configurable. Only runs if there are stories in
`stage: review` — exits immediately if none.

---

## Acceptance Criteria

- [ ] `zen-pr-monitor` scans `~/.zenflow/` and finds all `stage: review` stories
- [ ] PR approved → Teams notification sent + `state.json` updated to `stage: complete`
- [ ] PR has changes requested → review comments extracted and `story-implement` re-invoked
- [ ] `zen-pr-check` prints a readable PR status summary for a given story
- [ ] `zen-pr-check` with no story ID lists all active review stories
- [ ] `zen-pr-check` offers to address changes requested interactively
- [ ] `zen-pr-monitor` exits cleanly with no output if no stories are in review
