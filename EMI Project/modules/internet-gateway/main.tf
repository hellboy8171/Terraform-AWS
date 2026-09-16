variable "name" { type = string }
variable "vpc_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-igw" })
}

output "internet_gateway_id" { value = aws_internet_gateway.this.id }
