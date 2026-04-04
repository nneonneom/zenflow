---
name: zen-tool-plan
description: >
  Plans a new tool, CLI, service, or plugin using a diffusion methodology —
  refining from blurry global shape to implementation detail in discrete passes.
  Produces PLAN.md, STATUS.md, and slice files. See docs/zen-planning-methodology.md.
argument-hint: "[tool or feature name]"
disable-model-invocation: true
---

# Zen Tool Plan

Plans a new tool, CLI, service, or plugin using the zen planning methodology.
Produces `PLAN.md`, `STATUS.md`, and `slices/{NN}-{slug}.slice.md` files under
`docs/plans/{plan-name}/`. See [docs/zen-planning-methodology.md](../../docs/zen-planning-methodology.md)
for shared principles and artifact structure.

A planning approach that mirrors how diffusion models denoise images —
starting from a blurry global signal and progressively refining toward crisp
detail, pass by pass, without committing to fine structure before the coarse
shape is confirmed.

**Invoked for**: $ARGUMENTS

Use the project or feature name above as the subject throughout all passes.
If no argument was provided, ask the user what they're planning before
starting Pass 1.

**Core principle**: You cannot make good local decisions before global shape
is settled. Each pass reduces ambiguity across the *entire* system before any
part is zoomed into. Never detail one corner before the full silhouette is
approved.

---

## Output Quality Standard

Every pass output must meet all four of these bars before the exit condition
is accepted. Apply this as a checklist before asking the user to approve.

**Cohesive** — The output reads as one unified artifact, not a collection of
fragments. Each section tells a single story. If you removed one item and the
rest still made sense without it, the removed item probably doesn't belong.

**Concise** — Every word earns its place. No padding, no restating what was
already said in a prior pass. If a sentence can be cut without losing meaning,
cut it. Capability statements are one line. Vision is one paragraph. Module
descriptions are one sentence.

**Clear** — A developer unfamiliar with this conversation could read the
output cold and understand it without asking questions. No vague terms
("handles stuff", "manages things"). No ambiguous ownership. Every noun is
specific.

**Modular** — Each pass output is a self-contained artifact. It does not
require the reader to recall the conversation — all context it needs is either
in itself or explicitly referenced by name from a prior section. A section
should be cuttable and pasteable into `PLAN.md` without losing meaning.

---

## The Five Passes

Work through each pass in order. Do not advance until the exit condition is
met and explicitly confirmed by the user.

---

### Pass 1 — Vision (The Latent Vector)

**Goal**: Establish the irreducible core of what this thing is and why it
exists. This is the signal everything else will be decoded from.

**Ask the user:**
- What problem does this solve?
- Who experiences that problem? (could be yourself)
- What does success look like — what changes after this exists?

**Rules:**
- No tech. No features. No architecture.
- One paragraph maximum.
- If the user starts mentioning implementation details, gently redirect: "We'll
  get there — let's lock the 'why' first."

**Exit condition**: A single paragraph vision statement the user explicitly
approves. Write it out and ask: "Does this capture it?"

**Quality check before closing:**
- Cohesive: reads as one thought, not a list in disguise
- Concise: one paragraph, no filler phrases ("in order to", "the goal is to")
- Clear: a stranger could read it and know exactly what the tool does and why
- Modular: contains no jargon or context that requires knowing the conversation

**Output**: `## Vision` section in the plan doc.

---

### Pass 2 — Shape (The Silhouette)

**Goal**: Define the outer boundary of the system — what it can do, from the
user's perspective — without designing how.

**Ask the user:**
- What are the top-level things a user can *do* with this?
- What goes *in* and what comes *out*?
- What is explicitly out of scope?

**On out of scope**: Users often struggle to identify this themselves. If they
ask for help, offer candidates based on what is adjacent but not core — things
the system will touch but not own, or natural future extensions not needed now.
Confirm each candidate with the user rather than declaring it out of scope
unilaterally. Mark future-scope items with *(potential future scope)*.

