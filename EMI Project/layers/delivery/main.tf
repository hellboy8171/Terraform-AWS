variable "environment" { type = string }
variable "project" { type = string }
variable "github_repo" { type = string }
variable "oidc_arn" { type = string }
variable "break_glass_admins" {
  type    = list(string)
  default = []
}

locals {
  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "delivery"
  }
}

module "ci_cd_role" {
  source = "../../modules/ci-cd-role"

  name        = "${var.project}-${var.environment}-deploy-role"
  github_repo = var.github_repo
  oidc_arn    = var.oidc_arn
}

module "break_glass_role" {
  source = "../../modules/break-glass-role"

  name   = "${var.project}-${var.environment}-breakglass"
  admins = var.break_glass_admins
}

module "billing" {
  source = "../../modules/billing"

  name                = "${var.project}-${var.environment}-budget"
  budget_limit_amount = 250
  currency            = "USD"
  time_unit           = "MONTHLY"
  threshold           = 80
}

output "ci_cd_role_arn" { value = module.ci_cd_role.role_arn }
output "break_glass_group" { value = module.break_glass_role.group_name }
