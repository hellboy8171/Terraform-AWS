variable "name" { type = string }
variable "github_repo" { type = string }
variable "oidc_arn" { type = string }

resource "aws_iam_role" "this" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "terraform_apply" {
  name = "terraform-apply-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:*",
        "dynamodb:*",
        "ec2:*",
        "eks:*",
        "iam:PassRole",
        "rds:*",
        "logs:*",
        "ssm:*",
        "kms:*",
        "secretsmanager:*",
        "acm:*",
        "route53:*",
        "elasticloadbalancing:*"
      ]
      Resource = "*"
    }]
  })
}

output "role_arn" { value = aws_iam_role.this.arn }
