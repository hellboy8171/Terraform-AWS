variable "cluster_name" { type = string }
variable "oidc_thumbprint" { type = string }
variable "service_account_namespace" { type = string }
variable "service_account_name" { type = string }

data "aws_iam_openid_connect_provider" "existing" {
  url = "https://oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${aws_eks_cluster.this.id}"
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = "https://oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${aws_eks_cluster.this.id}"
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = ""

  vpc_config {
    subnet_ids = []
  }
}

data "aws_region" "current" {}

output "provider_arn" { value = aws_iam_openid_connect_provider.this.arn }
