---
name: review
description: Quick code review of staged or unstaged changes
---

Review my current code changes for bugs, security issues, and quality problems.

## Steps

1. Run `git diff` to see unstaged changes and `git diff --cached` to see staged changes
2. If no changes found, run `git diff HEAD~1` to review the last commit
3. Use the code-reviewer agent (read-only) to analyze the changes
4. Report findings grouped by severity: CRITICAL, HIGH, MEDIUM
5. Skip style issues — the auto-format hook handles those

## Output

Provide a concise summary:
- Number of files changed
- Issues found (grouped by severity)
- Overall assessment: ship it / fix these first / needs rethinking
