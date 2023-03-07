provider "aws" {
  region = "us-west-2"
}
resource "aws_s3_bucket" "first_bucket"{
  bucket = "vincentdepaul-first-bucket"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}
resource "aws_instance" "example" {
  ami = "ami-0ada3c5e01b15c321"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox http -f -p ${var.server_port} &
            EOF
  user_data_replace_on_change = true
  tags = {
    Name = "terraform-example"
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    protocol  = "tcp"
    to_port   = var.server_port
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_autoscaling_group" "example" {
  max_size = 0
  min_size = 0
}
output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP adress of the web server"
}
