# RDS Database
resource "aws_db_instance" "db" {
  count                  = length(var.private_db_subnet_cidrs)
  allocated_storage      = var.db_allocated_storage
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true

  tags = {
    Name = "GovTechDBInstance-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "govtech-db-subnet-group"
  subnet_ids = aws_subnet.private
}
