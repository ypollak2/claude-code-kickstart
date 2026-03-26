# Tips & Tricks

Power user techniques that aren't obvious from the docs.

---

## Agent Chaining

### Run multiple agents on different parts of the codebase

```
In parallel:
1. Use the security-auditor to scan src/auth/
2. Use the performance-analyzer to check src/api/routes/
3. Use the code-reviewer to review src/utils/
```

Claude will run all three simultaneously. Results come back faster than sequential.

### Use the planner before complex work

Before any task touching 3+ files:
```
Use the planner agent to create an implementation plan for: <your task>
```

Review the plan, then tell Claude to execute it. This prevents Claude from going down the wrong path and saves tokens.

### The read-only trick

If Claude keeps trying to "fix" things when you just want analysis, say:
```
Use the code-reviewer agent (read-only) to analyze this
```

The read-only constraint is enforced at the system level — the agent literally cannot modify files.

---

## Token Efficiency

### Keep CLAUDE.md under 100 lines

Every line of CLAUDE.md is loaded into every conversation. Put only universally-applicable content there. Move domain-specific knowledge to skills or agent prompts.

### Use `ccq` for quick questions

```bash
ccq "What does the --frozen-lockfile flag do in pnpm?"
```

This starts a one-shot session that doesn't load your full context, saving tokens.

### Disable MCP servers you don't use daily

Each MCP server costs ~500-2000 tokens per conversation. If you only use Playwright for testing, remove it from `mcp-servers.json` and add it back when needed.

### Use `cchealth` to audit your setup

```bash
cchealth
```

Shows you exactly what's installed. If you have 10 MCP servers configured, that's a sign you're spending tokens on tools you rarely use.

---

## Shell Workflow

### The `ccscan` → edit → commit workflow

For new projects:
```bash
cd new-project
ccscan              # Auto-generates CLAUDE.md
# Review and edit the generated CLAUDE.md
cc                  # Start working with project context
```

### Chain git helpers

```bash
ccreview && cccommit
```

Review your changes, then commit if everything looks good.

### Use `cce` to onboard quickly

```bash
cce src/index.ts           # Entry point
cce src/config/database.ts # Key config
cce src/middleware/auth.ts  # Important middleware
```

Three commands and you understand the core of any project.

---

## Hook Tricks

### Auto-format keeps your diffs clean

The auto-format hook runs after every Edit/Write. This means:
- No more "fix formatting" commits
- Diffs show only logic changes, not whitespace
- Code reviews are faster

### Use the block hooks as guardrails

The `rm -rf` and force-push blocks aren't just safety — they force Claude to use better approaches:
- Instead of `rm -rf node_modules`, Claude will suggest `rm -rf node_modules && npm install` as two steps
- Instead of force-push, Claude will suggest a clean merge or rebase

### Add project-specific hooks

If your project has a linter that isn't covered by auto-format:

```json
{
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "case \"$CLAUDE_FILE_PATH\" in *.swift) swiftformat \"$CLAUDE_FILE_PATH\" 2>/dev/null || true;; esac"
        }
      ]
    }
  ]
}
```

---

## Profile Stacking

### Combine multiple profiles

Run the installer multiple times to stack profiles:
```bash
./install.sh --profile web-dev --no-prompt
./install.sh --profile devops --no-prompt
```

Settings merge additively. You get web-dev permissions AND devops permissions AND the devops deny rules.

### Create a team profile

Share a common configuration across your team:
1. Create `profiles/your-team/` with your team's settings, hooks, and agents
2. Add a `CLAUDE.md` with your project's conventions
3. Everyone runs `./install.sh --profile your-team`

---

## Debugging Tips

### When Claude is confused

```bash
# Clear context and start fresh
# (type /clear inside Claude Code)

# Then explicitly set context
cc "Read CLAUDE.md and the project structure, then help me with: <task>"
```

### When tests fail after Claude's changes

```bash
ccfix  # Automated: finds failures, fixes them, confirms
```

If `ccfix` can't solve it:
```bash
claude "Use the debugger agent to investigate the test failures. Don't fix yet, just explain what's wrong."
```

### When you want a second opinion

```bash
claude "Use the code-reviewer agent to review the changes I just made. Be critical."
```

The read-only constraint means the reviewer won't try to "help" by modifying your code — it just reports issues.
