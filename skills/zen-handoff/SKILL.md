---
name: zen-handoff
description: >
  Pass workflow ownership to another team member. Sends a Teams notification
  with resume instructions and updates assigned_to in state.json.
---

# zen-handoff

Transfer a story workflow to another team member.

---

## Usage

```
/zen-handoff [story_id]
```

---

## Steps

### 1 — Resolve story ID

If not provided, list stories where `assigned_to` matches the current user's
email (read from `JIRA_EMAIL` env var). Present a numbered list.

---

### 2 — Validate story state

```bash
source scripts/zenflow-store-state.sh
state_json=$(state_read "$story_id")
stage=$(echo "$state_json" | jq -r '.stage')
```

If `stage == "complete"`:

```
Cannot hand off $story_id — workflow is already complete.
```

Exit.

---

### 3 — Prompt for recipient

```
Hand off to (email): _
```

---

### 4 — Send Teams notification

```bash
source scripts/notifier-adapter.sh
notify_teams "$story_id" \
  "Handoff: $story_id — $title
Assigned to: $recipient_email
Stage: $stage (slice $current_slice / $total_slices)
To resume: /zen-resume $story_id"
```

---

### 5 — Update state

```bash
state_write "$story_id" "{\"assigned_to\": \"${recipient_email}\"}"
```

---

### 6 — Confirm

```
Handoff complete.

  Story  : $story_id — $title
  To     : $recipient_email
  Stage  : $stage (slice $current_slice / $total_slices)

$recipient_email has been notified via Teams.
Note: Git branch access and GitHub PR reviewers are not transferred automatically.
```
