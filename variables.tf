# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

# Subnet Configuration
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_ec2_subnet_cidrs" {
  description = "CIDR blocks for private subnets (EC2 instances)"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private subnets (RDS instances)"
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
}

# RDS Configuration
variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "password"
}

variable "db_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# API Gateway and ALB Configuration
variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "govtech-api"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "govtech-alb"
}

variable "alb_internal" {
  description = "Whether the ALB is internal or external"
  type        = bool
  default     = false
}

# IAM Role Configuration
variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "govtech-ec2-role"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "govtech-ec2-policy"
}
