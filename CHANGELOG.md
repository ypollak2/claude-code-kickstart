# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-03-26

### Added
- **8 new agents** (12 total): test-writer, refactorer, doc-writer, pr-reviewer, performance-analyzer, migrator, git-assistant, api-designer
- **5 new profiles** (10 total): rust, go, devops, data-science, mobile
- **Profile-specific agents**: rust-reviewer, go-reviewer, infra-reviewer, data-analyst
- **Auto-detect** (`--auto` flag): scans package.json, Cargo.toml, go.mod, etc. to suggest the right profile
- **Health check**: `cchealth` command to verify installation status
- **13 new shell commands**: cctest, ccrefactor, ccrf, ccpr, ccrebase, ccbisect, ccscan, cchealth, ccupdate, ccsessions, ccstats, ccq
- **Tab completion** for zsh and bash on file-based commands
- **Post-install verification** step in installer (step 8/8)
- **Profile-aware plugin recommendations** in installer
- **Devops deny rules**: terraform apply, kubectl delete, docker system prune blocked by default

### Changed
- Installer now has 8 steps (was 7)
- Profile picker expanded to 10 options (was 5)
- Shell aliases.sh rewritten with better organization and KICKSTART_DIR tracking
- WHY.md expanded with agent design philosophy and profile rationale

## [1.0.0] - 2026-03-26

### Added
- Initial release
- **3 MCP servers**: Context7, Playwright, Sequential Thinking
- **5 hooks**: auto-format, block rm -rf, block force-push, block sensitive files, desktop notifications
- **4 agents**: code-reviewer, planner, security-auditor, debugger
- **5 profiles**: essential, web-dev, python, fullstack, privacy-first
- **7 shell aliases**: cc, ccp, ccr, ccreview, ccfix, cce, ccinit
- **install.sh** with interactive profile picker, backup, dry-run, merge-based config
- **uninstall.sh** with backup restore
- **docs/WHY.md** explaining every choice
- **docs/CUSTOMIZE.md** guide for modifications
- Privacy-respecting defaults (telemetry off, credential paths denied)
