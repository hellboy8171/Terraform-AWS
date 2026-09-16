variable "name" { type = string }
variable "value" { type = string }
variable "type" {
  type    = string
  default = "SecureString"
}
variable "description" {
  type    = string
  default = "Parameter store entry"
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_ssm_parameter" "this" {
  name        = var.name
  description = var.description
  type        = var.type
  value       = var.value

  tags = merge(var.tags, { Name = var.name })
}

output "arn" { value = aws_ssm_parameter.this.arn }
output "name" { value = aws_ssm_parameter.this.name }
