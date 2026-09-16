variable "domain_name" { type = string }
variable "validation_method" {
  type    = string
  default = "DNS"
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = var.validation_method

  tags = merge(var.tags, { Name = var.domain_name })
}

output "arn" { value = aws_acm_certificate.this.arn }
output "domain_name" { value = aws_acm_certificate.this.domain_name }
