# claude-code-kickstart shell integration
# Source this file in your .zshrc or .bashrc

KICKSTART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# ─── Core aliases ─────────────────────────────────────────────────

alias cc="claude"
alias ccp="claude --plan"
alias ccr="claude --resume"

# ─── Quick commands ───────────────────────────────────────────────

# Review current changes
alias ccreview='claude "Review my current git diff for bugs and issues"'

# Generate a commit message
alias cccommit='claude "/commit"'

# Fix failing tests
alias ccfix='claude "Run the tests, find what'\''s failing, and fix it. Run tests again to confirm."'

# ─── Functions ────────────────────────────────────────────────────

# Explain a file
cce() {
  if [[ -z "$1" ]]; then
    echo "Usage: cce <file>"
    return 1
  fi
  claude "Explain what this file does and its key design decisions: $1"
}

# Quick question without starting a full session
ccq() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccq 'your question'"
    return 1
  fi
  claude --no-input "$*"
}

# Ask Claude to review a specific file
ccrf() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccrf <file>"
    return 1
  fi
  claude "Review this file for bugs, security issues, and code quality: $1"
}

# Write tests for a specific file
cctest() {
  if [[ -z "$1" ]]; then
    echo "Usage: cctest <file>"
    return 1
  fi
  claude "Write comprehensive tests for this file. Include happy path, edge cases, and error handling: $1"
}

# Refactor a specific file
ccrefactor() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccrefactor <file>"
    return 1
  fi
  claude "Refactor this file for clarity and maintainability. Run tests before and after to ensure nothing breaks: $1"
}

# ─── Git helpers ──────────────────────────────────────────────────

# Review a PR by number
ccpr() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccpr <pr-number>"
    return 1
  fi
  claude "Review PR #$1 using 'gh pr view $1' and 'gh pr diff $1'. Check for bugs, security issues, missing tests, and design problems."
}

# Interactive rebase help
ccrebase() {
  claude "Help me with an interactive rebase. Show me the recent commits with 'git log --oneline -20' and guide me through cleaning up the history."
}

# Find which commit broke something
ccbisect() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccbisect 'description of what broke'"
    return 1
  fi
  claude "Help me find the commit that broke this: $*. Use git bisect or git log analysis to narrow it down."
}

# ─── Project setup ────────────────────────────────────────────────

# Initialize CLAUDE.md for current project
ccinit() {
  if [[ -f "CLAUDE.md" ]]; then
    echo "CLAUDE.md already exists in this directory."
    return 1
  fi
  if [[ -f "$KICKSTART_DIR/profiles/essential/CLAUDE.md" ]]; then
    cp "$KICKSTART_DIR/profiles/essential/CLAUDE.md" ./CLAUDE.md
    echo "Created CLAUDE.md — edit it with your project details."
  else
    cat > CLAUDE.md << 'TEMPLATE'
# Project Instructions

## Stack

## Commands

## Architecture

## Critical Constraints
TEMPLATE
    echo "Created CLAUDE.md — edit it with your project details."
  fi
}

# Auto-generate CLAUDE.md by scanning the project
ccscan() {
  claude "Scan this project directory and generate a CLAUDE.md file. Detect the tech stack from package.json/requirements.txt/Cargo.toml/go.mod/etc. List the main commands (dev, test, build, lint). Describe the project structure. Identify any critical constraints from existing configs."
}

# ─── Session management ───────────────────────────────────────────

# List recent Claude sessions
ccsessions() {
  local count="${1:-10}"
  ls -lt "$HOME/.claude/sessions/" 2>/dev/null | head -n "$((count + 1))"
}

# Show how much Claude has cost today (requires token tracking)
ccstats() {
  claude --no-input "Show me a summary of this session: tokens used, files modified, and commands run."
}

# ─── Health check ─────────────────────────────────────────────────

