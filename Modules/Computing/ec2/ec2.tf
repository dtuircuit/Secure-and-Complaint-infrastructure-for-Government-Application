# EC2 Instances
resource "aws_instance" "app" {
  count           = length(var.private_ec2_subnet_cidrs)
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  subnet_id       = aws_subnet.private_ec2[count.index].id
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "GovTechAppInstance-${count.index + 1}"
  }
}
