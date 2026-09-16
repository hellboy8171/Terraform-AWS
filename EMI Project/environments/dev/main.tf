terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }
}

module "network" {
  source = "../../layers/network"

  environment        = var.environment
  project            = var.project
  aws_region         = var.aws_region
  vpc_cidr           = "10.10.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets    = ["10.10.11.0/24", "10.10.12.0/24"]
}

module "security" {
  source = "../../layers/security"

  environment = var.environment
  project     = var.project
  vpc_id      = module.network.vpc_id
  vpc_cidr    = "10.10.0.0/16"
  kms_alias   = "main"
  secrets = {
    "app/db-password" = "changeme-dev"
  }
  ssm_parameters = {
    "/emi/dev/db/host" = "postgres.dev.local"
  }
}

module "data" {
  source = "../../layers/data"

  environment            = var.environment
  project                = var.project
  db_name                = "appdev"
  db_username            = "appuser"
  db_password            = "ChangeMe123!"
  db_subnet_group_name   = "dev-db-subnet-group"
  vpc_security_group_ids = [module.security.db_security_group_id]
  bucket_name            = "emi-dev-artifacts"
  dynamodb_name          = "emi-dev-locks"
}

module "compute" {
  source = "../../layers/compute"

  environment           = var.environment
  project               = var.project
  subnet_ids            = module.network.private_subnet_ids
  eks_cluster_name      = "emi-dev-cluster"
  node_group_name       = "emi-dev-ng"
  alb_name              = "emi-dev-alb"
  vpc_id                = module.network.vpc_id
  alb_security_group_id = module.security.alb_security_group_id
  app_security_group_id = module.security.app_security_group_id
}

module "observability" {
  source = "../../layers/observability"

  environment    = var.environment
  project        = var.project
  log_group_name = "/aws/emi/dev/application"
}

module "delivery" {
  source = "../../layers/delivery"

  environment        = var.environment
  project            = var.project
  github_repo        = "org/emi-app"
  oidc_arn           = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  break_glass_admins = ["admin-user"]
}

output "vpc_id" { value = module.network.vpc_id }
output "eks_cluster_name" { value = module.compute.eks_cluster_name }
output "alb_dns_name" { value = module.compute.alb_dns_name }
