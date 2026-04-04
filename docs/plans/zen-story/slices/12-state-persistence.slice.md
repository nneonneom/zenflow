# Slice 12 — State Persistence: `zen-pause` + `zen-resume`

[← Plan](../PLAN.md) | [← Slice 11: Full `zen-story` E2E](11-zen-story-e2e.slice.md) | [Slice 13: PR Monitor →](13-pr-monitor.slice.md)

**Depends on:** Slice 11
**Modules:** State Store, Commands / Workflows, gh CLI
**Status:** Pending Slice 11

---

## Implementation Plan

*Pass 5 not yet run — implement when Slice 11 is complete.*

**Includes:** `zen-pause`, `zen-resume {story-id}` — local resume via `~/.zenflow/` (local adapter). Cross-machine resume requires switching to the API adapter (`ZENFLOW_STATE_ADAPTER=api`) — deferred to the API adapter slice.

---

## Acceptance Criteria

*To be defined in Pass 5.*
