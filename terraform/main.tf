provider "aws" {
  region = "eu-north-1"
}

# Fetch latest Ubuntu 22.04 LTS AMI in eu-north-1
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Get the default VPC in the region
data "aws_vpc" "default" {
  default = true
}

terraform {
  backend "s3" {
    bucket         = "neo-tony-devsecops-state"  # Same as the bucket you created
    key            = "ghost/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

# Security Group to allow HTTP and SSH
resource "aws_security_group" "ghost_sg" {
  name        = "ghost-sg"
  description = "Allow HTTP (80) and SSH (22) traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance running Ghost CMS
resource "aws_instance" "ghost" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ghost_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    curl -sL https://deb.nodesource.com/setup_18.x | bash -
    apt-get update -y
    apt-get install -y nodejs nginx mysql-server
    npm install ghost-cli -g

    adduser --disabled-password --gecos "" ghost
    mkdir -p /var/www/ghost
    chown ghost:ghost /var/www/ghost
    sudo -u ghost ghost install --dir /var/www/ghost --no-prompt --url=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) --db=sqlite3 --start
  EOF

  tags = {
    Name = "GhostInstance"
  }
}