**Rules:**
- Write capabilities as user-facing actions: "User can X"
- No implementation language. "Fetches from Jira" is fine. "Calls Jira REST
  API v3 with OAuth" is Pass 5.
- Keep the list flat. If you find yourself nesting, you're detailing too early.
- Flag anything that feels like a "maybe later" — capture it in an
  `Out of Scope` list, not the capability list.

**Exit condition**: A flat capability list + out of scope list, user confirms
scope feels right and complete.

**Quality check before closing:**
- Cohesive: capabilities are consistently formatted ("User can X"), not a mix of styles
- Concise: each capability is one line — if it needs two lines, it's two capabilities
- Clear: each item is unambiguous without reading any other item
- Modular: the list is complete enough that someone could scope the project from it alone

**Output**: `## Capabilities` and `## Out of Scope` sections.

---

### Pass 3 — Boundaries (The Architecture Skeleton)

**Goal**: Assign every capability to a module/layer. Define what each part
*owns* and what it *does not own*. No capability should be "homeless."

**Steps:**
1. Identify the major parts of the system (CLI layer, domain core, adapters,
   config, etc.)
2. For each capability from Pass 2, assign it to exactly one module
3. Define the contract between modules — what does each one expose to the
   others?
4. Flag any capability that doesn't fit cleanly — that's a design smell worth
   resolving now

**Existing tools vs. custom modules**: For any external integration, ask
whether a well-maintained CLI tool or SDK already covers the required
operations before planning a custom module. If one exists, a thin wrapper is
less code, better maintained, and already handles auth. Surface this tradeoff
explicitly — the answer can collapse a module entirely.

**Access probe**: For any module that reads from or writes to an external
system (repo, API, database, file store), ask: *"Who needs access to this,
and do they have it in the target environment?"* Access assumptions that go
unquestioned here become architecture rewrites during implementation.

**Command scope probe**: For every user-facing command, establish when it is
run: one-time on install, once per project, or on every invocation. A command
whose scope is ambiguous will be built for the wrong context.

**Data ownership vs. transport ownership**: When one module owns a data schema
and another module owns the system where that data lives, declare explicitly
which module executes the read/write. Leaving this implicit causes boundary
confusion when the storage mechanism changes.

**Rules:**
- Think in terms of *responsibility*, not implementation.
- A module should be describable in one sentence: "X owns Y and knows nothing
  about Z."
- Column header is "Does NOT own" — not "Does NOT touch."
- If two modules need to know too much about each other, consider merging or
  introducing an abstraction.

**Exit condition**: A module map where every capability is assigned, every
module has a one-sentence responsibility statement, and no capability is
shared ambiguously between two modules. User approves.

**Quality check before closing:**
- Cohesive: the module set tells a consistent architectural story — no module feels bolted on
- Concise: each responsibility statement is exactly one sentence, no exceptions
- Clear: the "Does NOT own" column is specific — not "other stuff", but named modules or concerns
- Modular: each row is independently readable; no row requires another row to make sense

**Output**: `## Module Map` section with ownership table.

---

### Pass 4 — Proof of Shape (The First Slice)

**Goal**: Trace the single most important user journey end-to-end through
every boundary defined in Pass 3. This validates that the architecture holds
before any code is written.

**Steps:**
1. Ask the user: "What is the one thing this tool *has* to do well above all
   else?"
2. Write a numbered narrative of that journey, one step per boundary crossed.
   Example:
   ```
   1. User runs CLI command with story ID
   2. CLI layer parses args, calls domain with StoryId
   3. Domain calls Jira adapter, receives Story struct
   4. Domain applies lifecycle rules, returns PlanContext
   5. CLI renders PlanContext to stdout / writes to file
   ```
3. Check: does the story flow naturally? Does any step feel forced or awkward?

**State persistence probe**: For any workflow that spans multiple steps or
sessions, ask how state is persisted, whether it needs to be shared across
machines or users, and who controls the storage location — do all users of
this tool have the necessary access permissions? This question often surfaces
new modules or changes existing boundaries. Ask it before the journey is
approved, not after.

