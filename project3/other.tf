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
  default_tags {
    tags = var.default_tags
  }
}

# create VPC; CIDR 10.0.0.0/16
resource "aws_pc" "main" {
    cidr_block = var.vpc_cidr
    assign_generated_ipv6_cidr_block = true
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        "Name" = "${var.default_tags.env}-VPC"
    }
}

# public subnets 10.0.0.0/24
resource "aws_subnet" "public" {
    count = var.public_subnet_count
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
    map_public_ip_on_launch = true
    tags = {
      "Name" = "${var.default_tags.env}-PublicSubnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
    }
    availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

# private subnets
resource "aws_subnet" "private" {
    count = var.private_subnet_count
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.public_subnet_count)
    tags = {
      "Name" = "${var.default_tags.env}-PrivateSubnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
    }
    availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

# IGW
resource "aws_nat_gateway" "main_NAT" {
    vpc_id = aws_vpc.main.id
    tags = {
        "Name" = "${var.default_tags.env}-IGW"
    } 
}

# NGW
resource "aws_nat_gateway" "main_NAT" {
    count = 2
    allocation_id = aws_eip.NAT_EIP[count.index.id]
    subnet_id = aws_subnet.public[count.index].id
    tags = {
        "Name" = "${var.default_tags.env}-NGW-${count.index + 1}"
    }
}

# EIP
resource "aws_eip" "NAT_EIP" {
    count = 2
    vpc = true
    tags = {
        "Name" = "${var.default_tags.env}-EIP-${count.index + 1}"
    }
}

# public route table
resdata "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
        "Name" = "${var.default_tags.env}-PublicRT"
    }
}
# Public route
resource "aws_route" "public" {
    rouroute_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_route_table.private.id
}
# Public Route Table Association
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
# Private Route Table
resource "aws_route_table" "private-1" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-Private-RT-1"
  }
}

# Private Route Table 2
resource "aws_route_table" "private-2" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-Private-RT-2"
  }
}

# Private Route 1 - for route table
resource "aws_route" "private-1" {
  route_table_id = aws_route_table.private-1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main_NAT[0].id
}

# Private Route 2 - for route table
resource "aws_route" "private-2" {
  route_table_id = aws_route_table.private-2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main_NAT[1].id
}

# Private Route Table Association
resource "aws_route_table_association" "private-1" {
  count = var.private_subnet_count
  subnet_id = element(aws_subnet.private[0].id, count.index)
  route_table_id = aws_route_table.private-1.id
}

# Private Route Table Association 2
resource "aws_route_table_association" "private-2" {
  count = var.private_subnet_count
  subnet_id = element(aws_subnet.private[1].id, count.index)
  route_table_id = aws_route_table.private-2.id
}