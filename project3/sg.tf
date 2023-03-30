# Security groups

# App Instance Security Group
resource "aws_security_group" "AppInstanceSecurityGroup" {
  name        = "AppInstanceSecurityGroup"
  description = "Security Group allowing HTTP traffic for instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "All traffic from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kinzh-App-SG"
  }
}

# RDS Security Group
resource "aws_security_group" "RDSSecurityGroup" {
  name        = "RDSSecurityGroup"
  description = "Security Group allowing RDS instances to have internet traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kinzh-RDS-SG"
  }
}
# RDS Security Group
resource "aws_security_group" "EFSMountTargetSecurityGroup" {
  name        = "EFSMountTargetSecurityGroup"
  description = "Security Group allowing traffic between EFS Mount Targets and Amazon EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kinzh-EFS-SG"
  }
}