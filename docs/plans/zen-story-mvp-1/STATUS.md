# Zenflow — Build Status

[← Plan](PLAN.md)

**Current slice:** Slice 2 — `story-start` with mocked Jira
**Overall progress:** 1 of 16 slices complete (Slice 2 in progress)

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

**Status:** In Progress

| Deliverable | Status | Notes |
|---|---|---|
| `skills/story-start/SKILL.md` | ✅ Written | Stage command skill — story resolution, state init, context handoff |
| `scripts/mock-jira-story.sh` | ✅ Written | Mock Jira fetch; replaced by real adapter in Slice 6 |

### Acceptance Criteria

- [ ] Running `story-start` without a story ID presents the mock story list and accepts a selection
- [ ] Running `story-start PROJ-101` skips the list and proceeds directly
- [ ] `state.json` is created at `~/.zenflow/PROJ-101/state.json` with `stage: "planning"`
- [ ] `state.json` fields match the schema in `docs/state-schema.md` — no extra or missing fields
- [ ] Running `story-start PROJ-101` a second time prompts about existing state instead of overwriting
- [ ] Replying `reset` to the existing-state prompt re-initializes state cleanly
- [ ] Confirmation output shows story ID, title, stage, and state file path
- [ ] Story context (id, project_key, title, description, target_branch) is present in output for handoff

---

## Slice 3 — `story-plan` with Mocked Planning Core

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/story-plan/SKILL.md` | ✅ Written | Stage command skill — clarifying questions, plan approval, State Store writes |
| `scripts/mock-planning-core.sh` | ✅ Written | Mock plan generator — writes plan.md, status.md, slices/ to temp dir |

### Acceptance Criteria

- [ ] `story-plan` presents the mock plan to the user for review before writing anything
- [ ] User can request changes to the plan and see a revised version before approving
- [ ] Replying `approve` triggers State Store writes
- [ ] `~/.zenflow/$story_id/plan.md` exists and contains the approved plan content
- [ ] `~/.zenflow/$story_id/status.md` exists and lists slices with `⬜ Not started` status
- [ ] `~/.zenflow/$story_id/slices/` contains one file per slice
- [ ] `state.json` has `approved_plan: true`, `current_slice: 1`, `total_slices: 3`
- [ ] `state.json` `updated_at` is refreshed after the write
- [ ] Confirmation output shows story ID, slice count, and state path
- [ ] Story context (story_id, project_key, title, target_branch, total_slices) is present in output for handoff

---

---

## Slice 4 — `story-implement` with Mocked Planning Core + Teams

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/story-implement/SKILL.md` | ✅ Written | Slice execution loop, Teams notifications, state updates per slice |
| `scripts/mock-teams-notifier.sh` | ✅ Written | Prints to stdout; replaced by real notifier-adapter in Slice 10 |

### Acceptance Criteria

- [ ] `story-implement` reads `current_slice` and `total_slices` from `state.json`
- [ ] Each slice file is loaded and its goal/tasks are displayed before implementation begins
- [ ] After each slice, `status.md` is updated: that slice row changes to `✅ Complete`
- [ ] After each slice, `state.json` `current_slice` increments by 1
- [ ] Mid-implementation Teams notification is printed to stdout via mock notifier
- [ ] Completion notification is printed when all slices are done
- [ ] After all slices: `state.json` `current_slice` equals `total_slices + 1`
- [ ] Completion context (story_id, slices_done) is present in output for handoff

---

