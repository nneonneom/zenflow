---
name: zen-epic
description: >
  Orchestrates the full epic lifecycle: epic plan → technical design → story
  breakdown → Jira story creation. Three approval gates, one per phase.
  Can be run from anywhere — does not require a git repo.
---

# zen-epic

Epic lifecycle orchestrator. Guides the user through planning an epic,
generating a technical design, and breaking work into Jira stories.

> **Note (Slice 16):** Deferred until story workflow is stable (Slice 11 complete).
> Implementation detail to be refined at that time.

---

## Usage

```
/zen-epic [epic_id]
```

`epic_id` is optional. If omitted, prompt the user for requirements directly.

---

## Phases

### Phase 1 — Epic Plan

1. Fetch epic from Jira if `epic_id` provided; otherwise prompt for requirements
2. Planning Core generates:
   - Epic goal (one paragraph)
   - Scope (what's in, what's out)
   - Key risks and dependencies
3. Present for user approval — refine until approved
4. Write to `~/.zenflow/$epic_id/plan.md` and `state.json` (`phase: plan, approved_plan: true`)

---

### Phase 2 — Technical Design

1. Read `plan.md` for context
2. Planning Core generates:
   - Architecture overview
   - Component breakdown (what changes, what's new)
   - Key technical decisions and rationale
   - Sequence diagram (text/Mermaid)
3. Present for user approval — refine until approved
4. Write to `~/.zenflow/$epic_id/design.md` and update `state.json` (`approved_design: true`)

---

### Phase 3 — Story Breakdown

1. Read `plan.md` and `design.md` for context
2. Planning Core generates an ordered list of stories:
   - Title, description, acceptance criteria for each
   - Dependencies between stories
3. Present for user approval — refine until approved
4. On approval:
   - Create each story in Jira via `issue-tracker-adapter`
   - Send Teams notification with story list and Jira links
   - Write story IDs to `~/.zenflow/$epic_id/stories.md`
   - Update `state.json` (`phase: complete`)

---

## State Layout

```
~/.zenflow/$epic_id/
  state.json    — { phase, approved_plan, approved_design, story_ids[] }
  plan.md       — epic plan
  design.md     — technical design
  stories.md    — story breakdown with Jira IDs
```
