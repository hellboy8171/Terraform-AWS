variable "name" { type = string }
variable "subnet_id" { type = string }
variable "allocation_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_nat_gateway" "this" {
  allocation_id = var.allocation_id
  subnet_id     = var.subnet_id

  tags = merge(var.tags, { Name = "${var.name}-nat" })

  depends_on = [aws_eip.this]
}

resource "aws_eip" "this" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name}-nat-eip" })
}

output "nat_gateway_id" { value = aws_nat_gateway.this.id }
