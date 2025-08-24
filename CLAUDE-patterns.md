# Code Patterns and Conventions

## Development Philosophy

### Simplicity First
- **Keep all logic in a single file** when first implementing anything
- **Do simple things instead of complicated design** - user will review work anyway
- Avoid over-engineering or premature optimization
- Start minimal, then iterate based on feedback

### Install/Uninstall Pattern
- **ALWAYS create both INSTALL and UNINSTALL versions** for any deployment/setup script
- If all hell breaks loose, we can UNINSTALL everything to get fresh environment
- Then INSTALL again cleanly
- This provides reliable recovery path and clean slate capability

## Script Structure Guidelines

### Single File Approach
```bash
# Example structure for setup scripts
#!/bin/bash
set -euo pipefail

# All functions in same file
install_component() {
    # Installation logic
}

uninstall_component() {
    # Complete cleanup logic
}

# Simple main execution
case "${1:-install}" in
    install)   install_component ;;
    uninstall) uninstall_component ;;
    *)         echo "Usage: $0 {install|uninstall}" ;;
esac
```

### Recovery-First Design
- Every INSTALL action should have corresponding UNINSTALL action
- Document what gets created/modified for complete cleanup
- Test UNINSTALL � INSTALL cycle to ensure reliability
- Prefer stateless installations that can be completely removed

## Implementation Priority
1. **Single file with all logic**
2. **Simple, direct implementation**
3. **Both install and uninstall paths**
4. **Test the recovery cycle**
5. **Iterate based on user review**

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