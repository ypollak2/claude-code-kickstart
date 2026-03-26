# Why These Choices

Every item in this kit was chosen deliberately. Here's why.

---

## MCP Servers: Why only 3?

Most "awesome MCP" lists have 200+ servers. We picked 3 because every MCP server you add **consumes context window tokens** just to describe its tools. More servers = less room for your actual work.

### Context7 (library docs)
**Problem it solves**: Claude's training data is months old. When you ask about a library API, it might hallucinate outdated syntax.
**Why this one**: 50K+ stars, resolves library names automatically, serves current documentation. No configuration needed.
**What it replaces**: Manually pasting docs into your prompt, or getting wrong answers about recent APIs.

### Playwright (browser automation)
**Problem it solves**: Claude can't see the web. It can't test your UI, check a deployed site, or research a webpage.
**Why this one**: Microsoft's official MCP server. Uses accessibility snapshots (not screenshots), so it's fast and token-efficient. Works for testing, scraping, and browsing.
**What it replaces**: Manual copy-pasting of web content, or using less efficient screenshot-based approaches.

### Sequential Thinking (reasoning)
**Problem it solves**: Complex multi-step problems benefit from structured reasoning, but Claude sometimes jumps to implementation.
**Why this one**: Forces step-by-step thinking with the ability to revise and branch. Built by Anthropic.
**What it replaces**: Nothing directly — it adds a capability Claude doesn't have natively.

### Why not Memory MCP?
Claude Code already has built-in memory via `~/.claude/memory/`. Adding a separate memory MCP creates confusion about where knowledge is stored. Use Claude's native memory system instead.

### Why not Filesystem MCP?
Claude Code already has Read, Write, Edit, Glob, and Grep tools built in. The Filesystem MCP would duplicate these with worse integration.

---

## Hooks: Why these 5?

### Auto-format on Edit/Write (PostToolUse)
**The single highest-impact hook.** Claude writes correct logic but inconsistent formatting. This hook runs Prettier (JS/TS), Ruff/Black (Python), or goimports (Go) after every file change. Zero-effort code quality.

### Block destructive rm (PreToolUse)
Prevents `rm -rf` accidents. Claude sometimes tries aggressive cleanup. This forces it to use targeted deletion instead.

### Block force-push to main (PreToolUse)
One accidental `git push --force origin main` can ruin a team's day. This makes it impossible.

### Block sensitive file edits (PreToolUse)
Prevents Claude from modifying `.env`, credentials, private keys, or secrets files. These should only be edited manually.

### Desktop notifications (Notification)
Long-running tasks finish silently. This hook sends a macOS/Linux notification when Claude needs your attention. Small quality-of-life win.

---

## Settings: Why these defaults?

### Telemetry off
Privacy-respecting default. You can re-enable it if you want to help Anthropic improve the product.

### Thinking always on
Extended thinking (up to 32K tokens of internal reasoning) produces noticeably better results on complex tasks. The tradeoff is slightly higher token usage, but the quality improvement is worth it.

### Granular permissions
`Bash(git *)` is safer than blanket `Bash` access. We allow specific tool commands rather than giving Claude unrestricted shell access.

### Project MCP servers disabled by default
`enableAllProjectMcpServers: false` means project-level `.claude/mcp-servers.json` files won't auto-activate MCP servers when you `cd` into a project. This prevents untrusted repos from running arbitrary MCP servers on your machine.

---

## Agents: Why these 11?

Agents split into two categories by design: **observers** and **actors**.

### Observers (read-only — `disallowedTools: [Edit, Write]`)

| Agent | Why read-only? |
|-------|----------------|
| **code-reviewer** | A reviewer that can modify code will "fix" things instead of reporting them. Read-only keeps reviews honest. |
| **planner** | Planning should be pure analysis. No shell = no "just quickly trying something." No edits = no premature implementation. |
| **security-auditor** | Security analysis must be observational. If it could edit, it might "fix" a vulnerability incorrectly and give false confidence. |
| **pr-reviewer** | Same principle as code-reviewer, but for entire PRs. Reviews all commits, not just the last one. |
| **performance-analyzer** | Finds bottlenecks without the temptation to optimize prematurely. Reports issues with evidence and estimated impact. |
| **git-assistant** | Git operations are dangerous. This agent explains and suggests, but destructive commands require your explicit approval. |

