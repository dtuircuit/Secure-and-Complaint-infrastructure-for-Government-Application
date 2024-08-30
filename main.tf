provider "aws" {
  region = "us-east-2"
}

# Create VPC
resource "aws_vpc" "govtech_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "GovTech -VPC"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count      = 3
  vpc_id     = aws_vpc.govtech_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)

  availability_zone = element(["us-east-2a", "us-east-2b", "us-east-2c"], count.index)

  tags = {
    Name = "Public-Subnet-${count.index}"
  }
}

# Create Private Subnets for EC2 Instances
resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.govtech_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "private-app-subnet-1"
  }
}

resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.govtech_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "private-app-subnet-2"
  }
}

resource "aws_subnet" "private_app_3" {
  vpc_id            = aws_vpc.govtech_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-2c"
  tags = {
    Name = "private-app-subnet-3"
  }
}

# Create Private Database Subnets
resource "aws_subnet" "private_db" {
  count      = 3
  vpc_id     = aws_vpc.govtech_vpc.id
  cidr_block = element(var.private_db_subnet_cidrs, count.index)

  availability_zone = element(["us-east-2a", "us-east-2b", "us-east-2c"], count.index)

  tags = {
    Name = "Private-DB-Subnet-${count.index}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.govtech_vpc.id

  tags = {
    Name = "GovTech-IGW"
  }
}

# Create Route Table for Public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.govtech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 3
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Public Subnet NACL
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.govtech_vpc.id
  subnet_ids = aws_subnet.public[*].id

  # Inbound Rules
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = element(var.private_app_subnet_cidrs, 0) # Replace with actual CIDR blocks if needed
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound Rules
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Public-Subnet-NACL"
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.govtech_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [element(var.private_app_subnet_cidrs, 0)] # Replace with actual CIDR blocks if needed
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [element(var.private_app_subnet_cidrs, 0)] # Replace with actual CIDR blocks if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-SG"
  }
}

# Security Group for RDS Database
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.govtech_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = var.ec2_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "EC2-Role"
  }
}

# IAM Policy for EC2 Role
resource "aws_iam_policy" "ec2_policy" {
  name        = var.ec2_policy_name
  description = "IAM policy for EC2 instance to access other AWS services"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "logs:*",
          "cloudwatch:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# IAM Role for API Gateway
resource "aws_iam_role" "api_gateway_role" {
  name = var.api_gateway_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "API_Gateway_Role"
  }
}

# IAM Policy for API Gateway Role
resource "aws_iam_policy" "api_gateway_policy" {
  name        = var.api_gateway_policy_name
  description = "IAM policy for API Gateway"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "cloudwatch:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to API Gateway Role
resource "aws_iam_role_policy_attachment" "api_gateway_role_policy" {
  policy_arn = aws_iam_policy.api_gateway_policy.arn
  role       = aws_iam_role.api_gateway_role.name
}
