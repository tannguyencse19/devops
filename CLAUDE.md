# CLAUDE.md

## Planning Phase

- ALWAYS use `gpt-agent` MCP Server for planning. ALWAYS use model `gpt-5` when using `gpt-agent` MCP Server.
- Once planning finish, show the full detail plan and wait for review, NO CODE YET.

## Context Optimization

**CRITICAL**: Delegate aggressively to maintain peak performance.

### Delegation Thresholds

- **1-3 files**: Handle directly
- **3+ files**: ALWAYS delegate to GPT agent
- **Uncertain/research**: GPT agent
- **Context >30%**: Delegate everything

## Memory Bank System

Always read the memory bank files before doing any task: 

*   **CLAUDE-activeContext.md** - Current session state, goals, and progress (if exists)
    
*   **CLAUDE-patterns.md** - Established code patterns and conventions (if exists)
