variable "environment" { type = string }
variable "project" { type = string }
variable "log_group_name" { type = string }

locals {
  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "observability"
  }
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  log_group_name    = var.log_group_name
  retention_in_days = 30
  tags              = local.tags
}

output "log_group_arn" { value = module.cloudwatch.log_group_arn }
