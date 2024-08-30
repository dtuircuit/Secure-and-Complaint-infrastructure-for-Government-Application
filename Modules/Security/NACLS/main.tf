# Create Public Subnet NACL
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.govtech_vpc.vpc_id
  subnet_ids = aws_subnet.public[*].vpc_id

  dynamic "ingress" {
    for_each = [for rule in public_subnet_nacl_rules : rule if !rule.egress]
    content {
      rule_no    = ingress.value["rule_no"]
      action     = ingress.vale["action"]
      protocol   = ingress.value["protocol"]
      cidr_block = ingress.value["cidr_block"]
      from_port  = ingress.valu["from_port"]
      to_port    = ingress.value["to_port"]
    }
  }

  dynamic "egress" {
    for_each = [for rule in private_subnet_nacl_rules : rule if !rule.egress]
    content {
      rule_no    = egress.value["rule_no"]
      action     = egress.value["action"]
      protocol   = egress.value["protocol"]
      cidr_block = egress.value["cidr_block"]
      from_port  = egress.value["from_port"]
      to_port    = egress.value["to_port"]
    }
  }

  tags = {
    Name = "Private-Subnet-NACL"
  }
}