## Slice 5 — `zen-story` MVP End-to-End with All Mocks

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/zen-story/SKILL.md` | ✅ Written | Main orchestrator — story-start → story-plan → branch → story-implement → story-create-pr |
| `skills/story-create-pr/SKILL.md` | ✅ Written | Stage command — generates PR description, creates PR via mock |
| `scripts/mock-repo-adapter.sh` | ✅ Written | Fakes branch creation and PR creation; replaced in Slice 10 |

### Acceptance Criteria

- [ ] Running `/zen-story` without args presents a story list and completes the full workflow
- [ ] Running `/zen-story PROJ-101` completes the full workflow for that story
- [ ] Running `/zen-story PROJ-101` when state already exists shows resume/reset instructions and exits
- [ ] Feature branch name follows `zenflow/{story_id}-{slug}` convention
- [ ] `state.json` `feature_branch` is written after branch creation
- [ ] `state.json` `stage` is `review` and `pr_url` is set after PR creation
- [ ] PR description contains Summary, Implementation Notes, and Testing sections
- [ ] Handoff summary printed at end shows story ID, branch, PR URL, and stage

---

## Slice 6 — Real Jira Adapter in Isolation

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `scripts/issue-tracker-adapter.sh` | ✅ Written | `jira_fetch_story`, `jira_fetch_assigned_stories`, `jira_move_to_in_progress` + REST fallbacks |

### Acceptance Criteria

- [ ] `jira_fetch_story PROJ-123` returns valid JSON with all required fields
- [ ] `jira_fetch_assigned_stories` returns a JSON array of non-closed assigned stories
- [ ] `jira_move_to_in_progress` transitions the story status without error
- [ ] When `jira-cli` is absent, all functions fall back to REST API calls
- [ ] REST fallback produces output in the same JSON shape as `jira-cli` path
- [ ] Missing or invalid `JIRA_API_TOKEN` produces a clear error, not a silent failure
- [ ] Output shape matches `mock-jira-story.sh` exactly — no changes needed in `story-start`

---

## Slice 7 — Real Planning Core in Isolation

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/planning-core/SKILL.md` | ✅ Written | Describes plan generation and PR description generation |

### Acceptance Criteria

- [ ] Plan output is written to `/tmp/zenflow-plan-$story_id/` with the same structure as `mock-planning-core.sh`
- [ ] Slice count reflects story complexity — not always 3
- [ ] Each slice file has a single goal, 3–6 tasks, and a binary done-when criterion
- [ ] PR description has Summary, Implementation Notes, and Testing sections
- [ ] `story-plan` and `story-create-pr` require no code changes when swapped from mock

---

## Slice 8 — Real Teams Adapter in Isolation

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `scripts/notifier-adapter.sh` | ✅ Written | `notify_teams` — Teams webhook POST; graceful skip if URL unset |

### Acceptance Criteria

- [ ] `notify_teams` sends a POST to `TEAMS_WEBHOOK_URL` with correct JSON payload
- [ ] Message appears in the Teams channel within a few seconds
- [ ] If `TEAMS_WEBHOOK_URL` is unset, function prints a warning and returns 0
- [ ] Call site signature identical to `mock-teams-notifier.sh` — no changes in stage commands

---

## Slice 9 — Real GitHub Integration in Isolation

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `scripts/repo-adapter.sh` | ✅ Written | `repo_create_branch`, `repo_create_pr`, `repo_get_pr_status`, `repo_get_pr_comments` |

### Acceptance Criteria

- [ ] `repo_create_branch` creates and pushes the branch; HEAD is on the new branch
- [ ] `repo_create_pr` creates the PR and returns a valid GitHub PR URL
- [ ] `repo_get_pr_status` returns correct state after PR is open
- [ ] `repo_get_pr_comments` returns CHANGES_REQUESTED reviews as JSON array
- [ ] All functions fail clearly if `gh` is unauthenticated
- [ ] Call site signatures match `mock-repo-adapter.sh` — no changes in `zen-story` or `story-create-pr`

---

## Slice 10 — Integrate Real Adapters into Stage Commands

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/story-start/SKILL.md` | ✅ Written (update needed) | Swap mock Jira → real; add `jira_move_to_in_progress` |
| `skills/story-plan/SKILL.md` | ✅ Written (update needed) | Swap mock Planning Core → real |
| `skills/story-implement/SKILL.md` | ✅ Written (update needed) | Swap mock Teams → real notifier-adapter |
| `skills/story-create-pr/SKILL.md` | ✅ Written (update needed) | Swap mock repo → real repo-adapter + real PR description |
| `skills/zen-story/SKILL.md` | ✅ Written (update needed) | Swap mock branch creation → real repo-adapter |

### Acceptance Criteria

- [ ] `story-start` fetches real story from Jira and moves it to In Progress
- [ ] `story-plan` generates a real implementation plan via Planning Core (not mock)
- [ ] `story-implement` sends real Teams notifications via webhook
- [ ] `story-create-pr` creates a real GitHub PR with a generated description
- [ ] `zen-story` creates a real feature branch via `gh` CLI
- [ ] Each stage validated individually before the next swap
- [ ] No mock scripts are called after this slice is complete

---

## Slice 11 — Full `zen-story` End-to-End with Real Adapters

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| *(no new files — validation slice)* | — | Fix any integration issues found during E2E run |

### Acceptance Criteria

- [ ] Full `/zen-story` run completes without errors against real Jira, GitHub, and Teams
- [ ] Jira story status is "In Progress" after `story-start`
- [ ] Feature branch exists on GitHub after branch creation step
- [ ] GitHub PR exists with correct title, description, head, and base
- [ ] Teams channel received notifications at implementation start and completion
- [ ] `state.json` has `stage: review`, `pr_url` set, `approved_plan: true`
- [ ] `~/.zenflow/$story_id/plan.md`, `status.md`, and `slices/` all exist and are populated

---

## Slice 12 — State Persistence: `zen-pause` + `zen-resume`

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/zen-pause/SKILL.md` | ✅ Written | UX checkpoint — prints state summary + resume instructions |
| `skills/zen-resume/SKILL.md` | ✅ Written | Reads state, resumes zen-story from correct stage |

