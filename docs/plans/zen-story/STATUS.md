# Zenflow — Build Status

[← Plan](PLAN.md)

**Current slice:** Slice 2 — `story-start` with mocked Jira
**Overall progress:** 1 of 16 slices complete

---

## Slice 1 — Foundation: State Store Setup

**Status:** Complete

| Deliverable | Status | Notes |
|---|---|---|
| `scripts/zenflow-store-state.sh` | ✅ Amended | Adapter router — sources `state-adapter-local.sh` (default) or `state-adapter-api.sh` |
| `scripts/state-adapter-local.sh` | ✅ Written | Local filesystem adapter — `~/.zenflow/{story-id}/` |
| `scripts/state-adapter-api.sh` | ✅ Written | API adapter stub — not yet implemented |
| `skills/zen-setup/SKILL.md` | ✅ Written | 5-step setup wizard |
| `docs/state-schema.md` | ✅ Written | Full schema + env vars + function reference |

### Acceptance Criteria

- [ ] `zen-setup` completes without error on a fresh machine with valid credentials
- [ ] `zen-setup` lists missing env vars clearly if any are absent
- [ ] `state_init` creates `~/.zenflow/{story_id}/state.json` with a valid schema
- [ ] `state_read` returns parseable JSON from an existing branch
- [ ] `state_write` merges a patch, commits, and pushes — `updated_at` is updated
- [ ] `state_write_plan` writes `plan.md`, `status.md`, and `slices/` to the branch and pushes
- [ ] `state_branch_exists` correctly returns 0/1 without side effects
- [ ] All required env vars are documented in `docs/state-schema.md`

---

## Slice 2 — `story-start` with Mocked Jira

**Status:** Ready to build

| Deliverable | Status | Notes |
|---|---|---|
| `skills/story-start/SKILL.md` | ✗ Not started | — |

### Acceptance Criteria

*To be defined in Pass 5 before building.*

---

## Backlog

| Slice | Journey | Status |
|---|---|---|
| 1 | Foundation: State Store setup | ✅ Complete |
| 2 | `story-start` with mocked Jira | 🔄 In Progress |
| 3 | `story-plan` with mocked Planning Core | ⬜ Not started |
| 4 | `story-implement` with mocked Planning Core + Teams | ⬜ Not started |
| 5 | `zen-story` MVP end-to-end with all mocks | ⬜ Not started |
| 6 | Real issue-tracker-adapter in isolation | ⬜ Not started |
| 7 | Real Planning Core in isolation | ⬜ Not started |
| 8 | Real notifier-adapter in isolation | ⬜ Not started |
| 9 | Real repo-adapter in isolation | ⬜ Not started |
| 10 | Integrate real adapters into stage commands | ⬜ Not started |
| 11 | Full `zen-story` end-to-end with real adapters | ⬜ Not started |
| 12 | State persistence: `zen-pause` + `zen-resume` | ⬜ Not started |
| 13 | PR Monitor: `zen-pr-monitor` cron + `zen-pr-check` | ⬜ Not started |
| 14 | Handoff: pass workflow to another team member | ⬜ Not started |
| 15 | `zen-reset`: reset workflow state | ⬜ Not started |
| 16 | Epic workflow: `zen-epic` + full epic lifecycle | ⬜ Not started |
