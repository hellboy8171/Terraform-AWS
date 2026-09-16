bucket         = "emi-project-staging-tfstate"
key            = "platform/staging/terraform.tfstate"
dynamodb_table = "emi-project-staging-locks"
region         = "us-east-1"
encrypt        = true
