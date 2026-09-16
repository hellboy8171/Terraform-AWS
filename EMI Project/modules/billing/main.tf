variable "name" { type = string }
variable "budget_limit_amount" { type = number }
variable "currency" {
  type    = string
  default = "USD"
}
variable "time_unit" {
  type    = string
  default = "MONTHLY"
}
variable "threshold" {
  type    = number
  default = 80
}

resource "aws_budgets_budget" "this" {
  name         = var.name
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit_amount)
  limit_unit   = var.currency
  time_unit    = var.time_unit

  cost_types {
    include_credit             = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_amortized              = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["ops@example.com"]
  }
}

output "budget_name" { value = aws_budgets_budget.this.name }
