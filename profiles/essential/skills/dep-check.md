---
name: dep-check
description: Audit dependencies for outdated packages, vulnerabilities, and unused imports
---

Audit this project's dependencies.

## Steps

1. **Find outdated packages**:
   - JS/TS: `npm outdated` or `pnpm outdated`
   - Python: `pip list --outdated` or `uv pip list --outdated`
   - Rust: `cargo outdated` (if installed) or check Cargo.toml versions
   - Go: `go list -m -u all`

2. **Check for vulnerabilities**:
   - JS/TS: `npm audit`
   - Python: `pip audit` or `safety check`
   - Rust: `cargo audit`
   - Go: `govulncheck ./...`

3. **Find unused dependencies**:
   - JS/TS: check if `depcheck` or `knip` is available, run it
   - Python: check imports vs installed packages
   - Go: `go mod tidy -diff` to see what would be cleaned up

4. **Report findings**:

```
## Outdated (X packages)
| Package | Current | Latest | Breaking? |
|---------|---------|--------|-----------|

## Vulnerabilities (X found)
| Package | Severity | Advisory |
|---------|----------|----------|

## Unused (X packages)
| Package | Safe to remove? |
|---------|-----------------|
```

5. Ask the user if they want to:
   - Update non-breaking dependencies automatically
   - Use the migrator agent for major version upgrades
   - Remove unused dependencies
