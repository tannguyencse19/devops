# AWS interaction

- Use AWS API MCP Server to check the current state of my AWS
- ALWAYS use region "ap-southeast-1" (Singapore)
- You have to connect Amazon RDS PostgreSQL through Amazon EC2 (see PROPOSAL.md, Low-level Architecture Components to understand). NEVER TEMPORARILY TURN ON RDS PUBLIC ACCESS!
- NEVER setup Amazon Athena, Amazon Glue, Amazon S3 in order to access Amazon RDS PostgreSQL.
- When writing script using `aws cli`, if using the option `--output`, REMEMBER to use flag `--no-cli-pager` to prevent the script stucking at "vi editor"
- If AWS return error message, don't suppressed it (/dev/null) but echo it out in the script.
- For AWS QuickSight parameter names, use `camelCase` naming convention.