**Command naming**: If the project has a CLI or command surface, establish the
naming convention during the journey narrative — not in Pass 5. Naming
decisions affect how steps are described and whether commands are standalone
or orchestrated. Surface the convention once and apply it consistently.

**Rules:**
- If the narrative feels wrong, fix the module map (Pass 3) before proceeding.
  Do not paper over architecture issues with implementation cleverness.
- The narrative should not mention *how* things are implemented — only *what*
  moves between which parts.
- Expect the journey to go through multiple revisions. Each revision that
  simplifies the architecture is the process working correctly — do not rush
  to lock.

**Exit condition**: A clean end-to-end narrative the user agrees "feels right."
If it doesn't feel right, loop back to Pass 3.

**Interaction Map extraction**: Once the narrative is approved, mechanically
derive the module interaction map from it. Do not design this — read it
directly off the journey steps:

```markdown
## Interaction Map

| Caller       | Calls          | Via                        |
|--------------|----------------|----------------------------|
| CLI          | Domain         | StartStoryCommand (struct) |
| CLI          | Jira Adapter   | getStory(id)               |
| CLI          | State Store    | saveActiveStory()          |
```

Rules for the interaction map:
- Only include interactions that appeared in the journey narrative — do not
  invent connections that weren't traced
- If a module appears only as a callee and never a caller, note it — that
  module is a pure leaf and should have zero internal imports from other
  modules
- If two modules call each other bidirectionally, flag it as a design smell
  before proceeding to Pass 5 — circular dependencies should be resolved at
  the architecture level, not worked around in code

**Output**: `## Core Journey` + `## Interaction Map` sections.

**Quality check before closing:**
- Cohesive: the narrative reads as one unbroken flow — each step hands off cleanly to the next
- Concise: each step is one line; the interaction map has no redundant rows
- Clear: every step names the module involved and what it receives or returns
- Modular: the journey narrative and interaction map are each independently readable artifacts

---

### Pass 4.5 — Journey Backlog (The Full Map, Coarsely)

**Goal**: Convert every capability from Pass 2 into an ordered list of
implementation slices — giving the whole system a rough shape before any
slice is detailed. This is the only time you look at the full picture before
narrowing to one slice.

**Steps:**
1. Take every capability from Pass 2 and convert it into a named journey
2. Identify dependency order — which journeys require another to exist first?
3. Rank by value: which journeys deliver the most signal earliest?
4. Produce the backlog table

**Example:**

```markdown
## Journey Backlog

| Priority | Journey               | Depends On | Modules                   | Notes                      |
|----------|-----------------------|------------|---------------------------|----------------------------|
| 1        | Start a story         | —          | Commands, State Store     | Entry point for everything |
| 2        | View current stage    | Slice 1    | Commands                  | Trivial once state exists  |
| 3        | Advance to next stage | Slice 1    | Commands, Domain          | Core lifecycle logic       |
| 4        | Generate PR desc      | Slice 3    | Planning Core, GitHub     | Needs stage context        |
| 5        | Mark story complete   | Slice 3    | Commands                  | Final lifecycle transition |
```

**Mocks-first build order**: When the system has external adapters (APIs, CLIs,
third-party services), recommend building with mocked adapters first, then
implementing real adapters in isolation, then integrating one at a time. This
validates orchestration logic before external dependencies are introduced and
surfaces integration issues one at a time. Structure the backlog to reflect
this order.

**Rules:**
- The backlog is the contract for the whole system — it tells you what exists
  and in what order, without detailing how
- Include a Modules column — it makes dependency and integration sequencing
  visible at a glance
- Do not detail any slice beyond its name, dependencies, modules, and a one-line note
- Dependency order is non-negotiable — a slice cannot be planned or built
  before its dependencies are implemented and validated
- If two capabilities are trivially coupled (building one takes 10% more
  effort to include the other), they can be merged into one slice — note it
