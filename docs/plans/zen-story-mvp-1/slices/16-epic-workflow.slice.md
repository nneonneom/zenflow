# Slice 16 — Epic Workflow: `zen-epic` + Full Epic Lifecycle

[← Plan](../PLAN.md) | [← Slice 15: `zen-reset`](15-zen-reset.slice.md)

**Depends on:** Slice 11
**Modules:** Commands / Workflows, Planning Core, issue-tracker-adapter, repo-adapter, notifier-adapter, State Store
**Status:** Not started (deferred — next quarter)

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-epic/SKILL.md` | Orchestrates the full epic lifecycle |

---

### `zen-epic` Lifecycle

```
/zen-epic [epic_id]
```

Three phases, each requiring user approval before proceeding:

**Phase 1 — Epic Plan**
- Fetch epic from Jira (or prompt user for requirements)
- Planning Core generates: epic goal, scope, out-of-scope, key risks
- User approves or refines
- Written to `~/.zenflow/$epic_id/plan.md`

**Phase 2 — Technical Design**
- Planning Core generates: architecture overview, component breakdown, key decisions, sequence diagram (text)
- User approves or refines
- Written to `~/.zenflow/$epic_id/design.md`

**Phase 3 — Story Breakdown**
- Planning Core generates: ordered list of stories with titles, descriptions, acceptance criteria
- User approves or refines
- Stories created in Jira via `issue-tracker-adapter`
- Teams notification sent with story list and Jira links

---

### State Layout

```
~/.zenflow/$epic_id/
  state.json     — epic workflow state (phase, approved flags)
  plan.md        — epic plan
  design.md      — technical design
  stories.md     — story breakdown (pre-creation)
```

---

### Acceptance Criteria

*To be detailed in Pass 5 when this slice becomes active — deferred until
Slice 11 is complete and the story workflow is stable.*

High-level criteria:
- [ ] `zen-epic` produces an approved epic plan, technical design, and story breakdown
- [ ] Stories are created in Jira with correct titles, descriptions, and acceptance criteria
- [ ] Teams notification sent with story list and Jira links
- [ ] State persisted per-phase so the epic lifecycle can be paused and resumed
