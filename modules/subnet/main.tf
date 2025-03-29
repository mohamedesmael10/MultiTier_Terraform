resource "aws_subnet" "subnets" {
  for_each = var.subnet_configs

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.assign_public_ip

  tags = {
      Name = each.key
  }
}

locals {
  subnet_ids = { for key, value in aws_subnet.subnets : key => value.id }
}