variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
variable "cost_center" { type = string }

output "common_tags" {
  value = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }
}
