# 流 Zenflow

> *Master the ancient art of software cultivation. From epic to implementation, story to merge — each cycle refined, each release an ascension.*

Zenflow is a Claude Code plugin that guides your full software development lifecycle — plan epics and break them into stories, generate structured implementation plans, automate code, review and resolve PR feedback, and sync everything back to Jira without leaving your terminal.

Every ticket a lesson. Every merge a breakthrough.

---

## The Cultivation Path

A cultivator does not rush. They refine.

Most developers context-switch between tools, lose momentum between tickets, and carry the cognitive weight of process on top of the work itself. Zenflow removes that weight. Each stage of the lifecycle — from the first spark of a requirement to the final merge — flows into the next with intention and precision.

```
Requirement → Epic → Story → Plan → Implementation → PR → Merge
     ↑                                                        |
     └──────────────── Each cycle refined ───────────────────┘
```

---

## Capabilities

### 🌱 Plan — Seed the Vision
Zenflow's diffusion planner guides you from a blurry idea to a concrete architecture through deliberate passes — never detailing one corner before the full shape is confirmed.

- Define vision, scope, and module boundaries
- Generate a prioritized journey backlog
- Produce implementation-ready slice plans
- Output a living `PLAN.md` that drives every subsequent session

### 📜 Cultivate — Forge Epics and Stories
From your plan, Zenflow generates structured epics and stories ready for your team. No more blank Jira fields.

- Generate epics from vision and capability definitions
- Break epics into well-scoped, dependency-ordered stories
- Apply consistent acceptance criteria and Definition of Done

### ⚔️ Implement — Strike With Precision
Turn story plans into working code through guided, slice-by-slice implementation. Each slice independently testable. Each session context-aware.

- Generate implementation scaffolding from slice plans
- Enforce module boundaries defined in planning
- One slice at a time — no half-built foundations

### 🔍 Review — Discernment Before Ascension
Zenflow reviews pull requests with the rigor of a seasoned senior. Not just style — architecture, boundary violations, test coverage, and edge cases.

- Automated PR review with structured feedback
- Implements approved feedback directly
- Flags scope creep and design drift before it merges

### 🗂 Track — The Ledger of Progress
Jira integration via CLI keeps story status in sync with reality. No manual updates. No stale tickets.

- Transition stories through lifecycle stages automatically
- Add implementation notes and updates to tickets
- Sync PR status, branch names, and completion back to epics

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

## Quick Start

```bash
# Plan a new project or feature
/plan my-feature

# Create epics and stories from your plan
/cultivate

# Generate implementation plan for the next story
/implement

# Review an open PR
/review

# Sync story status to Jira
/track
```

---

## Philosophy

Zenflow is built on one principle: **the process should disappear so the work can breathe.**

Every ceremony in software development — planning, scoping, reviewing, tracking — exists for a reason. But the friction of doing it manually pulls a developer out of flow, fragments their attention, and makes the work feel heavier than it is.

Zenflow doesn't replace the ceremony. It absorbs it.

Each command is a cycle. Each cycle is a refinement. Each release is an ascension.

---

## Project Structure

```
zenflow/
├── skills/
│   ├── diffusion-planner/   # Pass-based planning methodology
│   ├── cultivate/           # Epic and story generation
│   ├── implement/           # Slice-by-slice implementation
│   ├── review/              # PR review and feedback automation
│   └── track/               # Jira CLI integration
├── PLAN.md                  # Zenflow's own plan (dogfooded)
├── CLAUDE.md                # Plugin context for Claude Code
└── README.md
```

---

## Status

🌱 Early cultivation — active development.

---

*Built with Claude Code. Powered by intention.*