# Zenflow — Plan

## Vision

Zenflow eliminates the overhead that slows down the software development lifecycle. Developers, Product Owners, and Tech Leads spend too much time creating, coordinating, and tracking plans — writing epics, refining stories, documenting designs, chasing PR status — work that surrounds building software without being the building itself. Zenflow centralizes and automates that surrounding work: planning artifacts are generated and refined with minimal input, story state and dependencies are always visible, and the path from idea to merged code is shorter because the connective tissue between steps is handled, not managed.

---

## Capabilities

- User can create epics and stories in Jira
- User can create feature branches in GitHub
- User can send direct notifications via Microsoft Teams
- User can generate epic plans from provided requirements
- User can generate technical design documents
- User can generate architecture diagrams (C4, Sequence, Flowchart, State Machine)
- User can generate story implementation plans
- User can trigger an epic lifecycle workflow (epic planning → technical design → story breakdown and prioritization)
- User can trigger a story implementation workflow (start story → generate plan → approve/refine → create branch → implement → test → create PR → address PR comments)
- User can approve and refine generated artifacts at any workflow stage before progression
- User can hand off a workflow stage to another team member
- User can pause a workflow and resume it later from any machine (`zen-pause`, `zen-resume`)
- User can manually trigger a PR check on demand (`zen-pr-check`)
- User can register a background PR monitor that periodically checks active PRs (`zen-pr-monitor`)

---

## Out of Scope

