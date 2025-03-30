resource "aws_route_table" "public_route" {
  vpc_id = var.vpc_id_input

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = var.internet_gateway_id_input
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table" "private_route" {
  count  = length(var.private_subnet_ids)
  vpc_id = var.vpc_id_input

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[count.index]
  }

  tags = {
    Name = "${var.route_table_name}-${count.index}"
  }
}

resource "aws_route_table_association" "private_association" {
  for_each = { for idx, subnet in var.private_subnet_ids : idx => subnet }
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route[each.key].id
  depends_on     = [aws_route_table.private_route]
}