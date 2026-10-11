# AWS Lambda Node.js 20.x EOL Audit (SF-15)

Date: 2026-04-14

## Scope

Checked this repository for AWS Lambda runtime configuration and AWS deployment IaC that could pin runtime to `nodejs20.x`.

## What Was Checked

- Searched source and config for: `nodejs20.x`, `lambda`, `aws`, `serverless`, `cloudformation`, `sam`, `terraform`, `@aws-sdk`, `arn:aws`.
- Reviewed repository file inventory for common infra files (`template.yaml`, `serverless.yml`, `.tf`, etc.).

## Result

- No AWS Lambda function definitions were found in this repository.
- No AWS deployment IaC was found in this repository.
- No runtime pin to `nodejs20.x` was found in repository code/config.

Conclusion: the Node.js 20.x Lambda EOL notification appears **not to be caused by code currently in this repo**.

## External Follow-up (AWS Account)

Run in each active AWS region to identify actual impacted Lambda functions:

```bash
aws lambda list-functions --region <region> --output text --query "Functions[?Runtime=='nodejs20.x'].FunctionArn"
```

If any functions are returned, plan migration to `nodejs22.x` before 2026-04-30.
