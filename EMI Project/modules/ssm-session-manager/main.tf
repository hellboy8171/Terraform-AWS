variable "instance_ids" {
  type    = list(string)
  default = []
}
variable "document_name" {
  type    = string
  default = "AWS-StartInteractiveCommand"
}

resource "aws_ssm_document" "session_manager" {
  name          = "SSM-SessionManager-${var.document_name}"
  document_type = "Session"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Enable interactive command sessions via SSM"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = ""
      s3KeyPrefix                 = ""
      cloudWatchLogGroupName      = ""
      cloudWatchEncryptionEnabled = false
      kmsKeyId                    = ""
      runAsEnabled                = false
    }
  })
}

output "document_name" { value = aws_ssm_document.session_manager.name }
