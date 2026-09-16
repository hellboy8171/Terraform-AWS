variable "name" { type = string }
variable "vpc_id" { type = string }
variable "ingress_rules" {
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    self            = optional(bool, false)
    security_groups = optional(list(string), [])
  }))
  default = []
}
variable "egress_rules" {
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    self            = optional(bool, false)
    security_groups = optional(list(string), [])
  }))
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_security_group" "this" {
  name        = var.name
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = {
    for idx, rule in var.ingress_rules : idx => rule
  }

  security_group_id            = aws_security_group.this.id
  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null

  depends_on = [aws_security_group.this]
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = {
    for idx, rule in var.egress_rules : idx => rule
  }

  security_group_id            = aws_security_group.this.id
  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null

  depends_on = [aws_security_group.this]
}

output "security_group_id" { value = aws_security_group.this.id }
output "security_group_name" { value = aws_security_group.this.name }
