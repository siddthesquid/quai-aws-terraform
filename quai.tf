terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "quai-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
}

resource "aws_security_group" "quai-ssh-sg-udp" {
  name        = "quai-ssh-sg-udp"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [
      30303, 8546, 8547, 30304, 30305, 30306, 8578, 8580, 8582, 8579, 8581,
      8583, 30307, 30308, 30309, 30310, 30311, 30312, 30313, 30314, 30315, 8610,
      8642, 8674, 8612, 8644, 8676, 8614, 8646, 8678, 8611, 8643, 8675, 8613,
      8645, 8677, 8615, 8647, 8679
    ]

    content {
      from_port  = ingress.value
      to_port = ingress.value
      protocol = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "quai-ssh-sg-udp"
  }
}

resource "aws_security_group" "quai-ssh-sg-tcp" {
  name        = "quai-ssh-sg-tcp"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [
      22, 30303, 8546, 8547, 30304, 30305, 30306, 8578, 8580, 8582, 8579, 8581,
      8583, 30307, 30308, 30309, 30310, 30311, 30312, 30313, 30314, 30315, 8610,
      8642, 8674, 8612, 8644, 8676, 8614, 8646, 8678, 8611, 8643, 8675, 8613,
      8645, 8677, 8615, 8647, 8679
    ]

    content {
      from_port  = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "quai-ssh-sg-tcp"
  }
}

resource "aws_key_pair" "quai-ssh-key-pair" {
  key_name   = "quai-ssh-key-pair"
  public_key = file("./quai_id_rsa.pub")
}

resource "aws_spot_instance_request" "quai-ec2" {
  ami           = "ami-084f7416680ed532b"
  instance_type = "t3.xlarge"
  subnet_id     = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.quai-ssh-sg-tcp.id, aws_security_group.quai-ssh-sg-udp.id]
  key_name = aws_key_pair.quai-ssh-key-pair.key_name
  valid_until = "2022-03-24T00:00:00+00:00"
  root_block_device {
    delete_on_termination = false
    volume_size = 100
    volume_type = "gp2"
  }
}