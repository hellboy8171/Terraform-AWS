variable "environment" { type = string }
variable "project" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_subnet_group_name" { type = string }
variable "vpc_security_group_ids" { type = list(string) }
variable "bucket_name" { type = string }
variable "dynamodb_name" { type = string }

locals {
  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "data"
  }
}

module "rds" {
  source = "../../modules/rds"

  identifier             = "${var.project}-${var.environment}-db"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = local.tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = var.bucket_name
  tags        = local.tags
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  name          = var.dynamodb_name
  hash_key      = "LockID"
  hash_key_type = "S"
  tags          = local.tags
}

output "rds_endpoint" { value = module.rds.endpoint }
output "s3_bucket_name" { value = module.s3.bucket_name }
output "dynamodb_name" { value = module.dynamodb.table_name }
