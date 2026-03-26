---
name: deploy-check
description: Pre-deployment checklist — tests, build, security, env vars, migrations
---

Run a pre-deployment checklist before shipping to production.

## Checklist

### 1. Tests
- Run the full test suite
- If any tests fail, STOP and report

### 2. Build
- Run the production build command
- If build fails, STOP and report
- Check build output size (flag if unusually large)

### 3. Security
- Run `npm audit` / `pip audit` / `cargo audit` / `govulncheck`
- Check for hardcoded secrets with: `grep -r "password\|secret\|api_key\|token" --include="*.{ts,js,py,go,rs}" -l`
- Verify no .env files are in git: `git ls-files | grep -i '\.env'`

### 4. Environment
- Check that all required env vars are documented (compare .env.example to code usage)
- Verify no dev-only settings leak to production (debug modes, verbose logging)

### 5. Database
- Check for pending migrations: `npx prisma migrate status` / `python manage.py showmigrations` / etc.
- Flag any destructive migrations (DROP TABLE, DROP COLUMN)

### 6. Git
- Confirm working tree is clean: `git status`
- Confirm you're on the right branch
- Confirm branch is up to date with remote

## Output

```
Pre-deploy checklist for: <project>
═══════════════════════════════════
[PASS] Tests: 142 passed, 0 failed
[PASS] Build: successful (2.3 MB)
[PASS] Security: no vulnerabilities
[PASS] Env vars: all documented
[PASS] Database: no pending migrations
[PASS] Git: clean, up to date

Verdict: READY TO DEPLOY
```

Or if issues found:
```
[FAIL] Tests: 3 failures
  → Fix before deploying

Verdict: NOT READY — fix 1 issue first
```
