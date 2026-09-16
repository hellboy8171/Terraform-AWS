variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "route_table_ids" {
  type    = list(string)
  default = []
}
variable "service_names" { type = list(string) }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_vpc_endpoint" "this" {
  for_each = toset(var.service_names)

  vpc_id              = var.vpc_id
  service_name        = each.value
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name}-${replace(each.value, ".", "-")}" })
}

output "ids" { value = { for k, v in aws_vpc_endpoint.this : k => v.id } }
