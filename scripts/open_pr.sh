#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-develop}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
  echo "You are on $BASE_BRANCH; switch to a feature branch first." >&2
  exit 1
fi

# Require a clean working tree (AI should handle commits separately)
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Uncommitted changes detected. Please commit or stash before creating a PR." >&2
  exit 1
fi

PR_TITLE="${1:-}"
PR_BODY="${2:-}"

if [[ -z "$PR_TITLE" ]]; then
  echo "Usage: $0 \"<Conventional Commit style title>\" \"[PR body]\"" >&2
  exit 1
fi

echo "Fetching latest from origin..."
git fetch origin

echo "Syncing $BASE_BRANCH..."
git checkout "$BASE_BRANCH"
git pull --ff-only origin "$BASE_BRANCH"

echo "Rebasing $CURRENT_BRANCH onto $BASE_BRANCH..."
git checkout "$CURRENT_BRANCH"
git rebase "origin/$BASE_BRANCH"

echo "Pushing branch to origin..."
git push -u origin "$CURRENT_BRANCH"

echo "Creating PR on GitHub..."
gh pr create \
  --base "$BASE_BRANCH" \
  --head "$CURRENT_BRANCH" \
  --title "$PR_TITLE" \
  --body "$PR_BODY"

echo "Done. This PR's title will become the squash commit on $BASE_BRANCH."
