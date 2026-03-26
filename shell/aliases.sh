# claude-code-kickstart shell integration
# Source this file in your .zshrc or .bashrc

# ─── Core aliases ─────────────────────────────────────────────────

alias cc="claude"
alias ccp="claude --plan"
alias ccr="claude --resume"

# ─── Quick commands ───────────────────────────────────────────────

# Review current changes
alias ccreview='claude "Review my current git diff for bugs and issues"'

# Generate a commit message
alias cccommit='claude "/commit"'

# Explain a file
cce() {
  if [[ -z "$1" ]]; then
    echo "Usage: cce <file>"
    return 1
  fi
  claude "Explain what this file does and its key design decisions: $1"
}

# Fix failing tests
ccfix() {
  claude "Run the tests, find what's failing, and fix it. Run tests again to confirm."
}

# Quick question without starting a session
ccq() {
  if [[ -z "$1" ]]; then
    echo "Usage: ccq 'your question'"
    return 1
  fi
  claude --no-input "$*"
}

# ─── Project setup ────────────────────────────────────────────────

# Initialize CLAUDE.md for current project
ccinit() {
  if [[ -f "CLAUDE.md" ]]; then
    echo "CLAUDE.md already exists in this directory."
    return 1
  fi
  local kickstart_dir
  kickstart_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}")")/.."
  if [[ -f "$kickstart_dir/profiles/essential/CLAUDE.md" ]]; then
    cp "$kickstart_dir/profiles/essential/CLAUDE.md" ./CLAUDE.md
    echo "Created CLAUDE.md — edit it with your project details."
  else
    echo "Kickstart template not found. Creating minimal CLAUDE.md."
    echo "# Project Instructions" > CLAUDE.md
    echo "" >> CLAUDE.md
    echo "## Stack" >> CLAUDE.md
    echo "## Commands" >> CLAUDE.md
    echo "## Architecture" >> CLAUDE.md
  fi
}
