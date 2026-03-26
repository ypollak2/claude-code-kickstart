#!/usr/bin/env bash
set -euo pipefail

# claude-code-kickstart uninstaller

CLAUDE_DIR="$HOME/.claude"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}claude-code-kickstart uninstaller${NC}"
echo ""

# Find the most recent backup
LATEST_BACKUP=$(ls -dt "$CLAUDE_DIR"/backup-* 2>/dev/null | head -1)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo -e "${YELLOW}No backup found.${NC} Cannot auto-restore."
  echo ""
  echo "To manually clean up:"
  echo "  - Edit ~/.claude/settings.json to remove kickstart hooks and permissions"
  echo "  - Remove agents: rm ~/.claude/agents/{code-reviewer,planner,security-auditor,debugger}.md"
  echo "  - Edit ~/.claude/mcp-servers.json to remove kickstart MCP servers"
  echo "  - Remove shell integration line from your .zshrc/.bashrc"
  exit 1
fi

echo -e "Found backup: ${BOLD}$LATEST_BACKUP${NC}"
echo ""

read -p "Restore from this backup? [Y/n]: " confirm
if [[ "${confirm:-Y}" =~ ^[Yy]$ ]]; then
  # Restore backed up files
  for f in "$LATEST_BACKUP"/*; do
    filename=$(basename "$f")
    # Skip the .bak suffix copy
    if [[ "$filename" == *.bak ]]; then continue; fi
    cp "$f" "$CLAUDE_DIR/$filename"
    echo -e "  ${GREEN}Restored${NC} $filename"
  done

  # Remove kickstart agents
  for agent in code-reviewer planner security-auditor debugger; do
    if [[ -f "$CLAUDE_DIR/agents/$agent.md" ]]; then
      rm "$CLAUDE_DIR/agents/$agent.md"
      echo -e "  ${GREEN}Removed${NC} agent: $agent"
    fi
  done

  # Remove shell integration
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [[ -f "$rc" ]] && grep -q "claude-code-kickstart" "$rc"; then
      sed -i.bak '/claude-code-kickstart/d' "$rc"
      rm -f "$rc.bak"
      echo -e "  ${GREEN}Removed${NC} shell integration from $(basename "$rc")"
    fi
  done

  echo ""
  echo -e "${GREEN}${BOLD}Uninstall complete.${NC} Your previous config has been restored."
  echo "Open a new terminal for shell changes to take effect."
else
  echo "Aborted."
fi
