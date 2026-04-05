# Slice 11 — Full `zen-story` End-to-End with Real Adapters

[← Plan](../PLAN.md) | [← Slice 10: Adapter Integration](10-adapter-integration.slice.md) | [Slice 12: State Persistence →](12-state-persistence.slice.md)

**Depends on:** Slice 10
**Modules:** Commands / Workflows, all Adapters, State Store
**Status:** Not started

---

## Implementation Plan

### Files Changed

No new files. This is a validation slice — run the full workflow and fix any
integration issues discovered.

### What to run

```
/zen-story           # with a real assigned Jira story
```

Follow the full journey:
1. Story selected from Jira list → moved to In Progress
2. Clarifying questions answered → plan approved
3. Feature branch created on GitHub
4. Each implementation slice executed
5. PR created on GitHub with generated description
6. Teams notification sent at completion
7. State at `~/.zenflow/$story_id/` reflects `stage: review`

### What to watch for

- Jira transition name mismatches (project-specific config)
- Teams webhook payload format rejections
- `gh` PR creation auth or permission errors
- `state_write_plan` path or encoding issues with real plan content
- Branch naming collisions if story has been run before

Fix any issues discovered in the relevant adapter or stage command skill
before marking this slice complete.

---

## Acceptance Criteria

- [ ] Full `/zen-story` run completes without errors against real Jira, GitHub, and Teams
- [ ] Jira story status is "In Progress" after `story-start`
- [ ] Feature branch exists on GitHub after branch creation step
- [ ] GitHub PR exists with correct title, description, head, and base
- [ ] Teams channel received notifications at implementation start and completion
- [ ] `state.json` has `stage: review`, `pr_url` set, `approved_plan: true`, `current_slice` past all slices
- [ ] `~/.zenflow/$story_id/plan.md`, `status.md`, and `slices/` all exist and are populated
