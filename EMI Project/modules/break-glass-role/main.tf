variable "name" { type = string }
variable "admins" {
  type    = list(string)
  default = []
}

resource "aws_iam_group" "breakglass" {
  name = var.name
}

resource "aws_iam_group_membership" "breakglass" {
  name  = "${var.name}-membership"
  group = aws_iam_group.breakglass.name
  users = var.admins
}

resource "aws_iam_group_policy" "breakglass_admin" {
  name  = "breakglass-admin"
  group = aws_iam_group.breakglass.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

output "group_name" { value = aws_iam_group.breakglass.name }
