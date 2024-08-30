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

#CIDRS for EC2 private subnet
variable "private_ec2_subnet_cidrs" {
  description = "CIDR blocks for private subnets (EC2 instances)"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
