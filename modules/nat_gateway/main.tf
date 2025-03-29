resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = var.nat_gateway_name
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_id_input

  tags = {
    Name = var.nat_gateway_name
  }

  depends_on = [aws_eip.nat_eip]
}