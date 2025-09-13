# AWS interaction

- Use AWS API MCP Server to check the current state of my AWS
- ALWAYS use region "ap-southeast-1" (Singapore)
- You have to connect Amazon RDS PostgreSQL through Amazon EC2 (see PROPOSAL.md, Low-level Architecture Components to understand). NEVER TEMPORARILY TURN ON RDS PUBLIC ACCESS!
- NEVER setup Amazon Athena, Amazon Glue, Amazon S3 in order to access Amazon RDS PostgreSQL.