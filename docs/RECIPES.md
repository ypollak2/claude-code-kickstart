# Recipes

End-to-end workflows that chain together kickstart tools. Each recipe is a real-world task you can run today.

---

## 1. New Project Onboarding (5 minutes)

You just cloned a repo you've never seen. Get productive fast.

```bash
cd the-project

# Auto-detect stack and install the right profile
/path/to/claude-code-kickstart/install.sh --auto

# Generate CLAUDE.md by scanning the project
ccscan

# Get a high-level overview
cce src/

# Check for obvious issues
ccreview
```

**What happens**: The installer detects your stack, installs matching permissions and agents. `ccscan` reads package.json/Cargo.toml/etc. and generates a CLAUDE.md with your tech stack, commands, and architecture. Now Claude understands your project.

---

## 2. Feature Development (TDD workflow)

Build a feature the safe way — tests first, then implementation.

```bash
# 1. Plan the feature
claude "Use the planner agent to create an implementation plan for: <feature description>"

# 2. Write tests first
cctest src/features/my-feature.ts

# 3. Implement until tests pass
ccfix

# 4. Refactor if needed
ccrefactor src/features/my-feature.ts

# 5. Review before committing
ccreview

# 6. Commit
cccommit
```

---

## 3. PR Review Pipeline

Thorough PR review using multiple agents in sequence.

```bash
# Review the PR (reads all commits, not just the diff)
ccpr 42

# Or review your own changes before pushing
ccreview

# Security check
claude "Use the security-auditor agent to scan the changes in this PR"

# Performance check
claude "Use the performance-analyzer agent to check for bottlenecks in the recent changes"
```

---

## 4. Bug Investigation

Systematic debugging, not guesswork.

```bash
# Option A: You know roughly when it broke
ccbisect "the login form stopped validating email addresses"

# Option B: You have a failing test
claude "Use the debugger agent to investigate and fix this: <paste error>"

# Option C: No test exists yet
cctest src/auth/login.ts   # Write a test that reproduces the bug
ccfix                       # Fix it and verify
```

---

## 5. Dependency Upgrade

Safely upgrade major dependencies.

```bash
# Let the migrator handle it
claude "Use the migrator agent to upgrade React from 18 to 19. Follow the official migration guide."

# Or for multiple deps
claude "Use the migrator agent to upgrade all outdated dependencies. One at a time, running tests between each."
```

**Key**: The migrator agent reads changelogs, finds all usages of changed APIs, and runs tests between each change. Never upgrades multiple major deps at once.

---

## 6. API Design Session

Design an API before implementing it.

```bash
# Design the contract
claude "Use the api-designer agent to design a REST API for user management with: registration, login, profile CRUD, and password reset"

# Review the design
claude "Use the code-reviewer agent to review the API design for consistency and completeness"

# Implement
claude "Implement the user management API following the design we just created"
```

---

## 7. Codebase Health Check

Run this weekly to catch issues before they become problems.

```bash
# Check your kickstart setup
cchealth

# Security audit
claude "Use the security-auditor agent to scan the entire project for vulnerabilities"

# Performance check
claude "Use the performance-analyzer agent to find performance bottlenecks in this project"

# Review test coverage
claude "Check test coverage and identify critical paths without tests. Use the test-writer agent to fill gaps."
```

---

## 8. Documentation Sprint

Generate docs from code, not imagination.

```bash
# Generate README
claude "Use the doc-writer agent to create a README.md for this project"

# Generate API docs
claude "Use the doc-writer agent to document all public API endpoints"

# Architecture overview
claude "Use the doc-writer agent to create an architecture guide explaining the project structure and key design decisions"
```

---

## 9. Git History Cleanup

Clean up before merging a feature branch.

```bash
# Interactive rebase guidance
ccrebase

# Or specific tasks
claude "Use the git-assistant agent to squash the last 5 commits into a single commit with a good message"
claude "Use the git-assistant agent to split the last commit into two — one for the refactoring, one for the feature"
```

---

## 10. Project Migration

Switching frameworks or major rewrites.

```bash
# Assess the scope
claude "Use the planner agent to plan a migration from Express to Fastify"

# Execute step by step
claude "Use the migrator agent to execute step 1 of the migration plan: replace Express imports with Fastify equivalents"

# Verify each step
ccfix
ccreview
```

---

## Combining Agents

You can chain agents in a single prompt:

```bash
claude "First use the planner agent to plan this feature: <description>.
Then use the test-writer agent to write tests.
Then implement the feature.
Then use the code-reviewer agent to review the result."
```

Or run agents in parallel for independent tasks:

```bash
claude "In parallel:
1. Use the security-auditor agent to scan src/auth/
2. Use the performance-analyzer agent to check src/api/
3. Use the code-reviewer agent to review src/utils/"
```
