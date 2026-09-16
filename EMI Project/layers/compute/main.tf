variable "environment" { type = string }
variable "project" { type = string }
variable "subnet_ids" { type = list(string) }
variable "eks_cluster_name" { type = string }
variable "node_group_name" { type = string }
variable "alb_name" { type = string }
variable "vpc_id" { type = string }
variable "alb_security_group_id" { type = string }
variable "app_security_group_id" { type = string }

locals {
  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "compute"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.eks_cluster_name
  subnet_ids      = var.subnet_ids
  node_group_name = var.node_group_name
  tags            = local.tags
}

module "alb" {
  source = "../../modules/alb"

  name              = var.alb_name
  subnet_ids        = var.subnet_ids
  security_groups   = [var.alb_security_group_id]
  target_group_port = 80
  vpc_id            = var.vpc_id
  tags              = local.tags
}

output "eks_cluster_name" { value = module.eks.cluster_name }
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "alb_security_group_id" { value = var.alb_security_group_id }
output "app_security_group_id" { value = var.app_security_group_id }
