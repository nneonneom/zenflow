# Slice 13 — PR Monitor: `zen-pr-monitor` + `zen-pr-check`

[← Plan](../PLAN.md) | [← Slice 12: State Persistence](12-state-persistence.slice.md) | [Slice 14: Handoff →](14-handoff.slice.md)

**Depends on:** Slice 11
**Modules:** PR Monitor, gh CLI, State Store, Teams Adapter
**Status:** Pending Slice 11

---

## Implementation Plan

*Pass 5 not yet run — implement when Slice 11 is complete.*

**Includes:** `zen-pr-monitor` scheduled cron trigger + `zen-pr-check {story-id}` user-invoked fallback. Polls active PRs, re-invokes `zen-story` on review comments, sends Teams notification on approval.

---

## Acceptance Criteria

*To be defined in Pass 5.*
