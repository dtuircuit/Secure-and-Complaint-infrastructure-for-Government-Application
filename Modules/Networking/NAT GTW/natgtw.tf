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
