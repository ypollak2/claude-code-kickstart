#!/usr/bin/env bash
set -euo pipefail

# claude-code-kickstart installer
# Go from fresh install to power user in one command.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}${BOLD}  ╔══════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}${BOLD}  ║     claude-code-kickstart installer      ║${NC}"
  echo -e "${CYAN}${BOLD}  ║  Power user setup in one command.        ║${NC}"
  echo -e "${CYAN}${BOLD}  ╚══════════════════════════════════════════╝${NC}"
  echo ""
}

info()    { echo -e "  ${BLUE}INFO${NC}  $1"; }
success() { echo -e "  ${GREEN}  OK${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}WARN${NC}  $1"; }
error()   { echo -e "  ${RED} ERR${NC}  $1"; }
step()    { echo -e "\n${BOLD}[$1/$TOTAL_STEPS] $2${NC}"; }

# ─── Parse arguments ──────────────────────────────────────────────

PROFILE=""
NO_PROMPT=false
DRY_RUN=false
SKIP_PLUGINS=false
SKIP_MCP=false
SKIP_SHELL=false

AUTO_DETECT=false

usage() {
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --profile <name>    Profile to install:"
  echo "                        essential, web-dev, python, fullstack, privacy-first,"
  echo "                        rust, go, devops, data-science, mobile"
  echo "  --auto              Auto-detect project type from current directory"
  echo "  --no-prompt         Skip interactive prompts, use defaults"
  echo "  --dry-run           Show what would be installed without making changes"
  echo "  --skip-plugins      Skip plugin installation"
  echo "  --skip-mcp          Skip MCP server configuration"
  echo "  --skip-shell        Skip shell integration"
  echo "  -h, --help          Show this help"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)     PROFILE="$2"; shift 2 ;;
    --no-prompt)   NO_PROMPT=true; shift ;;
    --dry-run)     DRY_RUN=true; shift ;;
    --skip-plugins) SKIP_PLUGINS=true; shift ;;
    --skip-mcp)    SKIP_MCP=true; shift ;;
    --skip-shell)  SKIP_SHELL=true; shift ;;
    --auto)        AUTO_DETECT=true; shift ;;
    -h|--help)     usage ;;
    *)             error "Unknown option: $1"; usage ;;
  esac
done

TOTAL_STEPS=8

# ─── Pre-flight checks ───────────────────────────────────────────

print_header

step 1 "Pre-flight checks"

# Check Claude Code is installed
if ! command -v claude &>/dev/null; then
  error "Claude Code CLI not found. Install it first:"
  echo "  npm install -g @anthropic-ai/claude-code"
  exit 1
fi
success "Claude Code CLI found: $(claude --version 2>/dev/null || echo 'installed')"

# Check jq for JSON merging
if ! command -v jq &>/dev/null; then
  warn "jq not found. Installing via Homebrew..."
  if command -v brew &>/dev/null; then
    brew install jq
    success "jq installed"
  else
    error "jq is required. Install it: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
  fi
fi
success "jq available"

# ─── Profile selection ────────────────────────────────────────────

step 2 "Profile selection"

# ─── Auto-detect project type ─────────────────────────────────────
detect_profile() {
  local detected=""

  # Check for language-specific files in current directory
  if [[ -f "Cargo.toml" || -f "Cargo.lock" ]]; then
    detected="rust"
  elif [[ -f "go.mod" || -f "go.sum" ]]; then
    detected="go"
  elif [[ -f "Dockerfile" || -f "docker-compose.yml" || -f "terraform.tf" || -d ".terraform" || -f "Makefile" && -f "k8s" ]]; then
    detected="devops"
  elif [[ -f "Podfile" || -f "app.json" && -f "metro.config.js" || -f "pubspec.yaml" || -f "*.xcodeproj" ]]; then
    detected="mobile"
  elif [[ -f "package.json" && -f "requirements.txt" ]] || [[ -f "package.json" && -f "pyproject.toml" ]]; then
    detected="fullstack"
  elif [[ -f "package.json" || -f "tsconfig.json" || -f "next.config.js" || -f "next.config.ts" || -f "vite.config.ts" ]]; then
    detected="web-dev"
  elif [[ -f "setup.py" || -f "pyproject.toml" || -f "requirements.txt" || -f "Pipfile" ]]; then
    # Check if it looks like data science
    if [[ -d "notebooks" || -f "*.ipynb" ]] || grep -q "pandas\|numpy\|scikit\|torch\|tensorflow\|jupyter" requirements.txt 2>/dev/null || grep -q "pandas\|numpy\|scikit\|torch\|tensorflow\|jupyter" pyproject.toml 2>/dev/null; then
      detected="data-science"
    else
      detected="python"
    fi
  fi

  echo "$detected"
}

