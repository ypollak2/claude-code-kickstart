# Troubleshooting

Quick fixes for common issues.

---

## Install Issues

### `jq: command not found`

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Fedora
sudo dnf install jq
```

### `claude: command not found`

Install Claude Code first:
```bash
npm install -g @anthropic-ai/claude-code
```

### `npx: command not found`

Install Node.js 18+:
```bash
# macOS
brew install node

# Or use nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
nvm install 22
```

### Install script fails with permission error

```bash
chmod +x install.sh
./install.sh
```

---

## Post-Install Issues

### Settings didn't merge correctly

Check the backup:
```bash
ls ~/.claude/backup-*
```

Restore and try again:
```bash
./uninstall.sh
./install.sh
```

### Hooks aren't firing

1. Verify hooks exist in settings:
```bash
jq '.hooks' ~/.claude/settings.json
```

2. If empty, re-run the installer:
```bash
./install.sh --profile essential --no-prompt
```

3. Check that the hook command works standalone:
```bash
CLAUDE_FILE_PATH="test.ts" npx --yes prettier --write test.ts
```

### Agents not found by Claude

Claude looks for agents in `~/.claude/agents/`. Verify they're there:
```bash
ls ~/.claude/agents/
```

If missing, re-run the installer. If present but Claude doesn't use them, reference them explicitly: "Use the code-reviewer agent to..."

### MCP servers not connecting

1. Check config exists:
```bash
cat ~/.claude/mcp-servers.json
```

2. Test a server manually:
```bash
npx -y @upstash/context7-mcp@latest
```

3. If npx hangs, clear cache:
```bash
npx clear-npx-cache
```

---

## Runtime Issues

### Claude says "I don't have access to that tool"

Your permissions may be too restrictive. Check:
```bash
jq '.permissions' ~/.claude/settings.json
```

Add the needed permission:
```json
{
  "permissions": {
    "allow": ["Bash(your-command *)"]
  }
}
```

### Auto-format is reformatting files I don't want formatted

The PostToolUse hook matches file extensions. To exclude a file type, edit `~/.claude/settings.json` and remove it from the case statement in the auto-format hook.

### Desktop notifications not appearing

**macOS**: Notifications work via `osascript`. Check System Settings > Notifications > Terminal (or your terminal app).

**Linux**: Requires `notify-send`:
```bash
sudo apt install libnotify-bin  # Ubuntu/Debian
sudo dnf install libnotify      # Fedora
```

### `cchealth` shows warnings

Run through each warning:
- `[!!] Claude Code CLI: NOT FOUND` → Install Claude Code
- `[!!] Settings: NOT FOUND` → Re-run `./install.sh`
- `[!!] npx: NOT FOUND` → Install Node.js
- `[!!] jq: NOT FOUND` → Install jq
- `[--]` items are optional, not errors

---

## Getting Help

If none of the above fixes your issue:

1. Run `cchealth` and note the output
2. Check your Claude Code version: `claude --version`
3. [Open an issue](https://github.com/ypollak2/claude-code-kickstart/issues) with the health check output and what you expected to happen
