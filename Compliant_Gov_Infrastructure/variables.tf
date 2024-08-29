#AWS region
variable "aws_region" {
    description = "The AWS region to deploy resources in"
    default = "us-east-2"
}

#AWS Access ID and Secret Access ID Key
variable "aws_access_key_id" {
    description = "AWS Access Key ID"
    type = string
}

variable "aws_secret_access_key" {
    description = "AWS Secret Access Key"
    type = string
}

#VPC ID (for referencing existing VPCs)
variable "vpc_id"{
    description ="The ID of he VPC to asscociate with subnets and other resources"
    type = string
}

#VPC CIDR Block
variable "vpc_cidr_block" {
    description = "The CIDR block for the VPC"
    default = "10.0.0.0/16"
}

#Public Subnet CIDR Blocks
variable "public_subnet_cidrs" {
    description = "The CIDR blocks for the public subnets"
    type = list(string)
    default = [
        "10.0.0.0/24",
        "10.0.1.0/24",
        "10.0.2.0/24"
    ]
}
# Private Subnet CIDR Blocks (Apps Instances)
variable "private_app_subnet_cidrs" {
    description = "The CIDR blocks for the private subnet for EC2 instances"
    type = list(string)
    default = [
        "10.0.3.0/24",
        "10.0.4.0/24",
        "10.0.5.0/24"
    ]
}

#Private Subnet CIDR Blocks (Database)
variable "private_db_subnet_cidrs" {
    description = "The CIDR blocks for the private subnets for databases"
    type = list(string)
    default = [
        "10.0.6.0/24",
        "10.0.7.0/24",
        "10.0.8.0/24"
    ]
}
#EC2 Instance type
variable "ec2_instance_type" {
    description = "The type of EC2 instances to launch"
    default ="t2.micro"
}

#AMI ID for ECC2 Instances
variable "ami_id" {
    description = "THE AMI ID for the EC2 instances"
    default = "ami-0490fddec0cbeb88b"
}

#IAM Role names
variable "ec2_role_name" {
    description = "The name of the IAM role for the EC2 instances"
    default = "ec2_role"
}

variable "api_gateway_role_name" {
    description = "The name of the IAM role for the API Gateway"
    default = "api_gateway_role"
}

#Security Group
variable "ec2_secuirty_group_name" {
    description = "The name of te security group forthe EC2 instances"
    default = "EC2-SG"
}

variable "rds_security_group_name" {
    description = "The name of the security group fo the RDS database"
    default = "RDS-SG"
}

#IAM Policies
variable "ec2_policy_name" {
description = "The name of the IAM policy for the EC2 instances"
default = "ec2_policy"

}

variable "api_gateway_policy_name" {
    description = "The name of the IAM policy for the API Gateway"
    default = "api_gateway_policy"
}

#Tags 
variable "tags" {
    description = "Tags to apply to all resources"
    type = map(string)
    default = {
        Enviroment = "Dev"
        Project = "GovTech"
    }
}