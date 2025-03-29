resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id_input

  tags = {
    Name = var.gateway_name
  }
}