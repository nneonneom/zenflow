# Slice 14 — Handoff: Pass Workflow to Another Team Member

[← Plan](../PLAN.md) | [← Slice 13: PR Monitor](13-pr-monitor.slice.md) | [Slice 15: `zen-reset` →](15-zen-reset.slice.md)

**Depends on:** Slice 13
**Modules:** Commands / Workflows, notifier-adapter, State Store
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-handoff/SKILL.md` | Pass workflow ownership to another team member |

---

### `zen-handoff` Behavior

```
/zen-handoff [story_id]
```

1. If no `story_id`: list stories where `assigned_to` matches current user
2. Read `state.json` — confirm story is not `complete`
3. Prompt for recipient email:
   ```
   Hand off to (email): _
   ```
4. Send Teams notification to the team channel:
   ```
   Zenflow handoff: PROJ-123 — Add login page
   Assigned to: recipient@example.com
   Stage: development (slice 2 of 3)
   To resume: /zen-resume PROJ-123
   ```
5. Update `state.json`:
   ```bash
   state_write "$story_id" "{\"assigned_to\": \"${recipient_email}\"}"
   ```
6. Print confirmation:
   ```
   Handoff complete.

     Story  : $story_id
     To     : $recipient_email
     Stage  : $stage (slice $current_slice / $total_slices)

   $recipient_email has been notified via Teams.
   ```

---

### Scope Note

Handoff changes ownership in `state.json` and sends a Teams notification.
It does not transfer git branch access or GitHub PR reviewers — those remain
the sender's responsibility. Cross-machine state access requires the API adapter.

---

## Acceptance Criteria

- [ ] `zen-handoff` prompts for recipient email if not provided
- [ ] Teams notification includes story ID, title, stage, slice progress, and resume command
- [ ] `state.json` `assigned_to` is updated to the recipient's email
- [ ] `state.json` `updated_at` is refreshed
- [ ] Attempting to hand off a `complete` story prints an error and exits
- [ ] Confirmation output shows the handoff details
