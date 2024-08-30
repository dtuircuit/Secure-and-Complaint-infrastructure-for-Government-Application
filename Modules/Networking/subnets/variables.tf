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
