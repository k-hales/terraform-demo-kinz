terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create VPC; CIDR 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = "${var.default_tags.env}-VPC"
  }
}

# Public Subnets 10.0.0.0/24
resource "aws_subnet" "public" {
  count      = var.public_subnet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  # netnum = number to change based on subnet addition: 1st subnet 10.0.0.0/24. 10.0.1.0/24, 10.0.2.0/24
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-Public-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}
# Private Subnets 10.0.0.0/24
resource "aws_subnet" "private" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.public_subnet_count)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-Private-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}
# IGW
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id #attachement

  tags = {
    "Name" = "${var.default_tags.env}-IGW"
  }
}

# EIP
resource "aws_eip" "NAT_EIP" {
  vpc = true
}
# NGW 1
resource "aws_nat_gateway" "main_NAT" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id = aws_subnet.public.0.id
  tags = {
    "Name" = "${var.default_tags.env}-NGW"
  }
}
# NGW 2


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-Public-RT"
  }
}
# Public Routes - for route table
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}
# Public Route Table Association
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-Private-RT"
  }
}
# Private Routes - for route table
resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main_NAT.id
}
# Private Route Table Association
resource "aws_route_table_association" "private" {
  count = var.private_subnet_count
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
# Naming Elastic IP
resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "kinzh-eip"
  }
}
# S3 bucket creation
resource "aws_s3_bucket" "b" {
  bucket = "kinzh-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "kinzh-test" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
#DB mysql creation
resource "aws_db_instance" "kinzh-test" {
  allocated_storage    = 10
  db_name              = "kinzhdbtest"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "kinzh"
  password             = "dbpassword"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  identifier = "kinzh-db-test"

  # Naming DB instance
  tags = {
    Name = "kinzh-db-test"
  }
}