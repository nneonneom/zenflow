# Slice 6 — Real Jira Adapter in Isolation

[← Plan](../PLAN.md) | [← Slice 5: `zen-story` MVP](05-zen-story-mvp.slice.md) | [Slice 7: Real Planning Core →](07-planning-core.slice.md)

**Depends on:** Slice 5
**Modules:** issue-tracker-adapter
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `scripts/issue-tracker-adapter.sh` | Real Jira operations — `jira-cli` primary, REST API fallback |

---

### Functions

| Function | Signature | Does |
|---|---|---|
| `jira_fetch_story` | `jira_fetch_story <story_id>` | Fetches story JSON; output shape matches `mock-jira-story.sh` |
| `jira_fetch_assigned_stories` | `jira_fetch_assigned_stories [project_key]` | Lists non-closed stories assigned to current user |
| `jira_move_to_in_progress` | `jira_move_to_in_progress <story_id>` | Moves story to In Progress via transition |
| `jira_fetch_story_rest` | `jira_fetch_story_rest <story_id>` | REST fallback for `jira_fetch_story` |

All functions output JSON in the same shape as the mock so `story-start`
needs no changes when swapped in Slice 10.

---

### Output Shape (single story)

```json
{
  "id": "PROJ-123",
  "project_key": "PROJ",
  "title": "...",
  "description": "...",
  "status": "To Do",
  "assignee": "dev@example.com"
}
```

---

### `jira-cli` vs REST

- Primary: `jira issue view` / `jira issue list` / `jira issue move` — simpler auth, better output
- Fallback: REST API via `curl` — used if `jira-cli` is not installed or a call fails
- Transition name "In Progress" may differ per project; emit a warning rather than hard-failing if not found

---

### Testing in Isolation

Test each function standalone before wiring into `story-start`:

```bash
source scripts/issue-tracker-adapter.sh
jira_fetch_story PROJ-123
jira_fetch_assigned_stories PROJ
jira_move_to_in_progress PROJ-123
```

---

## Acceptance Criteria

- [ ] `jira_fetch_story PROJ-123` returns valid JSON with all required fields
- [ ] `jira_fetch_assigned_stories` returns a JSON array of non-closed assigned stories
- [ ] `jira_move_to_in_progress` transitions the story status without error
- [ ] When `jira-cli` is absent, all functions fall back to REST API calls
- [ ] REST fallback produces output in the same JSON shape as `jira-cli` path
- [ ] Missing or invalid `JIRA_API_TOKEN` produces a clear error, not a silent failure
- [ ] Output shape matches `mock-jira-story.sh` exactly — no changes needed in `story-start`
