# Zenflow — Build Status

[← Plan](PLAN.md)

**Current slice:** Slice 1 — Foundation: `zenflow-state` Repo Setup
**Overall progress:** 1 of 16 slices (in progress)

---

## Slice 1 — Foundation: `zenflow-state` Repo Setup

**Status:** In Progress

| Deliverable | Status | Notes |
|---|---|---|
| `.claude/scripts/state.sh` | ✅ Written | All 5 functions implemented |
| `skills/zen-setup/SKILL.md` | ✗ Missing | Directory exists, no SKILL.md |
| `docs/state-schema.md` | ✗ Missing | — |

### Acceptance Criteria

- [ ] `zen-setup` completes without error on a fresh machine with valid credentials
- [ ] `zen-setup` lists missing env vars clearly if any are absent
- [ ] `state_init` creates a branch in `zenflow-state` with a valid `state.json`
- [ ] `state_read` returns parseable JSON from an existing branch
- [ ] `state_write` merges a patch, commits, and pushes — `updated_at` is updated
- [ ] `state_write_plan` writes `plan.md` to the branch and pushes
- [ ] `state_branch_exists` correctly returns 0/1 without side effects
- [ ] All required env vars are documented in `docs/state-schema.md`

---

## Backlog

| Slice | Journey | Status |
|---|---|---|
| 1 | Foundation: `zenflow-state` repo setup | 🔄 In Progress |
| 2 | `story-start` with mocked Jira | ⬜ Not started |
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
