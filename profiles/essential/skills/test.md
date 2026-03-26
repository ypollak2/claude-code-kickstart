---
name: test
description: Run tests, report results, fix failures
---

Run the project's test suite and handle the results.

## Steps

1. Detect the test framework:
   - Look for `jest.config`, `vitest.config`, `pytest.ini`, `pyproject.toml [tool.pytest]`, `Cargo.toml`, `go.mod`, `*.test.*` files
2. Run the appropriate test command:
   - JS/TS: `npm test` or `npx vitest run` or `npx jest`
   - Python: `pytest -v` or `python -m pytest -v`
   - Rust: `cargo test`
   - Go: `go test ./...`
3. If all tests pass: report the count and exit
4. If tests fail:
   - Show which tests failed and why
   - Ask the user: "Should I fix these failures?"
   - If yes, use the debugger agent to investigate and fix
   - Re-run tests to confirm the fix
5. Report final results with pass/fail counts
