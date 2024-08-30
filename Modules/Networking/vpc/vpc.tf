
# Create VPC
resource "aws_vpc" "govtech_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "GovTech -VPC"
  }
}
