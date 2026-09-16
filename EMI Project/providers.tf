provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "EMI-Project"
      Owner       = var.owner
      CostCenter  = var.cost_center
    }
  }
}

variable "aws_region" {
  description = "Default AWS region for the environment."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Primary owner or team responsible for the stack."
  type        = string
  default     = "platform-engineering"
}

variable "cost_center" {
  description = "Funding or cost center tag."
  type        = string
  default     = "engineering"
}