### Acceptance Criteria

- [ ] `/zen-pause` prints a clear state summary with resume instructions
- [ ] `/zen-resume PROJ-123` reads state and resumes at the correct stage
- [ ] Resume at `story-plan` re-presents the plan approval flow
- [ ] Resume at `story-implement` resumes from `current_slice`, not slice 1
- [ ] Resume when `stage: review` prints PR URL and check instructions
- [ ] Resume when `stage: complete` prints a done message and exits cleanly
- [ ] Resume with unknown story_id prints a clear error and exits

---

## Slice 13 — PR Monitor: `zen-pr-monitor` + `zen-pr-check`

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/zen-pr-monitor/SKILL.md` | ✅ Written | Scheduled cron — polls review-stage stories, reacts to approval or changes |
| `skills/zen-pr-check/SKILL.md` | ✅ Written | User-invoked — single story PR status + interactive changes-requested flow |

### Acceptance Criteria

- [ ] `zen-pr-monitor` scans `~/.zenflow/` and finds all `stage: review` stories
- [ ] PR approved → Teams notification sent + `state.json` updated to `stage: complete`
- [ ] PR has changes requested → review comments extracted and `story-implement` re-invoked
- [ ] `zen-pr-check` prints a readable PR status summary for a given story
- [ ] `zen-pr-check` with no story ID lists all active review stories
- [ ] `zen-pr-check` offers to address changes requested interactively
- [ ] `zen-pr-monitor` exits cleanly with no output if no stories are in review

---

## Slice 14 — Handoff: Pass Workflow to Another Team Member

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `skills/zen-handoff/SKILL.md` | ✅ Written | Teams notification + `assigned_to` update in state.json |

### Acceptance Criteria

- [ ] `zen-handoff` prompts for recipient email if not provided
- [ ] Teams notification includes story ID, title, stage, slice progress, and resume command
- [ ] `state.json` `assigned_to` is updated to the recipient's email
- [ ] `state.json` `updated_at` is refreshed
- [ ] Attempting to hand off a `complete` story prints an error and exits
- [ ] Confirmation output shows the handoff details

---

## Slice 15 — `zen-reset`: Reset Workflow State

**Status:** Not started (deferred)

| Deliverable | Status | Notes |
|---|---|---|
| `skills/zen-reset/SKILL.md` | ✅ Written | Requires typing story ID to confirm; deletes `~/.zenflow/$story_id/` |

### Acceptance Criteria

- [ ] `zen-reset` shows story details and requires typing the story ID to confirm
- [ ] On confirmation, `~/.zenflow/$story_id/` is fully removed
- [ ] After reset, `state_branch_exists` returns 1 for that story
- [ ] Running `zen-reset` on an unknown story ID prints a clear error
- [ ] Cancelling leaves state untouched

---

## Slice 16 — Epic Workflow: `zen-epic` + Full Epic Lifecycle

**Status:** Not started (deferred — next quarter)

| Deliverable | Status | Notes |
|---|---|---|
| `skills/zen-epic/SKILL.md` | ✅ Written | Epic plan → technical design → story breakdown → Jira creation |

### Acceptance Criteria

*To be detailed when this slice becomes active — acceptance criteria in [16-epic-workflow.slice.md](slices/16-epic-workflow.slice.md).*

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
