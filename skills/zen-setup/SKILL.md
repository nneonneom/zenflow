---
name: zen-setup
description: >
  One-time global setup for Zenflow. Configures credentials for Jira, GitHub,
  and Teams. Run once after installing the plugin — not per project.
disable-model-invocation: true
---

# Zen Setup

One-time credential setup for Zenflow. Run this once after installing the
plugin. No need to re-run when switching projects — per-project state is
handled automatically when you run `/zen-story`.

> **Important:** All zen-* commands must be run from inside the project repo
> you intend to work on. Zenflow identifies the project via
> `git remote get-url origin`.

---

## Steps

### 1 — Jira credentials

Check whether the following vars are set in `~/.claude/settings.json` under
`env`. If any are missing, prompt the user for the value and write it using
`scripts/claude-set-env.sh`:

| Var | Description |
|---|---|
| `JIRA_BASE_URL` | e.g. `https://yourcompany.atlassian.net` |
| `JIRA_EMAIL` | Atlassian account email |
| `JIRA_API_TOKEN` | Atlassian API token — generate at id.atlassian.com/manage-profile/security/api-tokens |

```bash
scripts/claude-set-env.sh JIRA_BASE_URL "<value>"
scripts/claude-set-env.sh JIRA_EMAIL "<value>"
scripts/claude-set-env.sh JIRA_API_TOKEN "<value>"
```

### 2 — GitHub CLI

Run: `gh auth status`

- If not installed: tell the user to install `gh` from https://cli.github.com and re-run `/zen-setup`.
- If unauthenticated: tell the user to run `gh auth login` and re-run `/zen-setup`.
- If authenticated: note the active account and continue.

### 3 — Teams webhook *(optional — skip until Slice 8)*

If `TEAMS_WEBHOOK_URL` is already set, confirm and move on. If not, inform
the user it is not required yet and will be configured in a later setup step.

### 4 — Confirm setup complete

Print a short confirmation:

```
Zenflow setup complete.

  Jira        : <JIRA_BASE_URL> (<JIRA_EMAIL>)
  GitHub      : <active gh user>
  Teams       : <set | not configured yet>

Run /zen-story from inside any project repo to start a story workflow.
```
