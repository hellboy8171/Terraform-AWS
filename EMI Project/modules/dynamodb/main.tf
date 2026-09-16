variable "name" { type = string }
variable "hash_key" { type = string }
variable "hash_key_type" {
  type    = string
  default = "S"
}
variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_dynamodb_table" "this" {
  name         = var.name
  hash_key     = var.hash_key
  billing_mode = var.billing_mode

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = merge(var.tags, { Name = var.name })
}

output "table_name" { value = aws_dynamodb_table.this.name }
output "arn" { value = aws_dynamodb_table.this.arn }
