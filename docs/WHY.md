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

## Agents: Why these 4?

### code-reviewer (read-only)
The `disallowedTools: [Edit, Write]` constraint is critical. A reviewer that can modify code will be tempted to "fix" things instead of reporting them. Read-only keeps the review honest and safe.

### planner (no shell, no edits)
Planning should be pure analysis. No shell access prevents the planner from "just quickly trying something." No edit access prevents premature implementation.

### security-auditor (read-only)
Same principle as code-reviewer. Security analysis must be observational, not interventional.

### debugger (full access)
Debugging requires reproduction — running tests, adding print statements, trying fixes. This is the one agent that needs Edit and Bash access.

---

## Shell aliases: Why these?

### `cc` / `ccp` / `ccr`
Just shorter. You'll type `claude` hundreds of times.

### `ccreview` / `ccfix`
The two most common one-shot commands. Review my changes, fix my tests. No need to type the full prompt every time.

### `cce <file>`
Explaining a file is the most common onboarding task. Making it a one-liner encourages the habit.

### `ccinit`
Creates a starter CLAUDE.md in the current project. The template has sections but no content — you fill in your project specifics. This is better than Claude guessing your architecture.
