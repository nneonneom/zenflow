---
name: story-implement
description: >
  Stage command for zen-story. Reads the current slice from the State Store,
  executes it (Claude writes the code), notifies Teams at key points, then
  updates state.json and status.md. Repeats until all slices are complete.
  Called by zen-story — not invoked directly by the user.
disable-model-invocation: true
---

# story-implement

Stage command called by `zen-story`. Executes implementation slices one at a
time, updating state after each one. Loops until all slices are complete.

> **Note (Slice 4):** Teams notifications use `scripts/mock-teams-notifier.sh`.
> Real notifier-adapter is wired in Slice 10.

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `story_id` | Passed by `zen-story` | Yes |
| `total_slices` | Passed by `zen-story` | Yes |

---

## Steps

### 1 — Load state

```bash
source scripts/zenflow-store-state.sh
state_json=$(state_read "$story_id")
current_slice=$(echo "$state_json" | jq -r '.current_slice')
total_slices=$(echo "$state_json" | jq -r '.total_slices')
```

---

### 2 — Execute slices (loop)

Repeat steps 2a–2d for each slice from `current_slice` to `total_slices`.

#### 2a — Load slice file

```bash
slice_file=$(printf "%02d-*.slice.md" "$current_slice")
slice_content=$(cat ~/.zenflow/$story_id/slices/$slice_file)
```

Print the slice goal and task list from the slice file so the user can see
what is being worked on.

#### 2b — Implement the slice

Read the slice goal and tasks. Implement the code changes described. Use
judgment for anything underspecified — state assumptions in comments.

If a task requires information that cannot be determined from the slice file
or the repo state, send a Teams notification and ask the user:

```bash
bash scripts/mock-teams-notifier.sh "$story_id" \
  "Input needed for slice $current_slice: <question>"
```

Wait for the user's reply before continuing.

#### 2c — Confirm slice complete

After implementing, ask:

```
Slice $current_slice of $total_slices complete. Continue to next slice? [y/n]
```

*(In automated invocation from zen-story with no user present, proceed
automatically.)*

#### 2d — Update state

Mark the slice done in `status.md`:

Read `~/.zenflow/$story_id/status.md`, change `⬜ Not started` → `✅ Complete`
for the current slice row, and write it back:

```bash
state_write_plan "$story_id" \
  "$(state_read_plan "$story_id")" \
  "$(cat ~/.zenflow/$story_id/status.md | sed "s/| $current_slice |.*⬜ Not started/| $current_slice | ... | ✅ Complete/")" \
  ""
```

Increment `current_slice` in state.json:

```bash
next_slice=$((current_slice + 1))
state_write "$story_id" "{\"current_slice\": $next_slice}"
```

---

### 3 — All slices complete

When `current_slice` exceeds `total_slices`, send a completion notification:

```bash
bash scripts/mock-teams-notifier.sh "$story_id" \
  "All $total_slices slices complete for $story_id. Proceeding to PR creation."
```

Print confirmation:

```
All slices complete.

  Story       : $story_id
  Slices done : $total_slices / $total_slices
  Next        : story-create-pr

Passing context to zen-story…
```

Return context to `zen-story`:

```
story_id:     $story_id
slices_done:  $total_slices
```
