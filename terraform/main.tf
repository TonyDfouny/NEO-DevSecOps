provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "ghost" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu Server 22.04 LTS (Free Tier)
  instance_type = "t2.micro"             # Free Tier eligible

  user_data = <<-EOF
              #!/bin/bash
              curl -sL https://deb.nodesource.com/setup_18.x | bash -
              apt-get update
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

  vpc_security_group_ids = [aws_security_group.ghost_sg.id]

  key_name = var.key_name # You'll define this later if needed
}

resource "aws_security_group" "ghost_sg" {
  name        = "ghost-sg"
  description = "Allow HTTP and SSH"
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

data "aws_vpc" "default" {
  default = true
}

# Triggering deployment

