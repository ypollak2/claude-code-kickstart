---
name: security-scan
description: Run a comprehensive security audit of the project
---

Perform a security audit of this project.

## Steps

1. Use the security-auditor agent (read-only) to scan the codebase for:
   - Hardcoded secrets, API keys, tokens, passwords
   - SQL injection, command injection, XSS vulnerabilities
   - Missing authentication or authorization checks
   - Sensitive data in logs or error messages
   - Insecure cryptographic patterns

2. Check dependency vulnerabilities:
   - JS/TS: `npm audit` or `pnpm audit`
   - Python: `pip audit` or `safety check`
   - Rust: `cargo audit`
   - Go: `govulncheck ./...`

3. Check for common misconfigurations:
   - `.env` files committed to git
   - Overly permissive CORS settings
   - Debug mode enabled in production configs
   - Default credentials in config files

## Output

Report findings as:
```
[CRITICAL] Issue title — must fix immediately
  File: path:line
  Fix: specific recommendation

[HIGH] Issue title — fix before next deploy
  File: path:line
  Fix: specific recommendation
```

If no issues found, confirm the codebase is clean.
