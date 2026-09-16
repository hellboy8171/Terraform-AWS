variable "environment" { type = string }
variable "project" { type = string }
variable "vpc_id" { type = string }
variable "kms_alias" { type = string }
variable "secrets" { type = map(string) }
variable "ssm_parameters" { type = map(string) }

locals {
  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "security"
  }
}

module "kms" {
  source = "../../modules/kms"

  name        = "${var.project}-${var.environment}-${var.kms_alias}"
  description = "KMS for ${var.project} ${var.environment}"
  tags        = local.tags
}

module "alb_security_group" {
  source = "../../modules/security-group"

  name   = "${var.project}-${var.environment}-alb"
  vpc_id = var.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTP from Internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    },
    {
      description = "Allow HTTPS from Internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    }
  ]

  tags = local.tags
}

module "app_security_group" {
  source = "../../modules/security-group"

  name   = "${var.project}-${var.environment}-app"
  vpc_id = var.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTP from ALB"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = []
      self        = false
    },
    {
      description = "Allow HTTPS from ALB"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = []
      self        = false
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      self        = false
    }
  ]

  tags = local.tags
}

module "secrets" {
  for_each = var.secrets

  source = "../../modules/secrets-manager"

  name         = each.key
  secret_value = each.value
  description  = "Secret for ${var.environment} ${var.project}"
  tags         = local.tags
}

module "ssm_parameters" {
  for_each = var.ssm_parameters

  source = "../../modules/ssm-parameter"

  name        = each.key
  value       = each.value
  description = "Parameter for ${var.environment} ${var.project}"
  type        = "SecureString"
  tags        = local.tags
}

output "kms_key_arn" { value = module.kms.key_arn }
output "secret_arns" { value = { for k, v in module.secrets : k => v.arn } }
output "ssm_parameter_arns" { value = { for k, v in module.ssm_parameters : k => v.arn } }
output "alb_security_group_id" { value = module.alb_security_group.security_group_id }
output "app_security_group_id" { value = module.app_security_group.security_group_id }
