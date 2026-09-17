resource "aws_instance" "web01" {
  ami           = "ami-0742b4e673072066f"
  instance_type = "t3.micro"
  user_data     = file("${path.module}/app1-install.sh")
  tags = {
    "Name" = "EC2 Demo"
  }

}