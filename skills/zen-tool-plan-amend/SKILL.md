---
name: zen-tool-plan-amend
description: >
  Propagates a plan-changing finding consistently across all affected tool
  plan artifacts. Run when a discovery during implementation invalidates part
  of the plan — do not patch docs individually. See docs/zen-planning-methodology.md.
argument-hint: "[path to PLAN.md]"
disable-model-invocation: true
---

# Zen Tool Plan Amend

Reactive change propagation. When a finding — a new constraint, a wrong
assumption, an architectural flaw — invalidates part of a tool plan, this
skill drives the change from decision through to every affected artifact.

The goal is consistency: no stale references, no docs that contradict each
other, no plan that diverges from reality. See
[docs/zen-planning-methodology.md](../../docs/zen-planning-methodology.md) for shared principles
and artifact structure.

**Invoked for**: $ARGUMENTS

If no plan path was provided, ask the user which plan is being amended before
starting.

---

## Process

### 1 — Understand the finding

Ask the user:
- What was discovered?
- Which part of the plan does it invalidate?
- Is this a constraint (external, organizational), a design flaw, or new information?

Do not jump to solutions yet. Make sure the finding is fully understood first.

### 2 — Impact analysis

Read the full plan at the provided path. Identify every artifact that references
or depends on the invalidated part:

- `PLAN.md` — which sections reference it? (Vision, Capabilities, Module Map,
  Core Journey, Interaction Map, Journey Backlog)
- `STATUS.md` — does the current slice or any backlog entry reference it?
- Slice files — which slice files reference the invalidated design?
- Supporting docs (state schema, adapter docs, config docs) — any references?
- Code or scripts already written — does any implementation assume the old design?

Present the full impact list to the user before proposing any changes.

### 3 — Evaluate options

For the invalidated part, propose two to three concrete alternatives. For each:
- What changes
- What stays the same
- What new risks or tradeoffs it introduces

Keep options at the architecture level — not implementation detail.

### 4 — Confirm the decision

Present options clearly and ask the user to choose. Do not proceed until a
decision is confirmed. Record the decision and the reason it was chosen.

### 5 — Revision summary

Before touching any file, present a concise summary table of every planned
change and ask the user to confirm:

| File | What will change |
|---|---|
| `PLAN.md` | … |
| `slices/XX-*.slice.md` | … |
| … | … |

Do not proceed until the user approves the revision summary.

### 6 — Propagate the change

Update every artifact identified in the impact analysis, in this order:

1. `PLAN.md` — update the affected sections; review the Journey Backlog and
   revise any entry whose description, dependencies, modules, or notes are
   invalidated by the change
2. Slice files — update any that reference the old design; for slices already
   marked complete, add an architecture note and reconcile the Files table,
   function references, and error cases against the actual code — note anything
   not implemented or deferred rather than silently removing it
3. Supporting docs — update schema docs, config docs, adapter docs
4. `STATUS.md` — update notes and backlog entries if the current slice or any
   listed slice is affected
5. Code/scripts — update any implementation that assumed the old design

For each file updated, state what changed and why.

### 7 — Consistency check

After all updates, re-read the full plan and verify:
- No section still references the old design
- No two sections contradict each other
- The Interaction Map still matches the Core Journey
- Module ownership is still unambiguous for the changed area

If any inconsistency is found, fix it before closing.

### 8 — Confirm amendment complete

Summarise:
- What changed
- Why it changed
- Every file updated
- Any follow-on risks introduced by the change that should be tracked

If new risks were introduced, recommend running `/zen-tool-plan-audit` on the
updated plan.

---

## Output

Changes are made directly to plan files. The amendment summary is presented
inline — no separate file needed unless the user asks for a change log.
