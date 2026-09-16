bucket         = "emi-project-prod-tfstate"
key            = "platform/prod/terraform.tfstate"
dynamodb_table = "emi-project-prod-locks"
region         = "us-east-1"
encrypt        = true
