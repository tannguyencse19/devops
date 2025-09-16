## Development Philosophy

### One-time setup pattern
- If detect there is a INSTALL script/instruction in the target existing files, plan to make an UNINSTALL script/instruction. So that if all hell breaks loose, we can UNINSTALL everything to get fresh environment.

## Implementation Priority
1. **Single file with all logic**
2. **Simple, direct implementation**
3. **Test the recovery cycle**
4. **Iterate based on user review**

## Coolify Integration Reference

**CRITICAL**: When working on tasks that involve Coolify (deployment, GitHub Actions with Coolify, API integration), 
**ALWAYS read `/root/CODE/TIMOTHY/devops/vps/ci-cd/coolify/README.md` first** before starting the task.

