###############################################################
#
# Create AWS Cribl
# Author : Danny Woo
# Date : 2023.04.17
#
###############################################################

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access
  secret_key = var.aws_secret
}

# create VPC
resource "aws_vpc" "cribl_vpc" {
  cidr_block = "10.8.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true
}

# create public subnet
resource "aws_subnet" "cribl_public_subnet" {
  vpc_id = aws_vpc.cribl_vpc.id
  cidr_block = "10.8.10.0/24"
  availability_zone = "ap-northeast-2a"
}

# create internet gateway
resource "aws_internet_gateway" "cribl_igw" {
  vpc_id = aws_vpc.cribl_vpc.id
}

# create route table for public subnet
resource "aws_route_table" "cribl_public_route_table" {
  vpc_id = aws_vpc.cribl_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cribl_igw.id
  }

  tags = {
    Name = "public"
  }
}

# Associate public subnet with the public route table
resource "aws_route_table_association" "cribl_public_subnet_association" {
  subnet_id = aws_subnet.cribl_public_subnet.id
  route_table_id = aws_route_table.cribl_public_route_table.id
}

# create security group for Cribl Stream
resource "aws_security_group" "cribl_sg" {
  name_prefix = "cribl-stream-sg"
  vpc_id = aws_vpc.cribl_vpc.id

  # Ingress rules

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# keypair
resource "aws_key_pair" "sample-key"{
  key_name = "sample-key"
  public_key = var.cribl_test_pem
}

# launch EC2 instance for Cribl Stream
resource "aws_instance" "cribl_instance" {
  ami = "ami-0676d41f079015f32"
  instance_type = "t3a.large"

  associate_public_ip_address = true

  subnet_id = aws_subnet.cribl_public_subnet.id
  vpc_security_group_ids = [aws_security_group.cribl_sg.id]
  key_name = aws_key_pair.sample-key.key_name

  user_data = <<-EOF
      #!/bin/bash
      curl -Lso - $(curl https://cdn.cribl.io/dl/latest-x64) | tar zxv
      mv ./cribl /opt/
      /opt/cribl/bin/cribl start
  EOF
 
  tags = {
    Name = "CriblStreamInstance"
  }
}
