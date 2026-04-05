# Slice 2 — `story-start` with Mocked Jira

[← Plan](../PLAN.md) | [← Slice 1: Foundation](01-foundation-state-repo.slice.md) | [Slice 3: `story-plan` Mocked →](03-story-plan-mocked.slice.md)

**Depends on:** Slice 1
**Modules:** Commands / Workflows, State Store
**Status:** In Progress

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/story-start/SKILL.md` | Stage command skill — resolves story, checks state, initializes state.json, returns context to zen-story |
| `scripts/mock-jira-story.sh` | Mock Jira fetch — returns hardcoded story objects; replaced by real adapter in Slice 6 |

---

### `mock-jira-story.sh` Interface

```bash
bash scripts/mock-jira-story.sh --list       # JSON array of assigned stories
bash scripts/mock-jira-story.sh <story_id>   # JSON object for a single story
```

Output shape (single story):

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

### `story-start` Behavior

1. If no `story_id` given: call `mock-jira-story.sh --list`, present numbered list, user selects
2. Call `mock-jira-story.sh <story_id>`, parse `project_key` and story fields
3. Source `scripts/zenflow-store-state.sh`, call `state_branch_exists <story_id>`
   - If state exists: prompt user to `zen-resume` or reply `reset`; on `reset` continue, otherwise exit
4. Call `state_init <project_key> <story_id>`
5. Print confirmation and return story context to `zen-story`

---

### Context Returned to `zen-story`

```
story_id:      PROJ-123
project_key:   PROJ
title:         Add login page
description:   Implement a login page…
target_branch: main
```

`zen-story` passes this to `story-plan` in Slice 3.

---

### Reuse from Slice 1

- `scripts/zenflow-store-state.sh` — sourced as-is; no changes needed
- `scripts/state-adapter-local.sh` — `state_branch_exists` and `state_init` used directly
- State schema in `docs/state-schema.md` — referenced, not duplicated here

---

### Error Cases

| Error | Handling |
|---|---|
| `story_id` not found in mock | Generic fallback story returned (any ID works) |
| `state_init` fails (e.g. `~/.zenflow/` not writable) | Error propagates from adapter; skill exits with message |
| User selects invalid number from story list | Re-prompt |
| User declines both `zen-resume` and `reset` | Exit cleanly with no state changes |

---

## Acceptance Criteria

- [ ] Running `story-start` without a story ID presents the mock story list and accepts a selection
- [ ] Running `story-start PROJ-101` skips the list and proceeds directly
- [ ] `state.json` is created at `~/.zenflow/PROJ-101/state.json` with `stage: "planning"`
- [ ] `state.json` fields match the schema in `docs/state-schema.md` — no extra or missing fields
- [ ] Running `story-start PROJ-101` a second time prompts about existing state instead of overwriting
- [ ] Replying `reset` to the existing-state prompt re-initializes state cleanly
- [ ] Confirmation output shows story ID, title, stage, and state file path
- [ ] Story context (id, project_key, title, description, target_branch) is present in output for handoff