- If a capability from Pass 2 doesn't appear here, it was implicitly deferred
  — make that explicit by adding it at the bottom with a "deferred" note

**Exit condition**: Every Pass 2 capability maps to exactly one backlog entry.
User approves the priority order. No capability is unaccounted for.

**Output**: `## Journey Backlog` section in `PLAN.md`. `STATUS.md` created alongside it.

**STATUS.md**: Create at the same time as the Journey Backlog. It is the build progress tracker — updated at the start of each Pass 5 session and after each slice is validated. Structure:

```markdown
# [Project Name] — Build Status

[← Plan](PLAN.md)

**Current slice:** Slice 1 — [slice name]
**Overall progress:** 1 of N slices (not started)

---

## Slice 1 — [Slice Name]

**Status:** Not started

| Deliverable | Status | Notes |
|---|---|---|
| `path/to/file.ts` | ✗ Missing | — |

### Acceptance Criteria

- [ ] criterion one
- [ ] criterion two

---

## Backlog

| Slice | Journey | Status |
|---|---|---|
| 1 | Slice name | ⬜ Not started |
| 2 | Slice name | ⬜ Not started |
```

Status values: `⬜ Not started` / `🔄 In Progress` / `✅ Complete`

**Quality check before closing:**
- Cohesive: the backlog reads as a logical progression — each slice builds on the last
- Concise: notes column is one phrase, not a sentence — enough to jog memory, not explain the slice
- Clear: dependency references are explicit ("Slice 1", not "the previous one")
- Modular: the table is the complete implementation contract — nothing lives outside it

**Important**: This pass produces the *rough* implementation plan for the
whole project. Pass 5 is run once per slice, on demand, only when that slice
is next in the backlog. Do not detail future slices in advance — implementation
of earlier slices will reveal information that changes how later ones should
be designed.

---

### Pass 5 — Implementation Planning (Per Slice, On Demand)

**Goal**: For the *next unbuilt slice in the backlog*, produce concrete
implementation detail sufficient for Claude Code to execute without ambiguity.

**When to run**: Only when the previous slice is implemented and validated.
Re-run this pass for each new slice as it becomes the next in line.
**Never run Pass 5 for multiple slices at once** — even if asked. One slice,
then stop.

**For each slice, define:**
- File names and locations
- Function/class signatures (not full implementations)
- External dependencies and why they were chosen
- What can be reused from previous slices vs. what is new
- Error cases and how they're handled
- Acceptance criteria — how do you know this slice is done?

**Slice file convention**: Write Pass 5 output to an individual slice file,
not appended to `PLAN.md`. File naming: `{NN}-{concise-slug}.slice.md` in
`docs/plans/{plan-name}/slices/`. Each slice file must include:
- Navigation links: `[← Plan](../PLAN.md)`, previous slice, next slice
- Depends On, Modules, Status fields in the header
- Full implementation plan and acceptance criteria

After writing the slice file:
1. Update the Journey Backlog row in `PLAN.md` to link to it
2. Update `STATUS.md` — set current slice, mark it `🔄 In Progress`, populate its deliverables table and acceptance criteria checklist from the slice file

Stub files for future slices (no Pass 5 content yet) are acceptable — they keep the navigation chain intact.

**Rules:**
- One slice at a time. Don't detail Slice 3 until Slice 2 is done.
- Each slice should be independently testable.
- If a slice touches more than 3 modules, it's probably two slices.
- Reference prior slice outputs rather than re-explaining shared foundations.

**Exit condition**: Implementation plan for the current slice is detailed
enough that Claude Code could execute it using only the plan doc as context,
with no further clarification needed.

**Quality check before closing:**
- Cohesive: file list, signatures, dependencies, and acceptance criteria tell one complete story
- Concise: signatures are stubs only — no inline logic, no comments explaining intent
- Clear: acceptance criteria are binary — each one either passes or fails, no grey area
- Modular: this slice section references prior slices by name for shared foundations rather than re-explaining them

