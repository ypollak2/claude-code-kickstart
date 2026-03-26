# FAQ

## Installation

### Will this overwrite my existing Claude Code config?

No. The installer **backs up** your existing config before making any changes. Backups are saved to `~/.claude/backup-YYYYMMDD-HHMMSS/`. Settings are **merged**, not replaced — your existing values take precedence on conflicts.

### Can I install this on top of an existing setup?

Yes. That's the expected use case. The merge strategy means your existing permissions, hooks, and settings are preserved. Kickstart adds to them, it doesn't replace.

### How do I undo the installation?

```bash
./uninstall.sh
```

This restores your backup and removes kickstart agents and shell integration.

### Does it work on Linux?

Yes. Tested on macOS and Linux. The only macOS-specific feature is desktop notifications via `osascript` — on Linux it falls back to `notify-send`.

### Does it work on Windows/WSL?

WSL should work since it's Linux under the hood. Native Windows is not supported (Claude Code itself is not available on native Windows).

---

## Profiles

### Can I combine profiles?

Profiles stack automatically. `essential` is always the base. If you want both `web-dev` and `python`, use `--profile fullstack`.

For custom combinations, run the installer twice:
```bash
./install.sh --profile web-dev --no-prompt
./install.sh --profile rust --no-prompt
```

Settings will merge correctly.

### What does auto-detect look for?

| File | Detected profile |
|------|-----------------|
| `Cargo.toml` | rust |
| `go.mod` | go |
| `Dockerfile`, `terraform.tf` | devops |
| `Podfile`, `pubspec.yaml` | mobile |
| `package.json` + `requirements.txt` | fullstack |
| `package.json`, `tsconfig.json` | web-dev |
| `requirements.txt` + pandas/numpy | data-science |
| `requirements.txt`, `pyproject.toml` | python |

### How do I create my own profile?

1. Create `profiles/my-profile/` with any of: `settings.json`, `hooks.json`, `mcp-servers.json`, `agents/*.md`
2. Run `./install.sh --profile my-profile`

See [CUSTOMIZE.md](CUSTOMIZE.md) for details.

---

## Agents

### How do I use an agent?

Inside a Claude Code session:
```
Use the code-reviewer agent to review the recent changes
```

Or more specifically:
```
Use the debugger agent to investigate why the login test is failing
```

Claude knows about all installed agents and will use them when you reference them by name.

### Can agents conflict with each other?

No. Agents are independent — they don't share state or interfere with each other. You can even run multiple agents in parallel.

### Why are some agents read-only?

Design decision: agents that analyze code (reviewer, security-auditor, performance-analyzer) are constrained to read-only access via `disallowedTools: [Edit, Write]`. This prevents them from "fixing" things instead of reporting them, which keeps analysis honest and safe.

### Can I change an agent's model?

Yes. Edit the agent's `.md` file in `~/.claude/agents/` and change the `model:` field to `sonnet`, `opus`, or `haiku`.

---

## Hooks

### Auto-format isn't working

The auto-format hook requires the formatter to be installed:
- **JS/TS**: `npx prettier` (works via npx, no install needed)
- **Python**: `pip install ruff` or `pip install black`
- **Go**: `go install golang.org/x/tools/cmd/goimports@latest`

The hook uses `|| true` so missing formatters won't block your edits.

### Can I disable a specific hook?

Edit `~/.claude/settings.json` and remove the hook from the `hooks` object. There's no way to disable individual hooks without editing the JSON.

### Hooks are blocking something I need to do

If a PreToolUse hook blocks a legitimate action, you can:
1. Edit `~/.claude/settings.json` to remove/modify the hook
2. Or perform the blocked action manually in your terminal

Never disable all hooks just to work around one. Fix the specific hook instead.

---

## MCP Servers

### Context7 isn't finding my library

Context7 resolves library names automatically, but it may not know very new or niche libraries. You can help by being specific: "Use Context7 to look up the Next.js 15 App Router API" works better than just "look up Next.js".

### MCP servers are using too many tokens

Each MCP server adds ~500-2000 tokens to every conversation just to describe its tools. If you're hitting context limits:
1. Remove servers you don't use daily from `~/.claude/mcp-servers.json`
2. Keep Context7 (most universally useful)
3. Add Playwright only when doing browser-related work

### How do I add more MCP servers?

Edit `~/.claude/mcp-servers.json`:
```json
{
  "your-server": {
    "command": "npx",
    "args": ["-y", "your-mcp-server@latest"]
  }
}
```

---

## Shell Commands

### Commands aren't available after install

Run `source ~/.zshrc` (or `source ~/.bashrc`) to reload your shell config. Or open a new terminal.

### Tab completion isn't working

Zsh completions are registered automatically. Bash completions use `complete -F` which is loaded when the aliases file is sourced. If it's not working, make sure the `source` line is in your shell config.

### Can I change the `cc` prefix?

Edit `shell/aliases.sh` and rename the functions. Re-source your shell config to apply.
