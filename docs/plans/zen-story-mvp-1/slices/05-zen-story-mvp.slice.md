# Slice 5 — `zen-story` MVP End-to-End with All Mocks

[← Plan](../PLAN.md) | [← Slice 4: `story-implement` Mocked](04-story-implement-mocked.slice.md) | [Slice 6: Real Jira Adapter →](06-jira-adapter.slice.md)

**Depends on:** Slice 4
**Modules:** Commands / Workflows, State Store
**Status:** Not started

---

## Implementation Plan

### Files

| File | Purpose |
|---|---|
| `skills/zen-story/SKILL.md` | Main orchestrator — calls stage commands in sequence, manages state transitions |
| `skills/story-create-pr/SKILL.md` | Stage command — generates PR description, creates PR via mock repo adapter |
| `scripts/mock-repo-adapter.sh` | Mock repo adapter — fakes branch creation and PR creation; replaced in Slice 10 |

---

### `mock-repo-adapter.sh` Interface

```bash
bash scripts/mock-repo-adapter.sh --create-branch <story_id> <branch_name>
# Prints: [MOCK repo] Branch created: <branch_name>

bash scripts/mock-repo-adapter.sh --create-pr <story_id> <title> <head_branch> <base_branch>
# Prints: https://github.com/mock-org/mock-repo/pull/<random-number>
```

---

### `zen-story` Orchestration Order

1. Check for existing state → exit with resume/reset instructions if found
2. `story-start` → story context
3. `story-plan` → approved plan, total_slices
4. `mock-repo-adapter --create-branch` → branch created; write `feature_branch` to `state.json`
5. `story-implement` → all slices executed
6. `story-create-pr` → PR URL
7. Write `stage: review`, `pr_url` to `state.json`; print handoff summary

---

### `story-create-pr` Behavior

1. Read `feature_branch` and `target_branch` from `state.json`
2. Read `plan.md` from State Store to inform PR description
3. Generate PR description (Summary, Implementation Notes, Testing)
4. Call `mock-repo-adapter --create-pr` → capture PR URL
5. Write PR URL to `state.json`
6. Return PR URL to `zen-story`

---

### Branch Naming Convention

```
zenflow/{story_id}-{slugified-title}
```

Title is lowercased, non-alphanumeric characters replaced with `-`, truncated at 50 characters.
Example: `PROJ-101` + "Add login page" → `zenflow/PROJ-101-add-login-page`

---

### State Transitions in This Slice

| Step | `stage` | Other fields written |
|---|---|---|
| After branch creation | `planning` | `feature_branch` |
| After PR creation | `review` | `pr_url` |

---

### Reuse from Prior Slices

- All stage command skills (story-start, story-plan, story-implement) from Slices 2–4
- `scripts/zenflow-store-state.sh` — `state_read`, `state_write`
- `scripts/mock-jira-story.sh`, `mock-planning-core.sh`, `mock-teams-notifier.sh`

---

## Acceptance Criteria

- [ ] Running `/zen-story` without args presents a story list and completes the full workflow
- [ ] Running `/zen-story PROJ-101` completes the full workflow for that story
- [ ] Running `/zen-story PROJ-101` when state already exists shows resume/reset instructions and exits
- [ ] Feature branch name follows `zenflow/{story_id}-{slug}` convention
- [ ] `state.json` `feature_branch` is written after branch creation
- [ ] `state.json` `stage` is `review` and `pr_url` is set after PR creation
- [ ] PR description contains Summary, Implementation Notes, and Testing sections
- [ ] Handoff summary printed at end shows story ID, branch, PR URL, and stage
