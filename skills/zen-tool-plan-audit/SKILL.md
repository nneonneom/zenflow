---
name: zen-tool-plan-audit
description: >
  Proactively audits a tool plan for assumptions and risks that could require
  rework during implementation. Run after Pass 3 and again after Pass 4
  before beginning any implementation work. See docs/zen-planning-methodology.md.
argument-hint: "[path to PLAN.md]"
disable-model-invocation: true
---

# Zen Tool Plan Audit

Adversarial review of a tool plan in progress. Where `zen-tool-plan` builds
forward, this skill attacks the plan looking for what could break. The goal
is to surface assumptions before they become architecture rewrites. See
[docs/zen-planning-methodology.md](../../docs/zen-planning-methodology.md) for shared principles.

**Invoked for**: $ARGUMENTS

If no plan path was provided, ask the user which plan to audit before
starting.

---

## When to Run

- After Pass 3 (Module Map locked, before Core Journey is traced)
- After Pass 4 (Core Journey locked, before implementation begins)
- Any time the user has a nagging feeling something was assumed rather than confirmed

---

## Process

### 1 — Read the plan

Read the full plan doc at the provided path. Identify:
- All modules and their stated ownership
- All external systems the plan touches (APIs, repos, databases, CLIs, file stores)
- All user-facing commands and their implied scope
- Any state persistence described
- All assumptions stated or implied

### 2 — Run the audit checklist

Work through each category. For every finding, record:
- **Assumption** — what was assumed
- **Risk** — what breaks if the assumption is wrong
- **Recommended action** — confirm, redesign, or explicitly defer

#### Access & Permissions
- Does every module that writes to an external system have confirmed write access in the target environment?
- Are there org policies (repo ownership, API token scopes, network restrictions) that could block any integration?
- If state is persisted externally, do all users of this tool have access to that location?

#### Module Boundaries
- Is every capability assigned to exactly one module? Flag any that feel shared.
- For every module that owns data stored in a system another module owns — is it explicit which module executes the I/O?
- Do any two modules know too much about each other's internals?

#### Command Scope
- For every user-facing command: is it clear whether it runs once on install, once per project, or on every invocation?
- Could any command be accidentally run in the wrong context (wrong repo, wrong environment)?

#### External Dependencies
- For every external CLI, SDK, or API: has it been confirmed it exists, is maintained, and is accessible in the target environment?
- Are there version or auth requirements that haven't been stated?

#### State & Persistence
- If the workflow spans sessions or machines: is the persistence mechanism confirmed to be accessible from all required contexts?
- Is there a concurrent write risk if multiple users run the tool simultaneously?

#### Organizational Constraints
- Are there team boundaries, access control policies, or infrastructure constraints not yet surfaced?
- Does the plan assume any permissions or resources that require approval or provisioning?

### 3 — Produce the audit report

Group findings by severity:

**Blocking** — if not resolved, this will require an architecture change during implementation.

**Notable** — worth confirming before building, but unlikely to require a redesign.

**Deferred risk** — acknowledged, low probability, can be revisited later.

Format:

```markdown
## Audit Report — [Plan Name]

### Blocking
- **[Assumption]**: [what was assumed]
  Risk: [what breaks]
  Action: [what to do before proceeding]

### Notable
- ...

### Deferred Risk
- ...

### No findings
- [category]: confirmed clean
```

### 4 — Recommend next step

- If there are blocking findings: recommend running `/zen-tool-plan-amend` for each one before continuing
- If findings are only notable or deferred: present them to the user and ask which to resolve now vs. defer
- If no findings: confirm the plan is clear to proceed to the next pass or to implementation

---

## Output

The audit report is conversational — present it inline, not written to a file.
If the user wants it saved, append it to the relevant slice file or a
`docs/plans/{plan-name}/audit.md` file.
