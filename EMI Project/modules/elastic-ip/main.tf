variable "name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name}-eip" })
}

output "eip_id" { value = aws_eip.this.id }
output "public_ip" { value = aws_eip.this.public_ip }
