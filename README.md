# claude-code-kickstart

**Go from fresh install to power user in one command.**

Every Claude Code resource is a catalog — "here's 200 things, good luck." This repo is different. It's an **opinionated starter kit** that installs a tested, curated setup in under a minute.

```bash
git clone https://github.com/yalipollak/claude-code-kickstart
cd claude-code-kickstart
./install.sh
```

That's it. You'll get a profile picker, automatic backup of your existing config, and a clean install of everything below.

---

## What You Get

### 3 MCP Servers (not 200)

Every MCP server eats context tokens just to exist. We picked the 3 that earn their keep:

| Server | Why it's here |
|--------|---------------|
| **Context7** | Live library docs. Claude stops hallucinating outdated APIs. |
| **Playwright** | Browser automation. Test UIs, scrape pages, verify deployments. |
| **Sequential Thinking** | Structured multi-step reasoning for complex problems. |

> Why not more? See [docs/WHY.md](docs/WHY.md#mcp-servers-why-only-3)

### 5 Battle-Tested Hooks

| Hook | What it does |
|------|--------------|
| **Auto-format** | Runs Prettier/Ruff/goimports after every edit. Zero-effort clean code. |
| **Block rm -rf** | Prevents destructive deletion accidents. |
| **Block force-push to main** | Saves your team from disaster. |
| **Block sensitive files** | Stops Claude from editing .env, credentials, private keys. |
| **Desktop notifications** | Get notified when long tasks finish (macOS + Linux). |

### 4 Purpose-Built Agents

| Agent | Model | Access | Purpose |
|-------|-------|--------|---------|
| **code-reviewer** | Sonnet | Read-only | Finds bugs, security issues, and quality problems. Can't "fix" things — keeps reviews honest. |
| **planner** | Opus | Read-only | Creates implementation plans. No shell = no premature coding. |
| **security-auditor** | Sonnet | Read-only | OWASP Top 10, secrets scanning, dependency checks. |
| **debugger** | Sonnet | Full | Reproduces, isolates, and fixes bugs systematically. |

### Privacy-Respecting Defaults

- Telemetry and error reporting **off**
- Credential paths (`~/.ssh`, `~/.aws`, `~/.gnupg`) **denied**
- Project MCP servers **require explicit opt-in**
- Granular permissions (`Bash(git *)` not blanket `Bash`)

### Shell Integration

```bash
cc          # Short for 'claude'
ccp         # Plan mode
ccr         # Resume last session
ccreview    # Review current git diff
ccfix       # Find and fix failing tests
cce <file>  # Explain a file
ccinit      # Create starter CLAUDE.md for current project
```

---

## Profiles

Pick a profile during install, or pass `--profile <name>`:

| Profile | What it adds |
|---------|-------------|
| **essential** | Everything above. Start here. |
| **web-dev** | + npm/yarn/pnpm/bun, vitest/jest, Playwright, ESLint, Prettier permissions |
| **python** | + python/pip/uv/poetry, pytest, ruff/black/mypy permissions |
| **fullstack** | + Both web-dev and python |
| **privacy-first** | + Hardened credential lockdown, all telemetry disabled, strictest permissions |

Profiles **stack**: essential is always the base, your chosen profile adds on top.

---

## Install Options

```bash
# Interactive (recommended for first time)
./install.sh

# Non-interactive with specific profile
./install.sh --profile web-dev --no-prompt

# Preview without making changes
./install.sh --dry-run

# Skip specific components
./install.sh --skip-plugins --skip-mcp --skip-shell

# Undo everything
./uninstall.sh
```

---

## Recommended Plugins

After installing, open Claude Code and run these:

```
/plugin install feature-dev@claude-plugins-official
/plugin install code-review@claude-plugins-official
/plugin install hookify@claude-plugins-official
```

These aren't auto-installed because plugins require an active Claude Code session.

---

## Project Structure

```
claude-code-kickstart/
├── install.sh                    # One command setup
├── uninstall.sh                  # Clean removal
├── profiles/
│   ├── essential/                # Base config (always installed)
│   │   ├── settings.json         # Permissions, privacy, thinking
│   │   ├── hooks.json            # Auto-format, safety guards
│   │   ├── keybindings.json      # Power user shortcuts
│   │   ├── mcp-servers.json      # Context7, Playwright, Sequential Thinking
│   │   ├── CLAUDE.md             # Starter template
│   │   └── agents/               # code-reviewer, planner, security-auditor, debugger
│   ├── web-dev/                  # JS/TS ecosystem permissions
│   ├── python/                   # Python ecosystem permissions
│   ├── fullstack/                # Both
│   └── privacy-first/            # Hardened security
├── shell/
│   └── aliases.sh                # cc, ccreview, ccfix, ccinit
└── docs/
    ├── WHY.md                    # Why every choice was made
    └── CUSTOMIZE.md              # How to modify for your needs
```

---

## Philosophy

1. **Opinionated > comprehensive.** We pick the best 5 things, not list 200.
2. **Explain every choice.** Read [WHY.md](docs/WHY.md) to understand the reasoning.
3. **Safe defaults.** Privacy on, destructive commands blocked, credentials protected.
4. **Easy to undo.** Automatic backup on install, clean uninstall script.
5. **Profiles, not forks.** One repo that adapts to your stack.

---

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Node.js 18+ (for MCP servers via npx)
- `jq` (auto-installed via Homebrew if missing)
- macOS or Linux

---

## Contributing

Found a hook that changed your workflow? An agent prompt that's unusually effective? PRs welcome — but remember the philosophy: every addition must earn its place. We'd rather have 5 great things than 50 mediocre ones.

---

## License

MIT
