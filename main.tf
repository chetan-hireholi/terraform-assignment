# Author: Chetan Hireholi

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
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}


# AWS vpc
resource "aws_vpc" "hiver_vpc" {
  cidr_block = "172.16.0.0/16"
}


# AWS private subnet
resource "aws_subnet" "hiver_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1"
}


# AWS network interface
resource "aws_network_interface" "hiver_network_interface" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]
}


# AWS security group
resource "aws_security_group" "prod-web-servers-sg" {
  name        = "prod-web-servers-sg"
  description = "Security group for production web servers"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "For port 443"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    },
    {
      description      = "For port 80"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.main.cidr_block]
      ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "prod-web-servers-sg"
  }
}

# AWS EC2 key pairs
resource "aws_key_pair" "hiver_terraform" {
  key_name   = "hiver_terraform"
  public_key = file("hiver_terraform.pub")
}


# Launch EC2 instances
resource "aws_instance" "hiver_ec2" {
  count         = var.instance_count
  ami           = lookup(var.ami,var.aws_region)
  instance_type = var.instance_type
  key_name      = aws_key_pair.hiver_terraform.key_name

  tags = {
    Name  = element(var.instance_tags, count.index)
  }
}


# AWS NLB
resource "aws_lb" "hiver_nlb" {
  name               = "hiver_nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public.*.id
  target_id          = aws_instance.hiver_ec2.id
  enable_deletion_protection = true
  tags = {
    Environment = "development"
  }
}