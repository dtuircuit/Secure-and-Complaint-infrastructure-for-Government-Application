provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "govtech_vpc" {
  cidr_block = var.vpc_cidr
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.govtech_vpc.id
}

# Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.govtech_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_ec2" {
  count             = length(var.private_ec2_subnet_cidrs)
  vpc_id            = aws_vpc.govtech_vpc.id
  cidr_block        = element(var.private_ec2_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.govtech_vpc.id
  cidr_block        = element(var.private_db_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

# NAT Gateways and EIPs
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

# Route Tables and Associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.govtech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_ec2_subnet_cidrs)
  vpc_id = aws_vpc.govtech_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
}

resource "aws_route_table_association" "private_ec2" {
  count          = length(var.private_ec2_subnet_cidrs)
  subnet_id      = aws_subnet.private_ec2[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count          = length(var.private_db_subnet_cidrs)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Groups
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.govtech_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.govtech_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "app" {
  count           = length(var.private_ec2_subnet_cidrs)
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  subnet_id       = aws_subnet.private_ec2[count.index].id
  security_groups = [aws_security_group.ec2_sg.name]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "GovTechAppInstance-${count.index + 1}"
  }
}

# RDS Database
resource "aws_db_instance" "db" {
  count                   = length(var.private_db_subnet_cidrs)
  allocated_storage       = var.db_allocated_storage
  engine                  = "mysql"
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  backup_retention_period = var.db_backup_retention_period
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "govtech-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "GovTechDBSubnetGroup"
  }
}

# IAM Role
resource "aws_iam_role" "ec2_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy
resource "aws_iam_policy" "ec2_policy" {
  name        = var.iam_policy_name
  description = "Policy for EC2 to access AWS services"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "s3:GetObject",
          "s3:PutObject",
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "govtech-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
