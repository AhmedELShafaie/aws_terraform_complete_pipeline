terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  # cloud {
  #   organization = "my-learn-terraform-aws"

  #   workspaces {
  #     name = "gh-actions-demo"
  #   }
  # }

  #Add Backend
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "samir-toptal"
    workspaces {
      name = "samir-toptal-workspace"

    }
  }


}

provider "aws" {
  region = "us-west-2"
}

resource "random_pet" "sg" {}

resource "aws_key_pair" "toptal-access-key" {
  key_name   = "toptal_access_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl59hcXNOkns62o34FH1JkqRAUojia659PsOcj52Ofv debian@Ahmed-Laptop"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.toptal-access-key.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}

output "server-address" {
  value = "${aws_instance.web.public_dns}"
}

