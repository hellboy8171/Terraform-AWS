# public ip

output "ec2_public_ip" {
  description = "public_ip"
  value = aws_instance.web01.public_ip
}

# public dns

output "ec2_public_dns" {
  description = "public_dns"
  value = aws_instance.web01.public_dns
}