**Output**: New `{NN}-{concise-slug}.slice.md` file. Journey Backlog row in `PLAN.md` linked. `STATUS.md` updated to reflect current slice in progress.

---

## Output Document Structure

After all passes, the plan skill produces a folder at `docs/plans/{plan-name}/`:

```
docs/plans/{plan-name}/
├── PLAN.md       # Full plan — all pass outputs (Passes 1–4.5)
├── STATUS.md     # Build progress tracker — current slice, checklist, backlog status
└── slices/
    ├── 01-{slug}.slice.md   # Pass 5 output for Slice 1
    ├── 02-{slug}.slice.md   # Pass 5 output for Slice 2
    └── ...
```

`{plan-name}` is derived from the project or feature name argument — kebab-cased, concise (e.g. `zen-story`, `auth-refactor`, `onboarding-flow`).

`PLAN.md` structure:

```markdown
# [Project Name] — Plan

## Vision
[One paragraph from Pass 1]

## Capabilities
- User can X
- User can Y
...

## Out of Scope
- X
- Y

## Module Map
| Module | Owns | Does NOT own |
|--------|------|--------------|
| ...    | ...  | ...          |

## Command Surface
| Command | Type |
|---------|------|
| ...     | ...  |

## Core Journey
1. ...
2. ...
...

## Interaction Map
| Caller | Calls | Via |
|--------|-------|-----|
| ...    | ...   | ... |

## Journey Backlog
| Priority | Journey | Depends On | Modules | Notes |
|----------|---------|------------|---------|-------|
| 1        | [Slice name](slices/01-slug.slice.md) | — | ... | ... |
| ...      | ...     | ...        | ...     | ...   |
```

**Command Surface section**: Include whenever the project has a user-facing
command surface (CLI, slash commands, scripts). Columns: Command, Type. Types
are: "User-invoked", "Orchestrator", "Stage command (called by X)",
"Scheduled/background trigger".

**Slice files**: `docs/plans/{plan-name}/slices/{NN}-{slug}.slice.md` — one per backlog entry, stub or full. Journey Backlog rows link to them.

This folder becomes the project's plan and should be referenced from `CLAUDE.md`:
- Plan: `docs/plans/{plan-name}/PLAN.md`
- Build status: `docs/plans/{plan-name}/STATUS.md`

---

## Facilitator Notes

- **Pace the user.** Some users want to blast through all passes in one
  session. That's fine, but make sure each exit condition is genuinely met —
  don't rubber-stamp a pass just because the user is eager to move on.

- **Protect the passes.** If the user jumps ahead (starts talking about
  database schemas in Pass 2), acknowledge it, park it ("good detail, let's
  capture that for Pass 5"), and redirect.

- **Name the smells.** If something feels architecturally off during Pass 3 or
  4, say so explicitly rather than quietly working around it. The plan is
  supposed to catch these before implementation, not hide them.

- **The plan is a living document.** If implementation reveals the plan was
  wrong in some way, return to the appropriate pass and re-run forward from
  there. Don't just patch the code — patch the plan first.

- **Let the journey breathe.** The Core Journey in Pass 4 often goes through
  many revisions as the user catches ordering issues, naming decisions, or
  concurrency questions. This is the process working correctly — do not rush
  to lock the journey. Each revision that simplifies the architecture is worth
  the extra turns.

- **One Pass 5 at a time.** Never produce implementation detail for more than
  one slice in a single session, even if asked. Future slices will change based
  on what earlier slices reveal. Stub files are fine — full detail is not.

- **Audit before locking.** After Pass 3 and again after Pass 4, suggest
  running `/zen-tool-plan-audit` to surface assumptions that could require
  rework. This is especially important before beginning implementation.

- **Amend don't patch.** If a finding during implementation invalidates part
  of the plan, do not patch just the code or just one doc. Run
  `/zen-tool-plan-amend` to propagate the change consistently across all plan
  artifacts before continuing.

---

## References

- `references/pass-examples.md` — Annotated examples of good vs. bad pass
  outputs (create this after the first real project run)