if [[ "$AUTO_DETECT" == true && -z "$PROFILE" ]]; then
  DETECTED=$(detect_profile)
  if [[ -n "$DETECTED" ]]; then
    info "Auto-detected project type: ${BOLD}$DETECTED${NC}"
    if [[ "$NO_PROMPT" == true ]]; then
      PROFILE="$DETECTED"
    else
      read -p "  Use detected profile '$DETECTED'? [Y/n]: " use_detected
      if [[ "${use_detected:-Y}" =~ ^[Yy]$ ]]; then
        PROFILE="$DETECTED"
      fi
    fi
  else
    info "Could not auto-detect project type — falling back to manual selection"
  fi
fi

if [[ -z "$PROFILE" && "$NO_PROMPT" == false ]]; then
  echo ""
  echo -e "  ${BOLD}Available profiles:${NC}"
  echo ""
  echo -e "  ${CYAN} 1)${NC} essential       Core setup everyone should have (recommended start)"
  echo -e "  ${CYAN} 2)${NC} web-dev         + React, Next.js, Node.js, Tailwind tools"
  echo -e "  ${CYAN} 3)${NC} python          + Python, FastAPI, Django, pytest tools"
  echo -e "  ${CYAN} 4)${NC} fullstack       + Both web-dev and python"
  echo -e "  ${CYAN} 5)${NC} rust            + Cargo, clippy, rustfmt, Rust reviewer agent"
  echo -e "  ${CYAN} 6)${NC} go              + go tools, golangci-lint, Go reviewer agent"
  echo -e "  ${CYAN} 7)${NC} devops          + Docker, K8s, Terraform, infra reviewer agent"
  echo -e "  ${CYAN} 8)${NC} data-science    + Jupyter, pandas, data analyst agent"
  echo -e "  ${CYAN} 9)${NC} mobile          + React Native, Expo, Flutter, Xcode, Gradle"
  echo -e "  ${CYAN}10)${NC} privacy-first   + Hardened security, no telemetry, credential lockdown"
  echo ""
  read -p "  Pick a profile [1-10] (default: 1): " choice
  case "${choice:-1}" in
    1)  PROFILE="essential" ;;
    2)  PROFILE="web-dev" ;;
    3)  PROFILE="python" ;;
    4)  PROFILE="fullstack" ;;
    5)  PROFILE="rust" ;;
    6)  PROFILE="go" ;;
    7)  PROFILE="devops" ;;
    8)  PROFILE="data-science" ;;
    9)  PROFILE="mobile" ;;
    10) PROFILE="privacy-first" ;;
    *)  PROFILE="essential" ;;
  esac
fi

PROFILE="${PROFILE:-essential}"
info "Selected profile: ${BOLD}$PROFILE${NC}"

# ─── Backup existing config ──────────────────────────────────────

step 3 "Backing up existing config"

