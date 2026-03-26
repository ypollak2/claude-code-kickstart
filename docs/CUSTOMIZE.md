# Customizing Your Setup

This kit is opinionated by default, customizable by design.

---

## Adding MCP Servers

Edit `~/.claude/mcp-servers.json` to add more servers:

```json
{
  "your-server": {
    "command": "npx",
    "args": ["-y", "your-mcp-server@latest"],
    "description": "What it does"
  }
}
```

**Popular additions:**
- `@anthropic-ai/mcp-server-memory` — if you want dedicated persistent memory
- `firecrawl-mcp-server` — advanced web scraping with JS rendering
- `@anthropic-ai/mcp-server-github` — GitHub API integration

**Rule of thumb**: Every MCP server costs ~500-2000 context tokens just to exist. Only add servers you'll use in most sessions.

---

## Modifying Hooks

Hooks live inside `~/.claude/settings.json` under the `hooks` key.

### Disable a hook
Remove it from the array, or comment it out (JSON doesn't support comments, so you'll need to remove it).

### Add a new hook
```json
{
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "your-command-here"
        }
      ]
    }
  ]
}
```

### Hook exit codes
- `exit 0` — allow the action to proceed
- `exit 1` — hook failed (action still proceeds, error is logged)
- `exit 2` — **block the action** and show stderr to the user

### Useful hook ideas
- Run `eslint --fix` after JS/TS edits
- Run `cargo fmt` after Rust edits
- Block edits to `package-lock.json` (force use of `npm install`)
- Log all Bash commands to a file for audit

---

## Adding Agents

Create a `.md` file in `~/.claude/agents/`:

```markdown
---
name: my-agent
description: What it does in one line
model: sonnet  # or opus, haiku
tools:
  - Read
  - Grep
  - Glob
disallowedTools:
  - Edit
  - Write
---

Your agent's system prompt goes here.
```

**Key settings:**
- `model: haiku` — fast and cheap for simple tasks
- `model: opus` — deep reasoning for complex analysis
- `model: sonnet` — best balance for most agents
- `isolation: worktree` — runs in a git worktree (isolated copy of repo)

---

## Modifying Permissions

In `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(git *)"],
    "deny": ["Bash(rm -rf *)"]
  }
}
```

**Pattern syntax:**
- `Bash(git *)` — allow any git command
- `Bash(npm test*)` — allow npm test and npm test:unit etc.
- `Read(~/.ssh/*)` — allow/deny reading SSH keys

**Less restrictive** (for personal projects):
```json
"allow": ["Bash", "Read", "Write", "Edit"]
```

**More restrictive** (for work/sensitive projects):
```json
"allow": ["Bash(git status)", "Bash(git diff)", "Bash(git log)", "Read", "Glob", "Grep"]
```

---

## Changing the CLAUDE.md Template

The starter CLAUDE.md is deliberately minimal. Fill in the sections for each project:

```markdown
## Stack
TypeScript, Next.js 15, PostgreSQL, Prisma, Tailwind

## Commands
- `npm run dev` — start dev server on port 3000
- `npm test` — run vitest
- `npm run db:push` — push schema changes

## Architecture
- app/ — Next.js app router
- components/ — React components (PascalCase.tsx)
- lib/ — shared utilities
- server/ — tRPC routers

## Critical Constraints
- Always use server actions for mutations, never API routes
- Use Prisma transactions for multi-table writes
- Never import server code in client components
```

---

## Profile Layering

Profiles stack. `essential` is always applied first, then your chosen profile overlays on top.

To create your own profile:
1. Create `profiles/my-profile/`
2. Add any of: `settings.json`, `hooks.json`, `mcp-servers.json`, `keybindings.json`, `agents/*.md`
3. Run `./install.sh --profile my-profile`

Settings are **merged** (your profile adds to essential), not replaced.