- CI/CD pipeline management (Zenflow triggers workflows, does not own pipelines)
- Replacing Jira, GitHub, or Teams (Zenflow integrates with them, doesn't replicate them)
- Test infrastructure ownership (Zenflow invokes and updates tests; users own the test suite)
- UI/UX design or mockups *(potential future scope)*
- Sprint velocity, reporting, or analytics *(potential future scope)*
- Infrastructure or DevOps setup
- Time tracking or resource allocation
- VSCode extension or IDE plugin behavior (Zenflow is a Claude Code plugin)
- `zen-reset` — resetting workflow state *(deferred)*
- Teams Graph API / direct messages *(deferred — webhook vs Graph API TBD at implementation)*

---

## Module Map

| Module | Owns | Does NOT own |
|---|---|---|
| **Commands / Workflows** | Slash commands, skill entry points, multi-step orchestration, stage transitions, handoff logic, approval/refinement prompts | Artifact generation, external API calls |
| **Planning Core** | Generation of plans, technical designs, diagrams, and story implementation plans | Workflow state, external services, user interaction |
| **State Store** | Reading/writing workflow state to `zenflow-state` repo branches (`{project-key}/{story-id}`), `plan.md` and `state.json` per branch | Business logic, artifact generation, orchestration |
| **Jira Adapter** | All Jira operations via `jira-cli` (primary) + Jira REST API (fallback) — fetch stories, move to In Progress | GitHub, Teams, workflow state, artifact generation |
| **gh CLI** | All GitHub operations — feature branches, PRs, PR comment handling, `zenflow-state` repo reads/writes | Jira, Teams, workflow logic, artifact generation |
| **Teams Adapter** | All Teams operations — notifications, approval messages (implementation TBD: webhook or Graph API) | Jira, GitHub, workflow state, artifact generation |
| **PR Monitor** | Scheduled cron trigger, polling active PRs in `zenflow-state`, detecting review comments and approvals, invoking `zen-story` on events, sending Teams notifications on approval | Workflow orchestration, artifact generation, PR operations beyond status checks |

**API credentials** live in `.claude/settings.json` env section — not a module.

**Capability assignments:**

| Capability | Module |
|---|---|
| Create epics/stories in Jira | Jira Adapter |
| Create feature branches in GitHub | gh CLI |
| Send notifications via Teams | Teams Adapter |
| Generate epic plans | Planning Core |
| Generate technical design documents | Planning Core |
| Generate architecture diagrams | Planning Core |
| Generate story implementation plans | Planning Core |
| Trigger epic lifecycle workflow | Commands / Workflows |
| Trigger story implementation workflow | Commands / Workflows |
| Approve/refine artifacts at any stage | Commands / Workflows |
| Hand off workflow stage to another team member | Commands / Workflows + Teams Adapter |
| Pause workflow | Commands / Workflows + State Store |
| Resume workflow | Commands / Workflows + State Store |
| Manual PR check | PR Monitor |
| Background PR monitoring | PR Monitor |

---

## Command Surface

| Command | Type |
|---|---|
| `zen-story` | User-invoked orchestrator |
| `zen-resume {story-id}` | User-invoked |
| `zen-pause` | User-invoked |
| `zen-pr-check {story-id}` | User-invoked fallback |
| `story-start` | Stage command (called by `zen-story`) |
| `story-plan` | Stage command (called by `zen-story`) |
| `story-implement` | Stage command (called by `zen-story`) |
| `story-create-pr` | Stage command (called by `zen-story`) |
| `zen-pr-monitor` | Scheduled cron trigger |

---

## Core Journey — Story Implementation Workflow

1. Developer runs `zen-story` with optional story ID
2. `zen-story` calls `story-start` — fetches story from Jira via `jira-cli` (or prompts user to select from assigned non-closed stories), moves story to In Progress, initializes `state.json` on `zenflow-state/{project-key}/{story-id}` branch
3. `zen-story` calls `story-plan` — Planning Core generates implementation plan, asks clarifying questions if needed, confirms target PR branch (default: main), presents plan for user approval
4. User approves plan — `plan.md` and updated `state.json` committed to state branch
5. `zen-story` creates feature branch `zenflow/{story-id}-{concise-description}` via `gh` CLI
6. `zen-story` calls `story-implement` — executes approved plan, notifies developer via Teams if input needed mid-implementation
7. Quality checks and test suite run
8. `zen-story` calls `story-create-pr` — Planning Core generates PR description from plan and story context, `gh` CLI opens PR to target branch, PR URL written to `state.json`
9. `zen-story` hands off to PR Monitor and exits
10. PR Monitor wakes periodically:
    - Review comments detected → invokes `zen-story` with PR event + workflow state → `zen-story` calls `story-implement` to address comments, pushes commits (PR auto-updates)
    - PR approved → sends Teams notification to developer, marks workflow state complete in `state.json`

**Pause/Resume:**
- `zen-pause` — writes current stage to `state.json` on state branch, exits cleanly
- `zen-resume {story-id}` — fetches state branch, reads `state.json`, re-invokes `zen-story` from last saved stage
- `zen-story {story-id}` on existing state — prompts: "State found — run `zen-resume` to continue or `zen-reset` to start fresh"

---

## Interaction Map

| Caller | Calls | Via |
|---|---|---|
| `zen-story` | `story-start` | optional story ID argument |
| `zen-story` | `story-plan` | story context from State Store |
| `zen-story` | `gh` CLI | create feature branch |
| `zen-story` | `story-implement` | approved plan from State Store |
| `zen-story` | `story-create-pr` | workflow state (branch, target branch) |
| `zen-story` | PR Monitor | workflow state handoff after PR creation |
| `zen-resume` | `zen-story` | stage + context from State Store |
| `story-start` | Jira Adapter | story ID or assigned story fetch |
| `story-start` | State Store | initialize state branch |
| `story-plan` | Planning Core | story context + clarifying Q&A |
| `story-plan` | State Store | write approved plan + state |
| `story-implement` | Planning Core | approved plan from State Store |
| `story-implement` | Teams Adapter | mid-implementation notifications |
| `story-create-pr` | Planning Core | generate PR description |
| `story-create-pr` | gh CLI | open PR, write PR URL to state |
| `story-create-pr` | State Store | write PR URL to state |
| PR Monitor | `gh` CLI | fetch PR status and comments |
| PR Monitor | `zen-story` | PR event + workflow state |
| PR Monitor | Teams Adapter | approval notification |
| PR Monitor | State Store | mark workflow complete |

**Notes:**
- Stage commands are pure leaves — they never call each other
- `zen-story` is the only orchestrator of stage commands
- `gh` CLI owns all GitHub operations including `zenflow-state` repo reads/writes
- API credentials stored in `.claude/settings.json` env section
- `jira-cli` is primary for Jira operations, REST API is fallback

---

## Journey Backlog

| Priority | Journey | Depends On | Modules | Notes |
|----------|---------|------------|---------|-------|
| 1 | [Foundation: `zenflow-state` repo setup](slices/01-foundation-state-repo.slice.md) | — | State Store | State repo init, credentials in `settings.json` |
| 2 | [`story-start` with mocked Jira](slices/02-story-start-mocked.slice.md) | Slice 1 | Commands / Workflows, State Store | Mocked story fetch, state branch init |
| 3 | [`story-plan` with mocked Planning Core](slices/03-story-plan-mocked.slice.md) | Slice 2 | Commands / Workflows, Planning Core, State Store | Mocked plan generation, real approval flow |
| 4 | [`story-implement` with mocked Planning Core + Teams](slices/04-story-implement-mocked.slice.md) | Slice 3 | Commands / Workflows, Planning Core, State Store | Mocked implementation, real quality/test invocation |
| 5 | [`zen-story` MVP end-to-end with all mocks](slices/05-zen-story-mvp.slice.md) | Slice 4 | Commands / Workflows, State Store | First fully runnable workflow, validates orchestration |
| 6 | [Real Jira Adapter in isolation](slices/06-jira-adapter.slice.md) | Slice 5 | Jira Adapter | `jira-cli` + REST API fallback — tested standalone |
| 7 | [Real Planning Core in isolation](slices/07-planning-core.slice.md) | Slice 5 | Planning Core | Real plan generation with clarifying Q&A — tested standalone |
| 8 | [Real Teams Adapter in isolation](slices/08-teams-adapter.slice.md) | Slice 5 | Teams Adapter | Webhook or Graph API TBD — tested standalone |
| 9 | [Real GitHub Integration in isolation](slices/09-github-integration.slice.md) | Slice 5 | gh CLI, Planning Core, State Store | `gh` CLI setup, branch creation, PR creation, PR description — tested standalone |
| 10 | [Integrate real adapters into stage commands one at a time](slices/10-adapter-integration.slice.md) | Slices 6-9 | Commands / Workflows, all Adapters | `story-start` → `story-plan` → `story-implement` → `story-create-pr` each validated with real tools |
| 11 | [Full `zen-story` end-to-end with real adapters](slices/11-zen-story-e2e.slice.md) | Slice 10 | Commands / Workflows, all Adapters, State Store | Full workflow validated against real Jira, GitHub, Teams |
| 12 | [State Persistence: `zen-pause` + `zen-resume`](slices/12-state-persistence.slice.md) | Slice 11 | State Store, Commands / Workflows, gh CLI | Cross-machine resume via state branch |
| 13 | [PR Monitor: `zen-pr-monitor` cron + `zen-pr-check`](slices/13-pr-monitor.slice.md) | Slice 11 | PR Monitor, gh CLI, State Store, Teams Adapter | Polls active PRs, re-invokes `zen-story` on events |
| 14 | [Handoff: pass workflow to another team member](slices/14-handoff.slice.md) | Slice 13 | Commands / Workflows, Teams Adapter, State Store | Teams notification + state branch ownership transfer |
| 15 | [`zen-reset`: reset workflow state](slices/15-zen-reset.slice.md) | Slice 12 | State Store, Commands / Workflows | Deferred — low priority |
| 16 | [Epic Workflow: `zen-epic` + full epic lifecycle](slices/16-epic-workflow.slice.md) | Slice 11 | Commands / Workflows, Planning Core, Jira Adapter, gh CLI, Teams Adapter, State Store | Deferred — next quarter |
