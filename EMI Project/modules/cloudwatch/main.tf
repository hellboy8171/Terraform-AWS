variable "log_group_name" { type = string }
variable "retention_in_days" {
  type    = number
  default = 30
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days

  tags = merge(var.tags, { Name = var.log_group_name })
}

output "log_group_arn" { value = aws_cloudwatch_log_group.this.arn }
