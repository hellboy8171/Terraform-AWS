terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

variable "environment" { type = string }
variable "project" { type = string }
variable "aws_region" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "availability_zones" { type = list(string) }

locals {
  tags = {
    Environment = var.environment
    Project     = var.project
    Layer       = "network"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name            = "${var.project}-${var.environment}"
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = local.tags
}

module "igw" {
  source = "../../modules/internet-gateway"

  name   = "${var.project}-${var.environment}"
  vpc_id = module.vpc.vpc_id
  tags   = local.tags
}

module "nat" {
  source = "../../modules/nat-gateway"

  name          = "${var.project}-${var.environment}"
  subnet_id     = module.vpc.public_subnet_ids[0]
  allocation_id = module.eip.eip_id
  tags          = local.tags
}

module "eip" {
  source = "../../modules/elastic-ip"

  name = "${var.project}-${var.environment}"
  tags = local.tags
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.igw.internet_gateway_id
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-public-rt" })
}

resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.nat.nat_gateway_id
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-private-rt" })
}

resource "aws_route_table_association" "public" {
  for_each = toset(module.vpc.public_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = toset(module.vpc.private_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "nat_gateway_id" { value = module.nat.nat_gateway_id }
output "public_route_table_id" { value = aws_route_table.public.id }
output "private_route_table_id" { value = aws_route_table.private.id }