if [[ -d "$CLAUDE_DIR" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY RUN] Would backup $CLAUDE_DIR to $BACKUP_DIR"
  else
    mkdir -p "$BACKUP_DIR"
    # Backup specific files we'll modify (not the whole dir)
    for f in settings.json CLAUDE.md keybindings.json; do
      if [[ -f "$CLAUDE_DIR/$f" ]]; then
        cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f"
        success "Backed up $f"
      fi
    done
    if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
      # Also backup hooks from settings
      cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/settings.json.bak"
    fi
    info "Backup saved to: $BACKUP_DIR"
  fi
else
  info "No existing .claude directory found — fresh install"
  mkdir -p "$CLAUDE_DIR"
fi

# ─── Install configs ─────────────────────────────────────────────

step 4 "Installing configurations"

ensure_dir() { [[ "$DRY_RUN" == true ]] || mkdir -p "$1"; }

# Merge JSON: existing + new (existing values take precedence for conflicts)
merge_json() {
  local target="$1"
  local source="$2"
  if [[ -f "$target" ]]; then
    local merged
    merged=$(jq -s '.[0] * .[1]' "$target" "$source")
    echo "$merged" > "$target"
  else
    cp "$source" "$target"
  fi
}

# Always install essential profile first
install_profile() {
  local profile_dir="$REPO_DIR/profiles/$1"
  if [[ ! -d "$profile_dir" ]]; then
    warn "Profile directory not found: $profile_dir"
    return
  fi
  info "Applying profile: $1"

  # Settings
  if [[ -f "$profile_dir/settings.json" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would merge settings.json"
    else
      ensure_dir "$CLAUDE_DIR"
      merge_json "$CLAUDE_DIR/settings.json" "$profile_dir/settings.json"
      success "Merged settings.json"
    fi
  fi

  # Hooks (merge into settings.json)
  if [[ -f "$profile_dir/hooks.json" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would merge hooks into settings.json"
    else
      # Merge hooks into the settings.json hooks key
      local current_settings="$CLAUDE_DIR/settings.json"
      local hooks_content
      hooks_content=$(cat "$profile_dir/hooks.json")
      local updated
      updated=$(jq --argjson hooks "$hooks_content" '.hooks = ($hooks)' "$current_settings")
      echo "$updated" > "$current_settings"
      success "Installed hooks"
    fi
  fi

  # Agents
  if [[ -d "$profile_dir/agents" ]]; then
    ensure_dir "$CLAUDE_DIR/agents"
    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would copy agents"
    else
      cp "$profile_dir/agents"/*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
      success "Installed agents"
    fi
  fi

  # Skills
  if [[ -d "$profile_dir/skills" ]]; then
    ensure_dir "$CLAUDE_DIR/skills"
    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would copy skills"
    else
      cp "$profile_dir/skills"/*.md "$CLAUDE_DIR/skills/" 2>/dev/null || true
      success "Installed skills"
    fi
  fi

  # CLAUDE.md — only copy if none exists (never overwrite user's CLAUDE.md)
  if [[ -f "$profile_dir/CLAUDE.md" && ! -f "$HOME/CLAUDE.md" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would create starter ~/CLAUDE.md"
    else
      cp "$profile_dir/CLAUDE.md" "$HOME/CLAUDE.md"
      success "Created starter ~/CLAUDE.md"
    fi
  fi

  # Keybindings
  if [[ -f "$profile_dir/keybindings.json" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would install keybindings.json"
    else
      merge_json "$CLAUDE_DIR/keybindings.json" "$profile_dir/keybindings.json"
      success "Installed keybindings"
    fi
  fi
}

# Install essential first, then selected profile
install_profile "essential"
if [[ "$PROFILE" != "essential" ]]; then
  if [[ "$PROFILE" == "fullstack" ]]; then
    install_profile "web-dev"
    install_profile "python"
  else
    install_profile "$PROFILE"
  fi
fi

# ─── MCP Servers ──────────────────────────────────────────────────

step 5 "Configuring MCP servers"

if [[ "$SKIP_MCP" == true ]]; then
  info "Skipping MCP server configuration (--skip-mcp)"
else
  MCP_CONFIG="$CLAUDE_DIR/mcp-servers.json"

  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY RUN] Would configure MCP servers"
  else
    # Build MCP config from profile
    if [[ -f "$REPO_DIR/profiles/$PROFILE/mcp-servers.json" ]]; then
      merge_json "$MCP_CONFIG" "$REPO_DIR/profiles/$PROFILE/mcp-servers.json"
    elif [[ -f "$REPO_DIR/profiles/essential/mcp-servers.json" ]]; then
      merge_json "$MCP_CONFIG" "$REPO_DIR/profiles/essential/mcp-servers.json"
    fi
    success "Configured MCP servers"

    # Check if npx is available for MCP servers
    if command -v npx &>/dev/null; then
      success "npx available (needed for MCP servers)"
    else
      warn "npx not found — MCP servers using npx won't work until Node.js is installed"
    fi
  fi
fi

# ─── Plugins ──────────────────────────────────────────────────────

step 6 "Plugin recommendations"

if [[ "$SKIP_PLUGINS" == true ]]; then
  info "Skipping plugin installation (--skip-plugins)"
else
  echo ""
  info "Recommended plugins (install inside Claude Code with /plugin install):"
  echo ""
  echo -e "  ${CYAN}/plugin install feature-dev@claude-plugins-official${NC}"
  echo -e "    Multi-phase feature development workflow (89K+ installs)"
  echo ""
  echo -e "  ${CYAN}/plugin install code-review@claude-plugins-official${NC}"
  echo -e "    Automated code review with multiple specialized agents"
  echo ""
  echo -e "  ${CYAN}/plugin install hookify@claude-plugins-official${NC}"
  echo -e "    Auto-generates hooks by analyzing your workflow"
  echo ""

  case "$PROFILE" in
    web-dev|fullstack)
      echo -e "  ${CYAN}/plugin install frontend-design@claude-plugins-official${NC}"
      echo -e "    High-quality frontend interface generation"
      echo ""
      ;;&
    python|fullstack|data-science)
      echo -e "  ${CYAN}/plugin install python-review@claude-plugins-official${NC}"
      echo -e "    Python-specific code review (PEP 8, type hints, security)"
      echo ""
      ;;
    rust)
      echo -e "  ${CYAN}/plugin install rust-review@claude-plugins-official${NC}"
      echo -e "    Rust-specific code review (ownership, lifetimes, unsafe)"
      echo ""
      ;;
    go)
      echo -e "  ${CYAN}/plugin install go-review@claude-plugins-official${NC}"
      echo -e "    Go-specific code review (concurrency, error handling)"
      echo ""
      ;;
  esac

  info "Run these commands inside a Claude Code session to install."
fi

# ─── Shell integration ────────────────────────────────────────────

step 7 "Shell integration"

if [[ "$SKIP_SHELL" == true ]]; then
  info "Skipping shell integration (--skip-shell)"
else
  SHELL_RC=""
  if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
  fi

  SHELL_SOURCE_LINE='# claude-code-kickstart shell integration'
  SHELL_FILE="$REPO_DIR/shell/aliases.sh"

  if [[ -n "$SHELL_RC" && -f "$SHELL_FILE" ]]; then
    if grep -q "claude-code-kickstart" "$SHELL_RC" 2>/dev/null; then
      info "Shell integration already installed in $SHELL_RC"
    elif [[ "$DRY_RUN" == true ]]; then
      info "[DRY RUN] Would add shell aliases to $SHELL_RC"
    elif [[ "$NO_PROMPT" == true ]]; then
      echo "" >> "$SHELL_RC"
      echo "$SHELL_SOURCE_LINE" >> "$SHELL_RC"
      echo "source \"$SHELL_FILE\"" >> "$SHELL_RC"
      success "Added shell aliases to $SHELL_RC"
    else
      echo ""
      read -p "  Add shell aliases to $SHELL_RC? [Y/n]: " add_shell
      if [[ "${add_shell:-Y}" =~ ^[Yy]$ ]]; then
        echo "" >> "$SHELL_RC"
        echo "$SHELL_SOURCE_LINE" >> "$SHELL_RC"
        echo "source \"$SHELL_FILE\"" >> "$SHELL_RC"
        success "Added shell aliases to $SHELL_RC"
        info "Run 'source $SHELL_RC' or open a new terminal to activate"
      else
        info "Skipped shell integration"
      fi
    fi
  else
    warn "Could not detect shell config file"
  fi
fi

# ─── Health check ─────────────────────────────────────────────────

step 8 "Verifying installation"

verify_item() {
  local label="$1"
  local check="$2"
  if eval "$check" &>/dev/null; then
    success "$label"
  else
    warn "$label"
  fi
}

if [[ "$DRY_RUN" != true ]]; then
  verify_item "settings.json exists" "[[ -f '$CLAUDE_DIR/settings.json' ]]"
  verify_item "Hooks configured" "jq -e '.hooks' '$CLAUDE_DIR/settings.json'"

  if [[ -d "$CLAUDE_DIR/agents" ]]; then
    local agent_count
    agent_count=$(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    success "$agent_count agents installed"
  fi

  if [[ -f "$CLAUDE_DIR/mcp-servers.json" ]]; then
    local mcp_count
    mcp_count=$(jq 'keys | length' "$CLAUDE_DIR/mcp-servers.json" 2>/dev/null || echo 0)
    success "$mcp_count MCP servers configured"
  fi

  verify_item "Keybindings configured" "[[ -f '$CLAUDE_DIR/keybindings.json' ]]"
else
  info "[DRY RUN] Would verify installation"
fi

# ─── Summary ──────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}  ══════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}   Installation complete!${NC}"
echo -e "${GREEN}${BOLD}  ══════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Profile:${NC}  $PROFILE"
echo -e "  ${BOLD}Backup:${NC}   $BACKUP_DIR"
echo ""
echo -e "  ${BOLD}What was installed:${NC}"
echo -e "    Settings    → ~/.claude/settings.json"
echo -e "    Hooks       → merged into settings.json"
echo -e "    Agents      → ~/.claude/agents/"
echo -e "    Keybindings → ~/.claude/keybindings.json"
echo -e "    MCP Servers → ~/.claude/mcp-servers.json"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    1. Open Claude Code and install recommended plugins (see above)"
echo -e "    2. Run ${CYAN}claude${NC} to start using your new setup"
echo -e "    3. Run ${CYAN}cchealth${NC} anytime to check your setup"
echo -e "    4. Run ${CYAN}ccupdate${NC} to pull the latest configs"
echo -e "    5. Read docs/WHY.md to understand each choice"
echo ""
echo -e "  ${BOLD}Useful commands:${NC}"
echo -e "    ${CYAN}cc${NC}          Start Claude Code"
echo -e "    ${CYAN}ccreview${NC}    Review your current changes"
echo -e "    ${CYAN}ccfix${NC}       Find and fix failing tests"
echo -e "    ${CYAN}cctest${NC}      Write tests for a file"
echo -e "    ${CYAN}cchealth${NC}    Check installation health"
echo -e "    ${CYAN}ccscan${NC}      Auto-generate CLAUDE.md for a project"
echo ""
echo -e "  ${BOLD}To undo:${NC}  ./uninstall.sh  or  restore from $BACKUP_DIR"
echo ""
