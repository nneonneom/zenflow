# Slice 8 — Real Teams Adapter in Isolation

[← Plan](../PLAN.md) | [← Slice 7: Real Planning Core](07-planning-core.slice.md) | [Slice 9: Real GitHub Integration →](09-github-integration.slice.md)

**Depends on:** Slice 5
**Modules:** notifier-adapter
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `scripts/notifier-adapter.sh` | Real Teams notifications via incoming webhook |

---

### Approach: Incoming Webhook

Incoming webhooks are a simple HTTP POST with a JSON payload — no Graph API,
no OAuth, no app registration required. Fits Zenflow's use case (one-way
channel notifications). Graph API deferred unless direct messages to individuals
are needed in a future slice.

### Function

```bash
notify_teams <story_id> <message>
```

Posts to `TEAMS_WEBHOOK_URL`. Gracefully skips if the var is unset (warns to
stderr) so the workflow is not blocked if Teams is unconfigured.

### Output Shape (Teams webhook payload)

```json
{ "title": "Zenflow — PROJ-123", "text": "<message>" }
```

---

### Testing in Isolation

```bash
source scripts/notifier-adapter.sh
notify_teams "PROJ-TEST" "Hello from Zenflow integration test"
```

Verify the message appears in the configured Teams channel.

---

## Acceptance Criteria

- [ ] `notify_teams` sends a POST to `TEAMS_WEBHOOK_URL` with the correct JSON payload
- [ ] Message appears in the Teams channel within a few seconds
- [ ] If `TEAMS_WEBHOOK_URL` is unset, function prints a warning and returns 0 (does not fail the workflow)
- [ ] Output shape (title + text) matches what Teams incoming webhooks expect
- [ ] Call site signature is identical to `mock-teams-notifier.sh` — no changes needed in stage commands
