#VPC ID (for referencing existing VPCs)
variable "vpc_id" {
  description = "The ID of he VPC to asscociate with subnets and other resources"
  type        = string
}

#VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
