variable "zone_name" { type = string }
variable "records" {
  type = map(object({
    ttl    = number
    type   = string
    values = list(string)
  }))
  default = {}
}

resource "aws_route53_zone" "this" {
  name = var.zone_name
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = aws_route53_zone.this.zone_id
  name    = each.key
  ttl     = each.value.ttl
  type    = each.value.type
  records = each.value.values
}

output "zone_id" { value = aws_route53_zone.this.zone_id }
output "name_servers" { value = aws_route53_zone.this.name_servers }
