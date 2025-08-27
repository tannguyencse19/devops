# Code Patterns and Conventions

## Development Philosophy

### Simplicity First
- When planning, aim for the simplest viable slice, not a full-fledged feature. Define a minimal, testable scope to ship quickly and iterate.
- NEVER plan alternative approach.
- **Do simple things instead of complicated design** - user will review work anyway
- Avoid over-engineering or premature optimization

### One-time setup pattern
- If detect there is a INSTALL script/instruction in the target existing files, plan to make an UNINSTALL script/instruction. So that if all hell breaks loose, we can UNINSTALL everything to get fresh environment.

## Implementation Priority
1. **Single file with all logic**
2. **Simple, direct implementation**
3. **Test the recovery cycle**
4. **Iterate based on user review**

## **COLOCATION PRINCIPLE** 🏆

**CRITICAL PATTERN**: Always follow the colocation principle

### Definition
Place related files as close as possible to where they're used:
- Documentation next to the code it describes
- Configuration files with the components they configure
- Scripts near the functionality they support

### Examples Applied
✅ **Correct**: `.github/COOLIFY_SETUP.md` near `.github/workflows/build-and-deploy.yml`
❌ **Wrong**: `docs/COOLIFY_SETUP.md` far from GitHub Actions workflow

### Benefits
- Easier to find related files
- Better maintainability
- Clear relationships between components
- Reduced cognitive load

### Implementation Rules
1. Documentation lives with the code it documents
2. Config files stay with components they configure
3. Helper scripts colocate with main functionality
4. Tests alongside source code when possible

**ALWAYS REMEMBER**: When creating or organizing files, ask "What is this most closely related to?" and place it there.

## Examples Applied
- Coolify INSTALL.sh � should have UNINSTALL.sh counterpart
- Docker setup � include Docker removal/cleanup
- Database setup � include data/container cleanup
- Configuration files � track and remove all created files

## Coolify Integration Reference

**CRITICAL**: When working on tasks that involve Coolify (deployment, GitHub Actions with Coolify, API integration), 
**ALWAYS read `/root/CODE/TIMOTHY/devops/vps/ci-cd/coolify/README.md` first** before starting the task.

