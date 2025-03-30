resource "aws_eip" "nat_eip" {
  count  = length(var.public_subnet_ids)
  domain = "vpc"

  tags = {
    Name = "${var.nat_gateway_name}-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_ids)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.nat_gateway_name}-${count.index}"
  }

  depends_on = [aws_eip.nat_eip]
}