### Actors (full access — can Edit, Write, Bash)

| Agent | Why full access? |
|-------|-----------------|
| **debugger** | Debugging requires reproduction — running tests, adding print statements, trying fixes. |
| **test-writer** | Needs to create test files, run the test suite, and iterate until tests pass. |
| **refactorer** | Must edit code AND run tests before/after each change to verify no behavior change. |
| **doc-writer** | Creates documentation files. Runs commands to verify code examples are accurate. |
| **migrator** | Upgrades dependencies, modifies import statements, runs tests between each migration step. |
| **api-designer** | Designs and implements API contracts — needs to write route definitions, schemas, and validation code. |

### Model routing

Agents that need deep reasoning (planner, migrator, api-designer) use **Opus**. Frequent-use agents (code-reviewer, debugger, test-writer) use **Sonnet** — 3x cheaper, fast enough for the task.

---

## Profiles: Why these 10?

### essential (everyone)
The base layer. Hooks, agents, MCP servers, and settings that make Claude Code better regardless of your stack. Always installed first.

### web-dev / python / fullstack
The most common stacks. These just add tool permissions — `Bash(npm *)`, `Bash(pytest *)`, etc. — so Claude can run your project's toolchain without asking permission each time.

### rust / go
These include language-specific reviewer agents in addition to permissions. Rust and Go have unique patterns (ownership/lifetimes, goroutine safety) that generic code review misses.

### devops
The only profile with **deny rules for destructive operations**. `terraform apply`, `kubectl delete`, `docker system prune` are blocked. Claude can plan and validate, but you pull the trigger on infrastructure changes.

### data-science
Includes a data analyst agent that enforces statistical rigor — null hypotheses, confidence intervals, reproducible seeds. Prevents the "correlation = causation" mistakes that AI assistants often make.

### mobile
Covers the fragmented mobile toolchain — React Native, Expo, Flutter, Xcode, Gradle, CocoaPods, ADB. No custom agent needed; mobile development is more about permissions than analysis patterns.

### privacy-first
Trail of Bits-inspired lockdown. Denies access to `~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.kube`, `~/.docker`. Disables all telemetry. For people working on sensitive codebases or in regulated industries.

---

## Shell tooling: Why these commands?

### Core aliases (`cc`, `ccp`, `ccr`)
You'll type `claude` hundreds of times. `cc` saves 4 characters each time.

### Code operations (`ccreview`, `ccfix`, `cctest`, `ccrefactor`)
The four most common one-shot workflows. Each encodes a best practice:
- `ccreview` reviews the git diff, not the whole codebase
- `ccfix` finds failures AND confirms the fix, not just patches blindly
- `cctest` asks for happy path, edge cases, AND error handling
- `ccrefactor` runs tests before and after — the cardinal rule of refactoring

### Git helpers (`ccpr`, `ccrebase`, `ccbisect`)
Git operations people do rarely enough to forget the syntax. `ccpr 42` is faster than remembering `gh pr diff` + `gh pr view` + manual review. `ccbisect` automates the most tedious debugging technique.

### Project setup (`ccinit`, `ccscan`)
Two approaches: `ccinit` gives you an empty template to fill in (good for new projects). `ccscan` uses Claude to auto-detect your stack and generate a CLAUDE.md (good for existing projects you're onboarding to).

### Maintenance (`cchealth`, `ccupdate`)
`cchealth` is the "did it actually install correctly?" command. Shows settings, hooks, agents, MCP servers, and privacy status in one glance. `ccupdate` pulls the latest configs from this repo.

### Tab completion
File-based commands (`cce`, `ccrf`, `cctest`, `ccrefactor`) have tab completion for both zsh and bash. No configuration needed — it's included automatically.
