## Setup

Run once before using any zen-* commands:

```bash
scripts/claude-set-env.sh JIRA_BASE_URL "https://yourcompany.atlassian.net"
scripts/claude-set-env.sh JIRA_EMAIL "you@yourcompany.com"
scripts/claude-set-env.sh JIRA_API_TOKEN "<token>"
```

This writes values to `~/.claude/settings.json` so they're available in any Claude Code session.
For all required env vars see `docs/state-schema.md`.

State is stored in `~/.zenflow/` by default (local adapter). Set `ZENFLOW_STATE_ADAPTER=api` to use the DynamoDB+S3 API adapter for cross-machine access.

> **Important:** Run `zen-story` from inside the project repo — it needs `git` for branch and PR operations. `zen-epic` can be run from anywhere.

## Skills

The following skills are available for this project:

- **zen-tool-plan** — `skills/zen-tool-plan/SKILL.md`
  Use when planning any new tool, CLI, service, or plugin from scratch.

- **zen-tool-plan-audit** — `skills/zen-tool-plan-audit/SKILL.md`
  Use after Pass 3 and Pass 4 to surface assumptions and risks before implementation begins.

- **zen-tool-plan-amend** — `skills/zen-tool-plan-amend/SKILL.md`
  Use when a finding during implementation invalidates part of the plan — propagates changes consistently across all artifacts.

See `docs/zen-planning-methodology.md` for shared planning principles and artifact structure.

## Plans

- **Zenflow — Story Workflow** — `docs/plans/zen-story-mvp-1/PLAN.md`
  Full project plan: vision, capabilities, module map, core journey, interaction map, and journey backlog.
  Build status and current slice: `docs/plans/zen-story-mvp-1/STATUS.md`