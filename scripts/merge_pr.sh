#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-develop}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
  echo "You are on $BASE_BRANCH; checkout the feature branch with the open PR first." >&2
  exit 1
fi

echo "Squash-merging PR for branch $CURRENT_BRANCH..."
# This targets the PR associated with the current branch
gh pr merge \
  --squash \
  --delete-branch

echo "Updating local $BASE_BRANCH..."
git checkout "$BASE_BRANCH"
git pull --ff-only origin "$BASE_BRANCH"

echo "Cleaning up local branch $CURRENT_BRANCH (if it still exists)..."
git branch -d "$CURRENT_BRANCH" || true

echo "Done. Branch $CURRENT_BRANCH was squash-merged into $BASE_BRANCH."
