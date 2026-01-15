# /merge-pr – Squash-merge the current branch PR into develop

You are Cursor Agent in this repo. Your job is to squash-merge the PR for the current branch into `develop` using GitHub CLI and my `scripts/merge_pr.sh`.

Follow this procedure:

1. Run `git rev-parse --abbrev-ref HEAD` to determine the current branch.
   - If the branch is `develop`, ask which feature branch to merge and switch to it with `git checkout <branch>`.

2. Verify that a PR exists for this branch:
   - Run `gh pr status`.
   - Confirm there is exactly one open PR for the current branch.
   - If none or multiple PRs are found, stop and ask me what to do.

3. Check PR readiness:
   - From `gh pr status`, make sure checks are passing and reviews look OK.
   - If checks are failing or missing, warn me and ask for confirmation before continuing.

4. After my explicit confirmation, run:

   ```bash
   bash scripts/merge_pr.sh
   ```

5. When the script finishes:
   • Summarize which PR was merged (number and title if available).
   • Confirm that it was merged with squash.
   • Confirm that the remote and local feature branch were deleted (if they were).
   • Confirm that develop is up to date and currently checked out.

Important rules:
• Do not modify code files in this command.
• Only interact with git and GitHub via gh and the merge script.
• If anything about merge safety is unclear, ask me before running the merge.
