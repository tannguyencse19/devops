# CLAUDE.md

## Memory Bank System

Always read the memory bank files before doing any task: 

- **CLAUDE-patterns.md** - Established code patterns and conventions
- **CLAUDE-activePlan.md** - Current working plan, how many parts, which part has done
- **CLAUDE-activeContext.md** - Current working part of the plan, current progress, goals

### Simplicity First
- When planning, aim for the simplest viable slice, not a full-fledged feature. Define a minimal, testable scope to ship quickly and iterate.
- NEVER plan alternative approach.
- **Do simple things instead of complicated design** - user will review work anyway
- Avoid over-engineering or premature optimization

## Planning Phase

- ALWAYS use `gpt-agent` MCP Server for planning. ALWAYS use model `gpt-5` when using `gpt-agent` MCP Server.
- Once planning finish, show the full detail plan and WAIT FOR REVIEW, NEVER DO ANYTHING NEXT.
- Once finish writing down the plan to `CLAUDE-activePlan.md`, WAIT FOR REVIEW, NEVER DO ANYTHING NEXT.

## Third Party Documentation

- ALWAYS use `context7` MCP Server to search for documnetation
- If `context7` not have enough documentation, by then using `web search`
- When fixing/debugging something, if you try 2 times by yourself and still can't fix it
   a) Perform some `context7` MCP Server search or Web Search.
   b) Asking `gpt-agent`

## Security Guidelines for Documentation

**CRITICAL**: NEVER WRITE DOWN SECRET VALUE INTO MARKDOWN FILE. ONLY WRITE DOWN:
a) **SECRET KEY NAME** (e.g., `GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN`, `ADMIN_PASSWORD`)
b) **HOW TO GET THE ACTUAL SECRET VALUE** (in this case is `/vps/ci-cd/coolify/.env`)

### Secret Handling Rules

- **Keys-Only Policy**: Always document secret names and retrieval location/process; never values, partial values, or screenshots
- **Safe Placeholders**: Use `<SECRET_KEY_NAME>` style placeholders in examples; never realistic-looking dummy values
- **Source of Truth**: Reference `/vps/ci-cd/coolify/.env` for actual values; do not duplicate values elsewhere
- **No Inline Secrets**: Prohibit secrets in code blocks, URLs, logs, outputs, or screenshots included in docs
- **CI/CD Handling**: Only refer to CI secret names and where to fetch values (the `.env` file); never paste values into YAML
- **Git Rules**: `.env` files must be ignored and never committed; do not paste `.env` contents into issues/PRs
- **Accidental Exposure**: If exposure occurs, rotate immediately, scrub the artifact, and update `.env` and CI stores

# Miscellaneous

- NEVER use special characters, unicode characters when editing files.
- All script file must in this format: `<UPPERCASE_NAME>.sh`