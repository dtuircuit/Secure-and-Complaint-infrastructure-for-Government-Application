
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
