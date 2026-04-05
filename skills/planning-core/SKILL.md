---
name: planning-core
description: >
  Real Planning Core — generates sliced implementation plans, technical design
  summaries, and PR descriptions from story context. Called by story-plan and
  story-create-pr. Not a user-facing command.
disable-model-invocation: false
---

# Planning Core

Generates implementation artifacts from story context. Called internally by
`story-plan` and `story-create-pr`.

> **Note (Slice 7):** Tested in isolation before being wired into stage commands
> in Slice 10. Until then, `mock-planning-core.sh` handles generation.

---

## Operation: Generate Implementation Plan

**Called by:** `story-plan`

**Inputs:** `story_id`, `title`, `description`, `target_branch`, answers to
any clarifying questions

**Output:** Written to `/tmp/zenflow-plan-$story_id/` (same structure as
`mock-planning-core.sh`) so `story-plan` can call `state_write_plan` unchanged.

### How to generate the plan

1. Read the story title and description carefully.
2. Identify the implementation work required. Break it into ordered,
   independently testable slices. Each slice should:
   - Have a single clear goal
   - Be completable in one focused session
   - Not depend on a later slice
   - Include 3–6 concrete tasks and a "done when" criterion

3. Write `plan.md`:
   - Story ID and title
   - Target branch
   - Slice table (number, name, one-line notes)
   - Key assumptions made during planning

4. Write `status.md`:
   - Slice table with `⬜ Not started` for all rows

5. Write one `{NN}-{slug}.slice.md` per slice:
   - Slice goal (one sentence)
   - Task list (checkboxes)
   - "Done when" criterion (binary — pass or fail)

6. Print the output directory path to stdout.

### Slice sizing guidance

- 1–3 slices: small story (UI tweak, config change, single endpoint)
- 4–6 slices: medium story (new feature with tests)
- 7+ slices: consider whether the story should be split in Jira

---

## Operation: Generate PR Description

**Called by:** `story-create-pr`

**Inputs:** `plan.md` content, story title, story ID

**Output:** Markdown string printed to stdout

### Format

```markdown
## Summary
<1–3 sentences: what this PR does and why>

## Implementation Notes
<non-obvious decisions made during implementation — skip if nothing notable>

## Testing
<how to verify the changes: what to run, what to look for>
```

Keep the description concise. The plan in `~/.zenflow/$story_id/plan.md` is
the full record — the PR description is the reviewer's entry point.
