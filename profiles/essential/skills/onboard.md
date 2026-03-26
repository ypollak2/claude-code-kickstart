---
name: onboard
description: Get oriented in an unfamiliar codebase — understand stack, structure, and patterns
---

Help me understand this codebase. I'm new here.

## Steps

1. **Detect the stack**:
   - Read package.json, requirements.txt, Cargo.toml, go.mod, pom.xml, etc.
   - Identify the framework(s), language(s), and key dependencies
   - Note the package manager and build tool

2. **Map the structure**:
   - List the top-level directories and their purpose
   - Identify the entry point(s) (main.ts, app.py, main.go, etc.)
   - Find the config files (env, docker, CI/CD)

3. **Identify key patterns**:
   - How is the project organized? (feature-based, layer-based, domain-driven)
   - What patterns are used? (MVC, clean architecture, serverless, monorepo)
   - How is state managed? (database, cache, in-memory)
   - How is auth handled?

4. **Find the dev workflow**:
   - How to install dependencies
   - How to run the dev server
   - How to run tests
   - How to build for production
   - How to deploy

5. **Generate a CLAUDE.md** with all the above information, following the kickstart template format

## Output

Provide a structured overview, then offer to create/update the CLAUDE.md file with everything discovered.
