# CLAUDE.md

## Memory Bank System

Always read the memory bank files before doing any task: 

- **CLAUDE-patterns.md** - Established code patterns and conventions
- **CLAUDE-activePlan.md** - Current working plan, how many parts, which part has done
- **CLAUDE-currentProgress.md** - Current session state, goals, and progress

- NEVER read files in `archive` folder EXCEPT
  + Being explictly tell to do so

# Simplicity First

- When planning, aim for the simplest viable slice, not a full-fledged feature. Define a minimal, testable scope to ship quickly and iterate.
- NEVER plan alternative approach.
- **Do simple things instead of complicated design** - user will review work anyway
- Avoid over-engineering or premature optimization

## Third Party Documentation

- ALWAYS use `context7` MCP Server to search for documnetation
- If `context7` not have enough documentation, by then using `web search`
- When fixing/debugging something, if you try 2 times by yourself and still can't fix it
   a) Perform some `context7` MCP Server search 
   b) Web Search.

# Development Principles

## COLOCATION Principle

**CRITICAL**: Follow COLOCATION principle - keep related files as close together as possible.

- **Don't scatter feature files**: Avoid putting one file in `components/`, another in `hooks/`, and another in `utils/`
- **Group by feature**: If files belong to the same feature, put them in the same directory
- If two features need to use a same logic, put that logic in a folder called `shared/`, located to the nearest common parent of both logic.

## Write Shell Script Principle

- All script file must in this naming convention: `<UPPERCASE_SNAKE_CASE_NAME>.sh`.
- After finish all your work, WRITE one single script to capture all your work, so that in future I just run the script to reproduce your work.
- Although everything is inside a single script, but if you have code or other files, you can create separate files near the script file, and reference those files in the script file. By doing that, it is easier to maintain the script.
- When fixing the script, run the command directly first, then after confirm the command work, by then fix the script. Don't fix the script and then run it to test if the command work because it takes longer time.
- If you changed the script, you have to TEST it before claiming the current step has done.
- ALWAYS echo message that MAKE DEBUGGING EASIER.

## Integration Philosophy

- Replace existing systems completely rather than gradual migration
- NEVER do immediate fix/hotfix

## Factual Check

- If you state something, ALWAYS cite the source you check.

# Security Guidelines for Documentation

**CRITICAL**: NEVER WRITE DOWN SECRET VALUE INTO MARKDOWN FILE. ONLY WRITE DOWN:
a) **SECRET KEY NAME** (e.g., `GITHUBB_TIMOTHYNGUYEN_COOLIFY_GITHUB_ACTION_API_TOKEN`, `ADMIN_PASSWORD`)
b) **HOW TO GET THE ACTUAL SECRET VALUE**

## Secret Handling Rules

- **Keys-Only Policy**: Always document secret names and retrieval location/process; never values, partial values, or screenshots
- **Safe Placeholders**: Use `<SECRET_KEY_NAME>` style placeholders in examples; never realistic-looking dummy values
- **No Inline Secrets**: Prohibit secrets in code blocks, URLs, logs, outputs, or screenshots included in docs
- **CI/CD Handling**: Only refer to CI secret names and where to fetch values (the `.env` file); never paste values into YAML

# Others

- If detect a port is occupied, stop any existing processes on that port, then try again. NEVER change the specified port.
- NEVER shorten environment variable names in code - always use the full original name to avoid misleading error messages.
- If you have anything concern, tell me EXPLICITLY so that I can make decision.
- If timeout happened, let me know so that I can make decision what to deal with that
- Use the environment variable in `scripts/STEP_1_SET_ENVIRONMENT.sh`
- If you create new resource, use CHEAPEAST OPTION FOR MINIMAL COST. BUT DO NOT CHANGE THE RESOURCE DEFINED IN THE ARCHITECTURE INTO SOMETHING DIFFERENT BUT CHEAPER. If you have trouble making this decision, STOP and let me know.
- All database timestamps must be stored in UTC+0 timezone only - applications handle timezone conversion, never the database.
- If you having timeout while doing something, but the next thing you intend to do depend on this timeout thing, STOP and let me know.