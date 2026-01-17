# /create-pr – Open a Conventional Commit PR for the current branch

You are Cursor Agent running in this repo. Your job is to **fully automate PR creation** into `develop` with a Conventional Commit–style title and a good PR body.

Follow this procedure step by step:

1. Run `git status --short` to ensure there are no uncommitted changes.
   - If there are changes, STOP and ask me whether to handle them manually.
   - Do **not** auto-commit in this command.

2. Run `git rev-parse --abbrev-ref HEAD` to get the current branch name.
   - If the branch is `develop`, ask me to switch to a feature branch.

3. Understand the changes:
   - Prefer `git diff --stat origin/develop...HEAD` if `origin/develop` exists, otherwise `git diff --stat` against the local develop.
   - Optionally inspect `git log --oneline origin/develop..HEAD` for extra context.

4. Based on the diff, choose a **Conventional Commit** style title (Conventional Commits v1.0.0):
   - Format: `<type>([optional scope]): <description>`
   - Common types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`.
   - Use imperative, present-tense, concise (< ~72 chars).
   - Example: `feat(auth): add passwordless login`.

5. Generate a detailed **PR body** in Markdown with these sections:
   - `## Summary` – one short paragraph describing the feature or fix.
   - `## Changes` – bullet list of the main code changes.
   - `## Testing` – how it was tested (commands run, environments).
   - `## Breaking Changes` – describe any breaking changes or write `None`.

6. Show me the proposed **title + body** in the chat and ask for “yes/no” confirmation.
   - If I say “no”, refine them and ask again.

7. After I approve the title and body, call the shell script:

   ```bash
   bash scripts/open_pr.sh "<exact title>" "<exact body>"
   ```

   • Carefully escape quotes so the title and body are passed correctly.

8. When the script finishes:
   • Show the command output.
   • If gh prints the PR URL, echo it clearly as: PR created: <url>.
   • Remind me that the PR title will become the final squash commit message on develop.

Important rules for this command:
• Do not modify code files here. Only:
• inspect git state
• generate title/body
• run scripts/open_pr.sh.
• If anything looks unsafe or ambiguous, ask me before running terminal commands.
