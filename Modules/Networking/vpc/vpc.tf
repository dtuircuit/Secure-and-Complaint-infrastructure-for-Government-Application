# VPC
resource "aws_vpc" "govtech_vpc" {
  cidr_block = var.vpc_cidr
}