cchealth() {
  echo ""
  echo "  claude-code-kickstart health check"
  echo "  ══════════════════════════════════"
  echo ""

  # Claude CLI
  if command -v claude &>/dev/null; then
    echo "  [OK] Claude Code CLI: $(claude --version 2>/dev/null || echo 'installed')"
  else
    echo "  [!!] Claude Code CLI: NOT FOUND"
  fi

  # Settings
  if [[ -f "$HOME/.claude/settings.json" ]]; then
    local hook_count
    hook_count=$(jq '[.hooks // {} | to_entries[] | .value | length] | add // 0' "$HOME/.claude/settings.json" 2>/dev/null)
    echo "  [OK] Settings: ~/.claude/settings.json ($hook_count hooks configured)"
  else
    echo "  [!!] Settings: NOT FOUND"
  fi

  # MCP servers
  if [[ -f "$HOME/.claude/mcp-servers.json" ]]; then
    local mcp_count
    mcp_count=$(jq 'keys | length' "$HOME/.claude/mcp-servers.json" 2>/dev/null)
    echo "  [OK] MCP Servers: $mcp_count configured"
  else
    echo "  [--] MCP Servers: none configured"
  fi

  # Agents
  local agent_count=0
  if [[ -d "$HOME/.claude/agents" ]]; then
    agent_count=$(ls "$HOME/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
  fi
  if [[ "$agent_count" -gt 0 ]]; then
    echo "  [OK] Agents: $agent_count installed"
    for f in "$HOME/.claude/agents/"*.md; do
      local name
      name=$(basename "$f" .md)
      echo "       - $name"
    done
  else
    echo "  [--] Agents: none installed"
  fi

  # Node/npx (needed for MCP)
  if command -v npx &>/dev/null; then
    echo "  [OK] npx: $(npx --version 2>/dev/null)"
  else
    echo "  [!!] npx: NOT FOUND (needed for MCP servers)"
  fi

  # jq
  if command -v jq &>/dev/null; then
    echo "  [OK] jq: $(jq --version 2>/dev/null)"
  else
    echo "  [!!] jq: NOT FOUND"
  fi

  # Privacy check
  local telemetry_off=false
  if [[ -f "$HOME/.claude/settings.json" ]]; then
    telemetry_off=$(jq -r '.env.DISABLE_TELEMETRY // "0"' "$HOME/.claude/settings.json" 2>/dev/null)
  fi
  if [[ "$telemetry_off" == "1" ]]; then
    echo "  [OK] Telemetry: disabled"
  else
    echo "  [--] Telemetry: enabled (run ./install.sh to disable)"
  fi

  # Shell integration
  local shell_rc=""
  if [[ -f "$HOME/.zshrc" ]]; then shell_rc="$HOME/.zshrc";
  elif [[ -f "$HOME/.bashrc" ]]; then shell_rc="$HOME/.bashrc"; fi
  if [[ -n "$shell_rc" ]] && grep -q "claude-code-kickstart" "$shell_rc" 2>/dev/null; then
    echo "  [OK] Shell integration: active in $(basename "$shell_rc")"
  else
    echo "  [--] Shell integration: not installed"
  fi

  echo ""
}

# ─── Updater ──────────────────────────────────────────────────────

ccupdate() {
  if [[ ! -d "$KICKSTART_DIR/.git" ]]; then
    echo "Error: kickstart directory is not a git repo: $KICKSTART_DIR"
    return 1
  fi
  echo "Updating claude-code-kickstart..."
  (cd "$KICKSTART_DIR" && git pull --rebase)
  echo ""
  echo "Re-run './install.sh' in $KICKSTART_DIR to apply updates."
}

# ─── Completions ──────────────────────────────────────────────────

if [[ -n "$ZSH_VERSION" ]]; then
  # Zsh completions
  _cc_commands() {
    local -a commands
    commands=(
      'cce:Explain a file'
      'ccq:Quick question'
      'ccrf:Review a file'
      'cctest:Write tests for a file'
      'ccrefactor:Refactor a file'
      'ccpr:Review a PR'
      'ccrebase:Interactive rebase help'
      'ccbisect:Find breaking commit'
      'ccinit:Create CLAUDE.md'
      'ccscan:Auto-generate CLAUDE.md'
      'cchealth:Health check'
      'ccupdate:Update kickstart'
      'ccreview:Review git diff'
      'ccfix:Fix failing tests'
      'cccommit:Smart commit'
      'ccsessions:List sessions'
    )
    _describe 'cc commands' commands
  }
elif [[ -n "$BASH_VERSION" ]]; then
  # Bash completions for file-based commands
  _cc_file_complete() {
    COMPREPLY=($(compgen -f -- "${COMP_WORDS[COMP_CWORD]}"))
  }
  complete -F _cc_file_complete cce ccrf cctest ccrefactor
fi
