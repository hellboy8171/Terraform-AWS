variable "name" { type = string }
variable "secret_value" { type = string }
variable "description" {
  type    = string
  default = "Managed secret"
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.name
  description             = var.description
  recovery_window_in_days = 30

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_value
}

output "arn" { value = aws_secretsmanager_secret.this.arn }
output "name" { value = aws_secretsmanager_secret.this.name }
