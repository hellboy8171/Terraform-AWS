# EMI Project Terraform Repository

This repository provides a production-oriented Terraform structure for a 3-tier AWS application deployed across `dev`, `staging`, and `prod` environments. It is organized around reusable modules, layer-based composition, and environment-specific state isolation.

## Repository layout

```text
EMI Project/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── .gitignore
├── README.md
├── providers.tf
├── versions.tf
├── modules/
│   ├── acm/
│   ├── alb/
│   ├── billing/
│   ├── break-glass-role/
│   ├── ci-cd-role/
│   ├── cloudwatch/
│   ├── dynamodb/
│   ├── ecr/
│   ├── ec2/
│   ├── eks/
│   ├── elastic-ip/
│   ├── iam/
│   ├── internet-gateway/
│   ├── kms/
│   ├── nat-gateway/
│   ├── oidc/
│   ├── rds/
│   ├── route53/
│   ├── s3/
│   ├── secrets-manager/
│   ├── security-group/
│   ├── ssm-parameter/
│   ├── ssm-session-manager/
│   ├── tags/
│   ├── vpc/
│   └── vpc-endpoints/
├── layers/
│   ├── compute/
│   ├── data/
│   ├── delivery/
│   ├── network/
│   ├── observability/
│   └── security/
├── environments/
│   ├── dev/
│   │   ├── backend.hcl
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   ├── staging/
│   │   ├── backend.hcl
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── prod/
│       ├── backend.hcl
│       ├── main.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── scripts/
│   ├── bootstrap-backend.sh
│   ├── drift-check.sh
│   ├── oidc-setup.sh
│   └── tfsec.sh
└── .terraform.lock.hcl (generated during init)
```

## Design principles

- Environment isolation via separate S3 state buckets and DynamoDB lock tables.
- Layered composition for network, security, data, compute, and delivery concerns.
- Reusable AWS modules for the services requested in the architecture.
- Strong IAM and security boundaries with break-glass controls.
- Provider pinning and default tagging across all AWS resources.
- CI/CD workflow gating for validate, plan, and approval-based prod apply.

## Architecture model

### Layers

- Network layer: VPC, subnets, IGW, NAT gateway, EIP, route tables.
- Security layer: KMS, Secrets Manager, SSM Parameter Store, security groups.
- Data layer: RDS, S3, DynamoDB.
- Compute layer: EKS, ALB, EC2, IRSA/OIDC-ready integration.
- Observability layer: CloudWatch and Logs.
- Delivery layer: CI/CD deploy role, break-glass admin access, billing guardrails.

### Environment model

- dev: small footprint, quick iteration, less strict drift cost controls
- staging: near-prod validation and regression confidence
- prod: protected approvals, stricter guardrails, targeted rollout controls

## Terraform state backend

Each environment has an isolated backend file in its directory. The backend bootstrap script creates the S3 bucket and DynamoDB lock table needed for a given environment.

### Backend bootstrap

```bash
cd scripts
AWS_REGION=us-east-1 PROJECT=emi ./bootstrap-backend.sh dev
AWS_REGION=us-east-1 PROJECT=emi ./bootstrap-backend.sh staging
AWS_REGION=us-east-1 PROJECT=emi ./bootstrap-backend.sh prod
```

This will create the following resources:
- S3 bucket: `emi-<env>-tfstate`
- DynamoDB table: `emi-<env>-locks`

Then initialize each environment with:

```bash
cd environments/dev
terraform init -backend-config=backend.hcl

cd ../staging
terraform init -backend-config=backend.hcl

cd ../prod
terraform init -backend-config=backend.hcl
```

## GitHub Actions release flow

The workflow in [`.github/workflows/terraform.yml`](.github/workflows/terraform.yml) does the following:

1. Validate Terraform formatting and syntax for dev, staging, and prod.
2. Run dev and staging plan jobs for pull requests and branch pushes.
3. Require GitHub environment approvals for `dev`, `staging`, and `prod`.
4. Apply prod only on push to `main` after staging plan and environment approval.

### GitHub environment setup

Create the following GitHub environments in the repository settings:
- `dev`
- `staging`
- `prod`

Then configure environment protection rules:
- `dev`: require reviewers for production-sensitive changes if desired
- `staging`: require reviewers and a wait timer
- `prod`: require reviewers, delay, and the final approval gate before apply

## Security model

### Security groups

The security layer defines separate SGs for:
- ALB ingress from the internet
- App tier ingress from ALB only
- EKS control-plane access from VPC CIDR
- RDS PostgreSQL ingress from app and EKS SGs

This creates a realistic east-west and ingress segmentation pattern without exposing database ports broadly.

## Operational guidance

### Drift detection

Use the drift checker script:

```bash
./scripts/drift-check.sh dev
./scripts/drift-check.sh staging
./scripts/drift-check.sh prod
```

### Static analysis

```bash
./scripts/tfsec.sh
```

### Break-glass access

The repo includes a break-glass path via IAM group/role patterns in the delivery layer. Use these strictly for emergency interventions and audit access.

## Production hardening checklist

- Keep `terraform.tfvars` values out of source control for real secrets.
- Use AWS Secrets Manager or SSM Parameter Store for runtime secrets.
- Restrict IAM roles to the minimum action set needed.
- Review and approve changes in the `staging` and `prod` GitHub environments.
- Enforce state bucket encryption and versioning.
- Add policy checks and scan tools such as tfsec / Checkov in CI.

## Example commands

```bash
# format
terraform fmt -recursive

# validate all environments
cd environments/dev && terraform init -backend=false && terraform validate
cd ../staging && terraform init -backend=false && terraform validate
cd ../prod && terraform init -backend=false && terraform validate
```

## Notes

This repo is intentionally structured as a realistic starting point rather than a fully hardened production deployment. Before going live, replace placeholder account IDs, admin users, and repo identifiers with your real values.
