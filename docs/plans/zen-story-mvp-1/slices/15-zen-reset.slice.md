# Slice 15 — `zen-reset`: Reset Workflow State

[← Plan](../PLAN.md) | [← Slice 14: Handoff](14-handoff.slice.md) | [Slice 16: Epic Workflow →](16-epic-workflow.slice.md)

**Depends on:** Slice 12
**Modules:** State Store, Commands / Workflows
**Status:** Not started (deferred — low priority)

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-reset/SKILL.md` | Delete all local workflow state for a story |

---

### `zen-reset` Behavior

```
/zen-reset <story_id>
```

1. Source State Store; call `state_branch_exists $story_id`
   — if not found: "No state found for $story_id"
2. Read `state.json` for confirmation context (title, stage, PR URL if any)
3. Warn user:
   ```
   This will permanently delete all local workflow state for $story_id.

     Story  : $story_id — $title
     Stage  : $stage
     PR     : $pr_url  ← this PR will NOT be closed

   This cannot be undone. Type "$story_id" to confirm, or Ctrl-C to cancel.
   ```
4. On confirmation: `rm -rf ~/.zenflow/$story_id/`
5. Print: `State cleared for $story_id. Run /zen-story $story_id to start fresh.`

---

### Scope

`zen-reset` deletes local state only. It does not:
- Close the GitHub PR (user's responsibility)
- Revert the Jira story status
- Delete the feature branch

---

## Acceptance Criteria

- [ ] `zen-reset` shows story details and requires typing the story ID to confirm
- [ ] On confirmation, `~/.zenflow/$story_id/` is fully removed
- [ ] After reset, `state_branch_exists` returns 1 for that story
- [ ] Running `zen-reset` on an unknown story ID prints a clear error
- [ ] PR URL and PR status are not affected — only local state is cleared
- [ ] Cancelling (Ctrl-C or wrong confirmation text) leaves state untouched
