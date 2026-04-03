# 流 Zenflow

> *Master the ancient art of software cultivation. From epic to implementation, story to merge — each cycle refined, each release an ascension.*

Zenflow eliminates the overhead that slows down the software development lifecycle. Developers, Product Owners, and Tech Leads spend too much time creating, coordinating, and tracking plans — writing epics, refining stories, documenting designs, chasing PR status — work that surrounds building software without being the building itself. Zenflow centralizes and automates that surrounding work: planning artifacts are generated and refined with minimal input, story state and dependencies are always visible, and the path from idea to merged code is shorter because the connective tissue between steps is handled, not managed.

---

## The Cultivation Path

A cultivator does not rush. They refine.

```
Requirements → Epic → Story → Plan → Implementation → PR → Merge
                        ↑                    ↑               |
                        └── PR comments ─────┘               |
                        └──────────── Each release ──────────┘
```

---

## Capabilities

- Create epics and stories in Jira
- Create feature branches in GitHub
- Send direct notifications via Microsoft Teams
- Generate epic plans from provided requirements
- Generate technical design documents
- Generate architecture diagrams (C4, Sequence, Flowchart, State Machine)
- Generate story implementation plans
- Trigger an epic lifecycle workflow (epic planning → technical design → story breakdown and prioritization)
- Trigger a story implementation workflow (start story → generate plan → approve/refine → create branch → implement → test → create PR → address PR comments)
- Approve and refine generated artifacts at any workflow stage before progression
- Hand off a workflow stage to another team member
- Pause a workflow and resume it later from any machine (`zen-pause`, `zen-resume`)
- Manually trigger a PR check on demand (`zen-pr-check`)
- Register a background PR monitor that periodically checks active PRs (`zen-pr-monitor`)

---

## Core Journey — Story Implementation

1. Developer runs `zen-story` with optional story ID
2. Fetches story from Jira, moves to In Progress, initializes state in `zenflow-state` repo
3. Planning Core generates implementation plan with clarifying Q&A — user approves before proceeding
4. Feature branch created: `zenflow/{story-id}-{concise-description}`
5. Approved plan executed — Teams notification sent if mid-implementation input needed
6. Quality checks and test suite run
7. PR description generated from plan and story context — PR opened via `gh` CLI
8. PR Monitor takes over: detects review comments and invokes `zen-story` to address them; sends Teams notification on approval

**Pause/Resume:** `zen-pause` writes current stage to state; `zen-resume {story-id}` fetches state and continues from last saved stage.

---

## Commands

| Command | Description |
|---|---|
| `zen-story` | Main orchestrator — start or continue a story workflow |
| `zen-resume {story-id}` | Resume a paused workflow from any machine |
| `zen-pause` | Pause the current workflow and save state |
| `zen-pr-check {story-id}` | Manually trigger a PR status check |
| `zen-pr-monitor` | Scheduled cron — polls active PRs, fires on review events |

---

## Installation

```bash
# Install via Claude Code plugin registry (coming soon)
claude plugin install zenflow

# Or clone and install locally
git clone https://github.com/yourusername/zenflow
claude plugin install ./zenflow
```

---

## Setup

```bash
# Configure credentials and state repo
/zen-setup
```

Zenflow requires:
- `ZENFLOW_STATE_REPO` — a GitHub repo used to persist workflow state across sessions and machines
- Jira credentials (via `jira-cli` config) — used by `issue-tracker-adapter`
- GitHub credentials (via `gh auth login`) — used by `repo-adapter`
- Microsoft Teams webhook URL — used by `notifier-adapter`

Credentials are stored in `.claude/settings.json` env section — never committed.

---

## Project Structure

```
zenflow/
├── .claude-plugin/
│   └── plugin.json                 # Plugin manifest
├── skills/
│   ├── zen-setup/                  # One-time setup wizard (user-facing)
│   ├── diffusion-planner/          # Pass-based planning methodology
│   ├── commands/                   # zen-story, zen-resume, zen-pause, zen-pr-check
│   ├── planning-core/              # Plan, design doc, diagram, and PR description generation
│   ├── state-store/                # zenflow-state repo reads/writes (state.json, plan.md)
│   ├── issue-tracker-adapter/      # Story/epic operations (currently: jira-cli + REST API)
│   ├── repo-adapter/               # Branch, PR, repo operations (currently: gh CLI)
│   ├── notifier-adapter/           # Notifications and approvals (currently: Teams webhook)
│   └── pr-monitor/                 # Cron-triggered PR polling and event dispatch
├── hooks/                          # Hook definitions (zen-pr-monitor cron trigger)
├── docs/
│   └── plans/
│       └── zen-story/
│           ├── PLAN.md             # Full project plan and journey backlog
│           ├── STATUS.md           # Current slice and build progress
│           └── slices/             # Per-slice implementation plans
├── CLAUDE.md                       # Plugin context for Claude Code
└── README.md
```

---

## Out of Scope

- CI/CD pipeline management (Zenflow triggers workflows, does not own pipelines)
- Replacing Jira, GitHub, or Teams (Zenflow integrates with them, doesn't replicate them)
- Test infrastructure ownership (Zenflow invokes tests; users own the suite)
- UI/UX design or mockups
- Sprint velocity, reporting, or analytics
- Infrastructure or DevOps setup

---

## Philosophy

Zenflow is built on one principle: **the process should disappear so the work can breathe.**

Every ceremony in software development — planning, scoping, reviewing, tracking — exists for a reason. But the friction of doing it manually pulls a developer out of flow, fragments their attention, and makes the work feel heavier than it is.

Zenflow doesn't replace the ceremony. It absorbs it.

Each command is a cycle. Each cycle is a refinement. Each release is an ascension.

---

## Status

🌱 Early cultivation — active development. See [docs/plans/zen-story/STATUS.md](docs/plans/zen-story/STATUS.md) for current progress.

---

*Built with Claude Code. Powered by intention.*
