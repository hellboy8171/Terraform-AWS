# Terraform 3-Tier AWS Repository

This repository is structured for a production-grade three-tier application deployed to AWS across separate `dev`, `staging`, and `prod` environments.

## Repository layout

```text
EMI Project/
├── README.md
├── .gitignore
├── versions.tf
├── providers.tf
├── modules/
│   ├── vpc/
│   ├── internet-gateway/
│   ├── nat-gateway/
│   ├── elastic-ip/
│   ├── vpc-endpoints/
│   ├── eks/
│   ├── ec2/
│   ├── ecr/
│   ├── rds/
│   ├── secrets-manager/
│   ├── ssm-parameter/
│   ├── kms/
│   ├── s3/
│   ├── dynamodb/
│   ├── iam/
│   ├── oidc/
│   ├── cloudwatch/
│   ├── alb/
│   ├── acm/
│   ├── route53/
│   ├── ssm-session-manager/
│   ├── billing/
│   ├── ci-cd-role/
│   ├── break-glass-role/
│   └── tags/
├── layers/
│   ├── network/
│   ├── security/
│   ├── data/
│   ├── compute/
│   ├── app/
│   ├── observability/
│   └── delivery/
├── environments/
│   ├── dev/
│   │   ├── backend.hcl
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── backend.hcl
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── backend.hcl
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
└── scripts/
    ├── drift-check.sh
    ├── tfsec.sh
    └── oidc-setup.sh
```

## Design principles

- Separate S3 backend and DynamoDB locking tables per environment.
- State file isolation via `backend.hcl` config files.
- `for_each` used for environment iteration and multi-resource patterns.
- Typed variables and explicit outputs across layers.
- Secret-scoped management using Secrets Manager and SSM Parameter Store.
- IAM least privilege + break-glass access patterns.
- CI/CD gates for plan/apply workflows, including drift detection.
- Provider pinning and consistent AWS tagging for governance.

## Tiering

- Tier 1: network, IAM, security, and edge services.
- Tier 2: application runtime, EKS, EC2, ALB, and databases.
- Tier 3: data, observability, secrets, and delivery workers.

## Example init commands

```bash
terraform init -backend-config=environments/dev/backend.hcl
terraform init -backend-config=environments/staging/backend.hcl
terraform init -backend-config=environments/prod/backend.hcl
```

## Best-practice notes

- Use `terraform plan -out=tfplan` in CI pipelines and require manual approval for apply.
- Enable guardrails using `aws_iam_policy` and role conditions.
- Protect secrets and rotate credentials via Secrets Manager.
- Keep `key` names unique per environment and workload.
- Use lifecycle rules and versioning for S3 objects.
- Configure ACM certs and Route 53 DNS records in the platform layer.
