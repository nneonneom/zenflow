# Zen Planning Methodology

Shared foundation for all `zen-*-plan` skill families. Each family applies
these principles through passes appropriate to its context — tool building,
epic planning, story planning — but the principles and artifact structure are
the same across all of them.

---

## Core Principles

**Progressive refinement** — Start blurry and get crisper pass by pass. You
cannot make good local decisions before the global shape is confirmed. Never
detail one corner before the full silhouette is approved.

**Quality standard** — Every pass output must meet all four bars before it is
accepted:
- *Cohesive* — reads as one unified artifact, not a collection of fragments
- *Concise* — every word earns its place; no padding, no restatement of prior passes
- *Clear* — a developer unfamiliar with the conversation could read it cold and understand it
- *Modular* — self-contained; does not require the reader to recall the conversation

**One slice at a time** — Never produce implementation detail for more than
one slice in a single session. Future slices will change based on what earlier
slices reveal. Stub files are fine — full detail is not.

**Name the smells** — If something feels architecturally wrong during boundary
or journey work, say so explicitly rather than working around it. The plan
exists to catch these before implementation, not hide them.

**The plan is a living document** — When a finding invalidates part of the
plan, return to the appropriate pass and revise forward from there. Do not
patch code or docs in isolation — run `/zen-tool-plan-amend` (or the
equivalent for the active skill family) to propagate changes consistently.

---

## Artifact Structure

All `zen-*-plan` skill families produce and maintain the same three artifact
types, stored under `docs/plans/{plan-name}/`:

```
docs/plans/{plan-name}/
├── PLAN.md
├── STATUS.md
└── slices/
    ├── 01-{slug}.slice.md
    ├── 02-{slug}.slice.md
    └── ...
```

### `PLAN.md`
The authoritative design document. Contains all pass outputs — vision,
capabilities, module map, core journey, interaction map, and journey backlog.
Never contains implementation detail — that lives in slice files. Updated by
`zen-*-plan-amend` when findings require architectural changes.

Navigation: Journey Backlog rows link to their slice files. `STATUS.md` links
back to `PLAN.md` at the top.

### `STATUS.md`
The live build tracker. Records the current slice, overall progress, per-slice
deliverable checklist, and acceptance criteria. Updated at the start of each
implementation session and after each slice is validated. The backlog table
mirrors the Journey Backlog in `PLAN.md` and shows slice status at a glance.

Navigation: links to `PLAN.md` at the top. Current slice section links to its
slice file.

### `slices/{NN}-{slug}.slice.md`
Per-slice implementation detail, written on demand — only when that slice is
next in the backlog and all its dependencies are validated. Contains file
names, function signatures, error handling, and acceptance criteria sufficient
for implementation without further clarification. Never written speculatively
for future slices.

Navigation: each slice file includes links to `PLAN.md`, the previous slice,
and the next slice at the top — keeping the full chain navigable in any
direction.

---

## Companion Skills

Each `zen-*-plan` family has three skills that work together:

| Skill | When to use |
|---|---|
| `zen-{family}-plan` | Starting a new plan from scratch |
| `zen-{family}-plan-audit` | Before locking a pass or beginning implementation — surface assumptions and risks proactively |
| `zen-{family}-plan-amend` | When a finding invalidates part of the plan — propagate the change consistently across all artifacts |

Current families:

| Family | Skills | For |
|---|---|---|
| `tool` | `zen-tool-plan`, `zen-tool-plan-audit`, `zen-tool-plan-amend` | Planning a new tool, CLI, service, or plugin from scratch |

Planned families (not yet built):

| Family | For |
|---|---|
| `epic` | Planning a feature epic — breakdown, technical design, story sequencing |
| `story` | Planning a story implementation — clarifying questions, slices, acceptance criteria |
