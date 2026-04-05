#!/usr/bin/env bash
# Zenflow repo-adapter — real GitHub operations via gh CLI.
# Built in Slice 9. Used by zen-story from Slice 10 onward.
# Requires: gh CLI (authenticated via gh auth login), git.
#
# Source this file to use the functions below. Never invoke directly.

set -euo pipefail

# Create and push a feature branch from base_branch.
# Usage: repo_create_branch <branch_name> <base_branch>
repo_create_branch() {
  local branch_name="$1" base_branch="${2:-main}"

  git checkout "$base_branch"
  git pull origin "$base_branch"
  git checkout -b "$branch_name"
  git push -u origin "$branch_name"
  echo "Branch created: ${branch_name}"
}

# Create a GitHub PR and print the PR URL to stdout.
# Usage: repo_create_pr <title> <body> <head_branch> <base_branch>
repo_create_pr() {
  local title="$1" body="$2" head="$3" base="${4:-main}"

  gh pr create \
    --title "$title" \
    --body "$body" \
    --head "$head" \
    --base "$base" \
    --no-maintainer-edit
}

# Print PR state and review summary to stdout as JSON.
# Usage: repo_get_pr_status <pr_url>
repo_get_pr_status() {
  local pr_url="$1"
  gh pr view "$pr_url" --json state,reviewDecision,reviews \
    | jq '{state: .state, reviewDecision: .reviewDecision, reviews: [.reviews[] | {author: .author.login, state: .state}]}'
}

# Print PR review comments to stdout as JSON array.
# Usage: repo_get_pr_comments <pr_url>
repo_get_pr_comments() {
  local pr_url="$1"
  gh pr view "$pr_url" --json reviews \
    | jq '[.reviews[] | select(.state == "CHANGES_REQUESTED") | {author: .author.login, body: .body}]'
}
