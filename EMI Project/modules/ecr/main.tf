variable "name" { type = string }
variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}
variable "scan_on_push" {
  type    = bool
  default = true
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(var.tags, { Name = var.name })
}

output "repository_url" { value = aws_ecr_repository.this.repository_url }
output "arn" { value = aws_ecr_repository.this.arn }
